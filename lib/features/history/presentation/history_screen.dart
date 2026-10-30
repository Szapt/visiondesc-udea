import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accessibility/widgets/accessible_button.dart';
import '../../../core/accessibility/widgets/audio_controls.dart';
import '../../../core/accessibility/widgets/headings.dart';
import '../../../core/accessibility/widgets/info_banner.dart';
import '../../../core/accessibility/widgets/status_region.dart';
import '../../../core/audio/description_player.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/dimensions.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/entities/history_entry.dart';
import 'history_providers.dart';

/// Historial (UI.md §4.9): las consultas guardadas en el backend, agrupadas
/// por día y con búsqueda. Cada día es un encabezado para saltar entre
/// grupos, y al elegir una consulta se escucha su descripción.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Timer? _debounce;

  AudioPlayer? _audioPlayer;
  HistoryEntry? _playing;
  int? _loadingAudioId;
  bool _isAudioPaused = false;
  String? _audioMessage;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  /// Filtra mientras se escribe, pero anuncia el número de resultados solo
  /// cuando el estudiante deja de escribir (no con cada letra).
  void _onSearchChanged(String value) {
    setState(() => _query = value.trim().toLowerCase());
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final entries = ref.read(historyEntriesProvider).value ?? const [];
      final l10n = AppLocalizations.of(context);
      ref.read(announcerProvider).announce(l10n.historyResultsCount(_filter(entries).length));
    });
  }

  List<HistoryEntry> _filter(List<HistoryEntry> entries) => _query.isEmpty
      ? entries
      : entries.where((e) => e.description.toLowerCase().contains(_query)).toList();

  Future<void> _play(HistoryEntry entry) async {
    if (_loadingAudioId != null) return;
    final l10n = AppLocalizations.of(context);
    final announcer = ref.read(announcerProvider);
    setState(() {
      _loadingAudioId = entry.id;
      _audioMessage = l10n.historyPreparingAudio;
    });
    announcer.announce(l10n.historyPreparingAudio);
    try {
      final audio = await ref.read(historyRepositoryProvider).fetchAudio(entry.id);
      final player = _audioPlayer ??= createDescriptionPlayer(onComplete: _onAudioComplete);
      await player.stop();
      await player.playDescription(audio);
      if (!mounted) return;
      setState(() {
        _playing = entry;
        _isAudioPaused = false;
        _audioMessage = l10n.historyPlaying(entry.title);
      });
      announcer.announce(l10n.historyPlaying(entry.title));
    } catch (error) {
      debugPrint('No fue posible reproducir el historial: $error');
      if (!mounted) return;
      setState(() => _audioMessage = l10n.historyAudioError);
      announcer.announce(l10n.historyAudioError);
    } finally {
      if (mounted) setState(() => _loadingAudioId = null);
    }
  }

  Future<void> _toggleAudio() async {
    final player = _audioPlayer;
    if (player == null) return;
    if (_isAudioPaused) {
      await player.resume();
      if (mounted) setState(() => _isAudioPaused = false);
    } else {
      await player.pause();
      if (mounted) setState(() => _isAudioPaused = true);
    }
  }

  Future<void> _stopAudio() async {
    final player = _audioPlayer;
    if (player == null) return;
    final stopped = AppLocalizations.of(context).historyStopped;
    await player.stop();
    if (mounted) setState(() => _isAudioPaused = true);
    ref.read(announcerProvider).announce(stopped);
  }

  void _onAudioComplete() {
    if (mounted) setState(() => _isAudioPaused = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entriesAsync = ref.watch(historyEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: ScreenTitle(l10n.historyTitle)),
      body: ResponsiveBody(
        children: [
          if (_audioMessage != null) ...[
            StatusRegion(message: _audioMessage!, large: true),
            const SizedBox(height: 8),
          ],
          if (_playing != null) ...[
            ResponsiveAudioControls(
              isPaused: _isAudioPaused,
              onToggle: _toggleAudio,
              onStop: _stopAudio,
            ),
            const SizedBox(height: Dimensions.pagePadding),
          ],
          ...entriesAsync.when(
            loading: () => [StatusRegion(message: l10n.historyLoading)],
            error: (error, _) => [
              InfoBanner(
                type: InfoBannerType.error,
                message: l10n.historyLoadError,
                actions: [
                  AccessibleButton(
                    label: l10n.historyRetry,
                    icon: Icons.refresh,
                    variant: AccessibleButtonVariant.secondary,
                    onPressed: () => ref.invalidate(historyEntriesProvider),
                  ),
                ],
              ),
            ],
            data: (entries) => entries.isEmpty
                ? [InfoBanner(type: InfoBannerType.info, message: l10n.historyEmpty)]
                : _buildList(context, l10n, _filter(entries)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildList(
    BuildContext context,
    AppLocalizations l10n,
    List<HistoryEntry> entries,
  ) {
    final localizations = MaterialLocalizations.of(context);
    final byDay = <DateTime, List<HistoryEntry>>{};
    for (final entry in entries) {
      final d = entry.createdAt;
      byDay.putIfAbsent(DateTime(d.year, d.month, d.day), () => []).add(entry);
    }

    return [
      TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: l10n.historySearch,
          prefixIcon: const Icon(Icons.search),
        ),
      ),
      const SizedBox(height: Dimensions.spacingBetweenTargets),
      StatusRegion(message: l10n.historyResultsCount(entries.length)),
      // Las entradas llegan ordenadas de la más reciente a la más antigua, y
      // el mapa conserva ese orden.
      for (final MapEntry(key: day, value: dayEntries) in byDay.entries) ...[
        SectionHeader(
          localizations.formatFullDate(day),
          semanticLabel: l10n.historyGroupSemantics(
            localizations.formatFullDate(day),
            dayEntries.length,
          ),
        ),
        for (final entry in dayEntries) ...[
          AccessibleButton(
            label: entry.title,
            semanticLabel: l10n.historyItemSemantics(
              entry.title,
              localizations.formatTimeOfDay(TimeOfDay.fromDateTime(entry.createdAt)),
            ),
            hint: l10n.historyItemHint,
            icon: _playing?.id == entry.id ? Icons.volume_up : Icons.play_circle_outline,
            variant: AccessibleButtonVariant.secondary,
            expand: true,
            onPressed: _loadingAudioId == null ? () => _play(entry) : null,
          ),
          const SizedBox(height: 8),
        ],
      ],
    ];
  }
}

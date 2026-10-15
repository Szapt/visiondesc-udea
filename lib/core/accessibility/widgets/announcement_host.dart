import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../announcer.dart';

/// Entrega los anuncios de [QueuedAnnouncer] a la plataforma.
///
/// - Si la plataforma admite anuncios (iOS), usa
///   [SemanticsService.sendAnnouncement].
/// - Si no (Android marcó como obsoletos los eventos de anuncio), publica el
///   mensaje en un nodo semántico con `liveRegion`, que TalkBack lee al cambiar.
///
/// El nodo vivo mide 1×1 px, es invisible, va al final del orden de foco y se
/// vacía a los pocos segundos para que el estudiante no se lo encuentre al
/// recorrer la pantalla.
class AnnouncementHost extends StatefulWidget {
  const AnnouncementHost({
    super.key,
    required this.announcer,
    required this.child,
    this.clearAfter = const Duration(seconds: 6),
  });

  final QueuedAnnouncer announcer;
  final Widget child;
  final Duration clearAfter;

  @override
  State<AnnouncementHost> createState() => _AnnouncementHostState();
}

class _AnnouncementHostState extends State<AnnouncementHost> {
  String _liveText = '';
  Timer? _clearTimer;

  @override
  void initState() {
    super.initState();
    widget.announcer.addListener(_onAnnouncement);
  }

  @override
  void didUpdateWidget(covariant AnnouncementHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.announcer != widget.announcer) {
      oldWidget.announcer.removeListener(_onAnnouncement);
      widget.announcer.addListener(_onAnnouncement);
    }
  }

  @override
  void dispose() {
    widget.announcer.removeListener(_onAnnouncement);
    _clearTimer?.cancel();
    super.dispose();
  }

  void _onAnnouncement() {
    final announcement = widget.announcer.current;
    if (announcement == null || !mounted) return;

    if (MediaQuery.maybeSupportsAnnounceOf(context) ?? false) {
      unawaited(
        SemanticsService.sendAnnouncement(
          View.of(context),
          announcement.message,
          Directionality.of(context),
        ),
      );
      return;
    }

    // Un espacio duro alterno hace que un texto repetido cuente como cambio
    // para la región viva; los lectores no lo pronuncian.
    final text = announcement.id.isOdd ? '${announcement.message} ' : announcement.message;
    setState(() => _liveText = text);
    _clearTimer?.cancel();
    _clearTimer = Timer(widget.clearAfter, () {
      if (mounted) setState(() => _liveText = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        if (_liveText.isNotEmpty)
          Positioned(
            left: 0,
            top: 0,
            width: 1,
            height: 1,
            child: Semantics(
              key: const ValueKey('announcement-live-region'),
              container: true,
              liveRegion: true,
              sortKey: const OrdinalSortKey(double.maxFinite),
              label: _liveText,
              child: const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }
}

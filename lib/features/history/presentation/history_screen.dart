import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/accessibility/widgets/accessible_button.dart';
import '../../../core/accessibility/widgets/headings.dart';
import '../../../core/accessibility/widgets/status_region.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/dimensions.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Elemento de ejemplo del historial (los reales vendrán de la base de datos).
class _HistoryItem {
  const _HistoryItem(this.title, this.subject, this.date);

  final String title;
  final String subject;
  final String date;
}

const _sampleItems = [
  _HistoryItem('Diagrama de clases: Sistema de pedidos', 'Ingeniería de software', 'hoy'),
  _HistoryItem('Diagrama de secuencia: Inicio de sesión', 'Ingeniería de software', 'ayer'),
  _HistoryItem('Diagrama entidad-relación: Biblioteca', 'Bases de datos', '13 de octubre'),
  _HistoryItem('Tabla: Formas normales', 'Bases de datos', '13 de octubre'),
  _HistoryItem('Diagrama de red: Laboratorio de redes', 'Redes', '10 de octubre'),
];

/// Historial (UI.md §4.9) con datos de ejemplo: búsqueda y agrupación por
/// materia. Cada materia es un encabezado para saltar entre grupos.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Filtra mientras se escribe, pero anuncia el número de resultados solo
  /// cuando el estudiante deja de escribir (no con cada letra).
  void _onSearchChanged(String value) {
    setState(() => _query = value.trim().toLowerCase());
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ref.read(announcerProvider).announce(l10n.historyResultsCount(_filtered.length));
    });
  }

  List<_HistoryItem> get _filtered => _query.isEmpty
      ? _sampleItems
      : _sampleItems
          .where(
            (i) => i.title.toLowerCase().contains(_query) || i.subject.toLowerCase().contains(_query),
          )
          .toList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = _filtered;
    final bySubject = <String, List<_HistoryItem>>{};
    for (final item in items) {
      bySubject.putIfAbsent(item.subject, () => []).add(item);
    }
    final subjects = bySubject.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: ScreenTitle(l10n.historyTitle)),
      body: ResponsiveBody(
        children: [
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
          StatusRegion(message: l10n.historyResultsCount(items.length)),
          for (final subject in subjects) ...[
            SectionHeader(
              subject,
              semanticLabel: l10n.historyGroupSemantics(subject, bySubject[subject]!.length),
            ),
            for (final item in bySubject[subject]!) ...[
              AccessibleButton(
                label: item.title,
                semanticLabel: l10n.historyItemSemantics(item.title, item.subject, item.date),
                icon: Icons.description_outlined,
                variant: AccessibleButtonVariant.secondary,
                expand: true,
                onPressed: () => context.push(AppRoutes.result),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

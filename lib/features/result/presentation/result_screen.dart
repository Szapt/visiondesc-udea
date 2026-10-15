import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/accessibility/haptic_service.dart';
import '../../../core/accessibility/widgets/accessible_button.dart';
import '../../../core/accessibility/widgets/adjustable_value.dart';
import '../../../core/accessibility/widgets/headings.dart';
import '../../../core/accessibility/widgets/info_banner.dart';
import '../../../core/accessibility/widgets/status_region.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/dimensions.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/domain/entities/app_settings.dart';
import '../../settings/presentation/settings_controller.dart';
import 'sample_result.dart';

/// Resultado (UI.md §4.6) con datos de ejemplo.
///
/// La barra de lectura está arriba para que el estudiante llegue a ella sin
/// recorrer todo el contenido. "Leer sección" hace que el lector de pantalla
/// lea la sección actual; la voz propia de la app (TTS) llegará después.
class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  int _current = 0;
  final _sectionKeys = List.generate(6, (_) => GlobalKey());

  List<(String title, String text)> _sections(AppLocalizations l10n) => [
    (l10n.resultSummary, SampleResult.resumen),
    (
      l10n.resultDetailed,
      SampleResult.regiones.map((r) => '${r.$1}: ${r.$2}').join(' '),
    ),
    (
      l10n.resultStructure,
      l10n.resultStructureCount(SampleResult.nodos, SampleResult.relaciones),
    ),
    (l10n.resultDetectedText, SampleResult.textoDetectado.join('. ')),
    (
      l10n.resultCode(SampleResult.lenguajeCodigo),
      [
        for (final (i, line) in SampleResult.codigo.indexed) l10n.resultCodeLine(i + 1, line.trim()),
      ].join(' '),
    ),
    (l10n.resultKeyConcepts, SampleResult.conceptosClave.join(', ')),
  ];

  void _goTo(int index) {
    final l10n = AppLocalizations.of(context);
    final sections = _sections(l10n);
    if (index < 0 || index >= sections.length) {
      unawaited(ref.read(hapticServiceProvider).play(HapticPattern.borde));
      ref
          .read(announcerProvider)
          .announce(index < 0 ? l10n.resultFirstSection : l10n.resultLastSection);
      return;
    }
    setState(() => _current = index);
    ref.read(announcerProvider).announce(sections[index].$1);
    final target = _sectionKeys[index].currentContext;
    if (target != null) {
      unawaited(
        Scrollable.ensureVisible(
          target,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 250),
        ),
      );
    }
  }

  void _readCurrent() {
    final (title, text) = _sections(AppLocalizations.of(context))[_current];
    ref.read(announcerProvider).announce('$title. $text');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = _sections(l10n);
    final rate = ref.watch(settingsControllerProvider.select((s) => s.speechRate));
    final settings = ref.read(settingsControllerProvider.notifier);
    String rateText(double r) => l10n.resultSpeedValue(r.toStringAsFixed(1));

    Widget section(int index, List<Widget> children) => _SectionFrame(
      key: _sectionKeys[index],
      highlighted: index == _current,
      children: [SectionHeader(sections[index].$1, padding: EdgeInsets.zero), ...children],
    );

    final bodyStyle = Theme.of(context).textTheme.bodyLarge;

    return Scaffold(
      appBar: AppBar(title: ScreenTitle(l10n.resultTitle)),
      body: ResponsiveBody(
        children: [
          // --- Barra de lectura ---
          SectionHeader(l10n.resultReadingHeader, padding: const EdgeInsets.only(bottom: 8)),
          ResponsiveGrid(
            columns: 3,
            children: [
              AccessibleButton(
                label: l10n.resultPreviousSection,
                icon: Icons.skip_previous,
                variant: AccessibleButtonVariant.secondary,
                expand: true,
                onPressed: () => _goTo(_current - 1),
              ),
              AccessibleButton(
                label: l10n.resultReadSection,
                hint: l10n.resultReadSectionHint,
                icon: Icons.record_voice_over_outlined,
                expand: true,
                onPressed: _readCurrent,
              ),
              AccessibleButton(
                label: l10n.resultNextSection,
                icon: Icons.skip_next,
                variant: AccessibleButtonVariant.secondary,
                expand: true,
                onPressed: () => _goTo(_current + 1),
              ),
            ],
          ),
          AdjustableValue(
            label: l10n.resultSpeed,
            valueText: rateText(rate),
            increasedValueText: rateText(rate + 0.1),
            decreasedValueText: rateText(rate - 0.1),
            onIncrease: rate < AppSettings.maxSpeechRate - 0.05
                ? () => settings.update((s) => s.copyWith(speechRate: _round(rate + 0.1)))
                : null,
            onDecrease: rate > AppSettings.minSpeechRate + 0.05
                ? () => settings.update((s) => s.copyWith(speechRate: _round(rate - 0.1)))
                : null,
          ),
          const SizedBox(height: 8),
          StatusRegion(message: l10n.resultCurrentSection(sections[_current].$1)),
          const SizedBox(height: Dimensions.pagePadding),

          const InfoBanner(type: InfoBannerType.warning, message: SampleResult.advertencia),
          const SizedBox(height: Dimensions.spacingBetweenTargets),

          // --- Contenido ---
          section(0, [Text(SampleResult.resumen, style: bodyStyle)]),
          section(1, [
            for (final (region, text) in SampleResult.regiones)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '$region: ', style: const TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: text),
                    ],
                  ),
                  style: bodyStyle,
                ),
              ),
          ]),
          section(2, [
            Text(sections[2].$2, style: bodyStyle),
            const SizedBox(height: Dimensions.spacingBetweenTargets),
            AccessibleButton(
              label: l10n.resultExploreStructure,
              icon: Icons.account_tree_outlined,
              variant: AccessibleButtonVariant.secondary,
              onPressed: () => context.push(AppRoutes.structure),
            ),
          ]),
          section(3, [
            for (final text in SampleResult.textoDetectado) Text(text, style: bodyStyle),
          ]),
          section(4, [_CodeBlock(lines: SampleResult.codigo, lineLabel: l10n.resultCodeLine)]),
          section(5, [Text(SampleResult.conceptosClave.join(', '), style: bodyStyle)]),

          Text(l10n.resultAiNotice, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: Dimensions.pagePadding),

          // --- Acciones ---
          ResponsiveGrid(
            children: [
              AccessibleButton(
                label: l10n.resultAsk,
                semanticLabel: l10n.resultAskSemantics,
                icon: Icons.question_answer_outlined,
                expand: true,
                onPressed: () => context.push(AppRoutes.chat),
              ),
              AccessibleButton(
                label: l10n.resultSave,
                icon: Icons.bookmark_add_outlined,
                variant: AccessibleButtonVariant.secondary,
                expand: true,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  static double _round(double v) => (v * 10).round() / 10;
}

/// Marco de una sección; la sección que se está leyendo se resalta con un
/// borde (además del texto "Sección actual", para no depender del color).
class _SectionFrame extends StatelessWidget {
  const _SectionFrame({super.key, required this.highlighted, required this.children});

  final bool highlighted;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.spacingBetweenTargets),
      padding: const EdgeInsets.all(Dimensions.pagePadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
        border: Border.all(
          color: highlighted ? tokens.focus : Colors.transparent,
          width: Dimensions.focusRingWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [...children.take(1), const SizedBox(height: 8), ...children.skip(1)],
      ),
    );
  }
}

/// Código literal en pantalla, una línea por nodo semántico ("Línea 2: …")
/// para poder recorrerlo con el lector. Se desplaza en horizontal en lugar
/// de cortar las líneas largas.
class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.lines, required this.lineLabel});

  final List<String> lines;
  final String Function(int number, String code) lineLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = AppColors.of(context);
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontFamily: 'monospace',
      fontSize: 17,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
        border: Border.all(color: tokens.outline),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, line) in lines.indexed)
              Semantics(
                label: lineLabel(i + 1, line.trim()),
                excludeSemantics: true,
                child: Text('${(i + 1).toString().padLeft(2)}  $line', style: style, softWrap: false),
              ),
          ],
        ),
      ),
    );
  }
}

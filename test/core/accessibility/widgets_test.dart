import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visiondesc/core/accessibility/haptic_service.dart';
import 'package:visiondesc/core/accessibility/widgets/accessible_button.dart';
import 'package:visiondesc/core/accessibility/widgets/accessible_radio_group.dart';
import 'package:visiondesc/core/accessibility/widgets/adjustable_value.dart';
import 'package:visiondesc/core/accessibility/widgets/headings.dart';
import 'package:visiondesc/core/accessibility/widgets/info_banner.dart';
import 'package:visiondesc/core/accessibility/widgets/status_region.dart';
import 'package:visiondesc/core/theme/dimensions.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AccessibleButton', () {
    testWidgets('expone etiqueta, rol de botón y vibra al pulsar', (tester) async {
      final deps = TestDeps();
      var pressed = 0;
      await tester.pumpAccessibleWidget(
        AccessibleButton(label: 'Capturar', hint: 'Fotografía la pizarra', onPressed: () => pressed++),
        deps: deps,
      );

      final semantics = tester.getSemantics(find.byType(AccessibleButton));
      expect(
        semantics,
        matchesSemantics(
          label: 'Capturar',
          hint: 'Fotografía la pizarra',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
        ),
      );

      await tester.tap(find.text('Capturar'));
      expect(pressed, 1);
      expect(deps.haptics.played, [HapticPattern.tap]);
    });

    testWidgets('desactivado: el lector dice el motivo', (tester) async {
      await tester.pumpAccessibleWidget(
        const AccessibleButton(
          label: 'Comando de voz',
          disabledReason: 'Disponible próximamente',
          onPressed: null,
        ),
      );
      final data = tester.getSemantics(find.byType(AccessibleButton)).getSemanticsData();
      expect(data.label, 'Comando de voz');
      expect(data.hint, 'Disponible próximamente');
      expect(data.flagsCollection.isEnabled, Tristate.isFalse);
    });

    testWidgets('el tamaño grande mide al menos 88 dp de alto', (tester) async {
      await tester.pumpAccessibleWidget(
        AccessibleButton(
          label: 'Historial',
          icon: Icons.history,
          size: AccessibleButtonSize.large,
          onPressed: () {},
        ),
      );
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(Dimensions.largeButtonHeight),
      );
    });

    testWidgets('cumple las guías de área táctil y etiqueta', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpAccessibleWidget(
        Column(
          children: [
            AccessibleButton(label: 'Guardar', onPressed: () {}),
            AccessibleButton(
              label: 'Borrar',
              variant: AccessibleButtonVariant.destructive,
              onPressed: () {},
            ),
            AccessibleButton(
              label: 'Ayuda',
              variant: AccessibleButtonVariant.secondary,
              onPressed: () {},
            ),
          ],
        ),
      );
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('Encabezados', () {
    testWidgets('ScreenTitle y SectionHeader se marcan como encabezados', (tester) async {
      await tester.pumpAccessibleWidget(
        const Column(children: [ScreenTitle('Resultado'), SectionHeader('Resumen')]),
      );
      expect(tester.getSemantics(find.text('Resultado')), matchesSemantics(label: 'Resultado', isHeader: true));
      expect(tester.getSemantics(find.text('Resumen')), matchesSemantics(label: 'Resumen', isHeader: true));
    });
  });

  group('AdjustableValue', () {
    testWidgets('es ajustable por el lector y por botones con etiqueta', (tester) async {
      var value = 10;
      await tester.pumpAccessibleWidget(
        StatefulBuilder(
          builder: (context, setState) => AdjustableValue(
            label: 'Velocidad',
            valueText: '${value / 10} por',
            increasedValueText: '${(value + 1) / 10} por',
            decreasedValueText: '${(value - 1) / 10} por',
            onIncrease: () => setState(() => value++),
            onDecrease: () => setState(() => value--),
          ),
        ),
      );

      final node = tester.getSemantics(find.text('Velocidad'));
      expect(
        node,
        matchesSemantics(
          label: 'Velocidad',
          value: '1.0 por',
          increasedValue: '1.1 por',
          decreasedValue: '0.9 por',
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );

      tester.semantics.performAction(find.semantics.byLabel('Velocidad'), SemanticsAction.increase);
      await tester.pump();
      expect(value, 11);

      await tester.tap(find.byTooltip('Disminuir Velocidad'));
      await tester.pump();
      expect(value, 10);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });

  group('AccessibleRadioGroup', () {
    testWidgets('cada opción dice su posición y su estado', (tester) async {
      var selected = 'b';
      await tester.pumpAccessibleWidget(
        StatefulBuilder(
          builder: (context, setState) => AccessibleRadioGroup<String>(
            options: const [
              RadioOption(value: 'a', label: 'Breve'),
              RadioOption(value: 'b', label: 'Estándar', description: 'Recomendado'),
              RadioOption(value: 'c', label: 'Exhaustivo'),
            ],
            selected: selected,
            onChanged: (v) => setState(() => selected = v),
          ),
        ),
      );

      final standard = tester.getSemantics(find.text('Estándar')).getSemanticsData();
      expect(standard.label, 'Estándar, 2 de 3');
      expect(standard.hint, 'Recomendado');
      expect(standard.flagsCollection.isChecked, CheckedState.isTrue);
      expect(standard.flagsCollection.isInMutuallyExclusiveGroup, isTrue);

      await tester.tap(find.text('Exhaustivo'));
      await tester.pump();
      expect(selected, 'c');
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });
  });

  group('InfoBanner y StatusRegion', () {
    testWidgets('el banner dice el tipo con palabras', (tester) async {
      await tester.pumpAccessibleWidget(
        const InfoBanner(type: InfoBannerType.warning, message: 'La imagen está borrosa.'),
      );
      expect(find.bySemanticsLabel('Advertencia. La imagen está borrosa.'), findsOneWidget);
    });

    testWidgets('la región de estado es una región viva y se oculta vacía', (tester) async {
      await tester.pumpAccessibleWidget(const StatusRegion(message: 'Analizando imagen'));
      final data = tester.getSemantics(find.text('Analizando imagen')).getSemanticsData();
      expect(data.flagsCollection.isLiveRegion, isTrue);

      await tester.pumpAccessibleWidget(const StatusRegion(message: ''));
      expect(find.byType(Text), findsNothing);
    });
  });
}

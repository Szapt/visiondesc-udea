import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('el título es un encabezado con etiqueta descriptiva', (tester) async {
    usePhoneSize(tester);
    await tester.pumpVisionDescApp(TestDeps());
    expect(
      tester.getSemantics(find.bySemanticsLabel('VisionDesc, inicio')),
      matchesSemantics(label: 'VisionDesc, inicio', isHeader: true),
    );
  });

  testWidgets('orden de foco: título, botones principales y comando de voz (UI.md §4.2)', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpVisionDescApp(TestDeps());

    final labels = tester.semantics
        .simulatedAccessibilityTraversal()
        .map((node) => node.label)
        .where((label) => label.isNotEmpty)
        .toList();

    expect(labels.first, 'VisionDesc, inicio');
    expect(labels.sublist(1), [
      'Capturar',
      'Importar archivo',
      'Historial',
      'Ajustes',
      'Comando de voz',
    ]);
  });

  testWidgets('Capturar navega y vibra; Atrás vuelve al inicio', (tester) async {
    usePhoneSize(tester);
    final deps = TestDeps();
    await tester.pumpVisionDescApp(deps);

    await tester.tap(find.text('Capturar'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('VisionDesc, inicio'), findsNothing);
    expect(deps.haptics.played, isNotEmpty);

    await tester.tap(find.byTooltip('Atrás'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('VisionDesc, inicio'), findsOneWidget);
  });

  testWidgets('en un teléfono vertical los botones van en dos columnas', (tester) async {
    usePhoneSize(tester);
    await tester.pumpVisionDescApp(TestDeps());

    final capture = tester.getRect(find.text('Capturar'));
    final importFile = tester.getRect(find.text('Importar archivo'));
    expect(importFile.left, greaterThan(capture.right), reason: 'uno al lado del otro');
  });

  testWidgets('con texto al 200 % los botones pasan a una columna', (tester) async {
    usePhoneSize(tester);
    await tester.pumpVisionDescApp(TestDeps(), textScale: 2.0);

    final capture = tester.getRect(find.text('Capturar'));
    final importFile = tester.getRect(find.text('Importar archivo'));
    expect(importFile.top, greaterThan(capture.bottom), reason: 'uno debajo del otro');
  });
}

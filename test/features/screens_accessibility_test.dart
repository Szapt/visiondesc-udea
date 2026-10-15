import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:visiondesc/core/router/app_router.dart';
import 'package:visiondesc/features/home/presentation/home_screen.dart';
import 'package:visiondesc/features/settings/domain/entities/app_settings.dart';

import '../helpers/pump_app.dart';

/// Checklist de UI.md §8 aplicado a todas las pantallas de la demostración:
/// tres temas × texto al 100 % y al 200 %, en teléfono vertical y en tablet
/// horizontal.
void main() {
  const screens = {
    'inicio': AppRoutes.home,
    'capturar': AppRoutes.capture,
    'importar': AppRoutes.importFile,
    'resultado': AppRoutes.result,
    'historial': AppRoutes.history,
    'ajustes': AppRoutes.settings,
    'explorar estructura': AppRoutes.structure,
    'chat': AppRoutes.chat,
  };

  Future<void> openScreen(WidgetTester tester, String route) async {
    if (route == AppRoutes.home) return;
    unawaited(GoRouter.of(tester.element(find.byType(HomeScreen))).push(route));
    await tester.pumpAndSettle();
  }

  for (final MapEntry(key: name, value: route) in screens.entries) {
    group('pantalla $name', () {
      for (final theme in TestTheme.values) {
        for (final scale in [1.0, 2.0]) {
          testWidgets('cumple las guías (tema ${theme.name}, texto ×$scale)', (tester) async {
            usePhoneSize(tester);
            final handle = tester.ensureSemantics();
            await tester.pumpVisionDescApp(
              TestDeps(settings: AppSettings(themePreference: theme.preference)),
              textScale: scale,
            );
            await openScreen(tester, route);

            expect(tester.takeException(), isNull, reason: 'sin desbordamientos');
            await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
            await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
            await expectLater(tester, meetsGuideline(textContrastGuideline));
            handle.dispose();
          });
        }
      }

      testWidgets('se adapta a una tablet en horizontal sin desbordamientos', (tester) async {
        tester.view.physicalSize = const Size(2560, 1600);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);

        await tester.pumpVisionDescApp(TestDeps());
        await openScreen(tester, route);
        expect(tester.takeException(), isNull);
      });

      testWidgets('el título es un encabezado', (tester) async {
        usePhoneSize(tester);
        await tester.pumpVisionDescApp(TestDeps());
        await openScreen(tester, route);

        final headers = tester.semantics
            .simulatedAccessibilityTraversal()
            .where((node) => node.getSemanticsData().flagsCollection.isHeader);
        expect(headers, isNotEmpty);
      });
    });
  }
}

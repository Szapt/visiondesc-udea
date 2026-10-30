import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:visiondesc/core/router/app_router.dart';
import 'package:visiondesc/features/history/data/history_repository_impl.dart';
import 'package:visiondesc/features/history/domain/entities/history_entry.dart';
import 'package:visiondesc/features/home/presentation/home_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('HistoryEntry.title', () {
    HistoryEntry entry(String description) =>
        HistoryEntry(id: 1, createdAt: DateTime(2026), description: description);

    test('deja intactas las descripciones cortas', () {
      expect(entry('  Tabla de\n formas normales. ').title, 'Tabla de formas normales.');
    });

    test('corta las largas en una palabra completa', () {
      final title = entry('palabra ' * 20).title;
      expect(title.length, lessThanOrEqualTo(71));
      expect(title, endsWith('palabra…'));
    });
  });

  group('HistoryRepositoryImpl', () {
    test('convierte la respuesta del backend en entradas', () async {
      final repository = HistoryRepositoryImpl(
        baseUrl: 'http://api',
        client: MockClient((request) async {
          expect(request.url.toString(), 'http://api/api/historial');
          return http.Response.bytes(
            utf8.encode(
              jsonEncode([
                {'id': 7, 'creado': '2026-10-29T14:00:00+00:00', 'descripcion': 'Gráfica de barras'},
              ]),
            ),
            200,
          );
        }),
      );

      final entries = await repository.fetchAll();
      expect(entries.single.id, 7);
      expect(entries.single.description, 'Gráfica de barras');
      expect(entries.single.createdAt.toUtc(), DateTime.utc(2026, 10, 29, 14));
    });

    test('pide el audio de una consulta y falla si el backend responde error', () async {
      final repository = HistoryRepositoryImpl(
        baseUrl: 'http://api',
        client: MockClient(
          (request) async => request.url.path == '/api/historial/3/audio'
              ? http.Response.bytes([1, 2, 3], 200)
              : http.Response('{"error":"x"}', 404),
        ),
      );

      expect(await repository.fetchAudio(3), [1, 2, 3]);
      await expectLater(repository.fetchAudio(4), throwsException);
    });
  });

  group('HistoryScreen', () {
    Future<void> openHistory(WidgetTester tester, TestDeps deps) async {
      usePhoneSize(tester);
      await tester.pumpVisionDescApp(deps);
      unawaited(GoRouter.of(tester.element(find.byType(HomeScreen))).push(AppRoutes.history));
      await tester.pumpAndSettle();
    }

    testWidgets('muestra las consultas guardadas y pide su audio al elegirlas', (tester) async {
      final deps = TestDeps();
      await openHistory(tester, deps);

      expect(find.text('2 resultados'), findsOneWidget);
      expect(find.text('Tabla de formas normales.'), findsOneWidget);

      await tester.tap(find.text('Tabla de formas normales.'));
      await tester.pumpAndSettle();
      expect(deps.history.requestedAudio, [1]);
    });

    testWidgets('filtra por el texto de la descripción', (tester) async {
      await openHistory(tester, TestDeps());

      await tester.enterText(find.byType(EditableText), 'pedidos');
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('1 resultado'), findsOneWidget);
      expect(find.text('Tabla de formas normales.'), findsNothing);
    });

    testWidgets('avisa cuando el historial está vacío', (tester) async {
      final deps = TestDeps();
      deps.history.entries.clear();
      await openHistory(tester, deps);

      expect(find.textContaining('Aún no hay descripciones guardadas'), findsOneWidget);
    });
  });
}

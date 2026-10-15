import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visiondesc/core/accessibility/announcer.dart';
import 'package:visiondesc/core/accessibility/widgets/announcement_host.dart';

void main() {
  late QueuedAnnouncer announcer;

  setUp(() => announcer = QueuedAnnouncer());
  tearDown(() => announcer.dispose());

  Future<void> pumpHost(WidgetTester tester, {required bool supportsAnnounce}) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(supportsAnnounce: supportsAnnounce),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AnnouncementHost(
            announcer: announcer,
            clearAfter: const Duration(seconds: 2),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  testWidgets('sin soporte de anuncios (Android) usa una región viva que se vacía sola', (tester) async {
    await pumpHost(tester, supportsAnnounce: false);
    final liveRegion = find.byKey(const ValueKey('announcement-live-region'));

    announcer.announce('Foto tomada');
    await tester.pump();
    final data = tester.getSemantics(liveRegion).getSemanticsData();
    expect(data.label.trim(), 'Foto tomada');
    expect(data.flagsCollection.isLiveRegion, isTrue);

    await tester.pump(const Duration(seconds: 3));
    expect(liveRegion, findsNothing);
  });

  testWidgets('un mismo mensaje repetido cambia la región viva para volver a anunciarse', (tester) async {
    await pumpHost(tester, supportsAnnounce: false);
    final liveRegion = find.byKey(const ValueKey('announcement-live-region'));

    announcer.announce('Sigo analizando.');
    await tester.pump();
    final first = tester.getSemantics(liveRegion).getSemanticsData().label;

    announcer.announce('Sigo analizando.');
    await tester.pump();
    final second = tester.getSemantics(liveRegion).getSemanticsData().label;

    expect(first, isNot(second));
    expect(first.trim(), second.trim());
  });

  testWidgets('con soporte de anuncios (iOS) envía el anuncio a la plataforma', (tester) async {
    final sent = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
      SystemChannels.accessibility,
      (message) async {
        sent.add(message);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        SystemChannels.accessibility,
        null,
      ),
    );

    await pumpHost(tester, supportsAnnounce: true);
    announcer.announce('Análisis listo');
    await tester.pump();

    expect(sent, hasLength(1));
    final event = sent.single! as Map<Object?, Object?>;
    expect(event['type'], 'announce');
    expect((event['data']! as Map<Object?, Object?>)['message'], 'Análisis listo');
    expect(find.byKey(const ValueKey('announcement-live-region')), findsNothing);
  });

  test('ignora mensajes vacíos', () {
    var notified = 0;
    announcer
      ..addListener(() => notified++)
      ..announce('   ');
    expect(notified, 0);
    expect(announcer.current, isNull);
  });
}

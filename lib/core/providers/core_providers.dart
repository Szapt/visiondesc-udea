import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../accessibility/announcer.dart';
import '../accessibility/haptic_service.dart';
import '../storage/key_value_store.dart';

/// Se sobrescribe en `main.dart` con el almacén ya inicializado.
final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => throw UnimplementedError('keyValueStoreProvider debe sobrescribirse en main()'),
);

final queuedAnnouncerProvider = Provider<QueuedAnnouncer>((ref) {
  final announcer = QueuedAnnouncer();
  ref.onDispose(announcer.dispose);
  return announcer;
});

/// Lo que usan las pantallas. En los tests se sobrescribe con un fake.
final announcerProvider = Provider<Announcer>((ref) => ref.watch(queuedAnnouncerProvider));

/// Si la vibración está activada. `app.dart` lo enlaza con los ajustes,
/// para que `core` no dependa de la feature de ajustes.
final hapticsEnabledProvider = Provider<bool>((ref) => true);

final hapticServiceProvider = Provider<HapticService>(
  (ref) => DeviceHapticService(isEnabled: () => ref.read(hapticsEnabledProvider)),
);

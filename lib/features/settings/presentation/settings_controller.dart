import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/settings_repository_impl.dart';
import '../domain/entities/app_settings.dart';
import '../domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(keyValueStoreProvider)),
);

final settingsControllerProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// Estado global de los ajustes. Los cambios se guardan al instante
/// (UI.md §4.10: no hay botón "Guardar").
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> update(AppSettings Function(AppSettings current) change) async {
    final next = change(state);
    if (next == state) return;
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }
}

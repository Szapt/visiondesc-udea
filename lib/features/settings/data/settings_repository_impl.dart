import 'dart:convert';

import '../../../core/storage/key_value_store.dart';
import '../domain/entities/app_settings.dart';
import '../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._store);

  static const storageKey = 'app_settings_v1';

  final KeyValueStore _store;

  @override
  AppSettings load() {
    final raw = _store.getString(storageKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on Object {
      // Ajustes corruptos o de un formato antiguo: se vuelve a los valores
      // por defecto en lugar de impedir que la app arranque.
      return const AppSettings();
    }
  }

  @override
  Future<void> save(AppSettings settings) =>
      _store.setString(storageKey, jsonEncode(settings.toJson()));

  @override
  Future<void> clear() => _store.remove(storageKey);
}

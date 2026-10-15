import 'package:shared_preferences/shared_preferences.dart';

/// Almacén clave-valor con lectura síncrona.
///
/// Abstrae `shared_preferences` para poder usar un mapa en memoria en los
/// tests sin depender de canales de plataforma.
abstract interface class KeyValueStore {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
  Future<void> clear();
}

/// Implementación sobre [SharedPreferencesWithCache]: lee de la caché en
/// memoria (síncrono) y escribe en disco.
class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore._(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static Future<SharedPreferencesStore> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    return SharedPreferencesStore._(prefs);
  }

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();
}

/// Almacén en memoria para tests y como respaldo si falla la plataforma.
class InMemoryKeyValueStore implements KeyValueStore {
  InMemoryKeyValueStore([Map<String, String>? initial]) : _data = {...?initial};

  final Map<String, String> _data;

  @override
  String? getString(String key) => _data[key];

  @override
  Future<void> setString(String key, String value) async => _data[key] = value;

  @override
  Future<void> remove(String key) async => _data.remove(key);

  @override
  Future<void> clear() async => _data.clear();
}

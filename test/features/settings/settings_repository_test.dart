import 'package:flutter_test/flutter_test.dart';
import 'package:visiondesc/core/storage/key_value_store.dart';
import 'package:visiondesc/features/settings/data/settings_repository_impl.dart';
import 'package:visiondesc/features/settings/domain/entities/app_settings.dart';

void main() {
  late InMemoryKeyValueStore store;
  late SettingsRepositoryImpl repository;

  setUp(() {
    store = InMemoryKeyValueStore();
    repository = SettingsRepositoryImpl(store);
  });

  test('sin datos guardados devuelve los valores por defecto', () {
    expect(repository.load(), const AppSettings());
  });

  test('guarda y recupera todos los campos', () async {
    const settings = AppSettings(
      themePreference: ThemePreference.altoContraste,
      hapticsEnabled: false,
      speechRate: 1.4,
      nivelDetalle: NivelDetalle.exhaustivo,
    );
    await repository.save(settings);
    expect(SettingsRepositoryImpl(store).load(), settings);
  });

  test('si los datos están corruptos vuelve a los valores por defecto', () async {
    await store.setString(SettingsRepositoryImpl.storageKey, '{no es json');
    expect(repository.load(), const AppSettings());
  });

  test('valores desconocidos de una versión futura no rompen la carga', () async {
    await store.setString(
      SettingsRepositoryImpl.storageKey,
      '{"themePreference":"sepia","speechRate":1.2}',
    );
    expect(repository.load(), const AppSettings(speechRate: 1.2));
  });

  test('clear borra los ajustes', () async {
    await repository.save(const AppSettings(hapticsEnabled: false));
    await repository.clear();
    expect(repository.load(), const AppSettings());
  });
}

import '../entities/app_settings.dart';

abstract interface class SettingsRepository {
  /// Lectura síncrona: los ajustes se necesitan antes del primer fotograma
  /// (tema, velocidad de voz).
  AppSettings load();

  Future<void> save(AppSettings settings);

  /// Borra todos los ajustes ("Borrar todos mis datos").
  Future<void> clear();
}

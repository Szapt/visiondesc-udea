import 'package:flutter/foundation.dart';

/// Preferencia de tema del estudiante.
enum ThemePreference { sistema, claro, oscuro, altoContraste }

/// Cuánto detalle pide el estudiante en las descripciones
/// (ARQUITECTURA.md §4.3).
enum NivelDetalle { breve, estandar, exhaustivo }

/// Ajustes persistentes de la app (UI.md §4.10).
@immutable
class AppSettings {
  const AppSettings({
    this.themePreference = ThemePreference.sistema,
    this.hapticsEnabled = true,
    this.speechRate = 1.0,
    this.nivelDetalle = NivelDetalle.estandar,
  });

  /// Lee los ajustes guardados. Los valores desconocidos o ausentes
  /// vuelven a su valor por defecto.
  factory AppSettings.fromJson(Map<String, Object?> json) {
    const defaults = AppSettings();
    return AppSettings(
      themePreference: ThemePreference.values.asNameMap()[json['themePreference']] ??
          defaults.themePreference,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? defaults.hapticsEnabled,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? defaults.speechRate,
      nivelDetalle:
          NivelDetalle.values.asNameMap()[json['nivelDetalle']] ?? defaults.nivelDetalle,
    );
  }

  final ThemePreference themePreference;
  final bool hapticsEnabled;

  /// Velocidad de lectura: 1.0 es normal (rango 0.5–2.0).
  final double speechRate;
  final NivelDetalle nivelDetalle;

  static const double minSpeechRate = 0.5;
  static const double maxSpeechRate = 2.0;

  AppSettings copyWith({
    ThemePreference? themePreference,
    bool? hapticsEnabled,
    double? speechRate,
    NivelDetalle? nivelDetalle,
  }) =>
      AppSettings(
        themePreference: themePreference ?? this.themePreference,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        speechRate: speechRate ?? this.speechRate,
        nivelDetalle: nivelDetalle ?? this.nivelDetalle,
      );

  Map<String, Object?> toJson() => {
    'themePreference': themePreference.name,
    'hapticsEnabled': hapticsEnabled,
    'speechRate': speechRate,
    'nivelDetalle': nivelDetalle.name,
  };

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themePreference == themePreference &&
      other.hapticsEnabled == hapticsEnabled &&
      other.speechRate == speechRate &&
      other.nivelDetalle == nivelDetalle;

  @override
  int get hashCode => Object.hash(themePreference, hapticsEnabled, speechRate, nivelDetalle);
}

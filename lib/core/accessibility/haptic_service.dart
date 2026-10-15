import 'package:flutter/services.dart';

/// Vocabulario háptico de la app (ARQUITECTURA.md §3.8).
///
/// La vibración nunca es el único canal: cada patrón va acompañado
/// de un anuncio o de un cambio visible (WCAG 1.3.3).
enum HapticPattern {
  /// Botón pulsado.
  tap,

  /// Foto tomada.
  captura,

  /// Operación completada.
  exito,

  /// Error.
  error,

  /// Se llegó al borde de una lista o tabla.
  borde,
}

abstract interface class HapticService {
  Future<void> play(HapticPattern pattern);
}

/// Implementación con [HapticFeedback] de Flutter, sin plugins nativos.
/// Los patrones de varios pulsos se harán con un plugin de vibración
/// cuando se implemente la cámara guiada.
class DeviceHapticService implements HapticService {
  DeviceHapticService({required this._isEnabled});

  final bool Function() _isEnabled;

  @override
  Future<void> play(HapticPattern pattern) async {
    if (!_isEnabled()) return;
    switch (pattern) {
      case HapticPattern.tap:
        await HapticFeedback.selectionClick();
      case HapticPattern.captura:
        await HapticFeedback.mediumImpact();
      case HapticPattern.exito:
        await HapticFeedback.lightImpact();
      case HapticPattern.error:
        await HapticFeedback.heavyImpact();
      case HapticPattern.borde:
        await HapticFeedback.vibrate();
    }
  }
}

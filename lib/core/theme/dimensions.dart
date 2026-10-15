/// Medidas de la interfaz (UI.md §1.3). Todas en píxeles lógicos (dp).
abstract final class Dimensions {
  /// Área táctil mínima de cualquier control (WCAG 2.5.8 exige 24; usamos 48).
  static const double minTapTarget = 48;

  /// Botones principales: inicio, "Tomar foto", acciones destacadas.
  static const double largeButtonHeight = 88;

  static const double captureButtonSize = 104;
  static const double spacingBetweenTargets = 12;
  static const double pagePadding = 16;
  static const double cornerRadius = 12;

  /// Anillo de foco exterior: separación respecto al control y grosor.
  static const double focusRingGap = 2;
  static const double focusRingWidth = 3;

  /// Borde de los controles en el tema de alto contraste.
  static const double highContrastBorder = 2;

  /// A partir de esta escala de texto, las cuadrículas pasan a una columna.
  static const double singleColumnTextScale = 1.5;

  /// Ancho de **contenido** por debajo del cual las cuadrículas pasan a una
  /// columna. Equivale a una pantalla de ~352 dp con los márgenes de 16 dp:
  /// un teléfono típico de 360 dp mantiene dos columnas.
  static const double singleColumnMaxWidth = 320;
}

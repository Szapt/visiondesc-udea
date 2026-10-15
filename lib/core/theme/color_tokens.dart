import 'package:flutter/material.dart';

/// Paleta de un tema. Los contrastes están documentados en UI.md §1.1
/// y protegidos por `test/core/theme/color_tokens_test.dart`.
@immutable
class ColorTokens {
  const ColorTokens({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.onBackground,
    required this.onSurfaceVariant,
    required this.primary,
    required this.onPrimary,
    required this.error,
    required this.onError,
    required this.warningContainer,
    required this.onWarning,
    required this.outline,
    required this.focus,
    required this.isHighContrast,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color onBackground;
  final Color onSurfaceVariant;
  final Color primary;
  final Color onPrimary;
  final Color error;
  final Color onError;
  final Color warningContainer;
  final Color onWarning;
  final Color outline;
  final Color focus;
  final bool isHighContrast;

  static const light = ColorTokens(
    brightness: Brightness.light,
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF3F5F8),
    onBackground: Color(0xFF1A1C1E),
    onSurfaceVariant: Color(0xFF44474E),
    primary: Color(0xFF00573A),
    onPrimary: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFF1D6),
    onWarning: Color(0xFF7A4B00),
    outline: Color(0xFF6F7378),
    focus: Color(0xFF1D4ED8),
    isHighContrast: false,
  );

  static const dark = ColorTokens(
    brightness: Brightness.dark,
    background: Color(0xFF121417),
    surface: Color(0xFF1E2126),
    onBackground: Color(0xFFE3E5E8),
    onSurfaceVariant: Color(0xFFC4C7CC),
    primary: Color(0xFF7FD8AA),
    onPrimary: Color(0xFF00210F),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF3B0905),
    warningContainer: Color(0xFF3D2A00),
    onWarning: Color(0xFFFFD597),
    outline: Color(0xFF8E9196),
    focus: Color(0xFF8AB4FF),
    isHighContrast: false,
  );

  /// Amarillo sobre negro, sin sombras ni degradados.
  static const highContrast = ColorTokens(
    brightness: Brightness.dark,
    background: Color(0xFF000000),
    surface: Color(0xFF000000),
    onBackground: Color(0xFFFFFFFF),
    onSurfaceVariant: Color(0xFFFFFFFF),
    primary: Color(0xFFFFE14D),
    onPrimary: Color(0xFF000000),
    error: Color(0xFFFF9A8F),
    onError: Color(0xFF000000),
    warningContainer: Color(0xFF000000),
    onWarning: Color(0xFFFFE14D),
    outline: Color(0xFFFFFFFF),
    focus: Color(0xFF00E5FF),
    isHighContrast: true,
  );
}

/// Expone los tokens en el árbol para los componentes propios
/// (banners, anillo de foco) que no encajan en [ColorScheme].
class AppColors extends ThemeExtension<AppColors> {
  const AppColors(this.tokens);

  final ColorTokens tokens;

  static ColorTokens of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()?.tokens ?? ColorTokens.light;

  @override
  AppColors copyWith({ColorTokens? tokens}) => AppColors(tokens ?? this.tokens);

  // Los temas cambian de golpe (sin animación) para no mezclar paletas
  // con contrastes no verificados.
  @override
  AppColors lerp(covariant AppColors? other, double t) => t < 0.5 ? this : (other ?? this);
}

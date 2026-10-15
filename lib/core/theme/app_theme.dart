import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'dimensions.dart';

/// Construye los temas claro, oscuro y de alto contraste a partir de
/// [ColorTokens].
abstract final class AppTheme {
  static ThemeData light() => _build(ColorTokens.light);
  static ThemeData dark() => _build(ColorTokens.dark);
  static ThemeData highContrast() => _build(ColorTokens.highContrast);

  static ThemeData _build(ColorTokens t) {
    final scheme = ColorScheme(
      brightness: t.brightness,
      primary: t.primary,
      onPrimary: t.onPrimary,
      secondary: t.primary,
      onSecondary: t.onPrimary,
      error: t.error,
      onError: t.onError,
      surface: t.background,
      onSurface: t.onBackground,
      surfaceContainerHighest: t.surface,
      surfaceContainerHigh: t.surface,
      surfaceContainer: t.surface,
      surfaceContainerLow: t.surface,
      surfaceContainerLowest: t.background,
      onSurfaceVariant: t.onSurfaceVariant,
      outline: t.outline,
      outlineVariant: t.outline,
      shadow: t.isHighContrast ? Colors.transparent : Colors.black,
      surfaceTint: Colors.transparent,
    );

    final borderSide = BorderSide(
      color: t.isHighContrast ? t.outline : t.primary,
      width: t.isHighContrast ? Dimensions.highContrastBorder : 1.5,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
    );
    const minSize = Size(Dimensions.minTapTarget, Dimensions.minTapTarget);
    const padding = EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: t.brightness,
      scaffoldBackgroundColor: t.background,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      focusColor: t.focus.withValues(alpha: 0.24),
      extensions: [AppColors(t)],
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, t),
      appBarTheme: AppBarTheme(
        backgroundColor: t.background,
        foregroundColor: t.onBackground,
        elevation: 0,
        scrolledUnderElevation: t.isHighContrast ? 0 : 2,
        centerTitle: false,
        toolbarHeight: 64,
        shape: t.isHighContrast
            ? Border(bottom: BorderSide(color: t.outline, width: Dimensions.highContrastBorder))
            : null,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: t.primary,
          foregroundColor: t.onPrimary,
          disabledBackgroundColor: t.surface,
          disabledForegroundColor: t.onSurfaceVariant,
          minimumSize: minSize,
          padding: padding,
          shape: shape,
          side: t.isHighContrast ? borderSide : null,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.isHighContrast ? t.onBackground : t.primary,
          minimumSize: minSize,
          padding: padding,
          shape: shape,
          side: borderSide,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.primary,
          minimumSize: minSize,
          padding: padding,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: t.onBackground,
          minimumSize: minSize,
          iconSize: 28,
        ),
      ),
      cardTheme: CardThemeData(
        color: t.surface,
        elevation: t.isHighContrast ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
          side: t.isHighContrast
              ? BorderSide(color: t.outline, width: Dimensions.highContrastBorder)
              : BorderSide.none,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
          borderSide: BorderSide(color: t.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
          borderSide: BorderSide(
            color: t.outline,
            width: t.isHighContrast ? Dimensions.highContrastBorder : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
          borderSide: BorderSide(color: t.focus, width: Dimensions.focusRingWidth),
        ),
        labelStyle: TextStyle(color: t.onSurfaceVariant, fontSize: 18),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(t.outline),
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? t.onPrimary : t.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? t.primary : t.background,
        ),
      ),
      dividerTheme: DividerThemeData(color: t.outline, thickness: t.isHighContrast ? 2 : 1),
      // Transiciones por defecto de cada plataforma; `app.dart` las sustituye
      // por instantáneas cuando el sistema pide reducir el movimiento.
    );
  }

  /// Escala tipográfica de UI.md §1.2: cuerpo de 18 sp e interlineado de 1.5.
  static TextTheme _textTheme(TextTheme base, ColorTokens t) {
    final color = t.onBackground;
    return base.copyWith(
      titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.3, color: color),
      titleMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3, color: color),
      titleSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3, color: color),
      bodyLarge: TextStyle(fontSize: 18, height: 1.5, color: color),
      bodyMedium: TextStyle(fontSize: 18, height: 1.5, color: color),
      bodySmall: TextStyle(fontSize: 16, height: 1.5, color: t.onSurfaceVariant),
      labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
      labelMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
    );
  }
}

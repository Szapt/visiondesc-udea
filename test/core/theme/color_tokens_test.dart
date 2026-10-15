import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visiondesc/core/theme/color_tokens.dart';

/// Contraste WCAG 2.x entre dos colores opacos.
double contrastRatio(Color a, Color b) {
  double channel(double c) => c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) => 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  final la = luminance(a);
  final lb = luminance(b);
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  const themes = {
    'claro': ColorTokens.light,
    'oscuro': ColorTokens.dark,
    'alto contraste': ColorTokens.highContrast,
  };

  test('la fórmula de contraste da 21:1 para negro sobre blanco', () {
    expect(contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)), closeTo(21, 0.01));
  });

  for (final MapEntry(key: name, value: t) in themes.entries) {
    group('tema $name', () {
      // AA para texto normal; en alto contraste se exige AAA (RNF-A4).
      final minText = t.isHighContrast ? 7.0 : 4.5;

      final textPairs = {
        'texto sobre fondo': (t.onBackground, t.background),
        'texto sobre superficie': (t.onBackground, t.surface),
        'texto secundario sobre superficie': (t.onSurfaceVariant, t.surface),
        'texto secundario sobre fondo': (t.onSurfaceVariant, t.background),
        'texto de botón primario': (t.onPrimary, t.primary),
        'color primario como texto': (t.primary, t.background),
        'texto sobre error': (t.onError, t.error),
        'error como texto': (t.error, t.background),
        'texto de advertencia': (t.onWarning, t.warningContainer),
      };

      for (final MapEntry(key: pair, value: (fg, bg)) in textPairs.entries) {
        test('$pair ≥ $minText:1', () {
          expect(contrastRatio(fg, bg), greaterThanOrEqualTo(minText));
        });
      }

      // WCAG 1.4.11: componentes no textuales ≥ 3:1.
      test('bordes ≥ 3:1 sobre el fondo', () {
        expect(contrastRatio(t.outline, t.background), greaterThanOrEqualTo(3));
      });

      test('anillo de foco ≥ 3:1 sobre el fondo (se dibuja por fuera del control)', () {
        expect(contrastRatio(t.focus, t.background), greaterThanOrEqualTo(3));
      });
    });
  }
}

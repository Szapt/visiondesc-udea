import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/core_providers.dart';
import '../../theme/dimensions.dart';
import '../haptic_service.dart';
import 'focus_ring.dart';

enum AccessibleButtonVariant { primary, secondary, destructive }

enum AccessibleButtonSize {
  /// Altura mínima de 48 dp.
  normal,

  /// Altura mínima de 88 dp, icono encima del texto (inicio, acciones principales).
  large,
}

/// Botón con las garantías de UI.md §1.5:
/// - área táctil ≥ 48 dp (88 dp en tamaño grande);
/// - la etiqueta semántica es el texto visible (WCAG 2.5.3);
/// - el icono es decorativo;
/// - vibración `tap` al pulsar;
/// - anillo de foco exterior;
/// - si está desactivado, el lector dice el motivo ([disabledReason]).
class AccessibleButton extends ConsumerWidget {
  const AccessibleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.hint,
    this.semanticLabel,
    this.disabledReason,
    this.variant = AccessibleButtonVariant.primary,
    this.size = AccessibleButtonSize.normal,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Pista breve que el lector añade al final.
  final String? hint;

  /// Etiqueta semántica alternativa. Debe **empezar** con [label].
  final String? semanticLabel;

  /// Motivo leído cuando el botón está desactivado.
  final String? disabledReason;
  final AccessibleButtonVariant variant;
  final AccessibleButtonSize size;

  /// Ocupa todo el ancho disponible.
  final bool expand;

  bool get _enabled => onPressed != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(
      semanticLabel == null || semanticLabel!.startsWith(label),
      'WCAG 2.5.3: la etiqueta semántica debe empezar con el texto visible.',
    );

    final callback = _enabled
        ? () {
            unawaited(ref.read(hapticServiceProvider).play(HapticPattern.tap));
            onPressed!();
          }
        : null;

    final isLarge = size == AccessibleButtonSize.large;
    final minHeight = isLarge ? Dimensions.largeButtonHeight : Dimensions.minTapTarget;
    // Sin color propio: el texto hereda el color del botón (onPrimary, etc.),
    // que es el par de contraste verificado.
    final textStyle = isLarge ? const TextStyle(fontSize: 22, fontWeight: FontWeight.w700) : null;

    final Widget content = isLarge && icon != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: textStyle),
            ],
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
              Flexible(child: Text(label, textAlign: TextAlign.center, style: textStyle)),
            ],
          );

    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(Dimensions.minTapTarget, minHeight)),
      padding: isLarge
          ? const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 16))
          : null,
    );

    final scheme = Theme.of(context).colorScheme;
    final Widget button = switch (variant) {
      AccessibleButtonVariant.primary => FilledButton(
        onPressed: callback,
        style: style,
        child: content,
      ),
      AccessibleButtonVariant.secondary => OutlinedButton(
        onPressed: callback,
        style: style,
        child: content,
      ),
      AccessibleButtonVariant.destructive => FilledButton(
        onPressed: callback,
        style: style.copyWith(
          backgroundColor: WidgetStatePropertyAll(scheme.error),
          foregroundColor: WidgetStatePropertyAll(scheme.onError),
        ),
        child: content,
      ),
    };

    final effectiveHint = !_enabled && disabledReason != null ? disabledReason : hint;

    return FocusRing(
      child: Semantics(
        label: semanticLabel ?? label,
        hint: effectiveHint,
        button: true,
        enabled: _enabled,
        // Se excluye la semántica interna del botón de Material (evita leer la
        // etiqueta dos veces), así que hay que declarar que es enfocable.
        focusable: _enabled,
        excludeSemantics: true,
        onTap: callback,
        child: SizedBox(width: expand ? double.infinity : null, child: button),
      ),
    );
  }
}

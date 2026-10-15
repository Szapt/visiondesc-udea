import 'package:flutter/material.dart';

import '../../theme/color_tokens.dart';
import '../../theme/dimensions.dart';

/// Dibuja un anillo de foco **por fuera** del control cuando este (o un
/// descendiente) tiene el foco de teclado o Switch Access.
///
/// El anillo queda sobre el fondo de la pantalla, no sobre el botón, por lo
/// que su contraste es el de `focus` frente a `background` (≥ 6.7:1 en los
/// tres temas; ver UI.md §1.1). El foco del lector de pantalla lo dibuja el
/// propio sistema.
class FocusRing extends StatefulWidget {
  const FocusRing({super.key, required this.child, this.borderRadius});

  final Widget child;
  final double? borderRadius;

  @override
  State<FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<FocusRing> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = AppColors.of(context);
    const inset = Dimensions.focusRingGap + Dimensions.focusRingWidth;
    final radius = (widget.borderRadius ?? Dimensions.cornerRadius) + inset;

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (hasFocus) {
        final highlight = hasFocus &&
            FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
        if (highlight != _focused) setState(() => _focused = highlight);
      },
      child: Container(
        padding: const EdgeInsets.all(inset),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: _focused ? tokens.focus : Colors.transparent,
            width: Dimensions.focusRingWidth,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

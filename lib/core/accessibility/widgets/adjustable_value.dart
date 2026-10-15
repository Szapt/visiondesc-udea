import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../theme/dimensions.dart';
import 'focus_ring.dart';

/// Valor ajustable con botones "−" y "+" visibles, en lugar de un `Slider`
/// (WCAG 2.5.7: ninguna acción depende de arrastrar).
///
/// El valor central es un nodo semántico ajustable: con TalkBack se cambia
/// deslizando arriba/abajo y con VoiceOver con el gesto de ajuste. Los
/// botones dan una alternativa para cualquier otra forma de interacción.
class AdjustableValue extends StatelessWidget {
  const AdjustableValue({
    super.key,
    required this.label,
    required this.valueText,
    required this.onIncrease,
    required this.onDecrease,
    this.increasedValueText,
    this.decreasedValueText,
  });

  final String label;
  final String valueText;

  /// `null` cuando ya se alcanzó el máximo.
  final VoidCallback? onIncrease;

  /// `null` cuando ya se alcanzó el mínimo.
  final VoidCallback? onDecrease;

  /// Valor que tendrá tras aumentar; el lector lo anuncia de antemano.
  final String? increasedValueText;
  final String? decreasedValueText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: Dimensions.spacingBetweenTargets,
        runSpacing: 8,
        children: [
          Semantics(
            container: true,
            label: label,
            value: valueText,
            increasedValue: onIncrease != null ? increasedValueText : null,
            decreasedValue: onDecrease != null ? decreasedValueText : null,
            onIncrease: onIncrease,
            onDecrease: onDecrease,
            excludeSemantics: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Dimensions.minTapTarget),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: textTheme.bodyLarge),
                  Text(valueText, style: textTheme.titleSmall),
                ],
              ),
            ),
          ),
          _StepButton(
            icon: Icons.remove,
            semanticLabel: l10n.adjustDecrease(label),
            onPressed: onDecrease,
          ),
          _StepButton(
            icon: Icons.add,
            semanticLabel: l10n.adjustIncrease(label),
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.semanticLabel, required this.onPressed});

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FocusRing(
      child: IconButton.outlined(
        onPressed: onPressed,
        tooltip: semanticLabel,
        icon: Icon(icon),
        constraints: const BoxConstraints(
          minWidth: Dimensions.minTapTarget,
          minHeight: Dimensions.minTapTarget,
        ),
      ),
    );
  }
}

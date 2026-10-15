import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../theme/dimensions.dart';
import 'focus_ring.dart';

/// Opción de un [AccessibleRadioGroup].
class RadioOption<T> {
  const RadioOption({required this.value, required this.label, this.description});

  final T value;
  final String label;

  /// Texto secundario visible (p. ej. "Recomendado").
  final String? description;
}

/// Grupo de opciones excluyentes. Cada opción se anuncia como
/// "{opción}, {i} de {n}" con su estado de selección (UI.md §5.4).
///
/// Toda la fila es táctil (≥ 48 dp) y el círculo es decorativo.
class AccessibleRadioGroup<T> extends StatelessWidget {
  const AccessibleRadioGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<RadioOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, option) in options.indexed)
          FocusRing(
            child: Semantics(
              container: true,
              inMutuallyExclusiveGroup: true,
              checked: option.value == selected,
              label: l10n.optionPosition(option.label, index + 1, options.length),
              hint: option.description,
              excludeSemantics: true,
              onTap: () => onChanged(option.value),
              child: InkWell(
                onTap: () => onChanged(option.value),
                borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: Dimensions.minTapTarget),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          option.value == selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: scheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(option.label, style: textTheme.bodyLarge),
                              if (option.description != null)
                                Text(option.description!, style: textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

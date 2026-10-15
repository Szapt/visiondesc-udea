import 'package:flutter/material.dart';

import '../../theme/color_tokens.dart';
import '../../theme/dimensions.dart';

/// Texto de estado visible y con `liveRegion` (UI.md §1.5): el lector
/// anuncia sus cambios sin mover el foco, y quien ve la pantalla lee
/// lo mismo. No ocupa espacio cuando [message] está vacío.
class StatusRegion extends StatelessWidget {
  const StatusRegion({super.key, required this.message, this.large = false});

  final String message;

  /// Texto de 22 sp para estados principales (cámara, procesando).
  final bool large;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    final tokens = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimensions.pagePadding),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
          border: Border.all(
            color: tokens.outline,
            width: tokens.isHighContrast ? Dimensions.highContrastBorder : 1,
          ),
        ),
        child: Text(message, style: large ? textTheme.titleMedium : textTheme.bodyLarge),
      ),
    );
  }
}

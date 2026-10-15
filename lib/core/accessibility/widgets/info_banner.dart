import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../theme/color_tokens.dart';
import '../../theme/dimensions.dart';

enum InfoBannerType { info, warning, error }

/// Aviso persistente con icono, texto y acciones opcionales (UI.md §1.5).
///
/// No desaparece solo (WCAG 2.2.1). El tipo se dice con palabras
/// ("Advertencia. …"), no solo con el color o el icono (WCAG 1.4.1).
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.type,
    required this.message,
    this.actions = const [],
    this.focusNode,
  });

  final InfoBannerType type;
  final String message;

  /// Botones de acción, normalmente `AccessibleButton` secundarios.
  final List<Widget> actions;

  /// Permite mover el foco al banner cuando un error bloquea la tarea.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppColors.of(context);

    final (IconData icon, String prefix, Color background, Color foreground) = switch (type) {
      InfoBannerType.info => (Icons.info_outline, l10n.commonInfoPrefix, tokens.surface, tokens.onBackground),
      InfoBannerType.warning => (
        Icons.warning_amber_rounded,
        l10n.commonWarningPrefix,
        tokens.warningContainer,
        tokens.onWarning,
      ),
      InfoBannerType.error => (Icons.error_outline, l10n.commonErrorPrefix, tokens.surface, tokens.error),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.pagePadding),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
        border: Border.all(
          color: type == InfoBannerType.error ? tokens.error : tokens.outline,
          width: tokens.isHighContrast ? Dimensions.highContrastBorder : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Focus(
            focusNode: focusNode,
            child: Semantics(
              container: true,
              label: '$prefix. $message',
              excludeSemantics: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: foreground, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: type == InfoBannerType.error ? tokens.onBackground : foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: Dimensions.spacingBetweenTargets,
              runSpacing: Dimensions.spacingBetweenTargets,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}

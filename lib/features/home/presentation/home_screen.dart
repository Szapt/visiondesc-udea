import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/accessibility/widgets/accessible_button.dart';
import '../../../core/accessibility/widgets/headings.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Pantalla de inicio (UI.md §4.2): cuatro botones grandes.
///
/// Orden de foco: título → Capturar → Importar →
/// Historial → Ajustes.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(
          l10n.homeTitle,
          semanticLabel: l10n.homeTitleSemantics,
        ),
      ),
      body: ResponsiveBody(
        children: [
          ResponsiveGrid(
            children: [
              AccessibleButton(
                label: l10n.homeCaptureLabel,
                hint: l10n.homeCaptureHint,
                icon: Icons.photo_camera_outlined,
                size: AccessibleButtonSize.large,
                expand: true,
                onPressed: () => context.push(AppRoutes.capture),
              ),
              AccessibleButton(
                label: l10n.homeImportLabel,
                hint: l10n.homeImportHint,
                icon: Icons.upload_file_outlined,
                size: AccessibleButtonSize.large,
                expand: true,
                onPressed: () => context.push(AppRoutes.importFile),
              ),
              AccessibleButton(
                label: l10n.homeHistoryLabel,
                icon: Icons.history,
                size: AccessibleButtonSize.large,
                variant: AccessibleButtonVariant.secondary,
                expand: true,
                onPressed: () => context.push(AppRoutes.history),
              ),
              AccessibleButton(
                label: l10n.homeSettingsLabel,
                icon: Icons.settings_outlined,
                size: AccessibleButtonSize.large,
                variant: AccessibleButtonVariant.secondary,
                expand: true,
                onPressed: () => context.push(AppRoutes.settings),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

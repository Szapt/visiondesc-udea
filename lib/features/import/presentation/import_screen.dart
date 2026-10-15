import 'package:flutter/material.dart';

import '../../../core/accessibility/widgets/accessible_button.dart';
import '../../../core/accessibility/widgets/headings.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/theme/dimensions.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Importar archivo (UI.md §4.4a).
class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  void _onOptionPressed() {}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: ScreenTitle(l10n.importTitle)),
      body: ResponsiveBody(
        children: [
          ResponsiveGrid(
            columns: 3,
            children: [
              AccessibleButton(
                label: l10n.importImage,
                icon: Icons.image_outlined,
                size: AccessibleButtonSize.large,
                variant: AccessibleButtonVariant.secondary,
                expand: true,
                onPressed: _onOptionPressed,
              ),
              AccessibleButton(
                label: l10n.importPdf,
                icon: Icons.picture_as_pdf_outlined,
                size: AccessibleButtonSize.large,
                variant: AccessibleButtonVariant.secondary,
                expand: true,
                onPressed: _onOptionPressed,
              ),
              AccessibleButton(
                label: l10n.importPowerPoint,
                icon: Icons.slideshow_outlined,
                size: AccessibleButtonSize.large,
                variant: AccessibleButtonVariant.secondary,
                expand: true,
                onPressed: _onOptionPressed,
              ),
            ],
          ),
          const SizedBox(height: Dimensions.pagePadding),
          Text(l10n.importMaxSize, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/accessibility/widgets/headings.dart';
import '../../../core/layout/responsive.dart';
import '../../../l10n/generated/app_localizations.dart';

enum PendingFeature { structure, chat }

/// Pantalla para las funciones que aún no están en la demostración
/// (explorador de estructura y chat).
class PendingFeatureScreen extends StatelessWidget {
  const PendingFeatureScreen({super.key, required this.feature});

  final PendingFeature feature;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = switch (feature) {
      PendingFeature.structure => l10n.pendingStructureTitle,
      PendingFeature.chat => l10n.pendingChatTitle,
    };

    return Scaffold(
      appBar: AppBar(title: ScreenTitle(title)),
      body: const ResponsiveBody(children: []),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/accessibility/haptic_service.dart';
import '../../../core/accessibility/widgets/accessible_button.dart';
import '../../../core/accessibility/widgets/accessible_switch_tile.dart';
import '../../../core/accessibility/widgets/headings.dart';
import '../../../core/accessibility/widgets/status_region.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/dimensions.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Cámara guiada (UI.md §4.3), versión de demostración sin cámara.
///
/// Orden de foco: título → Atrás → guía → interruptores → Tomar foto.
/// En horizontal, la vista de cámara va a la izquierda y los controles a la
/// derecha; el orden de foco no cambia.
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  bool _voiceGuidance = true;
  bool _flashlight = false;
  bool _autoCapture = false;

  void _takePhoto() {
    final l10n = AppLocalizations.of(context);
    unawaited(ref.read(hapticServiceProvider).play(HapticPattern.captura));
    ref.read(announcerProvider).announce(l10n.capturePhotoTaken);
    unawaited(context.push(AppRoutes.result));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatusRegion(message: l10n.captureGuidance, large: true),
        const SizedBox(height: Dimensions.spacingBetweenTargets),
        AccessibleSwitchTile(
          title: l10n.captureVoiceGuidance,
          value: _voiceGuidance,
          onChanged: (v) => setState(() => _voiceGuidance = v),
        ),
        AccessibleSwitchTile(
          title: l10n.captureFlashlight,
          value: _flashlight,
          onChanged: (v) => setState(() => _flashlight = v),
        ),
        AccessibleSwitchTile(
          title: l10n.captureAutoCapture,
          value: _autoCapture,
          onChanged: (v) => setState(() => _autoCapture = v),
        ),
        const SizedBox(height: Dimensions.spacingBetweenTargets),
        AccessibleButton(
          label: l10n.captureTakePhoto,
          hint: l10n.captureTakePhotoHint,
          icon: Icons.camera,
          size: AccessibleButtonSize.large,
          expand: true,
          onPressed: _takePhoto,
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: ScreenTitle(l10n.captureTitle)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final landscape = constraints.maxWidth > constraints.maxHeight &&
                constraints.maxWidth >= 600;

            if (landscape) {
              return Padding(
                padding: const EdgeInsets.all(Dimensions.pagePadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(flex: 3, child: _CameraPlaceholder()),
                    const SizedBox(width: Dimensions.pagePadding),
                    Expanded(flex: 2, child: SingleChildScrollView(child: controls)),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: (constraints.maxHeight * 0.35).clamp(160, 360),
                    child: const _CameraPlaceholder(),
                  ),
                  const SizedBox(height: Dimensions.spacingBetweenTargets),
                  controls,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Lugar de la vista de cámara. Se excluye de la semántica: no aporta
/// información al lector y obligaría a recorrer un elemento vacío.
class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder();

  @override
  Widget build(BuildContext context) {
    final tokens = AppColors.of(context);
    return ExcludeSemantics(
      child: Container(
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
          border: Border.all(color: tokens.outline, width: 2),
        ),
        child: Center(
          child: Icon(Icons.photo_camera_outlined, size: 64, color: tokens.onSurfaceVariant),
        ),
      ),
    );
  }
}

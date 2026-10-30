import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../core/accessibility/haptic_service.dart';
import '../../../core/accessibility/widgets/accessible_button.dart';
import '../../../core/accessibility/widgets/accessible_switch_tile.dart';
import '../../../core/accessibility/widgets/audio_controls.dart';
import '../../../core/accessibility/widgets/headings.dart';
import '../../../core/accessibility/widgets/status_region.dart';
import '../../../core/audio/description_player.dart';
import '../../../core/config/api_config.dart';
import '../../../core/providers/core_providers.dart';
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
  CameraController? _cameraController;
  AudioPlayer? _audioPlayer;
  final FlutterTts _tts = FlutterTts();
  Uint8List? _capturedImage;
  bool _voiceGuidance = true;
  bool _flashlight = false;
  bool _autoCapture = false;
  bool _isProcessing = false;
  bool _isAudioPaused = false;
  String? _processingMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeCamera());
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _cameraController = controller);
    } catch (error) {
      debugPrint('No fue posible iniciar la cámara: $error');
    }
  }

  Future<void> _takePhoto() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isProcessing) {
      return;
    }

    try {
      final photo = await controller.takePicture();
      final photoBytes = await photo.readAsBytes();
      if (mounted) {
        setState(() {
          _isProcessing = true;
          _capturedImage = photoBytes;
          _processingMessage = 'Procesando tu imagen.';
        });
      }
      await _speakProcessingMessage();
      ref.read(announcerProvider).announce('Procesando tu imagen.');
      final request =
          http.MultipartRequest(
              'POST',
              Uri.parse('$apiBaseUrl/api/convertir'),
            )
            ..files.add(
              http.MultipartFile.fromBytes(
                'documento',
                photoBytes,
                filename: 'captura.jpg',
                contentType: MediaType('image', 'jpeg'),
              ),
            );
      final response = await request.send().timeout(
        const Duration(seconds: 55),
        onTimeout: () => throw TimeoutException(
          'El procesamiento tardó demasiado. Intenta de nuevo.',
        ),
      );
      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        throw Exception(
          'El backend respondió ${response.statusCode}: $errorBody',
        );
      }

      final audio = await response.stream.toBytes();
      final player = _audioPlayer ??= createDescriptionPlayer(onComplete: _onAudioComplete);
      await player.playDescription(audio);
      if (mounted) setState(() => _isAudioPaused = false);
      unawaited(ref.read(hapticServiceProvider).play(HapticPattern.captura));
      ref
          .read(announcerProvider)
          .announce('Descripción lista. Reproduciendo audio.');
    } catch (error) {
      debugPrint('No fue posible analizar la captura: $error');
      if (mounted) {
        final message = 'No fue posible analizar la captura: $error';
        setState(() => _processingMessage = message);
        ref.read(announcerProvider).announce(message);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _toggleAudio() async {
    final player = _audioPlayer;
    if (player == null) return;
    if (_isAudioPaused) {
      await player.resume();
      if (mounted) setState(() => _isAudioPaused = false);
      ref.read(announcerProvider).announce('Audio reanudado.');
    } else {
      await player.pause();
      if (mounted) setState(() => _isAudioPaused = true);
      ref.read(announcerProvider).announce('Audio pausado.');
    }
  }

  Future<void> _stopAudio() async {
    final player = _audioPlayer;
    if (player == null) return;
    await player.stop();
    if (mounted) setState(() => _isAudioPaused = true);
    ref.read(announcerProvider).announce('Audio detenido.');
  }

  void _onAudioComplete() {
    if (mounted) setState(() => _isAudioPaused = true);
  }

  Future<void> _takeAnotherPhoto() async {
    await _stopAudio();
    final controller = _cameraController;
    if (controller != null) {
      await controller.dispose();
    }
    if (mounted) {
      setState(() {
        _cameraController = null;
        _capturedImage = null;
        _processingMessage = null;
      });
      ref.read(announcerProvider).announce('Cámara lista para otra foto.');
      await _initializeCamera();
    }
  }

  @override
  void dispose() {
    unawaited(_cameraController?.dispose());
    final player = _audioPlayer;
    if (player != null) unawaited(player.dispose());
    unawaited(_tts.stop());
    super.dispose();
  }

  Future<void> _speakProcessingMessage() async {
    try {
      await _tts.setLanguage('es-ES');
      await _tts.setSpeechRate(0.5);
      await _tts.speak('Procesando tu imagen');
    } catch (error) {
      debugPrint(
        'No fue posible reproducir el estado de procesamiento: $error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatusRegion(message: l10n.captureGuidance, large: true),
        if (_processingMessage != null) ...[
          const SizedBox(height: Dimensions.spacingBetweenTargets),
          _ProcessingStatus(
            message: _processingMessage!,
            isProcessing: _isProcessing,
          ),
        ],
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
          onPressed: _isProcessing ? null : _takePhoto,
        ),
        if (_capturedImage != null && !_isProcessing) ...[
          const SizedBox(height: Dimensions.spacingBetweenTargets),
          ResponsiveAudioControls(
            isPaused: _isAudioPaused,
            onToggle: _toggleAudio,
            onStop: _stopAudio,
          ),
          const SizedBox(height: Dimensions.spacingBetweenTargets),
          AccessibleButton(
            label: 'Tomar otra foto',
            hint: 'Descarta la foto actual y vuelve a activar la cámara',
            icon: Icons.camera_alt_outlined,
            variant: AccessibleButtonVariant.secondary,
            expand: true,
            onPressed: _takeAnotherPhoto,
          ),
        ],
      ],
    );

    return Scaffold(
      appBar: AppBar(title: ScreenTitle(l10n.captureTitle)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final landscape =
                constraints.maxWidth > constraints.maxHeight &&
                constraints.maxWidth >= 600;

            if (landscape) {
              return Padding(
                padding: const EdgeInsets.all(Dimensions.pagePadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _CameraView(
                        controller: _cameraController,
                        capturedImage: _capturedImage,
                        isLoading: _isProcessing,
                      ),
                    ),
                    const SizedBox(width: Dimensions.pagePadding),
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(child: controls),
                    ),
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
                    child: _CameraView(
                      controller: _cameraController,
                      capturedImage: _capturedImage,
                      isLoading: _isProcessing,
                    ),
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

class _ProcessingStatus extends StatelessWidget {
  const _ProcessingStatus({required this.message, required this.isProcessing});

  final String message;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    if (!isProcessing) return StatusRegion(message: message, large: true);

    return Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimensions.pagePadding),
        decoration: BoxDecoration(
          color: AppColors.of(context).surface,
          borderRadius: BorderRadius.circular(Dimensions.cornerRadius),
          border: Border.all(color: AppColors.of(context).outline),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(width: Dimensions.spacingBetweenTargets),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lugar de la vista de cámara. Se excluye de la semántica: no aporta
/// información al lector y obligaría a recorrer un elemento vacío.
class _CameraView extends StatelessWidget {
  const _CameraView({
    required this.controller,
    required this.capturedImage,
    required this.isLoading,
  });

  final CameraController? controller;
  final Uint8List? capturedImage;
  final bool isLoading;

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
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            if (capturedImage != null)
              Image.memory(capturedImage!, fit: BoxFit.contain)
            else if (controller?.value.isInitialized == true)
              CameraPreview(controller!)
            else
              Center(
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: 64,
                  color: tokens.onSurfaceVariant,
                ),
              ),
            if (isLoading)
              ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: Semantics(
                    label: 'Procesando tu imagen',
                    liveRegion: true,
                    child: const SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../core/accessibility/widgets/accessible_button.dart';
import '../../../core/accessibility/widgets/audio_controls.dart';
import '../../../core/accessibility/widgets/headings.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/theme/dimensions.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Importar archivo (UI.md §4.4a).
class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  AudioPlayer? _audioPlayer;
  bool _isProcessing = false;
  bool _isAudioPaused = false;
  String? _selectedFileName;

  Future<void> _pickAndAnalyze(List<String> extensions) async {
    if (_isProcessing) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    final file = result.files.single;
    final bytes = file.bytes!;
    setState(() => _isProcessing = true);
    try {
      final response = await _sendFile(
        bytes,
        file.name,
        _contentType(file.name),
      );
      if (response.statusCode != 200) {
        throw Exception('El backend respondió ${response.statusCode}.');
      }
      final player = _audioPlayer ??= AudioPlayer();
      await player.play(BytesSource(await response.stream.toBytes()));
      if (mounted) {
        setState(() {
          _isAudioPaused = false;
          _selectedFileName = file.name;
        });
      }
    } catch (error) {
      debugPrint('No fue posible analizar el archivo: $error');
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
    } else {
      await player.pause();
      if (mounted) setState(() => _isAudioPaused = true);
    }
  }

  Future<void> _stopAudio() async {
    final player = _audioPlayer;
    if (player == null) return;
    await player.stop();
    if (mounted) setState(() => _isAudioPaused = false);
  }

  Future<void> _analyzeAnotherFile() async {
    await _stopAudio();
    if (mounted) setState(() => _selectedFileName = null);
  }

  Future<http.StreamedResponse> _sendFile(
    Uint8List bytes,
    String filename,
    MediaType contentType,
  ) async {
    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse('http://localhost:3000/api/convertir'),
          )
          ..files.add(
            http.MultipartFile.fromBytes(
              'documento',
              bytes,
              filename: filename,
              contentType: contentType,
            ),
          );
    return request.send();
  }

  MediaType _contentType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return switch (extension) {
      'pdf' => MediaType('application', 'pdf'),
      'pptx' => MediaType(
        'application',
        'vnd.openxmlformats-officedocument.presentationml.presentation',
      ),
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      _ => MediaType('image', 'jpeg'),
    };
  }

  @override
  void dispose() {
    final player = _audioPlayer;
    if (player != null) player.dispose();
    super.dispose();
  }

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
                onPressed: () =>
                    _pickAndAnalyze(['jpg', 'jpeg', 'png', 'webp']),
              ),
              AccessibleButton(
                label: l10n.importPdf,
                icon: Icons.picture_as_pdf_outlined,
                size: AccessibleButtonSize.large,
                variant: AccessibleButtonVariant.secondary,
                expand: true,
                onPressed: () => _pickAndAnalyze(['pdf']),
              ),
              AccessibleButton(
                label: l10n.importPowerPoint,
                icon: Icons.slideshow_outlined,
                size: AccessibleButtonSize.large,
                variant: AccessibleButtonVariant.secondary,
                expand: true,
                onPressed: () => _pickAndAnalyze(['pptx']),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.pagePadding),
          Text(
            l10n.importMaxSize,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (_selectedFileName != null) ...[
            const SizedBox(height: Dimensions.spacingBetweenTargets),
            Semantics(
              liveRegion: true,
              child: Text(
                'Descripción lista para $_selectedFileName.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: Dimensions.spacingBetweenTargets),
            ResponsiveAudioControls(
              isPaused: _isAudioPaused,
              onToggle: _toggleAudio,
              onStop: _stopAudio,
            ),
            const SizedBox(height: Dimensions.spacingBetweenTargets),
            AccessibleButton(
              label: 'Analizar otro archivo',
              hint: 'Detiene el audio y permite elegir otro documento',
              icon: Icons.upload_file_outlined,
              variant: AccessibleButtonVariant.secondary,
              expand: true,
              onPressed: _analyzeAnotherFile,
            ),
          ],
        ],
      ),
    );
  }
}

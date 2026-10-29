import 'package:flutter/material.dart';

import 'accessible_button.dart';

class ResponsiveAudioControls extends StatelessWidget {
  const ResponsiveAudioControls({
    super.key,
    required this.isPaused,
    required this.onToggle,
    required this.onStop,
  });

  final bool isPaused;
  final VoidCallback onToggle;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AccessibleButton(
            label: isPaused ? 'Reanudar audio' : 'Pausar audio',
            hint: isPaused
                ? 'Continúa la descripción desde donde se pausó'
                : 'Pausa la descripción sin perder la posición',
            icon: isPaused ? Icons.play_arrow : Icons.pause,
            variant: AccessibleButtonVariant.secondary,
            expand: true,
            onPressed: onToggle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AccessibleButton(
            label: 'Detener audio',
            hint: 'Detiene la descripción completamente',
            icon: Icons.stop,
            variant: AccessibleButtonVariant.destructive,
            expand: true,
            onPressed: onStop,
          ),
        ),
      ],
    );
  }
}

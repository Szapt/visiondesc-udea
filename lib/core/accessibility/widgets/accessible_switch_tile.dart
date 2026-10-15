import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/core_providers.dart';
import '../haptic_service.dart';
import 'focus_ring.dart';

/// Interruptor con toda la fila táctil. El lector dice
/// "{título}, activado/desactivado" (rol `toggled`).
class AccessibleSwitchTile extends ConsumerWidget {
  const AccessibleSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FocusRing(
      child: SwitchListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        value: value,
        onChanged: onChanged == null
            ? null
            : (newValue) {
                unawaited(ref.read(hapticServiceProvider).play(HapticPattern.tap));
                onChanged!(newValue);
              },
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        minTileHeight: 56,
      ),
    );
  }
}

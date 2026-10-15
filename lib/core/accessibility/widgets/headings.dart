import 'package:flutter/material.dart';

/// Título de pantalla para el `AppBar`, marcado como encabezado.
///
/// El `AppBar` ya lo expone como nombre de la ruta (`namesRoute`), por lo
/// que TalkBack y VoiceOver lo anuncian al entrar en la pantalla.
/// [semanticLabel] permite una etiqueta más descriptiva que **empiece** con
/// el texto visible (p. ej. "VisionDesc, inicio").
class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.text, {super.key, this.semanticLabel});

  final String text;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: Text(text, maxLines: 2, softWrap: true, overflow: TextOverflow.visible),
    );
  }
}

/// Encabezado de sección (`header: true`) para navegar con el selector de
/// encabezados de TalkBack o el rotor de VoiceOver.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key, this.semanticLabel, this.padding});

  final String text;
  final String? semanticLabel;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 24, bottom: 8),
      child: Semantics(
        header: true,
        label: semanticLabel,
        excludeSemantics: semanticLabel != null,
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

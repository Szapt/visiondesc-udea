import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

/// Reproductor de las descripciones. [onComplete] se llama cuando el audio
/// termina solo, para que la pantalla cambie el botón a "Reanudar audio".
AudioPlayer createDescriptionPlayer({required void Function() onComplete}) =>
    AudioPlayer()..onPlayerComplete.listen((_) => onComplete());

extension DescriptionPlayback on AudioPlayer {
  /// Reproduce [audio] desde el inicio. Con `ReleaseMode.stop`, "Detener"
  /// conserva el audio cargado y "Reanudar" lo vuelve a empezar; con el modo
  /// por defecto se liberaría y "Reanudar" no sonaría.
  Future<void> playDescription(Uint8List audio) async {
    await setReleaseMode(ReleaseMode.stop);
    await play(BytesSource(audio));
  }
}

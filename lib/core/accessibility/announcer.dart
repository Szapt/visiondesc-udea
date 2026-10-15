import 'package:flutter/foundation.dart';

/// Envía mensajes de estado al lector de pantalla sin mover el foco
/// (WCAG 4.1.3).
///
/// Las pantallas solo conocen esta interfaz; en los tests se sustituye
/// por un `FakeAnnouncer` que registra los mensajes.
abstract interface class Announcer {
  void announce(String message);
}

/// Mensaje pendiente de anunciar. [id] cambia en cada anuncio para que
/// un mismo texto repetido también se anuncie.
@immutable
class Announcement {
  const Announcement(this.message, this.id);

  final String message;
  final int id;
}

/// Implementación que publica los mensajes para que `AnnouncementHost`
/// los entregue a la plataforma.
///
/// No llama directamente a `SemanticsService` porque necesita el
/// `FlutterView` y saber si la plataforma admite anuncios, y ambos
/// dependen del `BuildContext` (ver `AnnouncementHost`).
class QueuedAnnouncer extends ChangeNotifier implements Announcer {
  Announcement? _current;
  int _nextId = 0;

  Announcement? get current => _current;

  @override
  void announce(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;
    _current = Announcement(trimmed, _nextId++);
    notifyListeners();
  }
}

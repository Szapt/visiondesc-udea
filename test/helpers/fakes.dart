import 'dart:typed_data';

import 'package:visiondesc/core/accessibility/announcer.dart';
import 'package:visiondesc/core/accessibility/haptic_service.dart';
import 'package:visiondesc/features/history/domain/entities/history_entry.dart';
import 'package:visiondesc/features/history/domain/repositories/history_repository.dart';

/// Registra los anuncios para comprobarlos en los tests.
class FakeAnnouncer implements Announcer {
  final List<String> messages = [];

  @override
  void announce(String message) => messages.add(message);
}

/// Registra los patrones hápticos reproducidos.
class FakeHapticService implements HapticService {
  final List<HapticPattern> played = [];

  @override
  Future<void> play(HapticPattern pattern) async => played.add(pattern);
}

/// Historial en memoria; registra qué audios se pidieron.
class FakeHistoryRepository implements HistoryRepository {
  FakeHistoryRepository([List<HistoryEntry>? entries])
    : entries =
          entries ??
          [
            HistoryEntry(
              id: 2,
              createdAt: DateTime(2026, 10, 29, 9, 30),
              description: 'Diagrama de clases del sistema de pedidos con tres clases relacionadas.',
            ),
            HistoryEntry(
              id: 1,
              createdAt: DateTime(2026, 10, 28, 15),
              description: 'Tabla de formas normales.',
            ),
          ];

  final List<HistoryEntry> entries;
  final List<int> requestedAudio = [];

  @override
  Future<List<HistoryEntry>> fetchAll() async => entries;

  @override
  Future<Uint8List> fetchAudio(int id) async {
    requestedAudio.add(id);
    return Uint8List(0);
  }
}

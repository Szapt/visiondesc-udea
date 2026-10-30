import 'dart:typed_data';

import '../entities/history_entry.dart';

abstract interface class HistoryRepository {
  /// Consultas guardadas, de la más reciente a la más antigua.
  Future<List<HistoryEntry>> fetchAll();

  /// MP3 con la descripción de la consulta [id].
  Future<Uint8List> fetchAudio(int id);
}

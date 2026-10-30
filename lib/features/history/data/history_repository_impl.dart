import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../domain/entities/history_entry.dart';
import '../domain/repositories/history_repository.dart';

/// Lee el historial desde el backend, que lo guarda en Supabase.
class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 55);

  final String baseUrl;
  final http.Client _client;

  @override
  Future<List<HistoryEntry>> fetchAll() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/historial')).timeout(_timeout);
    _checkStatus(response);
    final rows = jsonDecode(utf8.decode(response.bodyBytes)) as List<Object?>;
    return [
      for (final row in rows.cast<Map<String, Object?>>())
        HistoryEntry(
          id: (row['id']! as num).toInt(),
          createdAt: DateTime.parse(row['creado']! as String).toLocal(),
          description: row['descripcion'] as String? ?? '',
        ),
    ];
  }

  @override
  Future<Uint8List> fetchAudio(int id) async {
    final response = await _client
        .get(Uri.parse('$baseUrl/api/historial/$id/audio'))
        .timeout(_timeout);
    _checkStatus(response);
    return response.bodyBytes;
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('El backend respondió ${response.statusCode}: ${response.body}');
    }
  }
}

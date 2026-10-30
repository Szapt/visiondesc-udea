/// Una consulta guardada en el historial: la descripción que generó la IA.
class HistoryEntry {
  const HistoryEntry({required this.id, required this.createdAt, required this.description});

  static const _maxTitleLength = 70;

  final int id;
  final DateTime createdAt;
  final String description;

  /// Inicio de la descripción, cortado en una palabra completa, para
  /// identificar la consulta en la lista.
  String get title {
    final text = description.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.length <= _maxTitleLength) return text;
    final cut = text.lastIndexOf(' ', _maxTitleLength);
    return '${text.substring(0, cut > 0 ? cut : _maxTitleLength)}…';
  }
}

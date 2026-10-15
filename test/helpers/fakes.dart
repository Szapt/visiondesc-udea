import 'package:visiondesc/core/accessibility/announcer.dart';
import 'package:visiondesc/core/accessibility/haptic_service.dart';

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

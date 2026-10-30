import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../data/history_repository_impl.dart';
import '../domain/entities/history_entry.dart';
import '../domain/repositories/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepositoryImpl(baseUrl: apiBaseUrl),
);

/// Se vuelve a pedir cada vez que se abre el historial, para incluir las
/// consultas hechas desde la última visita. Sin reintentos automáticos: la
/// pantalla anuncia el error y ofrece "Reintentar".
final historyEntriesProvider = FutureProvider.autoDispose<List<HistoryEntry>>(
  (ref) => ref.watch(historyRepositoryProvider).fetchAll(),
  retry: (_, _) => null,
);

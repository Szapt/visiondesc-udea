import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/capture/presentation/capture_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/pending_feature_screen.dart';
import '../../features/import/presentation/import_screen.dart';
import '../../features/result/presentation/result_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

/// Rutas de la app (ARQUITECTURA.md §3.3, UI.md §3).
abstract final class AppRoutes {
  static const home = '/';
  static const capture = '/capturar';
  static const importFile = '/importar';
  static const result = '/resultado';
  static const structure = '/resultado/estructura';
  static const chat = '/resultado/chat';
  static const history = '/historial';
  static const settings = '/ajustes';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.capture, builder: (context, state) => const CaptureScreen()),
      GoRoute(path: AppRoutes.importFile, builder: (context, state) => const ImportScreen()),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) => const ResultScreen(),
        routes: [
          GoRoute(
            path: 'estructura',
            builder: (context, state) =>
                const PendingFeatureScreen(feature: PendingFeature.structure),
          ),
          GoRoute(
            path: 'chat',
            builder: (context, state) => const PendingFeatureScreen(feature: PendingFeature.chat),
          ),
        ],
      ),
      GoRoute(path: AppRoutes.history, builder: (context, state) => const HistoryScreen()),
      GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

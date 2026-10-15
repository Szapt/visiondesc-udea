import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/accessibility/widgets/announcement_host.dart';
import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/presentation/settings_controller.dart';
import 'l10n/generated/app_localizations.dart';

/// Enlaza ajustes de la feature `settings` con providers de `core`, para que
/// `core` no dependa de las features.
final appProviderOverrides = [
  hapticsEnabledProvider.overrideWith(
    (ref) => ref.watch(settingsControllerProvider.select((s) => s.hapticsEnabled)),
  ),
];

class VisionDescApp extends ConsumerWidget {
  const VisionDescApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePreference = ref.watch(settingsControllerProvider.select((s) => s.themePreference));
    final router = ref.watch(appRouterProvider);
    final announcer = ref.watch(queuedAnnouncerProvider);

    // "Alto contraste" fuerza el tema propio. "Sistema" respeta claro/oscuro y,
    // si el sistema pide más contraste, usa también el de alto contraste.
    final (ThemeData light, ThemeData dark, ThemeMode mode) = switch (themePreference) {
      ThemePreference.sistema => (AppTheme.light(), AppTheme.dark(), ThemeMode.system),
      ThemePreference.claro => (AppTheme.light(), AppTheme.dark(), ThemeMode.light),
      ThemePreference.oscuro => (AppTheme.light(), AppTheme.dark(), ThemeMode.dark),
      ThemePreference.altoContraste => (
        AppTheme.highContrast(),
        AppTheme.highContrast(),
        ThemeMode.dark,
      ),
    };

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: light,
      darkTheme: dark,
      highContrastTheme: AppTheme.highContrast(),
      highContrastDarkTheme: AppTheme.highContrast(),
      themeMode: mode,
      // Los temas no se animan al cambiar: evita fotogramas con contrastes intermedios.
      themeAnimationDuration: Duration.zero,
      locale: const Locale('es', 'CO'),
      supportedLocales: const [Locale('es', 'CO'), Locale('es')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        Widget content = child ?? const SizedBox.shrink();
        if (MediaQuery.disableAnimationsOf(context)) {
          content = Theme(
            data: Theme.of(context).copyWith(pageTransitionsTheme: _noTransitions),
            child: content,
          );
        }
        return AnnouncementHost(announcer: announcer, child: content);
      },
    );
  }
}

/// Transiciones instantáneas cuando el sistema pide reducir el movimiento.
const _noTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: _InstantTransitionsBuilder(),
    TargetPlatform.iOS: _InstantTransitionsBuilder(),
  },
);

class _InstantTransitionsBuilder extends PageTransitionsBuilder {
  const _InstantTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}

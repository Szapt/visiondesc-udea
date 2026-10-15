import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:visiondesc/app.dart';
import 'package:visiondesc/core/providers/core_providers.dart';
import 'package:visiondesc/core/storage/key_value_store.dart';
import 'package:visiondesc/core/theme/app_theme.dart';
import 'package:visiondesc/features/settings/data/settings_repository_impl.dart';
import 'package:visiondesc/features/settings/domain/entities/app_settings.dart';
import 'package:visiondesc/l10n/generated/app_localizations.dart';

import 'fakes.dart';

/// Dependencias simuladas compartidas por los tests de widgets.
class TestDeps {
  TestDeps({AppSettings settings = const AppSettings()})
    : store = InMemoryKeyValueStore({
         SettingsRepositoryImpl.storageKey: jsonEncode(settings.toJson()),
       });

  final InMemoryKeyValueStore store;
  final announcer = FakeAnnouncer();
  final haptics = FakeHapticService();

  List<Override> get overrides => [
    keyValueStoreProvider.overrideWithValue(store),
    announcerProvider.overrideWithValue(announcer),
    hapticServiceProvider.overrideWithValue(haptics),
    ...appProviderOverrides,
  ];
}

/// Escala de texto y tema para las matrices de pruebas de accesibilidad.
enum TestTheme { claro, oscuro, altoContraste }

extension TestThemePreference on TestTheme {
  ThemePreference get preference => switch (this) {
    TestTheme.claro => ThemePreference.claro,
    TestTheme.oscuro => ThemePreference.oscuro,
    TestTheme.altoContraste => ThemePreference.altoContraste,
  };

  ThemeData get data => switch (this) {
    TestTheme.claro => AppTheme.light(),
    TestTheme.oscuro => AppTheme.dark(),
    TestTheme.altoContraste => AppTheme.highContrast(),
  };
}

extension PumpApp on WidgetTester {
  /// Monta la app completa (router, temas, anuncios) con dependencias simuladas.
  Future<void> pumpVisionDescApp(TestDeps deps, {double textScale = 1.0}) async {
    if (textScale != 1.0) {
      platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(platformDispatcher.clearTextScaleFactorTestValue);
    }
    await pumpWidget(ProviderScope(overrides: deps.overrides, child: const VisionDescApp()));
    await pumpAndSettle();
  }

  /// Monta un widget suelto con localización, tema y dependencias simuladas.
  Future<void> pumpAccessibleWidget(
    Widget child, {
    TestDeps? deps,
    TestTheme theme = TestTheme.claro,
    double textScale = 1.0,
  }) async {
    final effectiveDeps = deps ?? TestDeps();
    await pumpWidget(
      ProviderScope(
        overrides: effectiveDeps.overrides,
        child: MaterialApp(
          theme: theme.data,
          locale: const Locale('es', 'CO'),
          supportedLocales: const [Locale('es', 'CO'), Locale('es')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );
    await pumpAndSettle();
  }
}

/// Configura una pantalla de teléfono típico (360×800 dp).
void usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

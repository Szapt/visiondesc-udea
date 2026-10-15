import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/core_providers.dart';
import 'core/storage/key_value_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Los ajustes se cargan antes del primer fotograma para aplicar el tema
  // elegido (p. ej. alto contraste) sin parpadeos.
  final store = await SharedPreferencesStore.create();

  runApp(
    ProviderScope(
      overrides: [
        keyValueStoreProvider.overrideWithValue(store),
        ...appProviderOverrides,
      ],
      child: const VisionDescApp(),
    ),
  );
}

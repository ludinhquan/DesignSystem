import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'config/env.dart';
import 'core/http.dart';
import 'core/storage.dart';

/// Composition root: the only place that wires vendors and overrides.
///
/// Run with `flutter run --dart-define-from-file=config/brand_a.dev.json`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final app = ProviderScope(
    // The app's only retry policy; Dio has no retry interceptor.
    retry: retryPolicy,
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const App(),
  );

  if (Env.sentryDsn.isEmpty) return runApp(app);
  await SentryFlutter.init(
    (options) => options
      ..dsn = Env.sentryDsn
      ..environment = Env.name,
    appRunner: () => runApp(app),
  );
}

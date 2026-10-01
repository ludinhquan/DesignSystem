import 'package:app/app.dart';
import 'package:app/core/analytics.dart';
import 'package:app/core/http.dart';
import 'package:app/core/storage.dart';
import 'package:app/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records analytics calls as strings: `identify:<id>`, `track:<event>`, `reset`.
class FakeAnalytics implements Analytics {
  final calls = <String>[];

  @override
  void identify(String userId) => calls.add('identify:$userId');

  @override
  void track(String event, [Map<String, Object> props = const {}]) =>
      calls.add('track:$event');

  @override
  void reset() => calls.add('reset');
}

/// How long the fake login takes in tests, so the loading state is visible.
const fakeLoginDelay = Duration(milliseconds: 100);

/// Fresh in-memory shared_preferences and secure storage.
Future<SharedPreferences> setUpStorage({
  Map<String, Object> prefs = const {},
  Map<String, String> secure = const {},
}) {
  SharedPreferences.setMockInitialValues(prefs);
  FlutterSecureStorage.setMockInitialValues(Map.of(secure));
  return SharedPreferences.getInstance();
}

/// The overrides `main.dart` sets, plus fakes.
List<Override> testOverrides(
  SharedPreferences prefs,
  FakeAnalytics analytics,
) => [
  sharedPreferencesProvider.overrideWithValue(prefs),
  analyticsProvider.overrideWithValue(analytics),
  authRepositoryProvider.overrideWith(
    (ref) => FakeAuthRepository(
      ref.watch(tokenStoreProvider),
      delay: fakeLoginDelay,
    ),
  ),
];

/// Pumps the whole app (router, theme, l10n) with fakes and settles.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  FakeAnalytics? analytics,
  Map<String, Object> prefs = const {},
  Map<String, String> secure = const {},
}) async {
  final p = await setUpStorage(prefs: prefs, secure: secure);
  await tester.pumpWidget(
    ProviderScope(
      retry: retryPolicy,
      overrides: testOverrides(p, analytics ?? FakeAnalytics()),
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(App)));
}

/// Fills the login form and waits for the redirect.
Future<void> logIn(
  WidgetTester tester, {
  String email = 'lan@example.com',
  String password = 'secret',
}) async {
  await tester.enterText(find.byKey(const Key('login.email')), email);
  await tester.enterText(find.byKey(const Key('login.password')), password);
  await tester.tap(find.byKey(const Key('login.submit')));
  await tester.pumpAndSettle();
}

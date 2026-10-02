import 'package:app/app.dart';
import 'package:app/config/brand.dart';
import 'package:app/core/analytics.dart';
import 'package:app/core/clock.dart';
import 'package:app/core/http.dart';
import 'package:app/core/storage.dart';
import 'package:app/features/auth/data/auth_repository.dart';
import 'package:app/features/wallet/data/wallet_repository.dart';
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

/// How long the fakes take, so loading states are visible.
const fakeLoginDelay = Duration(milliseconds: 100);
const fakeWalletDelay = Duration(milliseconds: 50);

/// A fixed "now": a Friday morning.
final testNow = DateTime(2026, 10, 2, 9, 30);

/// Fresh in-memory shared_preferences and secure storage.
Future<SharedPreferences> setUpStorage({
  Map<String, Object> prefs = const {},
  Map<String, String> secure = const {},
}) {
  SharedPreferences.setMockInitialValues(prefs);
  FlutterSecureStorage.setMockInitialValues(Map.of(secure));
  return SharedPreferences.getInstance();
}

/// The overrides `main.dart` sets, plus fakes and a fixed clock.
List<Override> testOverrides(
  SharedPreferences prefs,
  FakeAnalytics analytics, {
  Brand? brand,
}) => [
  sharedPreferencesProvider.overrideWithValue(prefs),
  analyticsProvider.overrideWithValue(analytics),
  clockProvider.overrideWithValue(() => testNow),
  authRepositoryProvider.overrideWith(
    (ref) => FakeAuthRepository(
      ref.watch(tokenStoreProvider),
      delay: fakeLoginDelay,
    ),
  ),
  walletRepositoryProvider.overrideWith(
    (ref) => FakeWalletRepository(
      now: ref.watch(clockProvider),
      delay: fakeWalletDelay,
    ),
  ),
  if (brand != null) brandProvider.overrideWithValue(brand),
];

/// Pumps the whole app (router, theme, l10n) with fakes and settles.
///
/// Reduce Motion is on by default, so focused amount fields do not blink
/// forever under `pumpAndSettle`.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  FakeAnalytics? analytics,
  Map<String, Object> prefs = const {},
  Map<String, String> secure = const {},
  Brand? brand,
  bool reduceMotion = true,
}) async {
  if (reduceMotion) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final p = await setUpStorage(prefs: prefs, secure: secure);
  await tester.pumpWidget(
    ProviderScope(
      retry: retryPolicy,
      overrides: testOverrides(p, analytics ?? FakeAnalytics(), brand: brand),
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(App)));
}

/// Fills the login form and waits for the redirect and the wallet.
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

/// Taps a tab of the floating tab bar by its label.
Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(find.bySemanticsLabel(label).last);
  await tester.pumpAndSettle();
}

import 'package:app/core/http.dart';
import 'package:app/core/storage.dart';
import 'package:app/features/auth/data/session.dart';
import 'package:app/features/auth/data/session_controller.dart';
import 'package:app/features/home/ui/tap_count_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAnalytics analytics;

  Future<ProviderContainer> container({
    Map<String, String> secure = const {},
  }) async {
    analytics = FakeAnalytics();
    final prefs = await setUpStorage(secure: secure);
    return ProviderContainer.test(overrides: testOverrides(prefs, analytics));
  }

  const lan = Session(
    userId: 'fake-lan@example.com',
    email: 'lan@example.com',
    name: 'lan',
  );

  test('restore: no stored token -> logged out', () async {
    final c = await container();
    expect(await c.read(sessionProvider.future), isNull);
  });

  test('restore: stored token -> the stored user', () async {
    final c = await container(
      secure: {
        'auth.access_token': 'fake-access:lan@example.com',
        'auth.refresh_token': 'fake-refresh',
      },
    );
    expect(await c.read(sessionProvider.future), lan);
  });

  test(
    'login stores tokens, identifies the user and sets the session',
    () async {
      final c = await container();
      await c.read(sessionProvider.future);

      await c
          .read(sessionProvider.notifier)
          .login(email: 'lan@example.com', password: 'x');

      expect(c.read(sessionProvider).value, lan);
      expect(
        (await c.read(tokenStoreProvider).read())?.access,
        'fake-access:lan@example.com',
      );
      expect(analytics.calls, ['identify:fake-lan@example.com', 'track:login']);
    },
  );

  test('rejected login throws and leaves the state logged out', () async {
    final c = await container();
    await c.read(sessionProvider.future);

    await expectLater(
      c
          .read(sessionProvider.notifier)
          .login(email: 'lan@example.com', password: 'wrong'),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(c.read(sessionProvider), const AsyncData<Session?>(null));
    expect(await c.read(tokenStoreProvider).read(), isNull);
  });

  test(
    'logout clears tokens, resets analytics and sets AsyncData(null)',
    () async {
      final c = await container();
      await c.read(sessionProvider.future);
      await c
          .read(sessionProvider.notifier)
          .login(email: 'lan@example.com', password: 'x');
      analytics.calls.clear();

      await c.read(sessionProvider.notifier).logout();

      expect(c.read(sessionProvider), const AsyncData<Session?>(null));
      expect(await c.read(tokenStoreProvider).read(), isNull);
      expect(analytics.calls, ['track:logout', 'reset']);
    },
  );

  test('logout resets per-user providers', () async {
    final c = await container();
    await c.read(sessionProvider.future);
    await c
        .read(sessionProvider.notifier)
        .login(email: 'lan@example.com', password: 'x');
    final sub = c.listen(tapCountProvider, (_, _) {});
    c.read(tapCountProvider.notifier)
      ..increment()
      ..increment();
    expect(sub.read(), 2);

    await c.read(sessionProvider.notifier).logout();
    expect(c.read(tapCountProvider), 0);
  });

  test('a rejected token refresh logs the user out', () async {
    final c = await container();
    await c.read(sessionProvider.future);
    await c
        .read(sessionProvider.notifier)
        .login(email: 'lan@example.com', password: 'x');

    c.read(sessionExpiryProvider).notify();
    await pumpEventQueue();

    expect(c.read(sessionProvider), const AsyncData<Session?>(null));
    expect(analytics.calls, contains('reset'));
  });
}

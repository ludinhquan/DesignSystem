import 'package:app/core/router.dart';
import 'package:app/features/auth/data/session.dart';
import 'package:app/features/auth/data/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const user = Session(userId: '1', email: 'lan@example.com', name: 'Lan');
  const loading = AsyncLoading<Session?>();
  const loggedOut = AsyncData<Session?>(null);
  const loggedIn = AsyncData<Session?>(user);

  String? go(AsyncValue<Session?> s, String location) =>
      authRedirect(s, Uri.parse(location));

  group('while restoring', () {
    test('any page waits on the splash, keeping the target', () {
      expect(go(loading, '/'), '/splash');
      expect(go(loading, '/orders/7'), '/splash?from=%2Forders%2F7');
      expect(go(loading, '/splash?from=%2Forders%2F7'), isNull);
    });
  });

  group('logged out', () {
    test('a protected page goes to /login?from=<path>', () {
      expect(
        go(loggedOut, '/orders/7?tab=items'),
        '/login?from=%2Forders%2F7%3Ftab%3Ditems',
      );
    });

    test('home goes to /login without from', () {
      expect(go(loggedOut, '/'), '/login');
    });

    test('the splash hands its target over to login', () {
      expect(
        go(loggedOut, '/splash?from=%2Forders%2F7'),
        '/login?from=%2Forders%2F7',
      );
    });

    test('/login stays', () {
      expect(go(loggedOut, '/login?from=%2Forders'), isNull);
    });

    test('a failed restore counts as logged out', () {
      expect(
        go(AsyncError<Session?>(Exception('x'), StackTrace.empty), '/'),
        '/login',
      );
    });
  });

  group('logged in', () {
    test('/login returns to from', () {
      expect(go(loggedIn, '/login?from=%2Forders%2F7'), '/orders/7');
    });

    test('/login without from goes home', () {
      expect(go(loggedIn, '/login'), '/');
      expect(go(loggedIn, '/splash'), '/');
    });

    test('from must be a path inside the app', () {
      expect(go(loggedIn, '/login?from=https%3A%2F%2Fevil.com'), '/');
      expect(go(loggedIn, '/login?from=%2F%2Fevil.com'), '/');
      expect(go(loggedIn, '/login?from=%2Flogin'), '/');
    });

    test('protected pages stay', () {
      expect(go(loggedIn, '/'), isNull);
      expect(go(loggedIn, '/orders/7'), isNull);
    });

    test(
      'refreshing (loading with a value) does not bounce to the splash',
      () async {
        final prefs = await setUpStorage(
          secure: {
            'auth.access_token': 'fake-access:lan@example.com',
            'auth.refresh_token': 'fake-refresh',
          },
        );
        final c = ProviderContainer.test(
          overrides: testOverrides(prefs, FakeAnalytics()),
        );
        await c.read(sessionProvider.future);
        c.invalidate(sessionProvider);
        final refreshing = c.read(sessionProvider);

        expect(refreshing.isLoading && refreshing.hasValue, isTrue);
        expect(authRedirect(refreshing, Uri.parse('/')), isNull);
      },
    );
  });
}

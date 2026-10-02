import 'package:app/config/brands/brand_b.dart';
import 'package:app/features/auth/auth_routes.dart';
import 'package:app/features/auth/ui/login_screen.dart';
import 'package:ds/ds.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/harness.dart';

void main() {
  String location(WidgetTester tester) =>
      GoRouter.of(tester.element(find.byType(Scaffold).first))
          .routeInformationProvider
          .value
          .uri
          .toString();

  testWidgets('a fresh install starts at login, drawn in Pebble', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(location(tester), AuthPaths.login);
    expect(find.text('Sign in to Pebble'), findsOneWidget);
    final theme = Theme.of(tester.element(find.byType(LoginScreen)));
    expect(theme.extension<DsTokens>()!.system.name, 'Pebble');
  });

  testWidgets('a stored session skips login on restart', (tester) async {
    await pumpApp(
      tester,
      secure: {
        'auth.access_token': 'fake-access:lan@example.com',
        'auth.refresh_token': 'fake-refresh',
      },
    );
    expect(location(tester), '/');
    expect(find.text('Total balance'), findsOneWidget);
  });

  testWidgets('brand B is the same app in the Classic design system', (
    tester,
  ) async {
    await pumpApp(tester, brand: brandB);
    expect(find.text('Sign in to Acme'), findsOneWidget);
    final theme = Theme.of(tester.element(find.byType(LoginScreen)));
    expect(theme.extension<DsTokens>()!.system, same(classic));

    await logIn(tester);
    expect(find.text('Total balance'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

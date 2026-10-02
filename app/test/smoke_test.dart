import 'package:app/features/auth/auth_routes.dart';
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

  testWidgets('a fresh install starts at login', (tester) async {
    await pumpApp(tester);
    expect(location(tester), AuthPaths.login);
    expect(find.text('Sign in to Acme'), findsOneWidget);
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
    expect(find.text('Welcome to Acme, lan!'), findsOneWidget);
  });
}

import 'package:ds_components/ds_components.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetbook_app/main.dart';

void main() {
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first
      ..physicalSize = const Size(1600, 1000)
      ..devicePixelRatio = 1;
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first.reset();
  });

  testWidgets('catalog lists every component', (tester) async {
    await tester.pumpWidget(const WidgetbookApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('AppButton'), findsOneWidget);
    expect(find.text('AppCard'), findsOneWidget);
  });

  for (final component in ['AppButton', 'AppCard']) {
    testWidgets('$component use case renders with the design-system theme', (
      tester,
    ) async {
      await tester.pumpWidget(const WidgetbookApp());
      await tester.pumpAndSettle();

      // Components with a single use case are leaves: tapping opens it.
      await tester.tap(find.text(component));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final finder = component == 'AppButton'
          ? find.byType(AppButton)
          : find.byType(AppCard);
      expect(finder, findsOneWidget);
      // context.colors throws if the material_ui Theme is missing.
      expect(tester.element(finder).colors.primary, AppColors.light.primary);
    });
  }
}

import 'package:ds_components/ds_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

Color? _backgroundOf(WidgetTester tester) {
  return tester
      .widget<Material>(
        find.descendant(
          of: find.byType(TextButton),
          matching: find.byType(Material),
        ),
      )
      .color;
}

void main() {
  group('AppButton', () {
    testWidgets('renders its label and calls onPressed', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        AppButton.primary(label: 'Save', onPressed: () => taps++),
      );

      expect(find.text('Save'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(taps, 1);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpApp(
        const AppButton.primary(label: 'Save', onPressed: null),
      );

      expect(tester.widget<TextButton>(find.byType(TextButton)).enabled, false);
      expect(_backgroundOf(tester), AppColors.light.disabledBackground);
    });

    testWidgets('ignores taps and shows a spinner while loading', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        AppButton.primary(
          label: 'Save',
          isLoading: true,
          onPressed: () => taps++,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(AppButton), warnIfMissed: false);
      expect(taps, 0);
      // Loading keeps the variant colour rather than looking disabled.
      expect(_backgroundOf(tester), AppColors.light.primary);
    });

    testWidgets('variants read their colours from the theme', (tester) async {
      await tester.pumpApp(
        AppButton.primary(label: 'Save', onPressed: () {}),
        theme: AppTheme.dark(),
      );
      expect(_backgroundOf(tester), AppColors.dark.primary);

      await tester.pumpApp(
        AppButton.secondary(label: 'Save', onPressed: () {}),
        theme: AppTheme.dark(),
      );
      expect(_backgroundOf(tester), AppColors.dark.surface);
    });

    for (final size in AppButtonSize.values) {
      testWidgets('size ${size.name} has a >= 48x48 tap target', (
        tester,
      ) async {
        await tester.pumpApp(
          AppButton.ghost(label: 'Go', size: size, onPressed: () {}),
        );
        final box = tester.getSize(find.byType(TextButton));
        expect(box.height, greaterThanOrEqualTo(48));
        expect(box.width, greaterThanOrEqualTo(48));
      });
    }

    testWidgets('grows with the text scale', (tester) async {
      await tester.pumpApp(AppButton.primary(label: 'Save', onPressed: () {}));
      final normal = tester.getSize(find.byType(TextButton));

      await tester.pumpApp(
        AppButton.primary(label: 'Save', onPressed: () {}),
        textScale: 2,
      );
      final large = tester.getSize(find.byType(TextButton));
      expect(large.width, greaterThan(normal.width));
    });

    testWidgets('semanticLabel overrides the announced label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        AppButton.primary(
          label: 'Save',
          semanticLabel: 'Save document',
          onPressed: () {},
        ),
      );
      expect(find.bySemanticsLabel('Save document'), findsOneWidget);
      handle.dispose();
    });

    for (final (name, theme) in [
      ('light', AppTheme.light),
      ('dark', AppTheme.dark),
    ]) {
      testWidgets('meets accessibility guidelines ($name)', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpApp(
          Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final variant in AppButtonVariant.values)
                  for (final size in AppButtonSize.values)
                    AppButton(
                      label: '${variant.name} ${size.name}',
                      variant: variant,
                      size: size,
                      onPressed: () {},
                    ),
              ],
            ),
          ),
          theme: theme(),
        );

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }
  });
}

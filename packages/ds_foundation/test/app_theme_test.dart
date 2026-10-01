import 'package:ds_foundation/ds_foundation.dart';
import 'package:ds_tokens/ds_tokens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AppTheme', () {
    test('light() maps semantic tokens onto ColorScheme', () {
      final theme = AppTheme.light();
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, ColorTokens.light.primary);
      expect(theme.colorScheme.onPrimary, ColorTokens.light.onPrimary);
      expect(theme.colorScheme.error, ColorTokens.light.danger);
      expect(theme.colorScheme.surface, ColorTokens.light.surface);
      expect(theme.scaffoldBackgroundColor, ColorTokens.light.background);
    });

    test('dark() maps semantic tokens onto ColorScheme', () {
      final theme = AppTheme.dark();
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, ColorTokens.dark.primary);
      expect(theme.colorScheme.onSurface, ColorTokens.dark.textPrimary);
    });

    test('maps the type scale onto TextTheme', () {
      final theme = AppTheme.light();
      expect(
        theme.textTheme.bodyLarge?.fontSize,
        TypographyTokens.body.fontSize,
      );
      expect(
        theme.textTheme.labelLarge?.fontWeight,
        TypographyTokens.label.fontWeight,
      );
    });

    for (final (name, build) in [
      ('light', AppTheme.light),
      ('dark', AppTheme.dark),
    ]) {
      test('$name() registers every ThemeExtension', () {
        final theme = build();
        expect(theme.extension<AppColors>(), isNotNull);
        expect(theme.extension<AppSpacing>(), AppSpacing.standard);
        expect(theme.extension<AppRadius>(), AppRadius.standard);
        expect(theme.extension<AppTypography>(), AppTypography.standard);
      });
    }
  });

  group('ThemeExtensions', () {
    test('AppColors.lerp interpolates between modes', () {
      final mid = AppColors.light.lerp(AppColors.dark, 0.5);
      expect(
        mid.primary,
        Color.lerp(ColorTokens.light.primary, ColorTokens.dark.primary, 0.5),
      );
      expect(
        AppColors.light.lerp(AppColors.dark, 0).primary,
        ColorTokens.light.primary,
      );
      expect(
        AppColors.light.lerp(AppColors.dark, 1).primary,
        ColorTokens.dark.primary,
      );
      expect(AppColors.light.lerp(null, 0.5), same(AppColors.light));
    });

    test('AppColors.copyWith overrides a single value', () {
      const brand = Color(0xFF7C3AED);
      final copy = AppColors.light.copyWith(primary: brand);
      expect(copy.primary, brand);
      expect(copy.surface, AppColors.light.surface);
    });

    test('AppSpacing copyWith / lerp', () {
      final dense = AppSpacing.standard.copyWith(md: SpaceTokens.sm);
      expect(dense.md, SpaceTokens.sm);
      expect(dense.lg, SpaceTokens.lg);
      final mid = AppSpacing.standard.lerp(dense, 0.5);
      expect(mid.md, (SpaceTokens.md + SpaceTokens.sm) / 2);
    });

    test('AppRadius copyWith / lerp', () {
      final square = AppRadius.standard.copyWith(md: RadiusTokens.none);
      expect(square.md, RadiusTokens.none);
      expect(AppRadius.standard.lerp(square, 1).md, RadiusTokens.none);
    });

    test('AppTypography copyWith / lerp', () {
      final big = AppTypography.standard.copyWith(body: TypographyTokens.title);
      expect(big.body, TypographyTokens.title);
      expect(
        AppTypography.standard.lerp(big, 1).body.fontSize,
        TypographyTokens.title.fontSize,
      );
    });
  });

  group('BuildContext accessors', () {
    testWidgets('read the extensions from the nearest Theme', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        Theme(
          data: AppTheme.dark(),
          child: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured.colors.primary, ColorTokens.dark.primary);
      expect(captured.spacing.md, SpaceTokens.md);
      expect(captured.radius.lg, RadiusTokens.lg);
      expect(captured.typography.body, TypographyTokens.body);
    });

    testWidgets('throw a helpful error when the theme is missing', (
      tester,
    ) async {
      late BuildContext captured;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
      );
      expect(() => captured.colors, throwsA(isA<FlutterError>()));
    });
  });
}

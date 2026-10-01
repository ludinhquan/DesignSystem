import 'package:ds_components/ds_components.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_cases/app_button_use_case.dart';
import 'use_cases/app_card_use_case.dart';

void main() => runApp(const WidgetbookApp());

/// The design-system catalog. Deploy with `flutter build web`.
class WidgetbookApp extends StatelessWidget {
  /// Creates the catalog.
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook(
      // Use cases run inside a package:material_ui MaterialApp so that the
      // design-system ThemeExtensions resolve (Widgetbook's own
      // `Widgetbook.material` / `MaterialThemeAddon` use flutter/material).
      appBuilder: (context, child) =>
          MaterialApp(debugShowCheckedModeBanner: false, home: child),
      addons: [
        ThemeAddon<ThemeData>(
          themes: [
            WidgetbookTheme(name: 'Light', data: AppTheme.light()),
            WidgetbookTheme(name: 'Dark', data: AppTheme.dark()),
          ],
          themeBuilder: (context, theme, child) => Theme(
            data: theme,
            child: Builder(
              builder: (context) =>
                  Material(color: context.colors.background, child: child),
            ),
          ),
        ),
        TextScaleAddon(),
        AlignmentAddon(),
      ],
      directories: [
        WidgetbookFolder(
          name: 'Components',
          children: [
            WidgetbookComponent(
              name: 'AppButton',
              useCases: [
                WidgetbookUseCase(
                  name: 'Playground',
                  builder: appButtonUseCase,
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'AppCard',
              useCases: [
                WidgetbookUseCase(name: 'Playground', builder: appCardUseCase),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

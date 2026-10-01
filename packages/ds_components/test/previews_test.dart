import 'package:ds_components/src/previews.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Keeps the `@Preview` functions compiling and rendering without errors.
void main() {
  final previews = <String, Widget Function()>{
    'AppButton': appButtonPreview,
    'AppCard': appCardPreview,
  };
  final wrappers = <String, Widget Function(Widget)>{
    'light': lightThemeWrapper,
    'dark': darkThemeWrapper,
  };

  for (final preview in previews.entries) {
    for (final wrapper in wrappers.entries) {
      testWidgets('${preview.key} preview renders (${wrapper.key})', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: wrapper.value(preview.value())),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}

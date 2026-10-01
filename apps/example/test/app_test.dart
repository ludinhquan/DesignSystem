import 'package:ds_components/ds_components.dart';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows the components', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Buttons'), findsOneWidget);
    expect(find.byType(AppButton), findsWidgets);
    expect(find.byType(AppCard), findsNWidgets(2));
  });

  testWidgets('toggles between light and dark themes', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    BuildContext ctx() => tester.element(find.byType(GalleryPage));

    expect(Theme.of(ctx()).brightness, Brightness.light);
    expect(ctx().colors.background, AppColors.light.background);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(Theme.of(ctx()).brightness, Brightness.dark);
    expect(ctx().colors.background, AppColors.dark.background);
  });

  testWidgets('tapping a card updates its counter', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.tap(find.text('Tappable card'));
    await tester.pump();
    expect(find.text('Tapped 1 times'), findsOneWidget);
  });
}

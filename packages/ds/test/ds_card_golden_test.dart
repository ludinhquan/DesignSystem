import 'package:alchemist/alchemist.dart';
import 'package:ds/ds.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/themed.dart';

void main() {
  const themes = <String, ThemeData Function([DsBrand])>{
    'light': DsTheme.light,
    'dark': DsTheme.dark,
  };

  for (final MapEntry(key: name, value: theme) in themes.entries) {
    goldenTest(
      'DsCard ($name)',
      fileName: 'ds_card_$name',
      builder: () => themed(
        theme(),
        GoldenTestGroup(
          children: [
            GoldenTestScenario(
              name: 'static',
              child: const SizedBox(width: 240, child: _CardBody()),
            ),
            GoldenTestScenario(
              name: 'tappable, sharp brand',
              child: Theme(
                data: theme(const DsBrand(radius: DsRadiusScale.r1)),
                child: const SizedBox(width: 240, child: _CardBody(tap: true)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({this.tap = false});
  final bool tap;

  @override
  Widget build(BuildContext context) => DsCard(
    onTap: tap ? () {} : null,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Title', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: context.ds.spacing.xs),
        Text('Supporting text', style: TextStyle(color: context.ds.textMuted)),
      ],
    ),
  );
}

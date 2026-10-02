import 'package:alchemist/alchemist.dart';
import 'package:ds/ds.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/themed.dart';

void main() {
  final themes = {'light': DsTheme.light(), 'dark': DsTheme.dark()};

  for (final MapEntry(key: name, value: theme) in themes.entries) {
    goldenTest(
      'DsButton ($name)',
      fileName: 'ds_button_$name',
      // The spinner never settles; pump a fixed amount instead.
      pumpBeforeTest: pumpNTimes(2, const Duration(milliseconds: 250)),
      builder: () => themed(theme, _matrix()),
    );
  }
}

Widget _matrix() {
  void noop() {}
  return GoldenTestGroup(
    columns: 3,
    children: [
      for (final v in DsButtonVariant.values) ...[
        GoldenTestScenario(
          name: '${v.name} enabled',
          child: DsButton(label: 'Label', variant: v, onPressed: noop),
        ),
        GoldenTestScenario(
          name: '${v.name} disabled',
          child: DsButton(label: 'Label', variant: v, onPressed: null),
        ),
        GoldenTestScenario(
          name: '${v.name} loading',
          child: DsButton(
            label: 'Label',
            variant: v,
            loading: true,
            onPressed: noop,
          ),
        ),
      ],
      for (final s in DsButtonSize.values)
        GoldenTestScenario(
          name: 'size ${s.name}',
          child: DsButton(
            label: 'Label',
            size: s,
            icon: Icons.add,
            onPressed: noop,
          ),
        ),
    ],
  );
}

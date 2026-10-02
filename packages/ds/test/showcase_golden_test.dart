import 'package:alchemist/alchemist.dart';
import 'package:ds/ds.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/showcase.dart';
import 'helpers/themed.dart';

/// Every component group × every design system × light and dark. A new
/// system added to [systems] gets a full visual baseline from this file.
void main() {
  for (final MapEntry(key: name, value: system) in systems.entries) {
    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';
      for (final MapEntry(key: group, value: build)
          in Showcase.groups.entries) {
        goldenTest(
          '$group ($name, $mode)',
          fileName: '${name}_${mode}_$group',
          // Spinners never settle: pump a fixed time instead.
          pumpBeforeTest: pumpNTimes(12, const Duration(milliseconds: 100)),
          builder: () => themed(
            dark ? DsTheme.dark(system) : DsTheme.light(system),
            SizedBox(width: 390, child: build()),
          ),
        );
      }
    }
  }
}

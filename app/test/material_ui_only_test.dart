import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// material_ui and the in-SDK Material library define different `Theme`,
/// `ThemeData` and `MaterialLocalizations` types, so mixing them silently
/// breaks theme and l10n lookup. This guards the whole workspace.
void main() {
  test('no Dart file imports flutter/material or flutter/cupertino', () {
    final banned = RegExp(
      r'''^\s*(import|export)\s+['"]package:flutter/(material|cupertino)\.dart['"]''',
      multiLine: true,
    );
    final offenders = [
      for (final dir in [
        'lib',
        'test',
        '../packages/ds/lib',
        '../packages/ds/test',
      ])
        for (final file in Directory(dir).listSync(recursive: true))
          if (file is File &&
              file.path.endsWith('.dart') &&
              !file.path.contains('/l10n/gen/') &&
              banned.hasMatch(file.readAsStringSync()))
            file.path,
    ];
    expect(offenders, isEmpty);
  });
}

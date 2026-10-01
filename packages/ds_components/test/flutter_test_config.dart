import 'dart:async';

import 'package:alchemist/alchemist.dart';

/// Runs every test in this package with CI-mode (platform-agnostic) goldens:
/// text is drawn as blocks so the PNGs are identical on macOS, Linux and
/// Windows. Platform goldens are disabled to avoid font-rendering diffs.
Future<void> testExecutable(FutureOr<void> Function() testMain) {
  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: false),
      ciGoldensConfig: CiGoldensConfig(enabled: true),
    ),
    run: () async => testMain(),
  );
}

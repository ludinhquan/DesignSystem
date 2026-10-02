import 'dart:async';

import 'package:alchemist/alchemist.dart';

/// CI-mode goldens only: text renders as blocks, so the PNGs are identical on
/// macOS, Linux and Windows.
Future<void> testExecutable(FutureOr<void> Function() testMain) {
  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: false),
      ciGoldensConfig: CiGoldensConfig(enabled: true),
    ),
    run: () async => testMain(),
  );
}

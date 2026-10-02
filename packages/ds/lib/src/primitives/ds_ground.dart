import 'package:flutter/widgets.dart';

import '../theme/ds_tokens.dart';

/// What a component sits on. Sheets set [DsGround.sheet], so the groups and
/// fields inside them use `surface-3` without being told.
enum DsGround {
  canvas,
  sheet;

  static DsGround of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DsGroundScope>()?.ground ??
      DsGround.canvas;

  /// The fill for chrome (fields, groups, panels) on this ground.
  static Color chrome(BuildContext context) => switch (of(context)) {
    DsGround.canvas => context.ds.colors.surface,
    DsGround.sheet => context.ds.colors.surface3,
  };

  /// The ground colour itself (rings around dots, gaps around focus).
  static Color color(BuildContext context) => switch (of(context)) {
    DsGround.canvas => context.ds.colors.canvas,
    DsGround.sheet => context.ds.colors.surface2,
  };
}

class DsGroundScope extends InheritedWidget {
  const DsGroundScope({required this.ground, required super.child, super.key});

  final DsGround ground;

  @override
  bool updateShouldNotify(DsGroundScope old) => old.ground != ground;
}

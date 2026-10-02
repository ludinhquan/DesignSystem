import 'package:flutter/widgets.dart';

import '../tokens/primitives.dart';

/// The brand-specific inputs to the design system.
///
/// Everything else (surfaces, text colors, dark mode) is derived from these
/// by [DsTheme](ds_theme.dart).
@immutable
class DsBrand {
  const DsBrand({
    this.primary = DsPalette.blue600,
    this.fontFamily,
    this.radius = DsRadiusScale.r3,
  });

  /// Seed and primary color.
  final Color primary;

  /// Font family bundled by the app (null = platform default).
  final String? fontFamily;

  /// Base control radius; card and chip radii are derived from it.
  final double radius;
}

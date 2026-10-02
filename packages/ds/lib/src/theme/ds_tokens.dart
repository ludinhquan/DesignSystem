import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/ds_colors.dart';
import '../foundation/ds_icons.dart';
import '../foundation/ds_metrics.dart';
import '../foundation/ds_motion.dart';
import '../foundation/ds_shadows.dart';
import '../foundation/ds_system.dart';
import '../foundation/ds_type.dart';
import '../systems/pebble/pebble.dart';

/// The one design-system [ThemeExtension]: a [DsSystem] resolved for one
/// brightness and platform. Components read only this.
///
/// Read it with `context.ds`.
@immutable
class DsTokens extends ThemeExtension<DsTokens> {
  DsTokens(this.system, this.brightness, {TargetPlatform? platform})
    : colors = brightness == Brightness.light
          ? system.tokens.colorsLight
          : system.tokens.colorsDark,
      shadows = brightness == Brightness.light
          ? system.tokens.shadowsLight
          : system.tokens.shadowsDark,
      text = DsTypography(
        system.tokens.type,
        system.fonts,
        platform ?? defaultTargetPlatform,
      );

  const DsTokens._(
    this.system,
    this.brightness,
    this.colors,
    this.shadows,
    this.text,
  );

  final DsSystem system;
  final Brightness brightness;
  final DsColors colors;
  final DsShadows shadows;

  /// Every type role resolved to a [TextStyle] (no colour).
  final DsTypography text;

  DsSpacing get spacing => system.tokens.spacing;
  DsRadii get radius => system.tokens.radii;
  DsSizes get size => system.tokens.sizes;
  DsOpacities get opacity => system.tokens.opacity;
  DsMotion get motion => system.motion;
  DsIconSet get icons => system.icons;
  bool get isDark => brightness == Brightness.dark;

  /// A rounded shape in the system's corner geometry.
  OutlinedBorder shape(double radius, {BorderSide? side}) =>
      system.shape(BorderRadius.circular(radius), side: side);

  @override
  DsTokens copyWith({DsSystem? system, Brightness? brightness}) =>
      DsTokens(system ?? this.system, brightness ?? this.brightness);

  /// Colours animate between themes; everything else switches halfway.
  @override
  DsTokens lerp(DsTokens? other, double t) {
    if (other == null || identical(this, other)) return this;
    final near = t < 0.5 ? this : other;
    return DsTokens._(
      near.system,
      near.brightness,
      colors.lerp(other.colors, t),
      near.shadows,
      near.text,
    );
  }
}

/// `context.ds.colors.text1`, `context.ds.text.body`, `context.ds.spacing.s4`
extension DsContext on BuildContext {
  DsTokens get ds {
    final tokens = Theme.of(this).extension<DsTokens>();
    assert(
      tokens != null,
      'No DsTokens in the theme. Use DsTheme.light/dark(system) as the '
      'MaterialApp theme (in tests and previews: DsTheme.light(pebble)).',
    );
    return tokens ?? DsTokens(pebble, Brightness.light);
  }

  /// Reduce Motion is on: replace movement with short fades.
  bool get dsReduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;
}

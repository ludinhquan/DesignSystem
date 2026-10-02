import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../foundation/ds_icons.dart';
import '../foundation/ds_shadows.dart';
import '../primitives/ds_box.dart';
import '../primitives/ds_glyph.dart';
import '../primitives/ds_ground.dart';
import '../primitives/ds_pressable.dart';
import '../theme/ds_tokens.dart';

/// Ground of a [DsIconButton].
enum DsIconButtonVariant {
  /// On canvas (Home header).
  surface,

  /// Over content or objects. Never glass on glass.
  glass,

  /// Inside sheets (close).
  soft,

  /// In an inline navigation bar (back, more).
  plain,
}

/// A `hit-target` disc holding one glyph. [label] is required: it is the
/// accessible name.
class DsIconButton extends StatelessWidget {
  const DsIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.variant = DsIconButtonVariant.surface,
    this.badge = false,
    super.key,
  });

  final DsIcon icon;
  final String label;
  final VoidCallback? onPressed;
  final DsIconButtonVariant variant;

  /// A small accent dot for unread items.
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final c = ds.colors;
    final d = ds.size.hitTarget;
    const shape = CircleBorder();
    Widget disc(bool pressed) => switch (variant) {
      DsIconButtonVariant.surface => DsBox(
        shape: shape,
        color: c.surface,
        shadow: ds.shadows.surface,
      ),
      DsIconButtonVariant.glass => ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DsBox(shape: shape, color: c.glass, shadow: ds.shadows.glass),
        ),
      ),
      DsIconButtonVariant.soft => DsBox(
        shape: shape,
        color: c.fillSubtle,
        shadow: DsShadow.none,
      ),
      DsIconButtonVariant.plain => const SizedBox.shrink(),
    };

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      child: DsPressable(
        onTap: onPressed,
        scale: ds.motion.pressScaleTile,
        focusShape: shape,
        builder: (context, state) => SizedBox.square(
          dimension: d,
          child: Stack(
            fit: StackFit.expand,
            children: [
              disc(state.pressed),
              Center(child: DsGlyph(icon, color: c.text1)),
              if (badge)
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: c.accent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: variant == DsIconButtonVariant.surface
                            ? c.surface
                            : DsGround.color(context),
                        width: 1.5,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

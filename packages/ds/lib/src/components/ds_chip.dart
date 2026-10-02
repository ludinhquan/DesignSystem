import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../foundation/ds_icons.dart';
import '../foundation/ds_shadows.dart';
import '../primitives/ds_box.dart';
import '../primitives/ds_glyph.dart';
import '../primitives/ds_haptics.dart';
import '../primitives/ds_pressable.dart';
import '../theme/ds_tokens.dart';

/// Colour of a [DsChip].
enum DsChipTone {
  /// `fill-subtle`, `text-1`: quick-add chips.
  neutral,

  /// `positive-soft`, `positive`: the delta chip.
  positive,

  /// `accent-soft`, `text-1`: a tinted badge.
  accent,
}

/// A small pill in the rounded voice with tabular figures. Tappable chips
/// (quick-add) give a selection haptic; read-only ones (delta) do not.
class DsChip extends StatelessWidget {
  const DsChip({
    required this.label,
    this.onPressed,
    this.icon,
    this.tone = DsChipTone.neutral,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final DsIcon? icon;
  final DsChipTone tone;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final c = ds.colors;
    final (fill, fg) = switch (tone) {
      DsChipTone.neutral => (c.fillSubtle, c.text1),
      DsChipTone.positive => (c.positiveSoft, c.positive),
      DsChipTone.accent => (c.accentSoft, c.text1),
    };
    final shape = ds.shape(ds.radius.full);
    final pill = DsBox(
      shape: shape,
      color: fill,
      shadow: DsShadow.none,
      child: SizedBox(
        height: ds.size.controlSm,
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: ds.spacing.s3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                DsGlyph(icon!, weight: DsGlyphWeight.bold, size: 14, color: fg),
                SizedBox(width: ds.spacing.s1),
              ],
              Flexible(
                child: Text(
                  label,
                  style: ds.text.chip.copyWith(color: fg),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (onPressed == null) {
      return Semantics(
        container: true,
        label: semanticLabel,
        excludeSemantics: semanticLabel != null,
        child: pill,
      );
    }
    void tap() {
      DsHaptics.selection(context);
      onPressed!();
    }

    return Semantics(
      container: true,
      button: true,
      label: semanticLabel ?? label,
      onTap: tap,
      excludeSemantics: true,
      child: DsPressable(
        onTap: tap,
        scale: ds.motion.pressScaleTile,
        focusShape: shape,
        builder: (context, _) => SizedBox(
          height: math.max(ds.size.controlSm, ds.size.hitTarget),
          child: Center(widthFactor: 1, child: pill),
        ),
      ),
    );
  }
}

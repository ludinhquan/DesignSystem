import 'package:material_ui/material_ui.dart';

import '../foundation/ds_colors.dart';
import '../foundation/ds_emoji.dart';
import '../foundation/ds_icons.dart';
import '../foundation/ds_shadows.dart';
import '../primitives/ds_box.dart';
import '../primitives/ds_glyph.dart';
import '../primitives/ds_pressable.dart';
import '../theme/ds_tokens.dart';

/// Tile sizes: `row` 40 (emoji in rows), `sm` 44, `lg` 60.
enum DsTileSize { row, sm, lg }

/// A soft squircle tile: a duotone glyph on an object field (actions) or a
/// 3D emoji on that field's pastel tint (categories). Never text inside;
/// an optional [label] sits under it.
class DsIconTile extends StatelessWidget {
  /// An action tile (quick actions use red, green, blue and purple; yellow
  /// stays for the accent and the default account).
  const DsIconTile.glyph({
    required DsField this.field,
    required DsIcon this.icon,
    this.size = DsTileSize.lg,
    this.label,
    this.onTap,
    this.semanticLabel,
    super.key,
  }) : emoji = null;

  /// A category tile; the tint comes from the emoji's category field unless
  /// [field] is given.
  const DsIconTile.emoji({
    required DsEmoji this.emoji,
    this.field,
    this.size = DsTileSize.lg,
    this.label,
    this.onTap,
    this.semanticLabel,
    super.key,
  }) : icon = null;

  final DsField? field;
  final DsIcon? icon;
  final DsEmoji? emoji;
  final DsTileSize size;

  /// One line under the tile (`tile-label`).
  final String? label;
  final VoidCallback? onTap;

  /// Accessible name when there is no [label].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final c = ds.colors;
    final (double d, double radius) = switch (size) {
      DsTileSize.row => (ds.size.tileRow, ds.radius.tileSm),
      DsTileSize.sm => (ds.size.tileSm, ds.radius.tileSm),
      DsTileSize.lg => (ds.size.tileLg, ds.radius.tileLg),
    };
    final shape = ds.shape(radius);

    Widget tile(bool pressed) {
      if (emoji != null) {
        final f = c.field(field ?? emoji!.field ?? DsField.graphite);
        final e = size == DsTileSize.lg ? ds.size.emojiTile : ds.size.emojiRow;
        return DsBox(
          shape: shape,
          color: f.tint ?? c.fillSubtle,
          shadow: ds.shadows.surface,
          child: Center(
            child: Image(
              image: ResizeImage.resizeIfNeeded(
                (e * MediaQuery.devicePixelRatioOf(context)).round(),
                null,
                emoji!.image,
              ),
              width: e,
              height: e,
              excludeFromSemantics: true,
            ),
          ),
        );
      }
      final f = c.field(field!);
      return DsObjectFace(
        field: f,
        shape: shape,
        pressed: pressed,
        grain: false,
        // Small objects get only the contact layer of the object shadow.
        shadow: DsShadow(f.shadow.layers.take(1).toList()),
        child: Center(
          child: DsGlyph(
            icon!,
            weight: DsGlyphWeight.duotone,
            size: size == DsTileSize.lg ? 28 : 22,
            color: f.ink,
          ),
        ),
      );
    }

    Widget body(bool pressed) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(dimension: d, child: tile(pressed)),
        if (label != null) ...[
          SizedBox(height: ds.spacing.s2),
          Text(
            label!,
            style: ds.text.tileLabel.copyWith(color: c.text1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    final name = label ?? semanticLabel;
    if (onTap == null) {
      return Semantics(
        container: true,
        label: name,
        excludeSemantics: true,
        child: body(false),
      );
    }
    return Semantics(
      container: true,
      button: true,
      label: name,
      onTap: onTap,
      excludeSemantics: true,
      child: DsPressable(
        onTap: onTap,
        scale: ds.motion.pressScaleTile,
        builder: (context, state) => body(state.pressed),
      ),
    );
  }
}

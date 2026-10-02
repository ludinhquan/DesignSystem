import 'package:flutter/widgets.dart';

import '../foundation/ds_icons.dart';
import '../theme/ds_tokens.dart';

/// Which drawing of a [DsIcon] to use. Size picks it: navigation 24
/// [regular], inline 16–18 [bold], selected tab [fill], action tiles
/// [duotone].
enum DsGlyphWeight { regular, bold, fill, duotone }

/// Renders a [DsIcon] in one weight. Duotone is the back layer at 20% under
/// the line layer, both in [color].
class DsGlyph extends StatelessWidget {
  const DsGlyph(
    this.icon, {
    this.weight = DsGlyphWeight.regular,
    this.size,
    this.color,
    this.semanticLabel,
    super.key,
  });

  final DsIcon icon;
  final DsGlyphWeight weight;

  /// Defaults to the nav size (regular, fill, duotone) or inline (bold).
  final double? size;

  /// Defaults to `text-1`.
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final s =
        size ??
        (weight == DsGlyphWeight.bold ? ds.size.iconInline : ds.size.iconNav);
    final c = color ?? ds.colors.text1;
    return switch (weight) {
      DsGlyphWeight.regular => Icon(
        icon.regular,
        size: s,
        color: c,
        semanticLabel: semanticLabel,
      ),
      DsGlyphWeight.bold => Icon(
        icon.bold,
        size: s,
        color: c,
        semanticLabel: semanticLabel,
      ),
      DsGlyphWeight.fill => Icon(
        icon.fill,
        size: s,
        color: c,
        semanticLabel: semanticLabel,
      ),
      DsGlyphWeight.duotone => Semantics(
        label: semanticLabel,
        child: ExcludeSemantics(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon.duotoneBack, size: s, color: c.withValues(alpha: .2)),
              Icon(icon.duotoneFront, size: s, color: c),
            ],
          ),
        ),
      ),
    };
  }
}

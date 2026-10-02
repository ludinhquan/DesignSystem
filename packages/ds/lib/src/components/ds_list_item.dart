import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../foundation/ds_colors.dart';
import '../foundation/ds_emoji.dart';
import '../foundation/ds_icons.dart';
import '../foundation/ds_shadows.dart';
import '../primitives/ds_box.dart';
import '../primitives/ds_glyph.dart';
import '../primitives/ds_ground.dart';
import '../theme/ds_tokens.dart';
import 'ds_icon_tile.dart';
import 'ds_money.dart';
import 'ds_monogram.dart';

/// Trailing accessory of a settings row.
enum DsAccessory { none, chevron, check }

/// One list row in one of two anatomies.
///
/// * [DsListItem.settings]: glyph tile, title, value, chevron or control.
/// * [DsListItem.content]: a merchant's category tile or a person's
///   monogram, title, "Category · time", signed amount. No chevron: the
///   whole row is tappable.
///
/// Pressed rows fill `fill-subtle` at once and fade out over 250ms.
class DsListItem extends StatefulWidget {
  const DsListItem.settings({
    required this.title,
    this.subtitle,
    this.glyph,
    this.leading,
    this.value,
    this.accessory = DsAccessory.none,
    this.trailing,
    this.destructive = false,
    this.onTap,
    super.key,
  }) : emoji = null,
       monogram = null,
       account = null,
       amount = null,
       flash = false,
       _content = false;

  const DsListItem.content({
    required this.title,
    required this.subtitle,
    required int this.amount,
    this.emoji,
    this.monogram,
    this.account,
    this.flash = false,
    this.onTap,
    super.key,
  }) : assert((emoji == null) != (monogram == null)),
       glyph = null,
       leading = null,
       value = null,
       accessory = DsAccessory.none,
       trailing = null,
       destructive = false,
       _content = true;

  final String title;
  final String? subtitle;

  /// Settings: a 30px glyph tile on `fill-subtle`.
  final DsIcon? glyph;

  /// Settings: a custom leading widget instead of [glyph].
  final Widget? leading;

  /// Settings: a value in `text-2`.
  final String? value;
  final DsAccessory accessory;

  /// Settings: a control (a `DsToggle`). One per row.
  final Widget? trailing;
  final bool destructive;

  /// Content: a merchant's category.
  final DsEmoji? emoji;

  /// Content: a person's initials.
  final String? monogram;

  /// Content: the paying account's field, drawn as a 13px dot.
  final DsField? account;

  /// Content: signed, in đồng. Inflows show `+` and `positive`.
  final int? amount;

  /// Content: a new inflow flashes `positive-soft` for 900ms.
  final bool flash;
  final VoidCallback? onTap;
  final bool _content;

  @override
  State<DsListItem> createState() => _DsListItemState();
}

class _DsListItemState extends State<DsListItem> {
  bool _pressed = false;
  bool _flashing = false;

  @override
  void initState() {
    super.initState();
    if (widget.flash) {
      _flashing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _flashing = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final c = ds.colors;
    final content = widget._content;
    final gutter = ds.spacing.gutterFor(MediaQuery.sizeOf(context).width);

    final Widget? leading = content
        ? _contentLeading(context)
        : widget.leading ??
              (widget.glyph == null
                  ? null
                  : DsBox(
                      shape: ds.shape(ds.radius.glyph),
                      color: c.fillSubtle,
                      shadow: DsShadow.none,
                      child: SizedBox.square(
                        dimension: ds.size.glyphTile,
                        child: Center(
                          child: DsGlyph(
                            widget.glyph!,
                            weight: DsGlyphWeight.bold,
                            size: 18,
                            color: widget.destructive ? c.negative : c.text1,
                          ),
                        ),
                      ),
                    ));

    final titleStyle = content ? ds.text.rowTitle : ds.text.body;
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: titleStyle.copyWith(
            color: widget.destructive ? c.negative : c.text1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.subtitle != null)
          Text(
            widget.subtitle!,
            style: ds.text.footnote.copyWith(color: c.text2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );

    final trailing = <Widget>[
      if (content) DsMoney(widget.amount!, sign: true),
      if (!content && widget.value != null)
        Text(widget.value!, style: ds.text.body.copyWith(color: c.text2)),
      if (!content && widget.trailing != null) widget.trailing!,
      if (widget.accessory == DsAccessory.chevron)
        DsGlyph(
          ds.icons.chevronRight,
          weight: DsGlyphWeight.bold,
          size: 16,
          color: c.text3,
        ),
      if (widget.accessory == DsAccessory.check)
        DsGlyph(
          ds.icons.check,
          weight: DsGlyphWeight.bold,
          size: 18,
          color: c.accentText,
        ),
    ];

    final row = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: content
            ? ds.size.rowContent
            : math.max(ds.size.rowMin, ds.size.hitTarget),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: content ? gutter : ds.spacing.s4,
          vertical: content ? ds.spacing.s3 : ds.spacing.s2,
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading, SizedBox(width: ds.spacing.s3)],
            // The title truncates; the amount never does.
            Expanded(child: texts),
            for (final t in trailing) ...[SizedBox(width: ds.spacing.s2), t],
          ],
        ),
      ),
    );

    final fill = _flashing
        ? c.positiveSoft
        : _pressed
        ? c.fillSubtle
        : const Color(0x00000000);
    final animated = AnimatedContainer(
      duration: _pressed
          ? Duration.zero
          : (widget.flash
                ? const Duration(milliseconds: 900)
                : ds.motion.fadeLong),
      color: fill,
      child: row,
    );

    if (widget.onTap == null) return MergeSemantics(child: animated);
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: animated,
        ),
      ),
    );
  }

  Widget _contentLeading(BuildContext context) {
    final ds = context.ds;
    final tile = widget.emoji != null
        ? DsIconTile.emoji(emoji: widget.emoji!, size: DsTileSize.row)
        : DsMonogram(widget.monogram!);
    if (widget.account == null) return tile;
    final f = ds.colors.field(widget.account!);
    return SizedBox.square(
      dimension: ds.size.tileRow + 4,
      child: Stack(
        children: [
          tile,
          PositionedDirectional(
            end: 0,
            bottom: 0,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: const Alignment(-0.42, -1),
                  end: const Alignment(0.42, 1),
                  colors: [f.face, f.end],
                ),
                border: Border.all(
                  color: DsGround.color(context),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

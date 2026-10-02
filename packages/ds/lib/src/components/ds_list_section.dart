import 'package:material_ui/material_ui.dart';

import '../foundation/ds_emoji.dart';
import '../primitives/ds_box.dart';
import '../primitives/ds_ground.dart';
import '../theme/ds_tokens.dart';
import 'ds_button.dart';

/// A titled group of rows.
///
/// * [DsListSection.plain]: content rows straight on canvas under a display
///   header, with an optional action link ("Xem tất cả"). Money screens.
/// * [DsListSection.grouped]: settings and form rows in a surface group,
///   with a `label` header and a footnote footer.
///
/// Rows are separated by a hairline inset to the text start.
class DsListSection extends StatelessWidget {
  const DsListSection.plain({
    required this.children,
    this.header,
    this.actionLabel,
    this.onAction,
    this.empty,
    super.key,
  }) : footer = null,
       grouped = false;

  const DsListSection.grouped({
    required this.children,
    this.header,
    this.footer,
    super.key,
  }) : actionLabel = null,
       onAction = null,
       empty = null,
       grouped = true;

  final List<Widget> children;
  final String? header;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? footer;

  /// Shown instead of the rows when [children] is empty.
  final Widget? empty;
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final c = ds.colors;
    final gutter = ds.spacing.gutterFor(MediaQuery.sizeOf(context).width);

    if (!grouped) {
      final inset = gutter + ds.size.tileRow + ds.spacing.s3;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null)
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: gutter,
                end: gutter - ds.spacing.s3,
                bottom: ds.spacing.s2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      container: true,
                      header: true,
                      child: Text(
                        header!,
                        style: ds.text.titleSection.copyWith(color: c.text1),
                      ),
                    ),
                  ),
                  if (actionLabel != null)
                    DsButton(
                      label: actionLabel!,
                      variant: DsButtonVariant.plain,
                      size: DsButtonSize.sm,
                      onPressed: onAction,
                    ),
                ],
              ),
            ),
          if (children.isEmpty && empty != null)
            empty!
          else
            ..._separated(children, inset, c.separator),
        ],
      );
    }

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null)
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: ds.spacing.s4,
                bottom: ds.spacing.s2,
              ),
              child: Semantics(
                container: true,
                header: true,
                child: Text(
                  header!,
                  style: ds.text.label.copyWith(color: c.text2),
                ),
              ),
            ),
          DsBox(
            shape: ds.shape(ds.radius.card),
            color: DsGround.chrome(context),
            shadow: ds.shadows.surface,
            clip: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _separated(
                children,
                ds.spacing.s4 + ds.size.glyphTile + ds.spacing.s3,
                c.separator,
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: ds.spacing.s4,
                end: ds.spacing.s4,
                top: ds.spacing.s2,
              ),
              child: Text(
                footer!,
                style: ds.text.footnote.copyWith(color: c.text2),
              ),
            ),
        ],
      ),
    );
  }

  static List<Widget> _separated(
    List<Widget> rows,
    double inset,
    Color color,
  ) => [
    for (final (i, row) in rows.indexed) ...[
      if (i > 0)
        Padding(
          padding: EdgeInsetsDirectional.only(start: inset),
          child: Container(height: 0.5, color: color),
        ),
      row,
    ],
  ];
}

/// An empty or success moment: one 3D emoji, a display line and one
/// sentence, entering on the object spring.
class DsEmptyState extends StatefulWidget {
  const DsEmptyState({
    required this.title,
    required this.message,
    this.emoji = DsEmoji.emptyNest,
    super.key,
  });

  final DsEmoji emoji;
  final String title;
  final String message;

  @override
  State<DsEmptyState> createState() => _DsEmptyStateState();
}

class _DsEmptyStateState extends State<DsEmptyState>
    with SingleTickerProviderStateMixin {
  late final _enter = AnimationController.unbounded(vsync: this, value: 0.9);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_enter.value == 0.9 && !_enter.isAnimating) {
      if (context.dsReduceMotion) {
        _enter.value = 1;
      } else {
        _enter.animateWith(context.ds.motion.object.simulate(0.9, 1));
      }
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final size = ds.size.emojiMoment;
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: ds.spacing.s6,
        vertical: ds.spacing.s6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _enter,
            child: Image(
              image: ResizeImage.resizeIfNeeded(
                (size * MediaQuery.devicePixelRatioOf(context)).round(),
                null,
                widget.emoji.image,
              ),
              width: size,
              height: size,
              excludeFromSemantics: true,
            ),
          ),
          SizedBox(height: ds.spacing.s3),
          Text(
            widget.title,
            style: ds.text.titleSection.copyWith(color: ds.colors.text1),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ds.spacing.s1),
          Text(
            widget.message,
            style: ds.text.subhead.copyWith(color: ds.colors.text2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

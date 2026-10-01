import 'package:ds_foundation/ds_foundation.dart';
import 'package:ds_tokens/ds_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// A bordered container on the raised surface colour.
///
/// Pass [onTap] to make the whole card interactive (hover/pressed overlays
/// come from the semantic `color.state.*` tokens).
///
/// ```dart
/// AppCard(
///   child: Column(children: [
///     Text('Title', style: context.typography.title),
///     Text('Body'),
///   ]),
/// )
/// ```
class AppCard extends StatelessWidget {
  /// Creates a card.
  const AppCard({
    required this.child,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  /// Card content. Default text style is `typography.body` in
  /// `color.text.primary`.
  final Widget child;

  /// Makes the card tappable.
  final VoidCallback? onTap;

  /// Label announced by screen readers for the card as a whole.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(CardTokens.radius)),
      side: BorderSide(
        color: colors.borderDefault,
        width: CardTokens.borderWidth,
      ),
    );

    Widget content = Padding(
      padding: const EdgeInsetsDirectional.all(CardTokens.padding),
      child: DefaultTextStyle.merge(
        style: context.typography.body.copyWith(color: colors.textPrimary),
        child: child,
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        customBorder: shape,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return colors.statePressed;
          if (states.contains(WidgetState.hovered)) return colors.stateHover;
          if (states.contains(WidgetState.focused)) return colors.stateFocus;
          return null;
        }),
        child: content,
      );
    }

    return Semantics(
      container: true,
      label: semanticLabel,
      child: Material(
        color: colors.surfaceRaised,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}

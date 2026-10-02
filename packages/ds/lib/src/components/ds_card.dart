import 'package:material_ui/material_ui.dart';

import '../theme/ds_tokens.dart';
import '../tokens/semantic.dart';

/// A bordered surface that groups related content. Tappable when [onTap] is
/// set.
class DsCard extends StatelessWidget {
  const DsCard({required this.child, this.onTap, this.padding, super.key});

  final Widget child;
  final VoidCallback? onTap;

  /// Defaults to `spacing.md`.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(ds.radius.lg)),
      side: BorderSide(color: ds.border, width: DsSize.borderThin),
    );
    return Material(
      color: scheme.surfaceContainerLow,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? EdgeInsetsDirectional.all(ds.spacing.md),
          child: child,
        ),
      ),
    );
  }
}

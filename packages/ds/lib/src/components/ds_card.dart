import 'package:material_ui/material_ui.dart';

import '../primitives/ds_box.dart';
import '../primitives/ds_ground.dart';
import '../primitives/ds_pressable.dart';
import '../theme/ds_tokens.dart';

/// A chrome group: `surface` (or `surface-3` in a sheet), `radius-card`,
/// the `shadow-surface` hairline. Chrome never casts a soft shadow and
/// never carries colour; colour lives on objects.
class DsCard extends StatelessWidget {
  const DsCard({required this.child, this.onTap, this.padding, super.key});

  final Widget child;
  final VoidCallback? onTap;

  /// Defaults to `space-4`.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final shape = ds.shape(ds.radius.card);
    Widget box(bool pressed) => DsBox(
      shape: shape,
      color: pressed
          ? Color.alphaBlend(ds.colors.fillSubtle, DsGround.chrome(context))
          : DsGround.chrome(context),
      shadow: ds.shadows.surface,
      padding: padding ?? EdgeInsetsDirectional.all(ds.spacing.s4),
      child: child,
    );
    if (onTap == null) return box(false);
    return DsPressable(
      onTap: onTap,
      scale: 1,
      focusShape: shape,
      builder: (context, state) => box(state.pressed),
    );
  }
}

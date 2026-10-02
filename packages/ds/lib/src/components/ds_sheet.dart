import 'package:material_ui/material_ui.dart';

import '../l10n/ds_localizations.dart';
import '../primitives/ds_box.dart';
import '../primitives/ds_ground.dart';
import '../theme/ds_tokens.dart';
import 'ds_icon_button.dart';

/// Shows a [DsSheet] over the dimmed screen. Drag down to dismiss.
Future<T?> showDsSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  WidgetBuilder? footer,
}) {
  final ds = context.ds;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0x00000000),
    elevation: 0,
    barrierColor: ds.colors.scrim,
    sheetAnimationStyle: AnimationStyle(
      duration: ds.motion.smooth.duration,
      curve: ds.motion.smooth.curve,
      reverseDuration: ds.motion.fadeLong,
    ),
    builder: (context) => DsSheet(
      title: title,
      onClose: () => Navigator.of(context).pop(),
      footer: footer?.call(context),
      child: Builder(builder: builder),
    ),
  );
}

/// A floating card for a focused task: inset 8px from the display edges,
/// `surface-2`, concentric corners, a grabber, a soft close button on the
/// left and the title centred. Exactly one confirm goes in [footer].
///
/// Groups and fields inside use `surface-3` automatically ([DsGround]).
class DsSheet extends StatelessWidget {
  const DsSheet({
    required this.title,
    required this.child,
    this.onClose,
    this.footer,
    super.key,
  });

  final String title;
  final Widget child;
  final VoidCallback? onClose;

  /// One prominent, full-width `DsButton` that names the action and amount.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final c = ds.colors;
    final inset = ds.spacing.s2;
    final shape = ds.system.shape(
      BorderRadius.vertical(
        top: Radius.circular(ds.radius.sheet),
        bottom: Radius.circular(ds.radius.sheetBottom),
      ),
    );
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: inset,
        end: inset,
        bottom: inset + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: DsBox(
        shape: shape,
        color: c.surface2,
        shadow: ds.shadows.sheet,
        clip: true,
        child: DsGroundScope(
          ground: DsGround.sheet,
          child: AnimatedSize(
            duration: ds.motion.smooth.duration,
            curve: ds.motion.smooth.curve,
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: ds.spacing.s2),
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: c.text3.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: ds.spacing.s3,
                  ),
                  child: Row(
                    children: [
                      if (onClose != null)
                        DsIconButton(
                          icon: ds.icons.close,
                          label: DsLocalizations.of(context).close,
                          variant: DsIconButtonVariant.soft,
                          onPressed: onClose,
                        )
                      else
                        SizedBox(width: ds.size.hitTarget),
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: ds.text.headline.copyWith(color: c.text1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: ds.size.hitTarget),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsetsDirectional.all(ds.spacing.s4),
                    child: child,
                  ),
                ),
                if (footer != null)
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: ds.spacing.s4,
                      end: ds.spacing.s4,
                      bottom: ds.spacing.s4,
                    ),
                    child: footer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../foundation/ds_icons.dart';
import '../foundation/ds_shadows.dart';
import '../l10n/ds_localizations.dart';
import '../primitives/ds_box.dart';
import '../primitives/ds_glyph.dart';
import '../primitives/ds_haptics.dart';
import '../primitives/ds_pressable.dart';
import '../theme/ds_tokens.dart';

/// Emphasis of a [DsButton].
enum DsButtonVariant {
  /// Ink on accent. The one action a screen exists for; at most one.
  prominent,

  /// A surface pill, beside the prominent one or on canvas.
  secondary,

  /// `fill-subtle`, inside surfaces and sheets.
  soft,

  /// Text only, for inline links ("Xem tất cả").
  plain,

  /// Lock, delete, remove. Carries an icon.
  destructive,
}

/// Height of a [DsButton]. The tap target is always at least `hit-target`.
enum DsButtonSize { sm, md, lg }

/// A pill button. Labels start with a verb and say what happens, amount
/// included ("Gửi 250.000 ₫"); they never wrap.
class DsButton extends StatelessWidget {
  const DsButton({
    required this.label,
    required this.onPressed,
    this.variant = DsButtonVariant.secondary,
    this.size = DsButtonSize.md,
    this.icon,
    this.block = false,
    this.loading = false,
    this.semanticLabel,
    this.loadingLabel,
    super.key,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final DsButtonVariant variant;
  final DsButtonSize size;

  /// Drawn in the bold weight at the inline size.
  final DsIcon? icon;

  /// Full width (the bottom confirm of a sheet).
  final bool block;

  /// Shows a spinner in place of the icon, keeps colours, ignores taps.
  final bool loading;

  /// Overrides what screen readers announce instead of [label].
  final String? semanticLabel;

  /// Announced while [loading]. Defaults to [DsLocalizations.loading].
  final String? loadingLabel;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final c = ds.colors;
    final height = switch (size) {
      DsButtonSize.sm => ds.size.controlSm,
      DsButtonSize.md => ds.size.controlMd,
      DsButtonSize.lg => ds.size.controlLg,
    };
    final padX = switch (size) {
      DsButtonSize.sm => ds.spacing.s3,
      DsButtonSize.md => ds.spacing.s4,
      DsButtonSize.lg => ds.spacing.s5,
    };
    final textStyle = size == DsButtonSize.sm
        ? ds.text.buttonSm
        : ds.text.button;
    final shape = ds.shape(ds.radius.full);

    final (Color? fill, Color fg, DsShadow shadow) = switch (variant) {
      DsButtonVariant.prominent => (c.accent, c.onAccent, ds.shadows.accent),
      DsButtonVariant.secondary => (c.surface, c.text1, ds.shadows.surface),
      DsButtonVariant.soft => (c.fillSubtle, c.text1, DsShadow.none),
      DsButtonVariant.plain => (null, c.accentText, DsShadow.none),
      DsButtonVariant.destructive => (
        c.negativeSoft,
        c.negative,
        DsShadow.none,
      ),
    };

    final Widget? leading = loading
        ? SizedBox.square(
            dimension: ds.size.iconInline,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : icon == null
        ? null
        : DsGlyph(icon!, weight: DsGlyphWeight.bold, color: fg);

    return Semantics(
      button: true,
      enabled: _enabled,
      label: semanticLabel ?? label,
      value: loading
          ? loadingLabel ?? DsLocalizations.of(context).loading
          : null,
      excludeSemantics: true,
      child: Opacity(
        opacity: onPressed == null && !loading ? ds.opacity.disabled : 1,
        child: DsPressable(
          onTap: _enabled ? onPressed : null,
          scale: ds.motion.pressScaleButton,
          focusShape: shape,
          onPressDown: variant == DsButtonVariant.prominent
              ? () => DsHaptics.press(context)
              : null,
          builder: (context, state) => SizedBox(
            height: math.max(height, ds.size.hitTarget),
            width: block ? double.infinity : null,
            child: Center(
              widthFactor: block ? null : 1,
              child: DsBox(
                shape: shape,
                color: state.pressed && variant == DsButtonVariant.prominent
                    ? c.accentPressed
                    : fill,
                shadow: shadow,
                child: SizedBox(
                  height: height,
                  width: block ? double.infinity : null,
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: padX),
                    child: Row(
                      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (leading != null) ...[
                          leading,
                          SizedBox(width: ds.spacing.s2),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            style: textStyle.copyWith(color: fg),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

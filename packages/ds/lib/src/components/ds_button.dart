import 'package:material_ui/material_ui.dart';

import '../l10n/ds_localizations.dart';
import '../theme/ds_tokens.dart';
import '../tokens/semantic.dart';

/// Visual emphasis of a [DsButton].
enum DsButtonVariant {
  /// Filled with the primary color. The main action of a screen.
  primary,

  /// Outlined, for secondary actions.
  secondary,

  /// Text only, for low-emphasis or inline actions.
  ghost,
}

/// Visual height of a [DsButton]. The tap target is always at least 48x48.
enum DsButtonSize { sm, md, lg }

/// The design-system button.
///
/// * Disabled when [onPressed] is null.
/// * While [loading] it shows a spinner, ignores taps and keeps its colors.
/// * Colors per state are resolved with [WidgetStateProperty] from semantic
///   tokens only.
class DsButton extends StatelessWidget {
  const DsButton({
    required this.label,
    required this.onPressed,
    this.variant = DsButtonVariant.primary,
    this.size = DsButtonSize.md,
    this.icon,
    this.loading = false,
    this.semanticLabel,
    this.loadingLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final DsButtonVariant variant;
  final DsButtonSize size;
  final IconData? icon;
  final bool loading;

  /// Overrides what screen readers announce instead of [label].
  final String? semanticLabel;

  /// Announced while [loading]. Defaults to [DsLocalizations.loading].
  final String? loadingLabel;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ds = context.ds;
    final text = Theme.of(context).textTheme;

    final height = switch (size) {
      DsButtonSize.sm => DsSize.controlSm,
      DsButtonSize.md => DsSize.controlMd,
      DsButtonSize.lg => DsSize.controlLg,
    };
    final paddingX = switch (size) {
      DsButtonSize.sm => ds.spacing.sm,
      DsButtonSize.md => ds.spacing.md,
      DsButtonSize.lg => ds.spacing.lg,
    };

    // Loading keeps the variant colors; only onPressed == null looks disabled.
    bool looksDisabled(Set<WidgetState> s) =>
        s.contains(WidgetState.disabled) && !loading;

    Color foreground(Set<WidgetState> s) {
      if (looksDisabled(s)) {
        return scheme.onSurface.withValues(alpha: DsOpacity.disabledContent);
      }
      return switch (variant) {
        DsButtonVariant.primary => scheme.onPrimary,
        DsButtonVariant.secondary || DsButtonVariant.ghost => scheme.primary,
      };
    }

    final style = ButtonStyle(
      textStyle: WidgetStatePropertyAll(text.labelLarge),
      minimumSize: WidgetStatePropertyAll(Size(height, height)),
      fixedSize: WidgetStatePropertyAll(Size.fromHeight(height)),
      padding: WidgetStatePropertyAll(
        EdgeInsetsDirectional.symmetric(horizontal: paddingX),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(ds.radius.md)),
        ),
      ),
      // Pads the hit area to >= 48x48 even for the sm size.
      tapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) => switch (variant) {
          DsButtonVariant.primary =>
            looksDisabled(s)
                ? scheme.onSurface.withValues(
                    alpha: DsOpacity.disabledContainer,
                  )
                : scheme.primary,
          DsButtonVariant.secondary || DsButtonVariant.ghost => null,
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith(foreground),
      iconColor: WidgetStateProperty.resolveWith(foreground),
      iconSize: const WidgetStatePropertyAll(DsSize.iconMd),
      overlayColor: WidgetStateProperty.resolveWith((s) {
        final base = variant == DsButtonVariant.primary
            ? scheme.onPrimary
            : scheme.primary;
        final alpha = s.contains(WidgetState.pressed)
            ? DsOpacity.pressed
            : s.contains(WidgetState.hovered)
            ? DsOpacity.hover
            : s.contains(WidgetState.focused)
            ? DsOpacity.focus
            : null;
        return alpha == null ? null : base.withValues(alpha: alpha);
      }),
      side: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.focused)) {
          return BorderSide(color: scheme.primary, width: DsSize.focusRing);
        }
        if (variant != DsButtonVariant.secondary) return null;
        return BorderSide(
          color: looksDisabled(s) ? ds.border : scheme.outline,
          width: DsSize.borderThin,
        );
      }),
    );

    final Widget? leading = loading
        ? SizedBox.square(
            dimension: DsSize.iconSm,
            child: CircularProgressIndicator(
              strokeWidth: DsSize.spinnerStroke,
              color: foreground(const {}),
            ),
          )
        : (icon == null ? null : Icon(icon));

    return Semantics(
      button: true,
      enabled: _enabled,
      label: semanticLabel ?? label,
      value: loading
          ? loadingLabel ?? DsLocalizations.of(context).loading
          : null,
      excludeSemantics: true,
      onTap: _enabled ? onPressed : null,
      child: TextButton(
        onPressed: _enabled ? onPressed : null,
        style: style,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading, SizedBox(width: ds.spacing.xs)],
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

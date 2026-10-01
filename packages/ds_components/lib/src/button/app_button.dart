import 'package:ds_foundation/ds_foundation.dart';
import 'package:ds_tokens/ds_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Visual emphasis of an [AppButton].
enum AppButtonVariant {
  /// Filled with the primary colour. One per screen for the main action.
  primary,

  /// Outlined on the surface colour, for secondary actions.
  secondary,

  /// Text-only, for low-emphasis or inline actions.
  ghost,
}

/// Height and horizontal padding of an [AppButton].
///
/// The interactive area is always at least 48x48 regardless of size.
enum AppButtonSize {
  /// Compact (32 high visually).
  sm,

  /// Default (40 high visually).
  md,

  /// Prominent (48 high visually).
  lg,
}

/// The design-system button.
///
/// ```dart
/// AppButton.primary(label: 'Save', onPressed: save)
/// AppButton.secondary(label: 'Cancel', icon: Icons.close, onPressed: close)
/// AppButton.ghost(label: 'Learn more', size: AppButtonSize.sm, onPressed: f)
/// ```
///
/// * Disabled when [onPressed] is `null`.
/// * While [isLoading] is true it shows a spinner, ignores taps and keeps its
///   variant colours (it does not look disabled).
/// * Hover, focus and pressed states are resolved with
///   [WidgetStateProperty] from the semantic `color.state.*` tokens.
/// * The tap target is padded to at least 48x48 and the label grows with the
///   ambient `TextScaler`.
class AppButton extends StatelessWidget {
  /// Creates a button with an explicit [variant].
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    this.loadingSemanticLabel = 'Loading',
    super.key,
  });

  /// Creates a [AppButtonVariant.primary] button.
  const AppButton.primary({
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    this.loadingSemanticLabel = 'Loading',
    super.key,
  }) : variant = AppButtonVariant.primary;

  /// Creates a [AppButtonVariant.secondary] button.
  const AppButton.secondary({
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    this.loadingSemanticLabel = 'Loading',
    super.key,
  }) : variant = AppButtonVariant.secondary;

  /// Creates a [AppButtonVariant.ghost] button.
  const AppButton.ghost({
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    this.loadingSemanticLabel = 'Loading',
    super.key,
  }) : variant = AppButtonVariant.ghost;

  /// Visible label.
  final String label;

  /// Called when the button is tapped. `null` disables the button.
  final VoidCallback? onPressed;

  /// Visual emphasis.
  final AppButtonVariant variant;

  /// Height / padding preset.
  final AppButtonSize size;

  /// Optional leading icon.
  final IconData? icon;

  /// Shows a progress indicator and ignores taps.
  final bool isLoading;

  /// Overrides the label announced by screen readers.
  final String? semanticLabel;

  /// Announced alongside the label while [isLoading] (localise this).
  final String loadingSemanticLabel;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (height, paddingX) = switch (size) {
      AppButtonSize.sm => (ButtonTokens.heightSm, ButtonTokens.paddingXSm),
      AppButtonSize.md => (ButtonTokens.heightMd, ButtonTokens.paddingXMd),
      AppButtonSize.lg => (ButtonTokens.heightLg, ButtonTokens.paddingXLg),
    };

    // Loading keeps the variant colours, so only a real `onPressed == null`
    // is treated as visually disabled.
    bool looksDisabled(Set<WidgetState> states) =>
        states.contains(WidgetState.disabled) && !isLoading;

    Color foregroundFor(Set<WidgetState> states) {
      if (looksDisabled(states)) return colors.disabledForeground;
      return switch (variant) {
        AppButtonVariant.primary => colors.onPrimary,
        AppButtonVariant.secondary || AppButtonVariant.ghost => colors.primary,
      };
    }

    final style = ButtonStyle(
      textStyle: WidgetStatePropertyAll(context.typography.label),
      minimumSize: WidgetStatePropertyAll(Size(height, height)),
      padding: WidgetStatePropertyAll(
        EdgeInsetsDirectional.symmetric(horizontal: paddingX),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(ButtonTokens.radius)),
        ),
      ),
      // Guarantees a >= 48x48 hit area even for the `sm` size.
      tapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        return switch (variant) {
          AppButtonVariant.primary =>
            looksDisabled(states) ? colors.disabledBackground : colors.primary,
          AppButtonVariant.secondary => colors.surface,
          AppButtonVariant.ghost => null,
        };
      }),
      foregroundColor: WidgetStateProperty.resolveWith(foregroundFor),
      iconColor: WidgetStateProperty.resolveWith(foregroundFor),
      iconSize: const WidgetStatePropertyAll(ButtonTokens.iconSize),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return colors.statePressed;
        if (states.contains(WidgetState.hovered)) return colors.stateHover;
        if (states.contains(WidgetState.focused)) return colors.stateFocus;
        return null;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return BorderSide(
            color: colors.borderFocus,
            width: ButtonTokens.focusRingWidth,
          );
        }
        if (variant != AppButtonVariant.secondary) return null;
        return BorderSide(
          color: looksDisabled(states)
              ? colors.disabledBackground
              : colors.borderStrong,
          width: ButtonTokens.borderWidth,
        );
      }),
    );

    final Widget? leading = isLoading
        ? SizedBox.square(
            dimension: ButtonTokens.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: ButtonTokens.spinnerStroke,
              color: foregroundFor(const {}),
              semanticsLabel: loadingSemanticLabel,
            ),
          )
        : (icon == null ? null : Icon(icon));

    Widget text = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (semanticLabel != null) {
      text = Semantics(
        label: semanticLabel,
        excludeSemantics: true,
        child: text,
      );
    }

    return TextButton(
      onPressed: _isEnabled ? onPressed : null,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: ButtonTokens.gap),
          ],
          Flexible(child: text),
        ],
      ),
    );
  }
}

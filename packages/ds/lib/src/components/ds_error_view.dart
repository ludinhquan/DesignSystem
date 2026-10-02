import 'package:material_ui/material_ui.dart';

import '../l10n/ds_localizations.dart';
import '../theme/ds_tokens.dart';
import '../tokens/semantic.dart';
import 'ds_button.dart';

/// Full-area error state with an optional retry action.
///
/// [message] is required and must be a localized, user-facing text: map the
/// error to it in the app (never pass `error.toString()`).
class DsErrorView extends StatelessWidget {
  const DsErrorView({
    required this.message,
    this.onRetry,
    this.title,
    this.retryLabel,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;

  /// Defaults to [DsLocalizations.errorTitle].
  final String? title;

  /// Defaults to [DsLocalizations.retry].
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final theme = Theme.of(context);
    final l10n = DsLocalizations.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(ds.spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: DsSize.controlMd,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: ds.spacing.sm),
            Text(
              title ?? l10n.errorTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ds.spacing.xs),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: ds.textMuted),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: ds.spacing.md),
              DsButton(
                label: retryLabel ?? l10n.retry,
                variant: DsButtonVariant.secondary,
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

import '../theme/ds_tokens.dart';
import '../tokens/semantic.dart';
import 'ds_button.dart';

/// Full-area error state with an optional retry action.
///
/// The body text is `error.toString()`, so give app exceptions a
/// user-facing `toString()` (or pass [message]).
class DsErrorView extends StatelessWidget {
  const DsErrorView(
    this.error, {
    this.onRetry,
    this.title = 'Something went wrong',
    this.message,
    this.retryLabel = 'Retry',
    super.key,
  });

  final Object error;
  final VoidCallback? onRetry;
  final String title;

  /// Overrides the text derived from [error].
  final String? message;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final theme = Theme.of(context);
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
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ds.spacing.xs),
            Text(
              message ?? '$error',
              style: theme.textTheme.bodyMedium?.copyWith(color: ds.textMuted),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: ds.spacing.md),
              DsButton(
                label: retryLabel,
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

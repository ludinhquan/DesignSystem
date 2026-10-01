import 'package:material_ui/material_ui.dart';

import '../l10n/ds_localizations.dart';
import '../theme/ds_tokens.dart';
import '../tokens/semantic.dart';

/// A centered progress indicator with an optional [label].
class DsLoading extends StatelessWidget {
  const DsLoading({this.label, super.key});

  /// Shown under the spinner and announced to screen readers. Without it,
  /// only [DsLocalizations.loading] is announced.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: DsSize.controlMd,
            child: CircularProgressIndicator(
              strokeWidth: DsSize.focusRing,
              semanticsLabel: label ?? DsLocalizations.of(context).loading,
            ),
          ),
          if (label != null) ...[
            SizedBox(height: ds.spacing.sm),
            ExcludeSemantics(
              child: Text(
                label!,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: ds.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

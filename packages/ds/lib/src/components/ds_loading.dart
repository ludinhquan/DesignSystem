import 'package:material_ui/material_ui.dart';

import '../l10n/ds_localizations.dart';
import '../theme/ds_tokens.dart';

/// A centred progress indicator with an optional [label].
class DsLoading extends StatelessWidget {
  const DsLoading({this.label, super.key});

  /// Shown under the spinner and announced. Without it, only
  /// [DsLocalizations.loading] is announced.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: ds.size.iconNav,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: ds.colors.text2,
              semanticsLabel: label ?? DsLocalizations.of(context).loading,
            ),
          ),
          if (label != null) ...[
            SizedBox(height: ds.spacing.s3),
            ExcludeSemantics(
              child: Text(
                label!,
                style: ds.text.subhead.copyWith(color: ds.colors.text2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

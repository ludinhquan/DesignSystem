import 'package:material_ui/material_ui.dart';

import '../l10n/ds_localizations.dart';
import '../primitives/ds_glyph.dart';
import '../theme/ds_tokens.dart';
import 'ds_button.dart';

/// Full-area error state: a glyph and a sentence (status is never colour
/// alone), with an optional retry.
///
/// [message] is required and must be localized and say how to fix it: map
/// the error in the app, never pass `error.toString()`.
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
    final l10n = DsLocalizations.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(ds.spacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsGlyph(
              ds.icons.warning,
              weight: DsGlyphWeight.fill,
              size: 40,
              color: ds.colors.negative,
            ),
            SizedBox(height: ds.spacing.s3),
            Text(
              title ?? l10n.errorTitle,
              style: ds.text.headline.copyWith(color: ds.colors.text1),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ds.spacing.s1),
            Text(
              message,
              style: ds.text.subhead.copyWith(color: ds.colors.text2),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: ds.spacing.s5),
              DsButton(label: retryLabel ?? l10n.retry, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

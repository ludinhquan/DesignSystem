/// Design-system widgets.
///
/// Every widget here reads colours, spacing, radii and type exclusively from
/// semantic/component tokens (via `ds_foundation` and `ds_tokens`) — never
/// from raw values or primitives.
///
/// Re-exports `ds_foundation` so apps get `AppTheme` and `context.colors`
/// from a single import.
library;

export 'package:ds_foundation/ds_foundation.dart';

export 'src/button/app_button.dart';
export 'src/card/app_card.dart';

/// Design tokens for the design system (semantic and component tiers).
///
/// Everything under `lib/src/` is GENERATED from `tokens/*.json` by
/// `dart run tool/gen_tokens.dart` — never edit it by hand.
///
/// Widgets should consume tokens through `ds_foundation`
/// (`context.colors`, `context.spacing`, ...) rather than importing this
/// library directly, so that values follow the active theme.
library;

export 'src/tokens.g.dart';

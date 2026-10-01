/// Theme layer of the design system.
///
/// * [AppTheme.light] / [AppTheme.dark] build a `ThemeData` from the tokens.
/// * [AppColors], [AppSpacing], [AppRadius] and [AppTypography] are
///   `ThemeExtension`s that carry the semantic tokens.
/// * `context.colors`, `context.spacing`, `context.radius` and
///   `context.typography` read them from the nearest `Theme`.
///
/// Uses `package:material_ui` (not `package:flutter/material.dart`). Apps must
/// provide the theme with the `material_ui` `MaterialApp`/`Theme`, otherwise
/// the lookups below will not find it.
library;

export 'src/app_radius.dart';
export 'src/app_spacing.dart';
export 'src/app_theme.dart';
export 'src/app_typography.dart';
export 'src/context_extensions.dart';
export 'src/generated/app_colors.g.dart';

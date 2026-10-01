# CLAUDE.md — working in the DesignSystem repo

This is a Flutter design-system monorepo (Dart pub workspace + Melos). The
architecture follows `docs/research/flutter-design-system.md` (sections 3–4).
Read this file before changing anything under `tokens/`, `packages/` or `apps/`.

## Layout and dependency direction

```
tokens/*.json  ──(dart run tool/gen_tokens.dart)──▶  packages/ds_tokens        (generated, widgets.dart only)
                                                     packages/ds_foundation/lib/src/generated (AppColors)
packages/ds_tokens → packages/ds_foundation → packages/ds_components → apps/example, apps/widgetbook
```

| Path | What it is | Hand-edit? |
|---|---|---|
| `tokens/` | W3C DTCG JSON — the **source of truth** for every design value | Yes |
| `tool/gen_tokens.dart` | Pure-Dart generator (no Node) | Yes |
| `packages/ds_tokens/lib/src/*.g.dart` | Generated constants | **Never** |
| `packages/ds_foundation/lib/src/generated/*.g.dart` | Generated `AppColors` ThemeExtension | **Never** |
| `packages/ds_foundation` | `AppTheme`, `AppSpacing`/`AppRadius`/`AppTypography`, `context.*` accessors | Yes |
| `packages/ds_components` | `App*` widgets + tests + goldens + `@Preview`s | Yes |
| `apps/example` | Minimal consumer app with light/dark toggle | Yes |
| `apps/widgetbook` | Widgetbook catalog (one use case per component) | Yes |

## Commands (run from the repo root)

```sh
flutter pub get                                   # one resolution for the whole workspace
dart run tool/gen_tokens.dart                     # regenerate tokens after editing tokens/*.json
dart run tool/gen_tokens.dart --check             # CI: fails if generated code is stale
dart format .                                     # format (CI uses --set-exit-if-changed)
flutter analyze .                                 # analyze every package/app
dart run melos run test --no-select               # flutter test in every package with test/
dart run melos run test:update-goldens --no-select  # regenerate alchemist goldens
```

Single package: `cd packages/ds_components && flutter test` (add
`--update-goldens --tags golden` to refresh goldens).

## Token rules

Three tiers (DTCG JSON → generated Dart):

1. **Primitive** — `tokens/primitives.json` → `PrimitiveColor.blue600`, `PrimitiveSpace.space4`…
   Raw values with no meaning. Only exported from `package:ds_tokens/primitives.dart`.
2. **Semantic** — `tokens/semantic.json` (theme-independent: `SpaceTokens`,
   `RadiusTokens`, `SizeTokens`, `TypographyTokens`) and
   `tokens/semantic.<mode>.json` (themed: `ColorTokens.light` / `.dark`,
   surfaced as the `AppColors` ThemeExtension). Light/dark differ **only** here.
3. **Component** — `tokens/component.json` → `ButtonTokens`, `CardTokens`.
   Add one only when a component needs to diverge from the semantic tier.

Hard rules:

- **Never hand-edit `*.g.dart`.** Edit `tokens/*.json`, then run
  `dart run tool/gen_tokens.dart` and commit JSON + generated files together.
- Aliases use DTCG syntax: `"$value": "{color.blue.600}"`. Prefer aliasing a
  primitive over repeating a literal.
- Every `semantic.<mode>.json` must define exactly the same token paths
  (the generator fails otherwise). Adding a semantic colour = add it to both
  `semantic.light.json` and `semantic.dark.json`; `ColorTokens` and
  `AppColors` (fields, `copyWith`, `lerp`) update automatically.
- Adding a key to a group in `semantic.json` (e.g. a new spacing step) also
  needs the matching field in the hand-written extension (`AppSpacing`,
  `AppRadius` or `AppTypography`, including `copyWith`/`lerp`).
- Do not invent design values inside Dart code. If a value is missing, add a
  token to the JSON first.
- `ds_tokens` must depend on `package:flutter/widgets.dart` only.

## Material import rule

Use `package:material_ui/material_ui.dart` everywhere (packages, apps, tests,
the generator's output). **Never** import `package:flutter/material.dart` or
`package:flutter/cupertino.dart` in our code: the in-SDK copies are frozen and
deprecated, and their `Theme`/`ThemeData` are *different types* — a theme
provided by one is invisible to widgets built on the other, so mixing them
silently breaks `context.colors`.

Third-party tools that are still on `flutter/material` (alchemist, Widgetbook
3.x, the widget previewer shell) are handled by wrapping content in our own
`material_ui` `Theme` (see `themed()` in `ds_components/test/helpers`,
`lightThemeWrapper` in `previews.dart`, the `ThemeAddon` in
`apps/widgetbook`). `test/token_hygiene_test.dart` enforces this for
`ds_components/lib`.

## Component rules

- Prefix every widget `App*`. Variants are enums + named constructors
  (`AppButton.primary(...)`, `size: AppButtonSize.md`).
- **Tokens only.** No `Color(0x…)`, `Colors.*`, `TextStyle(...)`, primitives or
  raw numeric dimensions. Read colours/spacing/radii/type via
  `context.colors`, `context.spacing`, `context.radius`, `context.typography`;
  static component dimensions via `ButtonTokens`/`CardTokens`.
  `token_hygiene_test.dart` fails the build on violations.
- Resolve interactive states (hover, focus, pressed, disabled, loading) with
  `WidgetStateProperty` and the `color.state.*` / `color.disabled.*` tokens.
- Accessibility: ≥48×48 tap target, `Semantics` labels, respect the ambient
  `TextScaler` (never fixed heights that clip text), RTL-safe
  `EdgeInsetsDirectional`.
- Every public member has dartdoc (`public_member_api_docs` is on for
  `packages/`).

### Definition of done for a component

A component is done only when **all** of these exist and pass:

1. `packages/ds_components/lib/src/<name>/app_<name>.dart`, exported from
   `lib/ds_components.dart`, with dartdoc and a usage snippet.
2. Widget tests in `packages/ds_components/test/app_<name>_test.dart`: behaviour,
   disabled/loading states, theme colours, and `meetsGuideline(...)` for
   `androidTapTargetGuideline`, `iOSTapTargetGuideline`,
   `labeledTapTargetGuideline`, `textContrastGuideline` in light and dark.
3. Alchemist golden tests (`test/app_<name>_golden_test.dart`): light/dark ×
   text scale 1.0/2.0 × key states, CI-mode PNGs committed under
   `test/goldens/ci/`. Look at every changed PNG before committing; never
   regenerate goldens just to make a failing test pass.
4. An `@Preview` (light, dark, 2× text) in `lib/src/previews.dart` and a case
   in `test/previews_test.dart`.
5. A Widgetbook use case with knobs in `apps/widgetbook/lib/use_cases/` and
   registered in `apps/widgetbook/lib/main.dart`.
6. Shown in `apps/example`.
7. The full validation checklist below is green.

## Validation checklist (same as CI)

```sh
dart format --output=none --set-exit-if-changed .
dart run tool/gen_tokens.dart --check
flutter analyze .
dart run melos run test --no-select
```

Do not skip, disable or loosen tests or lints to get green; fix the cause.

## Design hand-off

`tokens/*.json` is the interchange point with design tools. Designs from
Claude Design (claude.ai/design, "Send to Claude Code") or Figma Variables
(DTCG export plugin) should land as edits to `tokens/*.json` — map new values
onto the existing tier structure and names rather than pasting raw values into
widgets — then run the generator, update goldens deliberately, and review the
diff.

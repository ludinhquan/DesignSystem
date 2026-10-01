# Research: Building a Design System for a Flutter App

_Researched: October 2026_

This document summarizes the current (late‑2026) state of the Flutter ecosystem
and recommends an architecture, toolchain and roadmap for building this
`DesignSystem` repository as a reusable Flutter design system.

---

## 1. TL;DR – Recommendations

| Area | Recommendation |
|---|---|
| Flutter / Dart | Target **Flutter 3.47+ / Dart 3.13+** (current stable as of Aug 2026). |
| Material dependency | Build new code on the standalone **`material_ui` / `cupertino_ui`** packages, not `package:flutter/material.dart` (frozen, deprecated from the Nov 2026 stable). Keep the *token* layer free of Material entirely. |
| Repo layout | **Monorepo** with **Dart pub workspaces** + **Melos** for scripts. |
| Token source of truth | **Figma Variables → W3C DTCG JSON → generated Dart** (Style Dictionary or a Figma plugin). Never hand‑edit generated tokens. |
| Theming | Map tokens to `ColorScheme` / `TextTheme` where they fit; put everything else in typed **`ThemeExtension`s**, accessed via a `context` extension. |
| Components | Own a thin set of `App*` widgets (`AppButton`, `AppTextField`, …) that read only from tokens. |
| Catalog | **Widgetbook** for the shareable gallery; Flutter's built‑in **`@Preview`** (now stable) for in‑IDE iteration. |
| Visual testing | **Golden tests with `alchemist`** (light/dark × text scale × platform), run in CI. |
| Build vs buy | Build our own on top of Material; borrow ideas from **Forui**, **Mix 2.0**, **Moon Design**. |

---

## 2. State of the Flutter ecosystem (2026)

### 2.1 Flutter 3.47 & Dart 3.13 (released 12 Aug 2026)
- **Material and Cupertino are standalone packages.** `material_ui` and
  `cupertino_ui` reached **1.0** and now ship on a weekly cadence, independent
  of the quarterly SDK release.
- **In‑SDK `flutter/material.dart` and `flutter/cupertino.dart` are frozen**
  (no fixes since April 2026), **deprecated from the Fall/Nov 2026 stable**, and
  scheduled for removal in a 2027 release.
- **Material 3 Expressive** visual updates will land in `material_ui` releases
  after 1.0 — another reason to depend on the package.
- **Widget Previews (`@Preview`) are stable** — faster startup, caching,
  layered themes.
- **Impeller is the default renderer on desktop** (macOS/Windows/Linux); wide
  gamut color on macOS by default.
- **Dart 3.13: primary constructors are stable** — big boilerplate reduction
  for token/data classes.

### 2.2 Migration notes for Material/Cupertino decoupling
```yaml
# pubspec.yaml
dependencies:
  material_ui: ^1.0.0
  cupertino_ui: ^1.0.0   # only if we ship Cupertino variants
```
```dart
// before
import 'package:flutter/material.dart';
// after
import 'package:material_ui/material_ui.dart';
```
- Automated migration: `dart fix --apply --code=migrate_design_widgets`.
- **Gotcha:** widgets/themes from the old SDK library and the new package are
  *different types* even though class names match. A package on the new copy
  cannot see `Theme`s provided by the old copy. Every consumer app and every
  third‑party UI dependency must be on the same side. Check dependencies before
  migrating, and document the requirement for consumers of this design system.

> Design implication: keep the **token** and **foundation** packages depending
> only on `package:flutter/widgets.dart`. Then only the component layer is
> affected by Material/Cupertino churn.

---

## 3. Recommended architecture

### 3.1 Token tiers
Three tiers, the de‑facto industry standard:

1. **Primitive (reference) tokens** – raw values with no meaning.
   `blue500 = #2563EB`, `space4 = 16`, `radius2 = 8`.
2. **Semantic (system) tokens** – intent, theme‑aware.
   `color.surface`, `color.textPrimary`, `color.borderFocus`, `space.md`.
   Light/dark (and per‑brand) themes differ **only** at this layer.
3. **Component tokens** (optional) – `button.primary.background`,
   `textField.borderRadius`. Add only when a component needs to diverge.

Rule: **components may only read semantic/component tokens, never primitives.**

### 3.2 Mapping tokens to Flutter theming
| Token group | Flutter target |
|---|---|
| Brand/surface/text colors that M3 covers | `ColorScheme` |
| Extra colors (success, warning, info, brand accents…) | `ThemeExtension<AppColors>` |
| Type scale | `TextTheme` + `ThemeExtension<AppTypography>` for extra styles |
| Spacing, radii, elevation/shadows, durations, curves | `ThemeExtension`s (or `const` classes if never themed) |
| Icons | Generated icon font or `flutter_svg` assets + typed `AppIcons` |

`ThemeExtension` is the official, type‑safe way to add custom tokens to
`ThemeData`, and it supports `lerp`, so theme switches animate.

### 3.3 Example: semantic color extension
```dart
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.warning,
    required this.textMuted,
  });

  final Color success;
  final Color warning;
  final Color textMuted;

  @override
  AppColors copyWith({Color? success, Color? warning, Color? textMuted}) =>
      AppColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        textMuted: textMuted ?? this.textMuted,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}

extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>()!;
}

// Usage inside a component:
// Text('Saved', style: TextStyle(color: context.colors.success));
```
This boilerplate should be **generated** (from DTCG JSON or with
`theme_tailor`/Mix's `@MixableToken`), not written by hand.

### 3.4 Proposed repository layout
```
DesignSystem/
├── pubspec.yaml                 # workspace root (+ melos config)
├── tokens/                      # DTCG JSON exported from Figma (source of truth)
│   ├── primitives.json
│   ├── semantic.light.json
│   └── semantic.dark.json
├── tool/                        # Style Dictionary config / codegen scripts
├── packages/
│   ├── ds_tokens/               # GENERATED Dart constants (widgets.dart only)
│   ├── ds_foundation/           # ThemeExtensions, ThemeData builders, context ext
│   ├── ds_components/           # AppButton, AppTextField, AppCard, …
│   └── ds_icons/                # icon font / SVG assets + typed accessors
├── apps/
│   └── widgetbook/              # living catalog (deploy to web)
└── docs/
    ├── research/                # this document
    └── adr/                     # architecture decision records
```
Dependency direction: `ds_tokens → ds_foundation → ds_components`.
Consumer apps depend on `ds_components` (and `ds_foundation` if they need
`context.colors` directly).

### 3.5 Component API guidelines
- Prefix everything (`App*` or `Ds*`) so it never collides with Material names.
- Variants as enums / named constructors: `AppButton.primary(...)`,
  `AppButton.secondary(...)`, `size: AppButtonSize.md`.
- No raw colors, numbers or `TextStyle`s inside components — tokens only.
  Enforce with a custom lint (e.g. via `custom_lint` / DCM rules).
- Every interactive component handles: enabled, disabled, hover, focus,
  pressed, loading, error (use `WidgetStateProperty`).
- Accessibility built in: `Semantics` labels, ≥48×48 touch targets,
  respects `MediaQuery.textScalerOf(context)` (use `TextScaler`, not the
  deprecated `textScaleFactor`), RTL‑safe (`EdgeInsetsDirectional`).
- A component is "done" only when it has: Widgetbook stories, golden tests
  (light/dark, 1.0×/2.0× text), and dartdoc.

---

## 4. Toolchain

### 4.1 Figma → code (design tokens)
The 2026 consensus pipeline: **Figma Variables → W3C DTCG JSON → Style
Dictionary → Dart**.

Options:
- **Style Dictionary** + [`style-dictionary-figma-flutter`](https://github.com/aloisdeniel/style-dictionary-figma-flutter)
  transforms — most control, runs in CI.
- Figma plugins that export directly: **Token to Code** (DTCG + Flutter
  `ThemeExtension` output, pushes to Git), **Variables to Flutter/Dart Export**,
  **Variables2Flutter**.
- Dart‑side: `figma2flutter`.

Recommendation: commit the DTCG JSON to `tokens/`, generate Dart in CI, and fail
the build if generated code is out of date.

### 4.2 Catalog & previews
- **Widgetbook** – the shareable, deployable component gallery for designers,
  QA and PMs. **Widgetbook 4** (still maturing) introduces the
  **SAM (Story–Arg–Mode)** model: *stories* = component variants, *args* =
  typed knobs generated from the widget constructor via `build_runner`,
  *modes* = theme/locale/viewport combinations. Widgetbook Cloud adds PR
  visual review. Start on the stable line and plan a move to v4.
- **Flutter `@Preview`** (stable in 3.47) – zero‑dependency, in‑IDE previews;
  use `@MultiPreview` to show light/dark/text‑scale variants side by side.
  Good for authoring, not a replacement for a shared catalog.

### 4.3 Testing
- **`alchemist`** – the standard golden‑test library (replaced the discontinued
  `golden_toolkit`). Use CI‑mode goldens (platform‑agnostic) to avoid
  font‑rendering diffs between macOS and Linux runners.
- Golden matrix per component: theme (light/dark) × text scale (1.0, 2.0) ×
  key states.
- Widget tests for behavior + `meetsGuideline(textContrastGuideline)` /
  `androidTapTargetGuideline` / `labeledTapTargetGuideline` for a11y.

### 4.4 Monorepo
- **Dart pub workspaces** (Dart 3.6+) for a single resolution / lockfile.
- **Melos 7.x** for scripts: `melos run analyze`, `melos run test`,
  `melos run gen`, versioning & changelogs.

### 4.5 CI (GitHub Actions)
`format → analyze → token codegen check → unit/widget tests → goldens →
build & deploy Widgetbook (web) → publish packages on tag`.

---

## 5. Build vs. adopt: libraries worth studying

| Library | What it is | Take‑away for us |
|---|---|---|
| **Material (`material_ui`)** | Google's M3 / M3 Expressive | Best base: accessibility, i18n, platform behaviors for free. |
| **Forui** | shadcn/ui‑inspired, platform‑agnostic, desktop + touch (v0.27, requires Flutter 3.47) | Clean theming API and component styling model. |
| **Mix 2.0** | Styling system: fluent `Styler` APIs, variants (`onHovered`, `onDark`, breakpoints), animation, `@MixableToken` codegen | Could be our styling engine if we want to move away from Material styling. |
| **Moon Design** | Complete, themeable component set | Reference for component inventory & token naming. |
| **shadcn_flutter / shadcn_ui** | Other shadcn ports | Alternatives to Forui. |
| **Dievas** (GitHub) | Open‑source Melos DS monorepo with multi‑brand tokens + gallery | Closest reference to our proposed layout. |

Recommendation: **build on Material + our own tokens/components**. It gives the
widest compatibility with third‑party packages and keeps the option of
swapping the styling engine (e.g. Mix) later without changing component APIs.

---

## 6. Proposed roadmap

| Phase | Deliverables |
|---|---|
| **0. Setup** (week 1) | Workspace + Melos, lints, CI skeleton, Flutter `.gitignore` (current one is an AL/Dynamics template), ADR‑001 (this decision). |
| **1. Tokens** (weeks 1–2) | Figma Variables structure (primitive/semantic, light/dark), DTCG export, codegen into `ds_tokens`. |
| **2. Foundation** (week 2) | `ThemeExtension`s, `AppTheme.light()/dark()`, `context` accessors, typography & spacing scales. |
| **3. Core components** (weeks 3–5) | Button, IconButton, TextField, Checkbox/Radio/Switch, Card, Chip, Dialog/BottomSheet, Snackbar/Toast, AppBar, Avatar, Badge, Loading/Skeleton. |
| **4. Catalog & tests** (parallel) | Widgetbook app deployed to web; alchemist goldens + a11y tests in CI. |
| **5. Adoption** | Publish (private pub / git deps), migration guide, versioning policy (semver + changelog). |

---

## 7. Open questions for the team
1. Single brand or **multi‑brand** (white‑label)? Affects the semantic tier.
2. Platforms: mobile only, or also **web/desktop** (hover/focus/keyboard, density)?
3. Material look, **custom look**, or **adaptive** (Material on Android, Cupertino on iOS)?
4. Is there an existing **Figma file / brand guide** to derive tokens from?
5. Distribution: private pub server, git dependency, or public pub.dev?

---

## Sources
- [What's new in Flutter 3.47](https://flutter.dev/blog/whats-new-in-flutter-3-47)
- [Migrate to standalone material_ui and cupertino_ui packages](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui)
- [Code With Andrea – August 2026 newsletter](https://codewithandrea.com/newsletter/august-2026/)
- [freeCodeCamp – Material and Cupertino Decoupling handbook](https://www.freecodecamp.org/news/how-to-work-with-material-and-cupertino-decoupling-in-flutter-full-handbook/)
- [flutter/flutter#184093 – Material and Cupertino are now frozen](https://github.com/flutter/flutter/issues/184093)
- [Flutter 3.47 and Dart 3.13 – every change (Igniscor)](https://www.igniscor.com/post/flutter-3-47-and-dart-3-13)
- [Widgetbook – Building and maintaining high‑quality Flutter UIs with a design system](https://www.widgetbook.io/blog/building-and-maintaining-high-quality-flutter-uis-with-a-design-system)
- [Widgetbook – Custom design system](https://www.widgetbook.io/blog/custom-design-system)
- [Widgetbook 4 SAM architecture](https://docs.widgetbook.io/~1087/next/sam) · [widgetbook/widgetbook_4](https://github.com/widgetbook/widgetbook_4)
- [alchemist on pub.dev](https://pub.dev/packages/alchemist)
- [VGV – Design Systems at AI Speed: Figma‑to‑Flutter with Golden Tests](https://verygood.ventures/blog/figma-to-flutter-claude-code-skill-golden-tests/)
- [Token‑based design system in Flutter (Medium)](https://medium.com/@shahriarhu/building-a-token-based-design-system-in-flutter-that-actually-scales-280036aa3cd2)
- [Design tokens: naming, tiers, Figma‑to‑code (The Masterly)](https://www.themasterly.com/blog/design-tokens)
- [style-dictionary-figma-flutter](https://github.com/aloisdeniel/style-dictionary-figma-flutter)
- [Token to Code Figma plugin](https://www.figma.com/community/plugin/1656543523743847778/token-to-code-export-design-tokens-to-dtcg-flutter-swift-css-with-git)
- [Forui](https://forui.dev/) · [Mix](https://github.com/btwld/mix) · [Moon Design & others on Flutter Gems](https://fluttergems.dev/design-system/)
- [Dievas – Flutter DS monorepo](https://github.com/SerticodeInc/dievas)
- [Dart & Flutter monorepos: pub workspaces and Melos](https://lazebny.io/dart-flutter-workspaces/)
- [DCM – Flutter widget previewer](https://dcm.dev/blog/2025/12/15/flutter-widget-previewer/)
- [DCM – Practical accessibility in Flutter](https://dcm.dev/blog/2025/06/30/accessibility-flutter-practical-tips-tools-code-youll-actually-use/)

> Note: official flutter.dev pages could not be fetched directly from the
> research environment; release facts above come from search summaries of those
> pages and secondary coverage. Verify version numbers before pinning.

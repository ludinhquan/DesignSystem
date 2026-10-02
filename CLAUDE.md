# CLAUDE.md: working in the DesignSystem repo

One Flutter app (`app/`, a wallet) plus one design-system package
(`packages/ds`) in a Dart pub workspace. The design is
[`docs/research/architecture-review.md`](docs/research/architecture-review.md)
§3; [`README.md`](README.md) explains how auth, errors, l10n and the design
system work; [`docs/research/design-system-switching.md`](docs/research/design-system-switching.md)
explains why the design system is built the way it is.
Flutter **3.47.5** / Dart **3.13**.

## Commands (repo root)

```sh
flutter pub get                                   # whole workspace, one lockfile
dart format .                                     # CI: --set-exit-if-changed
flutter analyze --fatal-infos                     # infos fail CI too
(cd packages/ds && flutter test)                  # unit, widget, golden
(cd app && flutter test)
(cd app && flutter gen-l10n)                      # after editing any .arb
(cd packages/ds && dart run tool/gen_tokens.dart)  # after editing systems/*/tokens.json
(cd packages/ds && flutter test --update-goldens --tags golden)   # only for intended visual changes
(cd app && flutter run --dart-define-from-file=config/brand_a.dev.json)   # Pebble
(cd app && flutter run --dart-define-from-file=config/brand_b.dev.json)   # same app, Classic
```

## Layer rules (architecture-review §3.1)

```
app/lib/
  main.dart     composition root: the only place that wires vendors and overrides
  app.dart      MaterialApp.router, theme from the brand
  config/       env.dart (Env), brand.dart (Brand), brands/<brand>.dart
  core/         http, storage, router, analytics. Shared, no feature code
                (router.dart is the one exception: it assembles feature routes)
  features/<name>/
    data/       repositories, models, cross-feature state (e.g. sessionProvider)
    ui/         screens, widgets, screen-local controllers
    <name>_routes.dart   path constants + List<RouteBase>
  l10n/         ARB files, l10n.dart, gen/ (generated)
```

1. `ui/` may import `data/` and `core/`. `data/` never imports `ui/`.
   Features import other features **only through their `data/`** providers.
2. Screens are dumb widgets. Add a `*_controller.dart` (Notifier/AsyncNotifier)
   only when state is non-trivial; a one-shot fetch is a `FutureProvider`.
3. Repositories own API calls, caching and mapping, and throw `AppException`
   (`core/http.dart`). Wrap Dio calls in `guardHttp(...)`.
4. Vendor SDK imports live only in `core/` wrapper files or `main.dart`.
5. `ds` components read semantic tokens only, never raw colors. `ds` depends
   on Flutter, material_ui, intl and phosphoricons_flutter only (no app,
   vendor or HTTP code). `data/` never imports `ds`: map data enums (e.g.
   `AccountColor`) to design-system types in `ui/`.
6. No build_runner. Models use primary constructors and pattern-matching
   `fromJson`. Riverpod providers are written by hand (no generator).
7. A result type for expected outcomes, if one is ever added, is
   `sealed class Result<T>` with `Ok`/`Err`. **Never name a class `Error`**: it
   hides `dart:core`'s `Error`.

## Session rule

- `sessionProvider` (`features/auth/data/session_controller.dart`) is the
  **single source of auth state**. `AsyncData(null)` = logged out.
- **Every per-user provider must `ref.watch(sessionProvider)`** in its
  `build`, so logout (or another user logging in) rebuilds it from scratch.
  Examples: `walletProvider` and `balanceHiddenProvider` in
  `features/wallet/data/wallet_controller.dart`. Device settings such as the
  locale are not per-user and must not watch it.
- Never navigate after login/logout by hand. Change the session; the router's
  `redirect` (`core/router.dart`) moves the user.
- Logout goes through `sessionProvider.notifier.logout()` only. It clears
  tokens, calls `analytics.reset()` and sets `AsyncData(null)`.

## Errors and retries

- The UI shows `context.l10n.errorMessage(error)` (or a screen-specific
  message per `AppException` subtype). **Never show `error.toString()`.**
  `DsErrorView` takes an already-localized `message`.
- **Only Riverpod retries** (`ProviderScope(retry: retryPolicy)` in
  `main.dart`: Network/Server errors, 3 times). Do not add a Dio retry
  interceptor. Do not retry user actions.
- Analytics goes through `analyticsProvider`. Calls are fire-and-forget;
  `SafeAnalytics` isolates each vendor so one failing never breaks the others
  or the caller.

## l10n rules

- Every user-visible string comes from `app/lib/l10n/app_<lang>.arb` via
  `context.l10n`. Add each key to **every** ARB file (a test checks this),
  with an `@key` description in `app_en.arb`, then run `flutter gen-l10n` and
  commit `lib/l10n/gen/`.
- Brand names go through `{appName}` placeholders. No per-brand ARB files.
- `MaterialApp.localizationsDelegates` is `appLocalizationsDelegates`. Never
  `AppLocalizations.localizationsDelegates`: it brings the in-SDK Material
  delegate, which material_ui cannot see. material_ui ships its own
  `GlobalMaterialLocalizations.delegates`.
- `ds` has no translations. Its strings come from `DsLocalizations`, which the
  app fills from its `ds*` ARB keys. Debug builds assert the delegate exists.
  Package tests, goldens and previews use `DsLocalizations.englishDelegate`.

## Design system (packages/ds)

- **The contract** (`lib/src/foundation/`) is what every design system must
  define: `DsColors` (incl. six object fields by hue), `DsTypeScale`,
  spacing, radii, sizes, opacity, shadows, `DsMotion`, `DsIconSet`,
  corners. Components read only the contract, through `context.ds`
  (`ds.colors`, `ds.text`, `ds.spacing`, `ds.icons`, `ds.shape(r)`, ...).
- **Systems** (`pebble`, `classic`): `systems/<name>/tokens.json` (Design
  System artifact format, vendored verbatim) + `system.json` (hue slot →
  the system's field name) → generated `lib/src/systems/<name>/<name>_tokens.g.dart`
  + a hand-written `<name>.dart` (faces, motion, icons, corners).
  **Never edit `*.g.dart`.** Edit the JSON, run `dart run tool/gen_tokens.dart`,
  commit both. CI runs `--check`.
- **A brand picks its system** with `Brand.ds`. No `if (pebble)` anywhere.
- **Screens never name** a colour, size, font, icon font or radius: only
  `context.ds.*` and Ds* components. Component parameters describe intent
  (`variant`, `field`, `size`), never appearance.
- **New design need** → add a semantic token to the contract and to every
  system's `tokens.json` (the generator fails until each has it), then the
  component.
- **Every system is tested**: add it to `systems` in
  `packages/ds/test/helpers/themed.dart` and it gets the golden matrix and
  the WCAG contrast test. Keep both green.
- Interactive components: `Semantics(container: true, ..., onTap: ...)`
  with `excludeSemantics`, so screen readers get one node with a working
  tap action; tap targets ≥ `hit-target`; Reduce Motion handled (use
  `DsAnimatedSize`, `context.dsReduceMotion`).
- Haptics only through `DsHaptics` (systems can turn them off). Sheets only
  through `showDsSheet` (root navigator: above the tab bar).
- Money only through `DsMoney` / `DsMoneyFormat` (vi-VN grouping, true
  minus, inflows `positive`, never red spending).

## material_ui only

Import `package:material_ui/material_ui.dart` everywhere: app, `ds`, tests.
**Never** `package:flutter/material.dart` or `package:flutter/cupertino.dart`.
The two libraries define different `Theme`, `ThemeData` and
`MaterialLocalizations` types, so mixing them silently breaks theme and l10n
lookup. `app/test/material_ui_only_test.dart` enforces this. Third-party
tools still built on the in-SDK library (alchemist, the widget-preview shell)
get our material_ui `Theme` and `DsLocalizations` wrapped around the content
(`packages/ds/test/helpers/themed.dart`, `previews.dart`).

## Config

- `Env` reads every value with `const String.fromEnvironment(...)` from flat
  `app/config/<brand>.<env>.json` files (`--dart-define-from-file`). Public
  values only. Empty `API_URL` selects the fake repositories.
- Brand differences: first a field on `Brand`; if code must differ, a
  Riverpod override in `main.dart` keyed on the brand.

## Definition of done

A change is done when all of these hold:

- [ ] `dart format --set-exit-if-changed .`, `flutter analyze --fatal-infos`,
      and `flutter test` in `app/` and `packages/ds` pass locally.
- [ ] New behavior has tests: repository/controller logic through
      `ProviderContainer.test` with overrides (fakes, not mocks), screens with
      widget tests (`test/helpers/harness.dart`).
- [ ] No hard-coded user-visible strings; new keys exist in every ARB file and
      `lib/l10n/gen/` is regenerated.
- [ ] Errors reach the user as localized `AppException` messages, never
      `toString()`.
- [ ] New per-user providers watch `sessionProvider`.
- [ ] `ds` components: contract tokens only; goldens for every system in
      light and dark updated deliberately; contrast test green; tap targets
      ≥ `hit-target`; one semantics node with a label and tap action.
- [ ] README/CLAUDE.md updated if a rule, command or layout changed.

# DesignSystem

One Flutter app (a Vietnamese wallet) plus the design-system package it is
built on. Every brand is a **flavor** of the one app, and each brand picks a
**design system**: brand A is drawn in **Pebble**, brand B in **Classic**,
from the same screens. The design follows
[`docs/research/architecture-review.md`](docs/research/architecture-review.md)
(§3), with the fixes from
[`docs/research/flutter-app-architecture-analysis.md`](docs/research/flutter-app-architecture-analysis.md).

- Flutter **3.47.5** / Dart **3.13**, one Dart **pub workspace** (`app` + `packages/ds`), one lockfile
- **material_ui** instead of the frozen in-SDK `package:flutter/material.dart`
- Riverpod 3 (state + DI), go_router, Dio, gen-l10n. **No build_runner.**
- Design systems are data: a Design System `tokens.json` → generated Dart on
  one semantic contract ([why](docs/research/design-system-switching.md))
- Rules for contributors (and Claude Code): [`CLAUDE.md`](CLAUDE.md)

## Layout

```
DesignSystem/
├── pubspec.yaml               # workspace root: [app, packages/ds]
├── analysis_options.yaml      # shared lints for the whole workspace
├── app/                       # the ONE app (android, ios, web)
│   ├── config/                # brand_{a,b}.{dev,prod}.json (--dart-define-from-file)
│   ├── l10n.yaml              # gen-l10n settings
│   ├── lib/
│   │   ├── main.dart          # composition root: prefs, Sentry, ProviderScope(retry: ...)
│   │   ├── app.dart           # MaterialApp.router, theme from the brand, l10n delegates
│   │   ├── config/            # env.dart, brand.dart, brands/brand_a.dart (Pebble), brand_b.dart (Classic)
│   │   ├── core/              # http, storage, router, shell (tab bar), analytics, clock
│   │   ├── features/
│   │   │   ├── auth/          # data/ (repository, session), ui/ (login, splash), auth_routes.dart
│   │   │   ├── wallet/        # data/ (models, repository, controller), ui/ (home, cards, pay, activity, sheets)
│   │   │   └── profile/       # ui/ (profile: language, hide balances, logout)
│   │   └── l10n/              # app_en.arb, app_vi.arb, l10n.dart, gen/ (generated, committed)
│   └── test/
├── packages/ds/
│   ├── systems/<name>/        # tokens.json (Design System format) + system.json, per design system
│   ├── tool/gen_tokens.dart   # tokens.json → lib/src/systems/<name>/<name>_tokens.g.dart
│   ├── fonts/ assets/ licenses/   # Bricolage Grotesque, Inter, Fluent Emoji 3D (+ licences)
│   ├── lib/src/foundation/    # the contract: colours, type, metrics, shadows, motion, icons, DsSystem
│   ├── lib/src/systems/       # pebble/, classic/ (generated tokens + faces, motion, icons)
│   ├── lib/src/theme/         # DsTheme.light/dark(system), DsTokens (context.ds)
│   ├── lib/src/primitives/    # press, object material, glyph, haptics, ground, animated size
│   ├── lib/src/components/    # Ds* components
│   └── test/                  # golden matrix, contrast contract, behaviour, generator
├── docs/research/             # architecture research, reviews, design-system switching
└── .github/workflows/ci.yml   # format → token + l10n drift → analyze → tests
```

## Quick start

```sh
flutter pub get                       # resolves the whole workspace

cd app
flutter run --dart-define-from-file=config/brand_a.dev.json            # android / ios, Pebble
flutter run -d chrome --dart-define-from-file=config/brand_a.dev.json  # web, Pebble
flutter run -d chrome --dart-define-from-file=config/brand_b.dev.json  # web, the same app in Classic
```

With `API_URL` empty (the dev config) the app uses in-memory fakes:
**any email signs in; the password `wrong` shows the "wrong email or
password" error.** Each user gets a seeded wallet (three accounts, a week
of activity); transfers, top-ups and the demo payment change it for that
run. The token still goes to secure storage, so a restart keeps you signed
in.

## Checks (what CI runs)

Run from the repo root:

```sh
flutter pub get --enforce-lockfile
dart format --set-exit-if-changed .
(cd packages/ds && dart run tool/gen_tokens.dart --check)
(cd app && flutter gen-l10n && git diff --exit-code -- lib/l10n/gen)
flutter analyze --fatal-infos
(cd packages/ds && flutter test)
(cd app && flutter test)
```

Refresh goldens deliberately after a visual change:
`cd packages/ds && flutter test --update-goldens --tags golden`.
They are alchemist **CI-mode** goldens (text drawn as blocks), so they match on
macOS, Linux and Windows.

## Configuration

| What | Where | Example |
|---|---|---|
| Environment (`ENV`, `API_URL`, `SENTRY_DSN`) | `app/config/<brand>.<env>.json`, read with `const String.fromEnvironment` in `config/env.dart` | `--dart-define-from-file=config/brand_a.prod.json` |
| Brand (name, design system) | `app/lib/config/brands/<brand>.dart`, picked by `Brand.fromFlavor(appFlavor ?? BRAND)` | `brandA` (Pebble), `brandB` (Classic) |
| Language | saved in shared_preferences by `localeProvider` | Profile → Language |

Define files are flat key → value JSON and hold **public values only**:
everything in them ends up in the binary.

No native flavors are configured yet, so `appFlavor` is `null` and the
`BRAND` value in the define file picks the brand (this is also how web
selects one). Native flavors per brand are
[architecture-review.md §7](docs/research/architecture-review.md#7-new-branded-app-in-7-steps);
a native flavor, when present, wins over `BRAND`.

## How auth works

- `sessionProvider` (`features/auth/data/session_controller.dart`) is the only
  auth state: `AsyncData(null)` means logged out. `logout()` clears the tokens,
  calls `analytics.reset()` and sets `AsyncData(null)`.
- Every per-user provider watches `sessionProvider`, so logging out rebuilds
  all user state from scratch (see `tapCountProvider`).
- `core/router.dart` redirects on every session change: restoring →
  `/splash`, logged out → `/login?from=<path>`, logged in → back to `from`
  (same-app paths only).
- `core/http.dart` adds the bearer token, and on a 401 refreshes **once**
  (concurrent 401s share one refresh) and replays the request. A rejected
  refresh logs out; an unreachable one keeps the session and reports
  `NetworkException`.
- With `API_URL` set, `HttpAuthRepository` expects:

  | Request | Response |
  |---|---|
  | `POST /auth/login {email, password}` | `{access_token, refresh_token, user: {id, email, name}}`, 401 for bad credentials |
  | `POST /auth/refresh {refresh_token}` | `{access_token, refresh_token}`, 4xx when rejected |
  | `POST /auth/logout {refresh_token}` | anything (best effort) |
  | `GET /me` | `{id, email, name}` |

### Errors and retries

Repositories throw the sealed `AppException` (`Network`, `Unauthorized`,
`Server`, `Request`, `Unknown`); Dio errors are mapped once in
`AppException.fromDio`. The UI maps each subtype to a localized message with
`l10n.errorMessage(error)` and never shows `toString()`.

**Only Riverpod retries.** `main.dart` passes `ProviderScope(retry: retryPolicy)`,
which retries `NetworkException`/`ServerException` 3 times (0.5 s, 1 s, 2 s)
and nothing else. There is no Dio retry interceptor, so a failing request runs
at most 4 times. User actions such as login are never retried.

## Localization (English + Vietnamese)

gen-l10n is built into the flutter tool. Add a string to
`app/lib/l10n/app_en.arb` (with an `@key` description) and to every other
`app_<lang>.arb`, then run `flutter gen-l10n` in `app/` and commit the
generated files. Use it with `context.l10n.key`. A test fails when an ARB file
is missing a key.

- Brand names go in through placeholders (`"loginTitle": "Sign in to {appName}"`),
  not per-brand ARB files.
- Design-system strings (loading labels, error title and retry, sheet
  close, how amounts and cards are read aloud: "âm 65.000 đồng") come from
  `DsLocalizations`, which the app fills from its own `ds*` ARB keys.
- **material_ui ships its own localizations.** `material_ui` 1.5.0 exports its
  own `GlobalMaterialLocalizations` (Vietnamese included) for its own
  `MaterialLocalizations` type. The app installs
  `GlobalMaterialLocalizations.delegates` from material_ui (via
  `appLocalizationsDelegates` in `lib/l10n/l10n.dart`). Do **not** use the
  generated `AppLocalizations.localizationsDelegates`: it lists
  `flutter_localizations`' in-SDK Material delegate, and with it material_ui
  finds no `MaterialLocalizations` for `vi` at all (`test/l10n_test.dart`
  shows this).

To add a language: add `app_<lang>.arb` with every key, then check that
material_ui supports it (`kMaterialSupportedLanguages`).

## The design system

`packages/ds` separates **what any design system must define** (the
contract) from **the values one system gives it**:

| Part | Where | Edited by |
|---|---|---|
| Contract: `DsColors` (24 semantic colours + 6 object fields by hue), `DsTypeScale` (20 roles), spacing, radii, sizes, opacity, shadows, `DsMotion`, `DsIconSet`, corners | `lib/src/foundation/` | Hand, rarely |
| A system's values | `systems/<name>/tokens.json` (claude.ai Design System format, vendored verbatim) + `system.json` | The design tool |
| Generated Dart | `lib/src/systems/<name>/<name>_tokens.g.dart` | `dart run tool/gen_tokens.dart` |
| What tokens can't say: faces and variable axes, springs, icon family, corners, haptics | `lib/src/systems/<name>/<name>.dart` | Hand (mostly the 33-glyph icon map) |

The two systems:

- **Pebble** (from [the Design System artifact](https://claude.ai/artifact/HfyPF9wTVPvvxvtxqqpEeK)):
  warm daylight neutrals, a marigold accent, accounts as tactile cards
  (gradient, grain, lit edge, tinted shadow, specular), Bricolage Grotesque
  for money (variable `opsz`/`wdth`/`wght`, tabular figures), SF Pro on iOS
  and Inter on Android for UI, Phosphor icons, Fluent Emoji 3D for
  categories, superellipse corners, springs with a little bounce, haptics.
- **Classic**: the original calm blue/slate system rewritten on the same
  contract: platform faces, Material icons, circular corners, flat objects,
  no bounce, no haptics.

```dart
import 'package:ds/ds.dart';

MaterialApp(
  theme: DsTheme.light(pebble),          // or brand.ds; classic works the same
  darkTheme: DsTheme.dark(pebble),
  localizationsDelegates: appLocalizationsDelegates,   // includes DsLocalizations
  home: Builder(
    builder: (context) {
      final ds = context.ds;              // the contract, for this theme
      return DsButton(
        label: 'Gửi 250.000 ₫',
        icon: ds.icons.send,
        variant: DsButtonVariant.prominent,
        onPressed: send,
      );
    },
  ),
);
```

**Components**: `DsMoney` (vi-VN grouping, true minus, the raised ₫,
masked, rolling digits), `DsButton` (prominent/secondary/soft/plain/
destructive), `DsIconButton`, `DsChip`, `DsMonogram`, `DsToggle`,
`DsSegmentedControl`, `DsTextField`, `DsAmountField`, `DsAccountCard`,
`DsCardStack`, `DsIconTile` (glyph or 3D emoji), `DsListItem` (settings /
content), `DsListSection` (plain / grouped), `DsEmptyState`,
`DsNavigationBar` (home / large / inline), `DsTabBar` (floating glass),
`showDsSheet`/`DsSheet`, `DsTapToPay`, `DsCard`, `DsLoading`, `DsErrorView`.
Widget previews: `flutter widget-preview start` in `packages/ds`.

**Switching or adding a system**: drop its `tokens.json` in
`systems/<name>/`, write `system.json` and `<name>.dart`, run the generator,
add it to `systems` in `test/helpers/themed.dart` (it then gets 14 goldens
and the contrast test), and point a `Brand` at it. Details and limits:
[`docs/research/design-system-switching.md`](docs/research/design-system-switching.md).

## Known gaps

- No native flavors yet; brands are picked with `BRAND`. Android and iOS
  builds were not run in the environment that set this up (no Android SDK or
  Xcode); both brands were built for web and driven end to end in Chromium.
- Pebble pieces not built yet (each needs a package the architecture keeps
  out for now): card tilt from the gyroscope with a moving specular
  (`sensors_plus`), spring heroes card → detail (`heroine`), the presenting
  screen scaling behind a sheet, the per-digit rise in the AmountField. The
  monthly face shift mixes in RGB, not OKLab.
- `flutter build web` prints a warning that the `CupertinoIcons` font is
  missing. It comes from code in `cupertino_ui` (a material_ui dependency); the
  app shows no Cupertino icons. Add `cupertino_icons` if one is ever used.

# DesignSystem

One Flutter app plus the design-system package it is built on. Every brand
is a **flavor** of the one app. The design follows
[`docs/research/architecture-review.md`](docs/research/architecture-review.md)
(§3), with the fixes from
[`docs/research/flutter-app-architecture-analysis.md`](docs/research/flutter-app-architecture-analysis.md).

- Flutter **3.47.5** / Dart **3.13**, one Dart **pub workspace** (`app` + `packages/ds`), one lockfile
- **material_ui** instead of the frozen in-SDK `package:flutter/material.dart`
- Riverpod 3 (state + DI), go_router, Dio, gen-l10n. **No build_runner.**
- Rules for contributors (and Claude Code): [`CLAUDE.md`](CLAUDE.md)

## Layout

```
DesignSystem/
├── pubspec.yaml               # workspace root: [app, packages/ds]
├── analysis_options.yaml      # shared lints for the whole workspace
├── app/                       # the ONE app (android, ios, web)
│   ├── config/                # brand_a.dev.json, brand_a.prod.json (--dart-define-from-file)
│   ├── l10n.yaml              # gen-l10n settings
│   ├── lib/
│   │   ├── main.dart          # composition root: prefs, Sentry, ProviderScope(retry: ...)
│   │   ├── app.dart           # MaterialApp.router, theme from the brand, l10n delegates
│   │   ├── config/            # env.dart, brand.dart, brands/brand_a.dart
│   │   ├── core/              # http.dart, storage.dart, router.dart, analytics.dart
│   │   ├── features/
│   │   │   ├── auth/          # data/ (repository, session), ui/ (login, splash), auth_routes.dart
│   │   │   └── home/          # ui/ (home, language switch, tap counter), home_routes.dart
│   │   └── l10n/              # app_en.arb, app_vi.arb, l10n.dart, gen/ (generated, committed)
│   └── test/
├── packages/ds/               # tokens, DsTheme from DsBrand, Ds* components, goldens
├── docs/research/             # architecture research and reviews
└── .github/workflows/ci.yml   # format → l10n drift → analyze → tests
```

## Quick start

```sh
flutter pub get                       # resolves the whole workspace

cd app
flutter run --dart-define-from-file=config/brand_a.dev.json            # android / ios
flutter run -d chrome --dart-define-from-file=config/brand_a.dev.json  # web
```

With `API_URL` empty (the dev config) the app uses an in-memory fake backend:
**any email signs in; the password `wrong` shows the "wrong email or
password" error.** The token still goes to secure storage, so a restart keeps
you signed in.

## Checks (what CI runs)

Run from the repo root:

```sh
flutter pub get --enforce-lockfile
dart format --set-exit-if-changed .
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
| Brand (name, `DsBrand` colors/font/radius) | `app/lib/config/brands/<brand>.dart`, picked by `Brand.fromFlavor(appFlavor)` | `brandA` |
| Language | saved in shared_preferences by `localeProvider` | EN / VI switch on home |

Define files are flat key → value JSON and hold **public values only**:
everything in them ends up in the binary.

Only `brand_a` exists today and no native flavors are configured yet, so
`appFlavor` is `null` and selects brand A. Adding brand B is
[architecture-review.md §7](docs/research/architecture-review.md#7-new-branded-app-in-7-steps):
native flavor, `brands/brand_b.dart` + one `case` in `Brand.fromFlavor`,
`config/brand_b.*.json`, then `flutter run --flavor brand_b ...`.

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
- Design-system strings (`DsButton` loading label, `DsErrorView` title and
  retry, `DsLoading`) come from `DsLocalizations`, which the app fills from its
  own ARB keys (`dsLoading`, `dsErrorTitle`, `dsRetry`).
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

## Using the design system

```dart
import 'package:ds/ds.dart';
import 'package:material_ui/material_ui.dart';

MaterialApp(
  theme: DsTheme.light(brand.ds),    // ColorScheme + TextTheme + DsTokens from a DsBrand
  darkTheme: DsTheme.dark(brand.ds),
  localizationsDelegates: [myDsLocalizationsDelegate, ...GlobalMaterialLocalizations.delegates],
  home: Builder(
    builder: (context) => Padding(
      padding: EdgeInsetsDirectional.all(context.ds.spacing.md),
      child: DsButton(label: context.l10n.save, onPressed: save),
    ),
  ),
);
```

Components: `DsButton` (primary/secondary/ghost, sm/md/lg, `loading`),
`DsCard`, `DsErrorView(message: ...)`, `DsLoading`. Widget previews:
`flutter widget-preview start` in `packages/ds`.

## Known gaps

- No native flavors yet (one brand). Android and iOS builds were not run in
  the environment that set this up (no Android SDK or Xcode); the web build
  was built and driven end to end in Chromium.
- `flutter build web` prints a warning that the `CupertinoIcons` font is
  missing. It comes from code in `cupertino_ui` (a material_ui dependency); the
  app shows no Cupertino icons. Add `cupertino_icons` if one is ever used.

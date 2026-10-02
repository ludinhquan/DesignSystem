# Research: Scalable, Clean Flutter App Architecture (White-Label Ready)

_Researched: October 2026 · Flutter 3.47 / Dart 3.13_

Goal: one codebase and toolchain that lets us **launch a new app by changing
config, brand and content** (not code), and lets us **extend** features or
swap third-party providers without touching the rest of the app.

Companion doc: [`flutter-design-system.md`](./flutter-design-system.md) (tokens,
theming, components).

---

## 1. TL;DR – The decisions

| Concern | Decision | Why |
|---|---|---|
| Architecture style | **Flutter's official layered MVVM** (View → ViewModel → Repository → Service), plus an **optional domain layer** only where logic is shared | Official guidance, smallest amount of ceremony that still scales |
| Code organization | **Feature-first**, inside a **monorepo of packages** (pub workspaces + Melos) | Boundaries are enforced by the compiler, not by discipline |
| App shells | `apps/<brand>/` are **thin**: config + assets + composition root. All code lives in `packages/` | "Clone and launch" = new folder + config, no forking |
| State management | **Riverpod 3** (default). **Bloc 9** if the team is large / needs event audit trails. Pick one, never mix | Riverpod: compile-time safety, low boilerplate, also serves as DI |
| Async & errors | Sealed **`Result<T>`** (Ok/Error) from repositories; **Command** objects in ViewModels for running/error/done states | Official Flutter patterns; no exceptions leak into UI |
| Models | **freezed 3 + json_serializable**; DTOs ≠ domain models | Immutability, pattern matching, API changes don't ripple into UI |
| Backend API | **OpenAPI → generated Dio/Retrofit client** in its own package | API changes = regenerate, compiler shows what broke |
| Third-party SDKs | **Ports & adapters**: interfaces in `core`, one adapter package per vendor | Swap Firebase ↔ Sentry ↔ Mixpanel per brand with config |
| Routing | **go_router + go_router_builder (typed routes)**; each feature contributes its own routes | Compile-checked navigation, deep links for free |
| Config | `--flavor` for native IDs/icons + **`--dart-define-from-file`** for Dart config; **remote config / CMS** for content | Content changes without a store release |
| Offline | Repository = cache owner; **Drift** (SQLite) when offline-first is required | Local DB as UI source of truth |
| Scaffolding | **Mason bricks** for `new app` and `new feature` (Very Good CLI for the base) | Every feature/app looks the same → fast onboarding, AI-friendly |

---

## 2. Layering (the dependency rule)

```
 ┌──────────── UI layer ─────────────┐
 │  View (widgets, no logic)         │
 │      ▼ listens / calls commands   │
 │  ViewModel (state + Commands)     │
 └──────────────┬────────────────────┘
                ▼
 ┌──────── Domain (optional) ────────┐
 │  Use cases: logic reused by ≥2    │
 │  ViewModels or combining repos    │
 └──────────────┬────────────────────┘
                ▼
 ┌──────────── Data layer ───────────┐
 │  Repository (source of truth:     │
 │    caching, retry, mapping DTO→   │
 │    model, returns Result<T>)      │
 │      ▼                            │
 │  Services / Data sources          │
 │    (API client, DB, SDK adapter)  │
 └───────────────────────────────────┘
```

Rules:
1. Arrows only point **down**. A Service never imports a ViewModel; a View
   never imports a Repository directly.
2. **Views** hold only display logic (layout, show/hide, animation).
3. **ViewModels** hold UI state and expose **Commands** (`Command0`,
   `Command1<T>`) whose `running / error / completed` states drive the UI.
4. **Repositories** are the single source of truth per data type, return
   `Result<T>`, own caching/retry, and map DTOs to app models.
5. **Services** are thin wrappers over one data source each (REST endpoint
   group, local DB, a vendor SDK). No business logic.
6. **Domain/use cases are optional.** Add them when logic is reused or
   combines several repositories — not by default. (This is where "clean
   architecture" projects usually over-engineer.)

### 2.1 Result and Command (official Flutter patterns)
```dart
sealed class Result<T> {
  const Result();
  const factory Result.ok(T value) = Ok<T>;
  const factory Result.error(AppFailure failure) = Error<T>;
}
final class Ok<T> extends Result<T> { const Ok(this.value); final T value; }
final class Error<T> extends Result<T> { const Error(this.failure); final AppFailure failure; }

// Typed failures instead of raw exceptions
sealed class AppFailure { const AppFailure(); }
final class NetworkFailure extends AppFailure { const NetworkFailure(); }
final class UnauthorizedFailure extends AppFailure { const UnauthorizedFailure(); }
final class ServerFailure extends AppFailure { const ServerFailure(this.code); final int code; }
final class UnknownFailure extends AppFailure { const UnknownFailure(this.error); final Object error; }
```
```dart
// UI unwraps exhaustively – the compiler forces error handling
switch (await repo.getProfile()) {
  case Ok(:final value):  state = ProfileState.loaded(value);
  case Error(:final failure): state = ProfileState.failed(failure);
}
```

---

## 3. Repository / folder structure

Builds on the design-system skeleton already in this repo (`tokens/`,
`packages/ds_*`, `apps/example`).

```
DesignSystem/                       # (rename later, e.g. "app-platform")
├── pubspec.yaml                    # pub workspace root + melos scripts
├── CLAUDE.md                       # rules for AI agents (layers, naming, DoD)
├── tokens/                         # design tokens (DTCG JSON) – per brand overrides below
├── bricks/                         # Mason templates
│   ├── app/                        #   `mason make app`     → new branded app
│   └── feature/                    #   `mason make feature` → new feature package
├── packages/
│   ├── core/                       # NO Flutter UI. Result, AppFailure, logging,
│   │                               #   AppConfig, FeatureFlags, ports (interfaces)
│   ├── core_flutter/               # Flutter glue: router base, l10n, error widgets
│   ├── ds_tokens/ ds_foundation/ ds_components/   # design system
│   ├── api_client/                 # GENERATED from openapi.yaml (Dio + Retrofit + freezed)
│   ├── data/                       # shared repositories (auth, user, content), Drift DB
│   ├── features/
│   │   ├── auth/                   # each feature = its own package
│   │   │   └── lib/
│   │   │       ├── auth.dart               # public API: AuthModule only
│   │   │       └── src/
│   │   │           ├── data/               # feature-only repos/services/DTOs
│   │   │           ├── domain/             # (optional) use cases, models
│   │   │           ├── ui/
│   │   │           │   ├── login/          # login_screen.dart, login_view_model.dart
│   │   │           │   └── widgets/
│   │   │           └── routes.dart         # typed routes for this feature
│   │   ├── home/  catalog/  checkout/  profile/  settings/ ...
│   └── integrations/               # one adapter package per vendor (ports & adapters)
│       ├── analytics_firebase/  analytics_mixpanel/
│       ├── crash_sentry/  crash_crashlytics/
│       ├── payments_stripe/  push_fcm/  auth_firebase/  auth_supabase/
│       └── content_contentful/  content_strapi/  remote_config_firebase/
├── apps/                           # THIN shells – no business code
│   ├── brand_a/
│   │   ├── lib/main.dart           # composition root (≈50 lines)
│   │   ├── config/
│   │   │   ├── app.dev.json  app.stg.json  app.prod.json   # --dart-define-from-file
│   │   │   └── brand.yaml          # name, ids, features on/off, vendors, theme
│   │   ├── tokens/                 # brand token overrides (colors, fonts)
│   │   ├── assets/                 # logo, icons, fonts, splash
│   │   ├── android/ ios/ web/      # flavors: dev/stg/prod
│   │   └── test/                   # smoke + integration tests
│   ├── brand_b/
│   └── widgetbook/
├── tool/                           # gen_tokens.dart, new_app.dart, ci scripts
└── .github/workflows/              # CI per package, CD per app × flavor
```

Why packages per feature (and not just folders)?
- A feature **can only use what its `pubspec.yaml` declares** → layering is
  enforced by the compiler.
- `lib/src/` is private; the barrel file exports only the `FeatureModule`.
- Build/test only what changed (`melos run test --diff=origin/main`).
- A brand app opts in to a feature by adding one dependency + one line.

Small project? Start with the same layout **as folders inside one app**
(`lib/core`, `lib/features/<x>/{data,ui}`) and promote to packages when a
second app appears. The rules are identical, so the move is mechanical.

---

## 4. Extensibility: the Feature Module contract

Each feature exposes one object; the app composes the ones it wants.

```dart
// packages/core_flutter/lib/src/feature_module.dart
abstract interface class FeatureModule {
  String get id;                                   // "checkout"
  List<RouteBase> get routes;                      // typed go_router routes
  List<Override> get overrides => const [];        // Riverpod DI overrides
  Future<void> init(AppConfig config) async {}     // optional startup work
  List<NavDestination> get navDestinations => const []; // tabs/menu entries
}
```

```dart
// apps/brand_a/lib/main.dart – composition root
Future<void> main() async {
  final config = AppConfig.fromEnvironment();            // --dart-define-from-file
  final modules = <FeatureModule>[
    AuthModule(),
    HomeModule(),
    if (config.features.checkout) CheckoutModule(),
    if (config.features.loyalty) LoyaltyModule(),
  ];
  for (final m in modules) { await m.init(config); }

  runApp(ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(config),
      analyticsProvider.overrideWithValue(CompositeAnalytics([
        FirebaseAnalyticsAdapter(),
        if (config.vendors.mixpanelToken != null)
          MixpanelAdapter(config.vendors.mixpanelToken!),
      ])),
      crashReporterProvider.overrideWithValue(SentryCrashReporter(config.vendors.sentryDsn)),
      ...modules.expand((m) => m.overrides),
    ],
    child: PlatformApp(modules: modules, theme: BrandTheme.fromTokens()),
  ));
}
```

Extension points, from cheapest to most expensive:

| Level | What changes | How | Rebuild? |
|---|---|---|---|
| 1. **Content** | Texts, banners, menus, products, legal pages | Headless CMS / Remote Config through `ContentRepository` | **No** |
| 2. **Flags** | Turn a feature/section on or off, A/B tests | Remote Config / `FeatureFlags` port | **No** |
| 3. **Brand** | Colors, fonts, radius, logo, app name, icon | `tokens/` overrides + `assets/` + `brand.yaml` | Yes (config only) |
| 4. **Composition** | Which features/vendors are included | `main.dart` module list + adapters | Yes (≈1 line each) |
| 5. **Override** | Brand-specific behavior of an existing feature | Provide a different implementation through DI override | Yes (small code) |
| 6. **New feature** | Something genuinely new | `mason make feature` → new package | Yes |

Most new apps should need **levels 1–4 only**.

Server-driven UI: for screens that change often (home, promotions), render
sections from CMS JSON with a registry of known `ds_components`
(`"type": "banner" → AppBanner`). Official `rfw` (Remote Flutter Widgets)
exists for fully dynamic layouts, but a typed section registry is safer and
enough for most cases.

---

## 5. Launching a new app ("clone and change content")

Target: **under one day** from zero to a TestFlight/Play internal build.

```bash
mason make app --name brand_c --bundle_id com.acme.brandc --display_name "Brand C"
# → apps/brand_c with flavors dev/stg/prod, config/*.json, brand.yaml, CI job
```
Then:
1. Edit `apps/brand_c/config/brand.yaml` – features on/off, vendors.
2. Drop tokens (colors/fonts from Figma) into `apps/brand_c/tokens/`
   → `melos run gen`.
3. Replace `assets/` (logo, icon, splash) → `dart run flutter_launcher_icons`,
   `flutter_native_splash`.
4. Fill `config/app.*.json` (API base URL, public keys, CMS space id).
5. Create CMS space / Remote Config project from a seed export.
6. `flutter run --flavor dev -t lib/main.dart --dart-define-from-file=config/app.dev.json`
7. CI picks the new app up automatically (matrix over `apps/*`); Fastlane or
   Codemagic handles signing & store upload.

Tools: `flutter_flavorizr` (generates Android productFlavors / iOS schemes
from YAML – teams run 70+ flavors with it), `flutter_launcher_icons`,
`flutter_native_splash`, Mason, Very Good CLI.

---

## 6. Third-party APIs and SDKs

### 6.1 Your own backend (REST/GraphQL)
- Keep `openapi.yaml` in the repo (or pull it in CI) and **generate**
  `packages/api_client` (`openapi_retrofit_generator` → Dio + Retrofit +
  freezed/json_serializable). GraphQL: `ferry` or `graphql_codegen`.
- **Dio interceptors** in one place: auth header, **token refresh with a
  queue/lock**, retry with backoff for idempotent requests, logging (dev
  only), `Accept-Language`, request ID.
- Map errors **once** (Dio exception → `AppFailure`) inside the repository
  base class; UI never sees `DioException`.
- DTOs stay in `api_client`; repositories map them to app models. Backend
  renames a field → one mapper changes.
- Parse large JSON off the UI thread (`Isolate.run`).

### 6.2 Vendor SDKs – ports & adapters
Define what the **app** needs, not what the vendor offers:

```dart
// packages/core/lib/src/ports/analytics.dart
abstract interface class Analytics {
  Future<void> track(AnalyticsEvent event);
  Future<void> identify(String userId, {Map<String, Object?> traits});
  Future<void> reset();
}

// Typed events – no stringly-typed names scattered in features
sealed class AnalyticsEvent { const AnalyticsEvent(this.name); final String name; }
final class ProductViewed extends AnalyticsEvent {
  const ProductViewed(this.productId) : super('product_viewed');
  final String productId;
}

// Fan-out to many vendors
final class CompositeAnalytics implements Analytics {
  CompositeAnalytics(this._delegates);
  final List<Analytics> _delegates;
  @override
  Future<void> track(AnalyticsEvent e) async =>
      Future.wait(_delegates.map((d) => d.track(e)));
  // identify/reset likewise
}
```

Ports worth defining up front:

| Port (in `core`) | Typical adapters |
|---|---|
| `Analytics` | Firebase Analytics, Mixpanel, Amplitude, PostHog, `ConsoleAnalytics` (dev), `FakeAnalytics` (tests) |
| `CrashReporter` | Sentry, Crashlytics |
| `AuthProvider` | Firebase Auth, Supabase, Auth0, custom backend |
| `PushNotifications` | FCM, OneSignal |
| `PaymentGateway` | Stripe, in-app purchase (`in_app_purchase` / RevenueCat) |
| `ContentSource` | Contentful, Storyblok, Sanity, Strapi, Directus, local JSON |
| `RemoteConfig` / `FeatureFlags` | Firebase Remote Config, LaunchDarkly, ConfigCat, Unleash |
| `KeyValueStore` / `SecureStore` | shared_preferences, flutter_secure_storage |
| `Maps`, `DeepLinks`, `Storage`, `Chat`… | as needed |

Rules:
- Vendor packages are imported **only** inside `packages/integrations/*`.
  Enforce with an import lint (DCM `avoid-banned-imports` or `custom_lint`).
- Every port has a **fake** used by tests, Widgetbook and offline demos.
- Initialize vendors in the composition root, wire global error handlers
  (`FlutterError.onError`, `PlatformDispatcher.instance.onError`) to the
  `CrashReporter` port.
- **Secrets:** nothing secret in the app binary (anything shipped can be
  extracted). Only public client keys go in `--dart-define-from-file`;
  secret-bearing calls go through your backend. Use `--obfuscate
  --split-debug-info` for release builds.

---

## 7. Recommended package stack (Oct 2026)

| Purpose | Package(s) |
|---|---|
| State + DI | `flutter_riverpod` 3 (+ `riverpod_generator` optional) — or `flutter_bloc` 9 + `get_it` |
| Models / JSON | `freezed` 3, `json_serializable`, `build_runner` |
| HTTP | `dio` + `retrofit`, generated via `openapi_retrofit_generator` |
| Routing | `go_router` + `go_router_builder` |
| Local DB / cache | `drift` (relational, reactive), `shared_preferences`, `flutter_secure_storage` |
| i18n | `flutter_localizations` + `gen-l10n` (ARB) or `slang` |
| Design system | this repo's `ds_*` packages on `material_ui` |
| Testing | `flutter_test`, `mocktail`, `alchemist` (goldens), `patrol` (E2E) |
| Lints | `very_good_analysis` or `flutter_lints` + DCM |
| Monorepo | pub workspaces + `melos` 7 |
| Scaffolding | `mason_cli`, `very_good_cli` |
| Flavors / assets | `flutter_flavorizr`, `flutter_launcher_icons`, `flutter_native_splash` |
| Observability | `sentry_flutter` or `firebase_crashlytics`, + analytics adapters |
| CI/CD | GitHub Actions + Fastlane, or Codemagic; optional Shorebird for code push |

Verify exact versions on pub.dev before pinning.

---

## 8. Performance checklist ("optimized")

- `const` constructors everywhere possible; enable `prefer_const_*` lints.
- Keep rebuilds local: `select`/`watch` the smallest piece of state;
  split big widgets into smaller widgets (not helper methods).
- Lists: `ListView.builder` / slivers, `itemExtent` or
  `prototypeItem` when sizes are known.
- Images: correct `cacheWidth/cacheHeight`, `cached_network_image`, CDN
  resizing from the CMS.
- Heavy work (JSON > ~100 KB, crypto, image processing) in `Isolate.run`.
- Avoid `Opacity`/`saveLayer`/clips in animations; use `RepaintBoundary`
  around frequently changing areas.
- Startup: lazy-init vendor SDKs not needed for the first frame; deferred
  imports (`deferred as`) for big features on web.
- Measure, don't guess: DevTools performance & memory, `flutter build
  --analyze-size`, run in `--profile` on a real low-end device.
- Impeller is default on mobile and now desktop; test shaders/animations on it.

---

## 9. Quality gates (how a "10x" team stays fast)

1. **Conventions encoded, not documented**: Mason bricks for app/feature,
   lints for imports & layers, codegen for tokens/API/routes.
2. **Fast feedback**: format + analyze + unit tests < 3 min on PR; goldens and
   E2E in a parallel job; only changed packages are tested.
3. **Testing pyramid**: many unit tests (ViewModels with fake repos,
   repositories with fake services), widget + golden tests for UI, a few
   Patrol E2E smoke tests per app.
4. **ADRs** in `docs/adr/` for every major choice (state mgmt, vendors).
5. **`CLAUDE.md`** describing layers, folder rules, naming, and the
   definition of done, so AI agents generate code that fits the architecture.
6. **Release safety**: flavors dev/stg/prod, feature flags for risky work,
   staged rollouts, crash-free-sessions alert.

---

## 10. Suggested next steps for this repo

1. Agree on: Riverpod vs Bloc · single app now or multi-brand · backend type
   (REST/OpenAPI, GraphQL, Firebase/Supabase) · CMS choice.
2. Add `packages/core` (Result, AppFailure, AppConfig, ports + fakes) and
   `packages/core_flutter` (FeatureModule, router assembly).
3. Turn `apps/example` into the first brand shell with flavors and
   `--dart-define-from-file` config.
4. Write the `feature` and `app` Mason bricks; generate `auth` and `home`
   features with them.
5. Add one real integration per port category used (e.g. Sentry + Firebase
   Analytics) and the fakes.
6. CI matrix over `apps/*` × flavors.

---

## Sources
- Flutter docs – [Architecture design patterns](https://docs.flutter.dev/app-architecture/design-patterns), [Case study](https://docs.flutter.dev/app-architecture/case-study), [Data layer](https://docs.flutter.dev/app-architecture/case-study/data-layer), [UI layer](https://docs.flutter.dev/app-architecture/case-study/ui-layer), [Command pattern](https://docs.flutter.dev/app-architecture/design-patterns/command), [Result objects](https://docs.flutter.dev/app-architecture/design-patterns/result)
- [Code With Andrea – Repository pattern](https://codewithandrea.com/articles/flutter-repository-pattern/)
- [Clean Architecture in Flutter 2026 (DEV)](https://dev.to/techwithsam/clean-architecture-in-flutter-2026-practical-implementation-guide-1dfb) · [Flutter Clean Architecture guide 2026 (Flutter Studio)](https://flutterstudio.dev/blog/flutter-clean-architecture.html) · [Riverpod 2026 playbook](https://sachinsharma.dev/blogs/flutter-riverpod-2-architecture-2026)
- [Riverpod 3 vs BLoC vs Signals 2026](https://theflutterk.it.com/blog/flutter-riverpod-3-vs-bloc-vs-signals-2026) · [Riverpod 3 vs BLoC 9 (SharpSkill)](https://sharpskill.dev/en/blog/flutter/flutter-state-management-riverpod-vs-bloc) · [Provider vs Riverpod vs Bloc 2026](https://startdebugging.net/2026/06/provider-vs-riverpod-vs-bloc-for-flutter-state-management-in-2026/)
- [Taming 70 Flutter flavors with flavorizr](https://dev.to/kamero/taming-70-flutter-flavors-flavorizr-batch-ci-for-white-label-releases-54fl) · [White-label Flutter: one codebase, two stores](https://smartnet.rs/blog/white-label-flutter-mobile-app) · [White-label: build variants vs dependencies](https://medium.com/newsoft-official/flutter-white-labeling-buildvariants-vs-dependencies-d7758983affb) · [white-label template example](https://github.com/AlphaCryptoDev/whitelabel_app_template)
- [Configuring apps with --dart-define-from-file](https://www.monterail.com/blog/configuring-flutter-apps-using-dart-define-from-file) · [Flavors & environments](https://sagnikbhattacharya.com/blog/flutter-flavors-environments)
- [go_router typed routes 2026](https://theflutterk.it.com/blog/flutter-go-router-typed-routes-2026) · [VGV routing best practices](https://verygood.ventures/blog/routing-best-practices-in-flutter/)
- [Modern Flutter best practices 2026](https://dev.to/hamberluo/modern-flutter-best-practices-for-2026-56o3) · [openapi_retrofit_generator](https://github.com/open-runtime/openapi_retrofit_generator)
- [Offline-first sync with Drift & Riverpod](https://dev.to/mohamed_haizoun_ca3869828/offline-first-sync-in-flutter-with-drift-and-riverpod-5een) · [Offline-first practical guide](https://777genius.medium.com/offline-first-flutter-a-practical-guide-to-data-synchronization-5c37ee657755)
- [rfw (Remote Flutter Widgets)](https://fluttergems.dev/packages/rfw/) · [Headless CMS for Flutter 2026](https://unfoldcms.com/blog/headless-cms-for-flutter)
- [Crashlytics for Flutter](https://firebase.flutter.dev/docs/crashlytics/overview/) · [Sentry & crash tooling on Flutter Gems](https://fluttergems.dev/performance-crash-insights/)
- [Very Good Core & CLI](https://verygood.ventures/blog/flutter-starter-app-very-good-core-cli/) · [Code generation with Mason](https://verygood.ventures/blog/code-generation-with-mason/)
- [Pub workspaces + Melos](https://lazebny.io/dart-flutter-workspaces/) · [Melos starter template](https://github.com/rabiee-nasri/Melos-starter-template)

> Official flutter.dev pages could not be fetched directly from this
> environment; their content is summarized from search results. Verify package
> versions on pub.dev before pinning.

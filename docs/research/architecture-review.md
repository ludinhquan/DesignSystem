# Review: Simplifying the Flutter App Architecture

_Reviewed: October 2026 · Flutter 3.47 / Dart 3.13 · Assumes 1–3 devs, one app now, a few branded clones later, backend unknown._

Reviews [`flutter-app-architecture.md`](./flutter-app-architecture.md) and
[`flutter-design-system.md`](./flutter-design-system.md).

---

## 1. Verdict

- **Right:** feature-first folders, MVVM-ish split (screen / state / repository), one state library that is also the DI container, go_router, flavors + `--dart-define-from-file`, tokens -> `ThemeExtension`, building on `material_ui`, "no secrets in the binary".
- **Over-engineered:** it is laid out for a 10-person platform team running many apps. Package-per-feature, 4 core packages, `FeatureModule`, ports for every vendor, Mason, Melos, 3 design-system packages and a Figma codegen pipeline each solve a problem a 1–3 person team with one app does not have yet. A new dev has to learn about 15 concepts before shipping a screen.
- **Duplicated ideas:** `Command` + `Result<T>` + freezed state unions do the same job Riverpod's `AsyncNotifier`/`AsyncValue` already does. Pick one. That is Riverpod.
- **Codegen cost:** freezed, json_serializable, retrofit, go_router_builder and riverpod_generator mean 4–5 generators on `build_runner`. That adds `.g.dart` noise, merge conflicts and a "did you run build_runner?" step. Dart 3.13 primary constructors, sealed classes and patterns cover most of it. Target **zero build_runner** at the start.
- **Branding is simpler than the doc makes it.** A "clone" that changes brand, config and content is a **flavor of one app**, not a new app shell that composes packages.

---

## 2. Element-by-element

| Element | Verdict | Reason | Trigger to add later |
|---|---|---|---|
| Package per feature; `core`/`core_flutter`/`data`/`api_client` packages | **Drop → folders** | Same boundaries, without pubspecs, barrels or versioning | Team >5, squads own features, or analyze/test time hurts |
| Pub workspace / Melos | **Keep / Defer** | A 2-member workspace costs nothing. Melos is a tool for many packages | >4 packages or versioned publishing |
| Domain / use-case layer; Service layer | **Drop** | Flutter's guide marks the domain layer optional. Repos call Dio directly | Logic reused by 2+ controllers or merging repos: add one class, not a layer |
| `FeatureModule` contract | **Drop** | A per-feature `routes` list + brand feature flags | Features become packages composed per app |
| Riverpod 3 (no generator); "or Bloc" | **Keep / Drop** | One tool for state, DI, caching and test overrides. Decide once | `riverpod_generator` only if build_runner is already in use |
| Command + `Result<T>` + `AppFailure` tree | **Drop / Simplify** | `AsyncNotifier`/`AsyncValue` already models loading/error/data. Throw one sealed `AppException` from the HTTP layer | Use a local sealed outcome for *expected* results (e.g. payment declined) |
| freezed + json_serializable; DTO ≠ model | **Simplify** | Primary constructors, sealed classes and pattern-match `fromJson`. One model class | Over ~15 DTOs or nested JSON: add `json_serializable` (the only generator) |
| OpenAPI → Retrofit client | **Defer** | The backend is unknown. Hand-written repos are faster below ~20 endpoints | Stable spec and over ~20 endpoints |
| Dio + interceptors | **Keep** | Auth, token-refresh lock and error mapping in one place | Retry: add when logs show flaky networks |
| Ports & adapters for every vendor, `integrations/*`, import lints | **Simplify** | Wrap only what has many call sites *and* may differ per brand: **analytics**. Crash reporting is called in 2 places. An auth port won't make swapping a backend cheap | Payments or push differ per brand |
| `CompositeAnalytics`, typed sealed events | **Drop** | Event-name constants in one file | A brand needs 2 analytics vendors at once |
| go_router / go_router_builder | **Keep / Drop** | Deep links and redirects are worth it. Typed routes cost codegen. Use path constants | Over ~30 parameterized routes with real deep-link bugs |
| Drift | **Defer** | Prefs + Riverpod in-memory cache | Offline-first or relational local data |
| Mason / Very Good CLI | **Drop** | Copying a feature folder takes 30 s | Over 3 brands, or many devs adding features weekly |
| `apps/<brand>/` shells + `brand.yaml` + flavorizr | **Simplify** | One app. Flavor = brand, a Dart brand file, define file = env. Hand-edit 2–3 native flavors | Brands become different products; >5 brands → flavorizr |
| Remote Config / CMS / server-driven UI | **Defer** | Compile-time flags in the brand file first | Non-devs must change content or flags without a release. Then use a typed section registry, not `rfw` |
| 6-level extension model | **Simplify** | 3 levels: config (brand + env), override (Riverpod override per brand), code (feature folder) | — |
| 3 DS packages + `ds_icons` | **Simplify** | One `ds` package with `tokens/ theme/ components/` | DS consumed by other repos or teams |
| Figma → DTCG → Dart codegen + CI check | **Defer** | ~100 hand-written Dart constants are easy to read and review. The existing `tool/gen_tokens.dart` (~800 lines) is code to maintain | A designer owns Figma Variables and changes them often, or over 3 brands |
| 3 token tiers, many `ThemeExtension`s | **Simplify** | Primitives + semantic. `ColorScheme` + `TextTheme` + **one** `DsTokens` extension | A component must diverge per brand |
| `material_ui` | **Keep** | Forced: the in-SDK Material library is frozen and deprecated | — |
| Widgetbook | **Defer** | `@Preview` (stable in 3.47) covers in-IDE work | Designers/QA need a shared web catalog |
| Golden matrix, mocktail, Patrol, DCM | **Simplify** | Goldens for core components (light/dark) + **one showcase golden per brand**. Fakes via `ProviderScope` overrides. One `integration_test` smoke test. `flutter_lints` | Regressions slip through; native-dialog flows → Patrol |
| ADRs + `CLAUDE.md` | **Keep** | Cheap. Half-page ADRs | — |
| CI per package, apps × flavors matrix, Shorebird | **Simplify / Defer** | PR: format + analyze + test. Tag: build matrix over brands | Store-review delays block hot-fixes → Shorebird |

---

## 3. The simplified architecture

### 3.1 Repository and folders
```
/                                  # pub workspace root: [app, packages/ds]
├── app/                           # the ONE Flutter app (all brands = flavors)
│   ├── lib/
│   │   ├── main.dart              # composition root
│   │   ├── app.dart               # MaterialApp.router, theme from brand
│   │   ├── config/
│   │   │   ├── env.dart           # String.fromEnvironment(...) constants
│   │   │   ├── brand.dart         # Brand class + Feature enum + fromFlavor
│   │   │   └── brands/brand_a.dart  brand_b.dart
│   │   ├── core/                  # shared, no feature code
│   │   │   ├── http.dart          # Dio + interceptors + AppException mapping
│   │   │   ├── analytics.dart     # the one vendor wrapper
│   │   │   ├── storage.dart       # prefs + secure storage providers
│   │   │   └── router.dart        # assembles feature route lists
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   │   ├── data/          # auth_repository.dart, user.dart
│   │   │   │   ├── ui/            # login_screen.dart, login_controller.dart
│   │   │   │   └── auth_routes.dart
│   │   │   └── catalog/ …         # same shape: data/, ui/, *_routes.dart
│   │   └── l10n/                  # ARB files (gen-l10n, built into flutter tool)
│   ├── assets/brands/<brand>/     # logo, fonts – bundled per flavor
│   ├── config/<brand>.<env>.json  # API URL, public keys (--dart-define-from-file)
│   ├── android/ ios/              # one native flavor per brand
│   └── test/ integration_test/
└── packages/ds/                   # the only shared package
    └── lib/src/{tokens,theme,components}/
```
`ds` is the one extra package because this repo's purpose is a design system. Keeping it free of app and vendor dependencies lets goldens and previews run without Firebase or HTTP. The cost is one pubspec. Mapping from the current skeleton: `packages/ds_tokens` + `ds_foundation` + `ds_components` merge into `packages/ds`, and `apps/example` becomes `app/`.

**Rules (the whole list):**
1. `ui/` may import `data/` and `core/`. `data/` never imports `ui/`. Features import other features only through their `data/` repository providers.
2. Screens are dumb widgets. Add a `*_controller.dart` (Notifier/AsyncNotifier) only when state is non-trivial. A one-shot fetch can be a plain `FutureProvider`.
3. Repositories own API calls, caching and mapping, and throw `AppException`.
4. Vendor SDK imports live only in `core/` wrapper files or `main.dart`.
5. Components in `ds` read semantic tokens only, never raw colors.

### 3.2 Branding and environments
- **Flavor = brand.** It sets bundle ID, app name, icon and Firebase files natively. In Dart, `appFlavor` (from `flutter/services.dart`) selects the `Brand`.
- **Define file = environment.** `config/brand_a.prod.json` holds the API URL, Sentry DSN and analytics key. These are public keys only.
- **Brand assets** use flavor-conditional assets (`- path: assets/brands/brand_a/` with `flavors: [brand_a]`), so each binary ships only its own logo and fonts.
- **Brand behavior** differences: first try a flag in `Brand.features`. If code must differ, use a Riverpod override in `main.dart` keyed on brand.
- If brands belong to competing clients who must not find each other's names in a binary, move `Brand` from Dart constants to a per-flavor `brand.json` asset.

### 3.3 Dependencies (runtime ≤10, build_runner: 0)
| # | Package | Why |
|---|---|---|
| 1 | `material_ui` | Required since the SDK Material library is frozen |
| 2 | `flutter_riverpod` | State + DI |
| 3 | `go_router` | Navigation and deep links |
| 4 | `dio` | Interceptors (auth/refresh/errors) |
| 5 | `shared_preferences` | Small local cache and settings |
| 6 | `flutter_secure_storage` | Tokens |
| 7 | `sentry_flutter` *or* `firebase_crashlytics` | Crash reporting |
| 8 | one analytics SDK | Behind the `Analytics` wrapper |
| 9 | `intl` (+ SDK `flutter_localizations`) | gen-l10n |
| 10 | `cached_network_image` | Only if the app is image-heavy |

Dev dependencies: `flutter_lints`, `alchemist`, `flutter_launcher_icons`, `flutter_native_splash`. **Codegen:** none on build_runner. gen-l10n is built into the flutter tool. The first generator to add, if one is needed, is `json_serializable`.

---

## 4. Code sketches

**Brand + env** (`config/`)
```dart
enum Feature { checkout, loyalty }

class Brand {
  const Brand({required this.id, required this.appName, required this.ds, this.features = const {}});
  final String id, appName;
  final DsBrand ds;                 // from packages/ds: primary color, font, radius
  final Set<Feature> features;
  bool has(Feature f) => features.contains(f);

  static Brand fromFlavor(String? flavor) => switch (flavor) {
        'brand_b' => brandB,
        _ => brandA,
      };
}

const brandA = Brand(
  id: 'brand_a', appName: 'Acme',
  ds: DsBrand(primary: Color(0xFF2563EB), fontFamily: 'Inter', radius: 12),
  features: {Feature.checkout},
);

abstract final class Env {
  static const name = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const apiUrl = String.fromEnvironment('API_URL');
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');
}
```

**Composition root** (`main.dart`)
```dart
final brandProvider = Provider<Brand>((_) => throw UnimplementedError());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final brand = Brand.fromFlavor(appFlavor);
  await SentryFlutter.init(
    (o) => o..dsn = Env.sentryDsn..environment = Env.name,
    appRunner: () => runApp(ProviderScope(
      overrides: [brandProvider.overrideWithValue(brand)],
      child: const App(),
    )),
  );
}
```

**One feature** (`features/catalog/`)
```dart
// data/product.dart – primary constructor, no codegen
class Product(final String id, final String name, final int priceCents) {
  factory Product.fromJson(Map<String, Object?> j) => switch (j) {
        {'id': String id, 'name': String name, 'price_cents': int p} => Product(id, name, p),
        _ => throw FormatException('Bad product: $j'),
      };
}

// data/catalog_repository.dart
final catalogRepositoryProvider = Provider((ref) => CatalogRepository(ref.watch(dioProvider)));

class CatalogRepository {
  CatalogRepository(this._dio);
  final Dio _dio;
  Future<List<Product>> list() async {
    final res = await _dio.get<List<Object?>>('/products');   // errors -> AppException in interceptor
    return [for (final e in res.data!) Product.fromJson(e! as Map<String, Object?>)];
  }
}

// ui/catalog_screen.dart – simple fetch: no controller needed
final productsProvider = FutureProvider((ref) => ref.watch(catalogRepositoryProvider).list());

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (ref.watch(productsProvider)) {
        AsyncData(:final value) => ProductList(products: value),
        AsyncError(:final error) => DsErrorView(error, onRetry: () => ref.invalidate(productsProvider)),
        _ => const DsLoading(),
      };
}

// catalog_routes.dart
abstract final class CatalogPaths { static const list = '/products'; static String detail(String id) => '/products/$id'; }
final catalogRoutes = <RouteBase>[GoRoute(path: CatalogPaths.list, builder: (_, _) => const CatalogScreen())];
```
`core/router.dart` concatenates lists: `[...authRoutes, ...catalogRoutes, if (brand.has(Feature.loyalty)) ...loyaltyRoutes]`.

**The one SDK wrapper** (`core/analytics.dart`)
```dart
abstract interface class Analytics {
  void track(String event, [Map<String, Object> props = const {}]);
  void identify(String userId);
}

abstract final class Events { static const productViewed = 'product_viewed'; }

final analyticsProvider = Provider<Analytics>((ref) =>
    Env.name == 'prod' ? PostHogAnalytics() : DebugAnalytics());   // tests override with a fake
```

---

## 5. Growth path

| When | Add |
|---|---|
| **2nd brand** | Native flavor + brand file + flavor assets. Add a showcase golden per brand. Nothing structural. |
| **Over 3 brands, or non-devs onboarding brands** | `tool/new_brand.dart` script (or a Mason brick). Figma token codegen. Fastlane or Codemagic with a brand matrix. `flutter_flavorizr`. |
| **Content or flags must change without a release** | Remote Config or CMS behind a `ContentRepository`. Later, a typed section registry for home and promos. |
| **Backend over ~20 endpoints with an OpenAPI spec** | Generated client in `core/api/` (and with it build_runner). |
| **Many or nested models** | `json_serializable`. freezed only if you then need `copyWith` across many state classes. |
| **Offline-first or relational local data** | Drift. Repositories already own caching, so screens don't change. |
| **Shared business logic** | One use-case class in the owning feature's `data/`. Still not a layer. |
| **Team over 5, or analyze/test time hurts** | Promote `features/x/` to `packages/x` (the folder shape is already `data/ ui/ routes`). Add Melos and import lints. |
| **A truly different second product** | Thin app shells + shared feature packages, the original proposal's §3. You will have the real requirements by then. |

None of these needs a rewrite. They are additions because the folder rules (data/ui split, repositories as the only data access, vendor code in one place) already match the target shape.

---

## 6. Performance: what gives the most value
1. `const` widgets plus the `prefer_const_*` lints. Split big widgets into widget classes, not helper methods.
2. Watch narrowly: `ref.watch(p.select(...))`, and keep providers small, so a change rebuilds one subtree.
3. Lazy lists (`ListView.builder`/slivers, `itemExtent` when known). Set `cacheWidth`/`cacheHeight` on images and resize them on the server or CDN.
4. Startup: initialize only what the first frame needs. Init analytics and other SDKs after the first frame.
5. Move parsing of large JSON (over ~100 KB) into `Isolate.run`, but only after profiling shows jank.
6. Avoid `Opacity`/`saveLayer`/clips in animations. Wrap frequently repainting areas in `RepaintBoundary`.
7. Measure in `--profile` on a low-end Android device. Run `flutter build --analyze-size`. Release with `--obfuscate --split-debug-info`.

---

## 7. New branded app in 7 steps
1. **Native flavor:** add `brand_c` to Android `productFlavors` (applicationId, `app_name`) and an iOS scheme + xcconfig (bundle ID, display name). Add Firebase config files per flavor if you use Firebase.
2. **Assets:** add `assets/brands/brand_c/` and register it in `pubspec.yaml` with `flavors: [brand_c]`.
3. **Brand file:** add `lib/config/brands/brand_c.dart` (name, `DsBrand` colors/font/radius, features) and one `case` in `Brand.fromFlavor`.
4. **Env files:** add `config/brand_c.dev.json` and `config/brand_c.prod.json` (API URL, public keys).
5. **Icon and splash:** run `flutter_launcher_icons` and `flutter_native_splash` with the flavor's config.
6. **Verify:** run `flutter run --flavor brand_c --dart-define-from-file=config/brand_c.dev.json`, then regenerate the brand showcase golden.
7. **Ship:** add `brand_c` to the CI build matrix and set up signing and the store listing.

Target: half a day, with no code changes outside `config/`, `assets/` and native flavor files.

---

### Sources
- Flutter – [Guide to app architecture](https://docs.flutter.dev/app-architecture/guide) (the domain layer is optional; use cases only for reuse, complexity or merging repos)
- Code With Andrea – [Feature-first vs layer-first](https://codewithandrea.com/articles/flutter-project-structure/) · [Speeding up build_runner](https://codewithandrea.com/tips/speed-up-code-generation-build-runner-dart-flutter/)
- Riverpod – [About code generation](https://riverpod.dev/docs/concepts/about_code_generation) (codegen optional) · [What's new in 3.0](https://riverpod.dev/docs/whats_new)
- [Announcing Dart 3.13](https://dart.dev/blog/announcing-dart-3-13) (primary constructors) · [Do you still need Freezed?](https://johnthiriet.com/do-you-still-need-freezed-sealed-classes-and-pattern-matching-in-modern-dart/)
- VGV – [Layered architecture](https://verygood.ventures/blog/very-good-flutter-architecture/)

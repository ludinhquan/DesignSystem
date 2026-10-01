# Analysis: Flutter App Architecture (White-Label Ready)

_Analyzed: October 2026 · Flutter 3.47 / Dart 3.13.5_

A detailed analysis of [`flutter-app-architecture.md`](./flutter-app-architecture.md).
It checks the doc against its own goals, tests its code, lists what it leaves
out, and estimates what it costs to build and run.

**How the findings were checked.** Findings marked **[verified]** were
reproduced with the Dart 3.13.5 SDK (the doc's snippets, compiled with stub
types, and a three-package pub workspace). The other findings come from
reading the doc closely and from known Flutter, Riverpod and store behavior.

---

## 1. Executive summary

The architecture is **sound in direction and over-specified for day one**. Its
main ideas (layered MVVM, feature-first, thin brand config, ports for vendor
SDKs, typed config) are right. But it has five problems that matter in practice:

1. **Three code snippets are wrong as written.** `FeatureModule` does not
   compile for any real feature [verified]. `Result`'s `Error` class hides
   `dart:core`'s `Error` [verified]. The composition root starts SDKs and
   runs module `init` in an order that cannot work with Riverpod or Sentry.
2. **"Boundaries enforced by the compiler" is false in a pub workspace.** A
   feature package can import a sibling package it never declared, and it
   compiles and runs [verified]. Only a lint catches this, and only at
   `info` level unless you raise it.
3. **The white-label mechanics have gaps.** `brand.yaml` is listed but never
   read by anything. `--dart-define-from-file` gives flat string/number/bool
   values, not the nested `config.features.checkout` the code uses. And a
   runtime flag does **not** remove a feature's native plugin from the binary.
4. **Two state idioms are mixed.** Flutter's official `Command`/ViewModel
   pattern is `ChangeNotifier`-based. Riverpod 3 moved `ChangeNotifierProvider`
   to `legacy.dart` and has its own `AsyncNotifier`/`AsyncValue` for the same
   job. Using both doubles the concepts.
5. **Important white-label topics are missing:** auth/session across
   features, cross-feature navigation, per-brand localization, consent
   (GDPR/ATT), push and deep-link setup per brand, store operations, and how
   one shared change is released to N brands safely.

Scorecard against the doc's own goals:

| Goal (from the doc) | Score | Why |
|---|---|---|
| Launch a new app by changing config, brand and content | **6/10** | Design-time path is good. Config pipeline is unspecified; native and store setup is not "config only" (§3.5, §3.6) |
| Extend features without touching the rest | **7/10** | Feature packages + module list work. Cross-feature navigation and shared state are not designed (§3.4, §3.9) |
| Swap third-party providers | **8/10** | Ports + adapters + fakes is the right tool. Composite error handling, consent and SDK init order need fixing (§3.8) |
| Clean / understandable | **5/10** | ~27 packages and ~15 concepts before the first screen; two state idioms (§3.1, §6) |
| Optimized (performance) | **8/10** | Checklist is correct; startup advice conflicts with the sequential `init` in `main.dart` (§3.13) |

---

## 2. What the architecture assumes

The doc never states its context, but its choices only pay off under these
conditions:

| Assumption | Choice that depends on it |
|---|---|
| 5+ developers, or several teams owning features | Package per feature, Melos, import lints |
| Several brands that **differ in which features and native SDKs they ship** | `apps/<brand>/` shells, one adapter package per vendor |
| A stable backend with an OpenAPI spec | Generated `api_client`, DTO ≠ model |
| Non-developers editing content and flags | CMS, Remote Config, server-driven sections |
| Brands launched often (monthly or faster) | Mason `app` brick, CI matrix over `apps/*` |

Fit by context:

| Context | Fit | Advice |
|---|---|---|
| 1–3 devs, one app, brands "maybe later" | Poor | Same rules as folders in one app (the doc's own "small project" note, §3). See the simplification review on branch `claude/beautiful-ramanujan-wym087` |
| 2–5 brands, same features, different look | Partial | One app, **flavor = brand**. Shells add N native projects for nothing |
| 5–50 brands, different feature/SDK sets (agency, franchise, SaaS) | Good | This doc, with the fixes in §5 |
| Several distinct products sharing features | Good | Shells + shared feature packages are exactly right |

**The key question** that decides most of the design: *do brands differ in
native code (plugins, permissions, SDKs), or only in Dart-level config?* If
only config, one app with flavors is simpler. If native code differs, the
shells in this doc are needed (see §3.5).

---

## 3. Section-by-section analysis

### 3.1 Layering and MVVM (doc §2)

**Strong points**
- Downward-only dependencies, dumb Views, repositories as the single source
  of truth, and an *optional* domain layer match Flutter's official guide.
- Saying "use cases only when reused" stops the most common over-engineering.

**Problems**
- **Two state idioms.** The official `Command0/Command1` and ViewModels
  extend `ChangeNotifier`. Riverpod 3 moved `ChangeNotifierProvider`,
  `StateNotifierProvider` and `StateProvider` to `package:flutter_riverpod/legacy.dart`.
  Its own model is `Notifier`/`AsyncNotifier` with `AsyncValue`
  (loading/error/data), which is what `Command` gives you. If you pick
  Riverpod, the ViewModel *is* an `AsyncNotifier`, and `Command` is not needed.
  If you want the official pattern exactly, use `ChangeNotifier` ViewModels
  with `provider` or `get_it`, and not Riverpod.
- **Services vs. Repositories.** With a generated `api_client`, the "Service"
  layer is the generated client. Writing hand-made Service classes around it
  adds a layer with no logic. Say so explicitly: *generated client = service*.
- **No rule for one-off actions** (submit form, delete item). These are where
  `Command` helps most. With Riverpod, use an `AsyncNotifier` method plus
  `ref.listen` for side effects (snackbar, navigation), or a mutation
  (Riverpod 3 mutations are experimental, so don't build the architecture on them).

**Decision:** Riverpod idioms only. `Notifier`/`AsyncNotifier` = ViewModel. No
`Command` class.

### 3.2 `Result<T>`, `AppFailure` and error flow (doc §2.1)

**Strong points**
- Typed, sealed failures and exhaustive `switch` make error handling visible.
- Mapping `DioException → AppFailure` once, in a base repository, is right.

**Problems**
- **`Error<T>` hides `dart:core`'s `Error` [verified].** In any file that
  imports `core`, `throw Error()` no longer compiles ("1 positional argument
  expected by 'Error.new'"), and `catch (e) { if (e is Error) … }` silently
  means the wrong class. Flutter's own sample uses this name, but rename it
  (`Ok`/`Err`).
- **`Result` and `AsyncValue` overlap.** A repository returns `Result`, the
  notifier unwraps it, then rewraps it into `AsyncValue`. That is two error
  models in a row. Pick one boundary:
  - *Option A (simpler):* repositories **throw** a sealed `AppException`;
    `AsyncNotifier` + `AsyncValue.guard` catches it. UI switches on
    `AsyncError(:final error)` and pattern-matches the exception type.
  - *Option B (stricter):* repositories return `Result` only for **expected**
    business outcomes (payment declined, coupon invalid) and throw for
    infrastructure failures.
  Option B gets most of the safety for little cost.
- **Dart has no `?` operator**, so chaining 3–4 `Result` calls in a use case
  becomes nested `switch`es. Plan for small helpers (`map`, `flatMap`,
  `getOrElse`) if `Result` is used widely.
- **`UnknownFailure(Object error)` loses the stack trace.** Keep
  `StackTrace` too, or crash reports point at the mapper.

### 3.3 Monorepo and package boundaries (doc §3)

**Strong points**
- `lib/src/` private + one barrel export per feature is a real API boundary.
- `melos … --diff=origin/main` keeps CI fast as the repo grows.
- The "start as folders, promote to packages" note is the right growth path.

**Problems**
- **The compiler does not enforce declared dependencies in a pub workspace
  [verified].** A workspace has one shared `package_config.json`. In the test
  workspace, `feature_a` imported `feature_b` with no pubspec entry: `dart run`
  worked and `dart analyze` reported no issues. Only the
  `depend_on_referenced_packages` lint flags it, and as an **info**. Fix:
  ```yaml
  # analysis_options.yaml (root, included by every package)
  analyzer:
    errors:
      depend_on_referenced_packages: error
  ```
  and run `dart analyze --fatal-infos` in CI.
- **Layer rules inside a package are not enforced at all.** `ui/` importing
  `data/` services directly is just a relative import. You need a lint
  (DCM `avoid-banned-imports`, a `custom_lint` rule, or an
  architecture test that greps imports).
- **Package count.** The tree in §3 implies ~27 pubspecs on day one (7 core/DS,
  6 features, 11 integrations, 3 apps). Each has its own pubspec, lints,
  tests, and possibly `build_runner`. That cost is real (§6).
- **`data/` as a shared package is a magnet.** "Shared repositories" tends to
  absorb everything and becomes a second monolith. Keep only genuinely
  cross-feature repositories (auth session, user profile) there.

### 3.4 `FeatureModule` contract (doc §4)

**Problems**
- **It does not compile for real features [verified].** `abstract interface
  class` cannot be extended outside its library, and `implements` does not
  inherit bodies. A `HomeModule implements FeatureModule` that overrides only
  `id` and `routes` fails: *"Missing concrete implementations of
  'FeatureModule.init', 'navDestinations', 'overrides'"*. `extends` fails with
  *"can't be extended outside of its library because it's an interface class"*.
  Fix: `abstract class FeatureModule` (or `abstract base class`).
- **`init(AppConfig)` cannot use DI.** It runs before `ProviderScope` exists,
  so a module cannot read the providers it needs (storage, HTTP). Create a
  `ProviderContainer` first, pass it to `init`, then mount it with
  `UncontrolledProviderScope` (fixed code in §5).
- **`Override` type.** In Riverpod 3 several low-level types moved to
  `package:flutter_riverpod/misc.dart`. Check the import for `Override` when
  `core_flutter` declares the contract.
- **Cross-feature contracts are missing.** The contract covers routes, DI and
  tabs. It does not cover:
  - *navigation into another feature* (catalog → checkout) without importing
    it. Use path constants or route-name contracts in a small shared package,
    or a `CheckoutLauncher` port the app wires up;
  - *events between features* (logout must clear cart, profile, caches);
  - *a feature that is disabled by a flag* but linked from another feature.
    Callers must check the flag or the route must show a fallback.
- **Module order matters but is implicit.** Auth must initialize before
  features that read the session. Make dependencies explicit (a
  `dependsOn` list, or simply a documented order).

### 3.5 White-label composition: shells vs. flavors (doc §3, §4, §5)

This is the most important design decision in the doc, and it is not
discussed.

| | `apps/<brand>/` shells (doc) | One app, flavor = brand |
|---|---|---|
| Native projects to maintain | **N** (Gradle/AGP, Xcode, CocoaPods/SPM upgrades × N) | 1 |
| Feature/SDK set per brand | **Real**: each app depends only on the packages it uses | All brands ship all plugins |
| Binary size, permissions, privacy manifests | Per brand | Union of all brands |
| iOS build configurations | 3 env × 3 modes = 9 per project | 9 per brand in one project |
| New brand | Generate a folder | Add a flavor (native + Dart) |

**Native plugins are linked by dependency, not by flags.** The doc's
`if (config.features.checkout) CheckoutModule()` turns off Dart code only. If
`checkout` (and so `payments_stripe`) is in the app's pubspec, its plugin is
registered, its native SDK is linked, and its Android manifest permissions
are merged, even when the flag is off. App review can reject permission
strings or SDKs for features the app does not offer. So:
- **Compile-time composition** (pubspec + `main.dart` list) decides what is in
  the binary. This is level 4 in the doc's table, and it is *code*, not
  config. The `app` brick can generate it from `brand.yaml`.
- **Runtime flags** (level 2) should only toggle features that are already
  compiled in.

**Shell drift.** Once generated, N `android/` and `ios/` folders drift from the
template. Plan for it: keep native changes in the brick and regenerate
(`mason make app --on-conflict overwrite` + review the diff), or keep a script
that applies the same native change to every app. Budget a Flutter-upgrade
day per release that touches every shell.

**Recommendation.** Decide per product, using the key question in §2:
- Brands differ only in look, content and flags → one app, flavor = brand.
- Brands differ in features with native SDKs → shells, generated and
  regenerated from the brick.

### 3.6 Configuration pipeline (doc §1, §5)

**Problems**
- **`brand.yaml` has no reader.** It lists features, vendors and theme, but
  nothing turns it into Dart. Options: (a) a generator writes
  `lib/brand.g.dart` (consts, tree-shakeable, typed); (b) load it as an asset
  before `runApp` (async, untyped, every brand's code paths ship); (c) flatten
  it into the define file. **(a) is best:** brand data is compile-time and
  should be checked by the compiler.
- **`--dart-define-from-file` is flat.** Use it as key → string/number/bool.
  `config.features.checkout` and `config.vendors.mixpanelToken` imply nested
  objects. Use flat keys (`FEATURE_CHECKOUT`, `MIXPANEL_TOKEN`) or move
  structure into the generated brand file.
- **`String.fromEnvironment` must be called as `const`.** It is only
  guaranteed to work in a const expression (it returns the default on some
  targets otherwise). `AppConfig.fromEnvironment()` must read each field with
  `const …fromEnvironment(...)`.
- **Validation is missing.** An empty `API_URL` should fail at startup in dev
  and fail the CI build for release (a `tool/check_config.dart` step).
- **Split of responsibilities**, made explicit:

| Kind | Where | Changes need |
|---|---|---|
| Bundle ID, app name, icon, Firebase files, signing | Native flavor / shell | Store release |
| Feature set, vendors, theme tokens | Generated brand file | Build |
| API URL, public keys, environment name | Define file per env | Build |
| Copy, banners, menus | CMS | Nothing |
| Kill switches, rollouts, A/B | Remote Config | Nothing |

### 3.7 Data layer and backend (doc §6.1)

**Strong points**
- One Dio setup with auth, a token-refresh lock, retry for idempotent calls
  and one error-mapping place is exactly right.
- `Isolate.run` for large JSON.

**Problems**
- **Double retries.** Riverpod 3 retries failed providers automatically with
  backoff. With a Dio retry interceptor as well, one failing GET can run
  (Dio retries + 1) × (provider retries + 1) times. Pick one owner: disable
  provider retry for network errors (`ProviderScope(retry: …)`) or don't add
  Dio retry.
- **DTO ≠ model doubles the classes.** Generated DTOs + freezed models +
  mappers is 3 artifacts per entity. It pays when the API is unstable,
  shared, or badly shaped. For a backend you own, start with the generated
  DTOs as models and add a mapper only for an entity that needs one.
- **Generated client depends on spec quality.** Many real OpenAPI specs have
  wrong nullability or `oneOf` that generators mishandle. Add a CI step that
  lints the spec and a contract test against staging.
- **Per-brand backends.** If brands use different tenants or hosts, put tenant
  ID in an interceptor from config, and make sure caches (Drift, prefs) are
  scoped per brand and per user.

### 3.8 Ports & adapters for vendor SDKs (doc §6.2)

**Strong points**
- Interfaces in `core`, vendors only in `integrations/*`, a fake per port:
  this makes vendor swaps and tests cheap. It is the best part of the doc.
- Typed events stop event-name typos.

**Problems**
- **`CompositeAnalytics` lets one vendor break the others.** `Future.wait`
  fails as soon as one adapter throws, and the error reaches the caller (a
  button handler). Catch per delegate and report to the crash reporter.
  Callers should not `await` analytics (`unawaited(...)`).
- **Consent is missing.** GDPR (EU) and App Tracking Transparency (iOS) mean
  analytics, crash reporting and push must wait for consent. A
  `ConsentGatedAnalytics` decorator over the composite is a clean fit.
- **SDK initialization is skipped.** `SentryCrashReporter(dsn)` in an
  override does not initialize Sentry. Sentry wants
  `SentryFlutter.init(..., appRunner: () => runApp(...))`; Crashlytics needs
  `Firebase.initializeApp()` and the `FlutterError.onError` /
  `PlatformDispatcher.instance.onError` hooks set **before** `runApp`. Give
  each port an `init()` in the adapter, called by the composition root.
- **Port granularity.** `Analytics`, `CrashReporter`, `FeatureFlags`,
  `KeyValueStore` and `ContentSource` are worth it from day one. `AuthProvider`
  is the hardest to make swappable: Firebase, Supabase and Auth0 differ in
  session, refresh and linking. Define it from *your* flows (sign in, sign out,
  current user stream, token for HTTP) and accept that swapping auth is still
  a project, not a config change.
- **One package per adapter** (11 in the tree) is heavy. Group per vendor
  family (`integrations_firebase` = analytics + crash + push + remote config),
  because brands usually take a vendor's whole stack.

### 3.9 Routing (doc §1, §4)

**Problems**
- **Typed routes across packages.** `go_router_builder` generates
  `$appRoutes` per library. Combining lists from modules works. But
  navigating *to* another feature's typed route means importing that feature,
  which creates the feature-to-feature dependency the package design tries to
  avoid. Use path or name constants in a shared `routes_contract` package for
  cross-feature links. Typed routes are fine inside a feature.
- **Shell routes.** Bottom tabs use `StatefulShellRoute`, whose branches must
  be defined in one place. `navDestinations` lets modules provide tabs, but the
  app shell must build the branches. Document this.
- **Auth redirect** (logged out → login, deep link → return after login) is
  global and belongs in `core_flutter`'s router assembly with
  `refreshListenable` tied to the session. Not mentioned in the doc.
- **Deep links per brand** need per-brand domains, `apple-app-site-association`
  and `assetlinks.json`. That is native + web hosting work per brand.

### 3.10 Content, flags and server-driven UI (doc §4)

**Strong points**
- The extension-level table (content → flags → brand → composition →
  override → new feature) is a useful way to keep most brand requests out of
  code. Preferring a typed section registry over `rfw` is the right call.

**Problems**
- **Schema versioning.** A CMS section added today reaches old app versions
  in stores. Each section needs a `type`, a `version` and an optional
  `minAppVersion`. Unknown types must render nothing (and log), never crash.
- **Offline and first launch.** Cache the last good content, and bundle
  default content and Remote Config defaults in the app, so the first launch
  works without network.
- **Content validation.** Let editors preview on a staging app build. Give
  the CMS models the same constraints as the Dart parser.
- **Cost.** Each CMS is a vendor contract per brand (spaces, seats). Include
  it in the per-brand cost.

### 3.11 Offline (doc §1)

"Repository owns the cache; Drift when offline-first" is right, but
offline-first also needs: a write queue (outbox) for actions taken offline,
conflict rules (last-write-wins or server-wins per entity), and DB schema
migrations tested in CI. Only promise offline-first for the screens that
need it.

### 3.12 Code-generation budget

The doc implies up to seven generators: freezed, json_serializable,
retrofit/openapi, go_router_builder, riverpod_generator, drift, plus tokens.
Across ~20 packages this means:
- slow `build_runner` runs and committed `.g.dart`/`.freezed.dart` files that
  cause merge conflicts;
- a "did you run codegen?" CI check per package.

Dart macros were cancelled, so this cost will not go away. Dart 3.13 primary
constructors, sealed classes and patterns remove most of freezed's value
(except `copyWith` and deep equality). **Budget:** start with
`json_serializable` (or the OpenAPI generator) and gen-l10n. Add others only
when a specific pain shows up.

### 3.13 Performance (doc §8)

The checklist is correct and well ordered. Two conflicts with the rest of the
doc:
- `for (final m in modules) { await m.init(config); }` before `runApp` adds
  every module's startup time in sequence before the first frame. Run only
  critical inits before `runApp`, in parallel (`Future.wait`), and the rest
  after the first frame.
- Vendor SDKs in the composition root (Firebase, Sentry, Mixpanel) are the
  usual startup cost. Measure cold start per brand, because brands have
  different SDK sets.

Add: track app size per brand in CI (`--analyze-size`), since shells give
each brand a different size.

### 3.14 Quality gates and CI (doc §9)

**Strong points:** encoded conventions (bricks, lints, codegen), < 3 min PR
checks, fakes for every port, ADRs and `CLAUDE.md`.

**Problems**
- **CI matrix cost.** apps × flavors × platforms grows fast: 10 brands × 3
  envs × 2 platforms = 60 builds, and iOS builds need macOS runners. Build
  release binaries only on tags and only for affected apps (Melos diff +
  dependency graph). PRs build one representative app.
- **One commit ships to N brands.** A regression in a shared package hits
  every brand. Add per-brand smoke tests (one Patrol or `integration_test`
  flow per app), one golden showcase per brand theme, and staged rollouts per
  brand.
- **Brand version skew.** In a monorepo every brand builds from the same
  commit. Holding one brand on an older version needs a release branch. Plan
  for release trains and feature flags rather than per-brand version pinning.

---

## 4. Gaps: topics the doc does not cover

| Topic | Why it matters for white-label |
|---|---|
| Auth/session lifecycle | Login redirect, token refresh, logout must reset every feature's state (`ref.invalidate` or a session-scoped `ProviderContainer`) |
| Cross-feature navigation and events | See §3.4, §3.9 |
| Localization per brand | Brand name and tone in UI strings. gen-l10n has no overlay mechanism: use `{appName}` placeholders, or per-brand ARB overlays merged by a script, or `slang` |
| Accessibility | Brand colors must still pass contrast (WCAG AA). Check per brand in the token pipeline |
| Consent and privacy | GDPR, ATT, Google Play Data safety and Apple privacy manifests differ by SDK set, so per brand |
| Push notifications | Per-brand Firebase project / APNs setup, notification channels, deep-link routing from a notification |
| Force update and maintenance mode | Needed once N apps depend on one backend |
| Observability per brand | Tag every event and crash with `brand`, `env`, app version. Separate or shared Sentry projects decided once |
| Store operations | Accounts, signing keys, listings, screenshots per locale, review notes. Dominates "launch in a day" |
| Multi-tenant data isolation | Caches and secure storage keyed by brand and user |
| Security | Certificate pinning (optional), root/jailbreak policy, secure token storage. The doc covers secrets only |

---

## 5. Corrected code

**`Result`** without hiding `dart:core`:
```dart
sealed class Result<T> {
  const Result();
}
final class Ok<T> extends Result<T> { const Ok(this.value); final T value; }
final class Err<T> extends Result<T> {
  const Err(this.failure, [this.stackTrace]);
  final AppFailure failure;
  final StackTrace? stackTrace;
}
```

**`FeatureModule`** that features can actually extend:
```dart
abstract class FeatureModule {
  String get id;
  List<RouteBase> get routes;
  List<Override> get overrides => const [];
  List<NavDestination> get navDestinations => const [];
  /// Runs after DI exists. Keep it short; it delays the first frame.
  Future<void> init(ProviderContainer container) async {}
}
```

**Composition root** with DI before `init`, SDKs initialized properly, and
parallel startup:
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const config = AppConfig.fromEnvironment();   // every field read with const
  final brand = Brand.current;                  // generated from brand.yaml
  final modules = buildModules(brand);          // generated list, one per feature

  final container = ProviderContainer(overrides: [
    appConfigProvider.overrideWithValue(config),
    analyticsProvider.overrideWithValue(
      ConsentGatedAnalytics(CompositeAnalytics(buildAnalytics(brand, config))),
    ),
    ...modules.expand((m) => m.overrides),
  ]);
  await Future.wait(modules.map((m) => m.init(container)));

  await SentryFlutter.init(
    (o) => o..dsn = config.sentryDsn..environment = config.env,
    appRunner: () => runApp(UncontrolledProviderScope(
      container: container,
      child: PlatformApp(modules: modules, theme: BrandTheme.of(brand)),
    )),
  );
}
```

**`CompositeAnalytics`** that isolates failures:
```dart
final class CompositeAnalytics implements Analytics {
  CompositeAnalytics(this._delegates, {this.onError});
  final List<Analytics> _delegates;
  final void Function(Object error, StackTrace stack)? onError;

  Future<void> _each(Future<void> Function(Analytics a) call) =>
      Future.wait(_delegates.map((d) async {
        try {
          await call(d);
        } catch (e, s) {
          onError?.call(e, s);   // one vendor failing never breaks the others
        }
      }));

  @override
  Future<void> track(AnalyticsEvent e) => _each((d) => d.track(e));
  @override
  Future<void> identify(String userId, {Map<String, Object?> traits = const {}}) =>
      _each((d) => d.identify(userId, traits: traits));
  @override
  Future<void> reset() => _each((d) => d.reset());
}
```

**Lint config** that makes package boundaries real:
```yaml
include: package:flutter_lints/flutter.yaml
analyzer:
  errors:
    depend_on_referenced_packages: error
# CI: dart analyze --fatal-infos
```

---

## 6. Cost model

Rough estimates for an experienced 2–3 person team. Use them for relative
comparison, not as a plan.

| Item | Full architecture (doc) | Folders in one app |
|---|---|---|
| Packages / pubspecs at start | ~27 | 2 (app + `ds`) |
| Concepts before first screen | ~15 (module, port, adapter, Result, Command, DTO, mapper, brick, flavor, …) | ~6 |
| Platform setup before features | 4–6 weeks | 1–2 weeks |
| Flutter SDK upgrade | 1–3 days (N shells, many pubspecs) | ½ day |
| Marginal cost of brand #N (code side) | ½–1 day (brick) | ½–1 day (flavor) |
| Marginal cost of brand #N (store, accounts, CMS, push, links) | 2–5 days, same either way | same |

Takeaways:
- The doc's "< 1 day" target is realistic **for an internal build** once
  accounts exist. A first store release per brand takes days, mostly outside
  the code.
- The architecture's extra cost is paid **once, up front**. It pays back when
  brands differ in features/SDKs, or when the team is large enough that
  package boundaries prevent real conflicts.

---

## 7. Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Platform built before the first feature ships | High | High | Ship one feature end to end first; extract packages after |
| Shell native folders drift | High | Medium | Regenerate from the brick; one upgrade script for all apps |
| Feature packages import each other freely | High (without lint) | Medium | `depend_on_referenced_packages: error`, `--fatal-infos` |
| Two state idioms in the codebase | Medium | Medium | ADR: Riverpod idioms only; no `Command` |
| Unused SDKs and permissions in a brand's binary | Medium | High (store rejection) | Compile-time composition per brand; flags only for compiled-in features |
| Shared change breaks all brands at once | Medium | High | Per-brand smoke test + golden; staged rollout |
| Codegen slowness and conflicts | High | Low–Medium | Generator budget (§3.12) |
| CMS section breaks old app versions | Medium | Medium | Section `version`/`minAppVersion`; unknown types ignored |
| Analytics vendor outage affects UX | Low | Medium | Isolated composite; never `await` analytics in UI |

---

## 8. Recommendations

### 8.1 Changes to make to the doc
1. Fix `FeatureModule` (`abstract class`), rename `Error` → `Err`, rewrite the
   composition root (§5).
2. Replace "enforced by the compiler" with "enforced by lints treated as
   errors", and add the lint config.
3. Pick one state idiom: Riverpod `Notifier`/`AsyncNotifier`; drop `Command`.
   Use `Result` only for expected business outcomes.
4. Specify how `brand.yaml` becomes Dart (generator), and keep define files flat.
5. Add a "shells vs. flavors" decision with the native-plugin rule (§3.5).
6. Add the missing topics from §4, at least auth/session, cross-feature
   navigation, consent, per-brand l10n and store operations.
7. Set one retry owner (Dio or Riverpod), and a codegen budget.

### 8.2 Phased roadmap with triggers

| Phase | Build | Move on when |
|---|---|---|
| **0. Foundation** (1–2 wk) | One app, feature folders, `ds` package, Riverpod, go_router, Dio, Analytics + CrashReporter ports with fakes, lints, CI | — |
| **1. First features** | Auth + one core feature, end to end, tests, release to store | One real user flow in production |
| **2. Second brand** | Flavor = brand, generated brand file, per-brand tokens/assets, brand golden + smoke test | A second brand is signed |
| **3. Content & flags** | Remote Config + CMS behind ports, typed section registry | Non-devs need changes without releases |
| **4. Packages & shells** | Promote features to packages, `apps/<brand>` shells, Mason bricks, Melos, CI matrix | Brands need different native SDKs, or the team is > 5 |
| **5. Scale** | flavorizr, Fastlane/Codemagic per brand, OpenAPI client, Drift where offline is needed | > 5 brands, > 20 endpoints, offline requirement |

Each phase keeps the doc's rules (layers, ports, repositories as the only
data access), so moving forward is adding code, not rewriting it.

---

## 9. Relation to the simplification review

Branch `claude/beautiful-ramanujan-wym087` has
`docs/research/architecture-review.md`, which recommends one app with flavors,
no packages per feature, and zero `build_runner`. This analysis agrees on:
one state idiom, avoiding `Command` + `Result` duplication, a codegen budget,
and starting with folders.

It differs on two points:
- **Shells are not just over-engineering.** When brands differ in native SDKs,
  one app with flags ships every SDK and permission to every brand. Then
  shells (or at least compile-time composition) are required. The review's
  "one app, flavor = brand" is right only when brands share the same feature
  set.
- **Ports for more than analytics.** Crash reporting, feature flags, content
  and storage ports are cheap and give fakes for tests and previews. Worth
  having from phase 0, even with one vendor each.

---

### Verification notes
- Dart 3.13.5: `FeatureModule` as `abstract interface class` → errors
  `non_abstract_class_inherits_abstract_member` (with `implements`) and
  `invalid_use_of_type_outside_library` (with `extends`).
- Dart 3.13.5: with `Result`'s `Error<T>` imported, `throw Error()` →
  `not_enough_positional_arguments`.
- Pub workspace with packages `core`, `feature_a`, `feature_b`: `feature_a`
  imports undeclared `feature_b` → `dart run` succeeds, `dart analyze` clean;
  with `depend_on_referenced_packages` enabled → reported as `info`.
- Riverpod 3 behaviors (legacy providers moved to `legacy.dart`, automatic
  provider retry, `misc.dart` exports) are from the Riverpod 3.0 release notes.
  Check against the version you pin.

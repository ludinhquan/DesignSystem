# widgetbook_app

Widgetbook catalog for the design-system components: one use case per
component with knobs, plus light/dark theme, text-scale and alignment addons.

```sh
flutter run -d chrome      # local catalog
flutter build web          # static site in build/web (built in CI)
flutter test               # smoke test: every use case renders themed
```

New component? Add a `lib/use_cases/app_<name>_use_case.dart` and register it
in `lib/main.dart` (see the definition of done in the root `CLAUDE.md`).

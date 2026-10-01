# example

Minimal app that consumes the design system (`ds_components`) with a
light/dark theme toggle. Generated with
`flutter create --empty --platforms=android,ios,web`.

```sh
flutter run            # from this directory, after `flutter pub get` at the repo root
flutter test
```

Note: the app uses `package:material_ui`'s `MaterialApp`; using
`package:flutter/material.dart` here would hide the design-system theme.

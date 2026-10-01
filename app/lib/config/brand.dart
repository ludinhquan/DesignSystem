import 'package:ds/ds.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'brands/brand_a.dart';

/// Everything that differs between brands at compile time.
///
/// Flavor = brand: the native flavor sets bundle ID, app name and icon; in
/// Dart, [appFlavor] selects the [Brand]. Add a `Set<Feature> features` field
/// when the first brand-specific feature flag is needed.
class Brand {
  const Brand({required this.id, required this.appName, required this.ds});

  /// Matches the native flavor name and the `config/<id>.<env>.json` files.
  final String id;

  /// Shown in the UI through `{appName}` placeholders, never hard-coded in ARB.
  final String appName;

  /// Design-system inputs: primary color, font, radius.
  final DsBrand ds;

  static Brand fromFlavor(String? flavor) => switch (flavor) {
    // Add one case per brand: 'brand_b' => brandB,
    _ => brandA,
  };
}

/// The current brand. Tests override it to check another brand.
final brandProvider = Provider<Brand>((ref) => Brand.fromFlavor(appFlavor));

// Tier 1: primitive tokens. Raw values with no meaning.
//
// Only the semantic tier (semantic.dart) and the theme may read these.
// Components never do.

import 'package:flutter/widgets.dart';

/// Raw color palette.
abstract final class DsPalette {
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral100 = Color(0xFFF1F5F9);
  static const neutral200 = Color(0xFFE2E8F0);
  static const neutral300 = Color(0xFFCBD5E1);
  static const neutral400 = Color(0xFF94A3B8);
  static const neutral500 = Color(0xFF64748B);
  static const neutral600 = Color(0xFF475569);
  static const neutral700 = Color(0xFF334155);
  static const neutral800 = Color(0xFF1E293B);
  static const neutral900 = Color(0xFF0F172A);

  static const blue600 = Color(0xFF2563EB);
  static const teal600 = Color(0xFF0D9488);
  static const violet600 = Color(0xFF7C3AED);

  static const green300 = Color(0xFF86EFAC);
  static const green700 = Color(0xFF15803D);
  static const green900 = Color(0xFF14532D);
  static const amber300 = Color(0xFFFCD34D);
  static const amber700 = Color(0xFFB45309);
  static const amber900 = Color(0xFF78350F);
}

/// Spacing scale (logical pixels).
abstract final class DsSpaceScale {
  static const s0 = 0.0;
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s10 = 40.0;
  static const s12 = 48.0;
}

/// Corner radius scale (logical pixels).
abstract final class DsRadiusScale {
  static const none = 0.0;
  static const r1 = 4.0;
  static const r2 = 8.0;
  static const r3 = 12.0;
  static const r4 = 16.0;
  static const r6 = 24.0;
  static const full = 999.0;
}

/// Font size scale (logical pixels, before text scaling).
abstract final class DsFontSize {
  static const xs = 12.0;
  static const sm = 14.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

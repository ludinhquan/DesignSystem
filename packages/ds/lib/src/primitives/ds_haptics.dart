import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/ds_tokens.dart';

/// The only way components and screens fire haptics. Each call pairs with a
/// visible change in the same frame. Systems may turn haptics off.
abstract final class DsHaptics {
  static void _fire(BuildContext context, Future<void> Function() call) {
    if (context.ds.system.haptics) unawaited(call());
  }

  /// Toggles, segments, tabs, chips, the front card of a stack.
  static void selection(BuildContext context) =>
      _fire(context, HapticFeedback.selectionClick);

  /// The prominent button, a tappable card.
  static void press(BuildContext context) =>
      _fire(context, HapticFeedback.lightImpact);

  /// Confirm in a sheet.
  static void confirm(BuildContext context) =>
      _fire(context, HapticFeedback.mediumImpact);

  /// A payment or transfer succeeded (the ripple frame).
  static void success(BuildContext context) =>
      _fire(context, HapticFeedback.successNotification);

  static void warning(BuildContext context) =>
      _fire(context, HapticFeedback.warningNotification);

  /// Over the balance, validation failed.
  static void error(BuildContext context) =>
      _fire(context, HapticFeedback.errorNotification);
}

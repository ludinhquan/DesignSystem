import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';

/// The one vendor wrapper. Feature code only sees this interface.
///
/// Calls are fire-and-forget: they never throw and never need `await`.
abstract interface class Analytics {
  void track(String event, [Map<String, Object> props = const {}]);
  void identify(String userId);

  /// Forgets the current user. Called on logout.
  void reset();
}

/// Event names, in one place.
abstract final class Events {
  static const login = 'login';
  static const logout = 'logout';
  static const localeChanged = 'locale_changed';
}

/// Fans each call out to every vendor and isolates failures: one vendor
/// throwing (sync or async) never reaches the caller or the other vendors.
final class SafeAnalytics implements Analytics {
  SafeAnalytics(this._vendors, {void Function(Object, StackTrace)? onError})
    : _onError = onError ?? _report;

  final List<Analytics> _vendors;
  final void Function(Object error, StackTrace stack) _onError;

  static void _report(Object error, StackTrace stack) =>
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'analytics',
        ),
      );

  void _each(void Function(Analytics vendor) call) {
    for (final vendor in _vendors) {
      try {
        call(vendor);
      } catch (e, s) {
        _onError(e, s);
      }
    }
  }

  @override
  void track(String event, [Map<String, Object> props = const {}]) =>
      _each((v) => v.track(event, props));

  @override
  void identify(String userId) => _each((v) => v.identify(userId));

  @override
  void reset() => _each((v) => v.reset());
}

/// Prints events in debug builds. Stands in until a vendor is chosen.
final class DebugAnalytics implements Analytics {
  const DebugAnalytics();

  @override
  void track(String event, [Map<String, Object> props = const {}]) =>
      debugPrint('[analytics] $event $props');

  @override
  void identify(String userId) => debugPrint('[analytics] identify $userId');

  @override
  void reset() => debugPrint('[analytics] reset');
}

/// Add the vendor adapter here (e.g. `if (Env.isProd) PostHogAnalytics()`).
/// An adapter whose SDK is async starts its futures without awaiting them, so
/// an async failure lands in the zone's error handler (Sentry), not in the
/// caller and not in the other vendors.
final analyticsProvider = Provider<Analytics>(
  (ref) => SafeAnalytics([if (!Env.isProd) const DebugAnalytics()]),
);

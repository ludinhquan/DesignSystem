import 'package:app/core/analytics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

class _Broken implements Analytics {
  @override
  void identify(String userId) => throw StateError('vendor down');

  @override
  void track(String event, [Map<String, Object> props = const {}]) =>
      throw StateError('vendor down');

  @override
  void reset() => throw StateError('vendor down');
}

void main() {
  test('one vendor failing never breaks the others or the caller', () {
    final healthy = FakeAnalytics();
    final errors = <Object>[];
    final analytics = SafeAnalytics([
      _Broken(),
      healthy,
    ], onError: (e, _) => errors.add(e));

    analytics
      ..identify('u1')
      ..track(Events.login)
      ..reset();

    expect(healthy.calls, ['identify:u1', 'track:login', 'reset']);
    expect(errors, hasLength(3));
  });
}

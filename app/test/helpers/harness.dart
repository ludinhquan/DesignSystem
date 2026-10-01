import 'package:app/core/analytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records analytics calls as strings: `identify:<id>`, `track:<event>`, `reset`.
class FakeAnalytics implements Analytics {
  final calls = <String>[];

  @override
  void identify(String userId) => calls.add('identify:$userId');

  @override
  void track(String event, [Map<String, Object> props = const {}]) =>
      calls.add('track:$event');

  @override
  void reset() => calls.add('reset');
}

/// Fresh in-memory shared_preferences and secure storage.
Future<SharedPreferences> setUpStorage({
  Map<String, Object> prefs = const {},
  Map<String, String> secure = const {},
}) {
  SharedPreferences.setMockInitialValues(prefs);
  FlutterSecureStorage.setMockInitialValues(Map.of(secure));
  return SharedPreferences.getInstance();
}

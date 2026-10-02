import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Now", injectable so greetings and dates are testable.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/session_controller.dart';

/// Example per-user state. It watches [sessionProvider], so it starts from
/// zero for every login and is cleared on logout.
final tapCountProvider = NotifierProvider<TapCountController, int>(
  TapCountController.new,
);

class TapCountController extends Notifier<int> {
  @override
  int build() {
    ref.watch(sessionProvider);
    return 0;
  }

  void increment() => state++;
}

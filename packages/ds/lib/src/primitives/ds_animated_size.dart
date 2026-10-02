import 'package:flutter/widgets.dart';

import '../foundation/ds_motion.dart';
import '../theme/ds_tokens.dart';

/// Size changes on a spring; with Reduce Motion the new size applies at
/// once. (A zero-length `AnimatedSize` is rejected by Flutter, and while it
/// morphs, children outside its current size are not tappable.)
class DsAnimatedSize extends StatelessWidget {
  const DsAnimatedSize({
    required this.child,
    this.spring,
    this.alignment = Alignment.center,
    super.key,
  });

  final Widget child;

  /// Defaults to the system's smooth spring.
  final DsSpring? spring;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    if (context.dsReduceMotion) return child;
    final s = spring ?? context.ds.motion.smooth;
    return AnimatedSize(
      duration: s.duration,
      curve: s.curve,
      alignment: alignment,
      child: child,
    );
  }
}

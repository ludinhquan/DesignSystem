import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../foundation/ds_shadows.dart';
import '../foundation/ds_type.dart';
import '../primitives/ds_box.dart';
import '../primitives/ds_haptics.dart';
import '../theme/ds_tokens.dart';

/// One option of a [DsSegmentedControl].
@immutable
class DsSegment<T> {
  const DsSegment(this.value, this.label);

  final T value;

  /// One short word. No icons.
  final String label;
}

/// Two to four exclusive options in a pill track, with one raised thumb that
/// slides to the selection on the snappy spring.
class DsSegmentedControl<T> extends StatelessWidget {
  const DsSegmentedControl({
    required this.segments,
    required this.value,
    required this.onChanged,
    this.small = false,
    this.semanticLabel,
    super.key,
  }) : assert(segments.length >= 2 && segments.length <= 4);

  final List<DsSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;

  /// `control-sm` (inside cards) instead of `control-md`.
  final bool small;

  /// Names the group for screen readers.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final c = ds.colors;
    final height = small ? ds.size.controlSm : ds.size.controlMd;
    final index = math.max(0, segments.indexWhere((s) => s.value == value));
    final spring = ds.motion.snappy;
    final reduce = context.dsReduceMotion;
    final regular = DsTypography.withWeight(ds.text.subhead, 500);
    void select(int i) {
      if (i == index) return;
      DsHaptics.selection(context);
      onChanged(segments[i].value);
    }

    final bold = DsTypography.withWeight(ds.text.subhead, 600);

    return Semantics(
      container: true,
      label: semanticLabel,
      child: SizedBox(
        height: math.max(height, small ? height : ds.size.hitTarget),
        child: Center(
          child: DsBox(
            shape: ds.shape(ds.radius.full),
            color: c.fillSubtle,
            shadow: DsShadow.none,
            child: SizedBox(
              height: height,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = (constraints.maxWidth - 4) / segments.length;
                  return Stack(
                    children: [
                      AnimatedPositionedDirectional(
                        duration: reduce ? Duration.zero : spring.duration,
                        curve: spring.curve,
                        start: 2 + w * index,
                        top: 2,
                        bottom: 2,
                        width: w,
                        child: DsBox(
                          shape: ds.shape(ds.radius.full),
                          color: c.thumb,
                          shadow: ds.shadows.knob,
                        ),
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 2),
                          for (final (i, s) in segments.indexed)
                            SizedBox(
                              width: w,
                              child: Semantics(
                                container: true,
                                button: true,
                                selected: i == index,
                                inMutuallyExclusiveGroup: true,
                                label: s.label,
                                onTap: () => select(i),
                                excludeSemantics: true,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => select(i),
                                  child: Center(
                                    // A hidden bold copy reserves the width,
                                    // so selecting never shifts the label.
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Visibility.maintain(
                                          visible: false,
                                          child: Text(
                                            s.label,
                                            style: bold,
                                            maxLines: 1,
                                          ),
                                        ),
                                        Text(
                                          s.label,
                                          maxLines: 1,
                                          style: (i == index ? bold : regular)
                                              .copyWith(color: c.text1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

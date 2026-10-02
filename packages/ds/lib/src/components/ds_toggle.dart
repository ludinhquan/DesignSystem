import 'package:material_ui/material_ui.dart';

import '../primitives/ds_box.dart';
import '../primitives/ds_haptics.dart';
import '../theme/ds_tokens.dart';

/// An on/off switch: 52 × 32 track (`fill-strong` off, `accent` on) and a
/// 28px knob that slides on the snappy spring and stretches while pressed.
///
/// State is carried by the knob's position, not colour alone; with the
/// system's On/Off Labels setting it also draws I / O marks.
class DsToggle extends StatefulWidget {
  const DsToggle({
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    super.key,
  });

  final bool value;

  /// Null disables the toggle.
  final ValueChanged<bool>? onChanged;

  /// Needed when the row's title does not name the setting.
  final String? semanticLabel;

  @override
  State<DsToggle> createState() => _DsToggleState();
}

class _DsToggleState extends State<DsToggle> {
  bool _pressed = false;

  void _toggle() {
    if (widget.onChanged == null) return;
    DsHaptics.selection(context);
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final c = ds.colors;
    const width = 52.0;
    const height = 32.0;
    const knob = 28.0;
    final knobWidth = _pressed ? 34.0 : knob;
    final reduce = context.dsReduceMotion;
    final spring = ds.motion.snappy;
    final labels = MediaQuery.maybeOnOffSwitchLabelsOf(context) ?? false;
    final on = widget.value;

    return Semantics(
      container: true,
      toggled: on,
      enabled: widget.onChanged != null,
      label: widget.semanticLabel,
      onTap: widget.onChanged == null ? null : _toggle,
      child: Opacity(
        opacity: widget.onChanged == null ? ds.opacity.disabled : 1,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: _toggle,
          child: SizedBox(
            width: width,
            height: ds.size.hitTarget,
            child: Center(
              child: SizedBox(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: reduce ? Duration.zero : ds.motion.fade,
                        decoration: ShapeDecoration(
                          shape: const StadiumBorder(),
                          color: on ? c.accent : c.fillStrong,
                        ),
                      ),
                    ),
                    if (labels)
                      Positioned.fill(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: 1.5,
                              height: 10,
                              color: on ? c.onAccent : const Color(0x00000000),
                            ),
                            Container(
                              width: 9,
                              height: 9,
                              decoration: ShapeDecoration(
                                shape: CircleBorder(
                                  side: BorderSide(
                                    color: on
                                        ? const Color(0x00000000)
                                        : c.text2,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    AnimatedPositionedDirectional(
                      duration: reduce ? Duration.zero : spring.duration,
                      curve: spring.curve,
                      top: (height - knob) / 2,
                      start: on ? width - 2 - knobWidth : 2,
                      width: knobWidth,
                      height: knob,
                      child: DsBox(
                        shape: const StadiumBorder(),
                        color: c.knob,
                        shadow: ds.shadows.knob,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

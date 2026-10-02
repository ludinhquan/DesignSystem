import 'package:material_ui/material_ui.dart';

import '../theme/ds_tokens.dart';

/// What a [DsPressable] tells its builder.
@immutable
class DsPressState {
  const DsPressState({
    required this.pressed,
    required this.focused,
    required this.enabled,
  });

  final bool pressed;
  final bool focused;
  final bool enabled;
}

/// The one press behaviour: scale in over 80–120ms with a strong ease-out,
/// release on a spring, keyboard activation, and a focus ring (2px
/// `focus-ring` outside a 2px gap) drawn around [focusShape].
///
/// Reduce Motion keeps the press state but drops the scale.
class DsPressable extends StatefulWidget {
  const DsPressable({
    required this.builder,
    required this.onTap,
    this.scale,
    this.object = false,
    this.focusShape,
    this.onPressDown,
    this.enabled = true,
    super.key,
  });

  final Widget Function(BuildContext context, DsPressState state) builder;
  final VoidCallback? onTap;

  /// Pressed scale; defaults to the system's button scale.
  final double? scale;

  /// Objects (cards) press in more slowly and release on the object spring.
  final bool object;

  /// Shape the focus ring follows. No ring when null.
  final ShapeBorder? focusShape;

  /// Fires at touch-down (e.g. a haptic on the prominent button).
  final VoidCallback? onPressDown;
  final bool enabled;

  @override
  State<DsPressable> createState() => _DsPressableState();
}

class _DsPressableState extends State<DsPressable>
    with SingleTickerProviderStateMixin {
  late final _scale = AnimationController.unbounded(vsync: this, value: 1);
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.enabled && widget.onTap != null;

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  void _down() {
    if (!_enabled) return;
    setState(() => _pressed = true);
    widget.onPressDown?.call();
    if (context.dsReduceMotion) return;
    final m = context.ds.motion;
    _scale.animateTo(
      widget.scale ?? m.pressScaleButton,
      duration: widget.object ? m.pressInObject : m.pressIn,
      curve: m.pressCurve,
    );
  }

  void _up() {
    if (!_pressed) return;
    setState(() => _pressed = false);
    if (context.dsReduceMotion) {
      _scale.value = 1;
      return;
    }
    final m = context.ds.motion;
    final spring = widget.object ? m.object : m.snappy;
    _scale.animateWith(spring.simulate(_scale.value, 1));
  }

  @override
  Widget build(BuildContext context) {
    final state = DsPressState(
      pressed: _pressed,
      focused: _focused,
      enabled: _enabled,
    );
    Widget child = AnimatedBuilder(
      animation: _scale,
      builder: (context, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: widget.builder(context, state),
    );
    if (_focused && widget.focusShape != null) {
      child = CustomPaint(
        foregroundPainter: _FocusRingPainter(
          widget.focusShape!,
          context.ds.colors.focusRing,
        ),
        child: child,
      );
    }
    return FocusableActionDetector(
      enabled: _enabled,
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      mouseCursor: _enabled ? SystemMouseCursors.click : MouseCursor.defer,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => widget.onTap?.call(),
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _down(),
        onTapUp: (_) => _up(),
        onTapCancel: _up,
        onTap: _enabled ? widget.onTap : null,
        child: child,
      ),
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  _FocusRingPainter(this.shape, this.color);

  final ShapeBorder shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Centre line 3px out: a 2px ring with a 2px gap inside it.
    final path = shape.getOuterPath((Offset.zero & size).inflate(3));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_FocusRingPainter old) =>
      old.shape != shape || old.color != color;
}

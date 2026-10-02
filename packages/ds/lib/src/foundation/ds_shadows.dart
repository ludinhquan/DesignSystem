import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// One CSS-style shadow layer: `[inset] dx dy blur spread color`.
@immutable
class DsShadowLayer {
  const DsShadowLayer({
    required this.color,
    this.dx = 0,
    this.dy = 0,
    this.blur = 0,
    this.spread = 0,
    this.inset = false,
  });

  final Color color;
  final double dx;
  final double dy;
  final double blur;
  final double spread;

  /// Painted inside the shape (a lit top lip, an inner hairline).
  final bool inset;

  BoxShadow toBoxShadow() => BoxShadow(
    color: color,
    offset: Offset(dx, dy),
    blurRadius: blur,
    spreadRadius: spread,
  );
}

/// A stack of shadow layers, as one design token (`shadow-surface`, ...).
@immutable
class DsShadow {
  const DsShadow(this.layers);

  static const none = DsShadow([]);

  final List<DsShadowLayer> layers;

  /// The layers a [BoxShadow] can express (drawn outside the shape).
  List<BoxShadow> get outer => [
    for (final l in layers)
      if (!l.inset) l.toBoxShadow(),
  ];

  bool get hasInset => layers.any((l) => l.inset);

  /// Paints the inset layers inside [border] laid out in [rect].
  void paintInset(Canvas canvas, Rect rect, ShapeBorder border) {
    if (!hasInset) return;
    final shape = border.getOuterPath(rect);
    canvas.save();
    canvas.clipPath(shape);
    for (final l in layers) {
      if (!l.inset) continue;
      final hole = border.getOuterPath(
        rect.deflate(l.spread).shift(Offset(l.dx, l.dy)),
      );
      final ring = Path.combine(
        PathOperation.difference,
        Path()..addRect(rect.inflate(l.blur * 2 + l.dx.abs() + l.dy.abs() + 2)),
        hole,
      );
      final paint = Paint()..color = l.color;
      if (l.blur > 0) {
        paint.maskFilter = ui.MaskFilter.blur(BlurStyle.normal, l.blur / 2);
      }
      canvas.drawPath(ring, paint);
    }
    canvas.restore();
  }
}

/// Every shadow token of a system, for one brightness. Object shadows live
/// on each `DsFieldColors`.
@immutable
class DsShadows {
  const DsShadows({
    required this.surface,
    required this.highlight,
    required this.objectPress,
    required this.accent,
    required this.glass,
    required this.knob,
    required this.sheet,
  });

  /// Chrome edge: a hairline in light, a top lip in dark. Never soft.
  final DsShadow surface;

  /// The 1px lit top edge on objects.
  final DsShadow highlight;

  /// An object pressed toward the table.
  final DsShadow objectPress;

  /// The prominent button and the selected tab pill.
  final DsShadow accent;
  final DsShadow glass;
  final DsShadow knob;
  final DsShadow sheet;
}

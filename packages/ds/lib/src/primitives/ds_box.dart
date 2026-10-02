import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../foundation/ds_colors.dart';
import '../foundation/ds_shadows.dart';
import '../theme/ds_tokens.dart';

/// A shape with a fill and a shadow token, inset layers included. The
/// material of all chrome (groups, fields, pills) and the base of objects.
class DsBox extends StatelessWidget {
  const DsBox({
    required this.shape,
    this.color,
    this.gradient,
    this.shadow = DsShadow.none,
    this.foreground,
    this.padding,
    this.clip = false,
    this.child,
    super.key,
  });

  final ShapeBorder shape;
  final Color? color;
  final Gradient? gradient;
  final DsShadow shadow;

  /// Painted over [child] inside the shape (grain, specular).
  final CustomPainter? foreground;
  final EdgeInsetsGeometry? padding;

  /// Clips [child] to the shape.
  final bool clip;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Widget? content = child;
    if (padding != null) content = Padding(padding: padding!, child: content);
    if (clip && content != null) {
      content = ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: content,
      );
    }
    // Order: fill and outer shadows, then grain/specular, then the content,
    // then the inset layers (the lit lip sits on top of everything).
    return CustomPaint(
      foregroundPainter: _InsetPainter(shape, shadow),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape,
          color: gradient == null ? color : null,
          gradient: gradient,
          shadows: shadow.outer,
        ),
        child: foreground == null
            ? content
            : CustomPaint(
                painter: _ClippedPainter(shape, foreground!),
                child: content,
              ),
      ),
    );
  }
}

class _InsetPainter extends CustomPainter {
  _InsetPainter(this.shape, this.shadow);

  final ShapeBorder shape;
  final DsShadow shadow;

  @override
  void paint(Canvas canvas, Size size) =>
      shadow.paintInset(canvas, Offset.zero & size, shape);

  @override
  bool shouldRepaint(_InsetPainter old) =>
      old.shape != shape || old.shadow != shadow;
}

class _ClippedPainter extends CustomPainter {
  _ClippedPainter(this.shape, this.painter);

  final ShapeBorder shape;
  final CustomPainter painter;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipPath(shape.getOuterPath(Offset.zero & size));
    painter.paint(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ClippedPainter old) =>
      old.shape != shape || painter.shouldRepaint(old.painter);
}

/// The face of an object (account card, glyph tile, monogram): a 155°
/// gradient of the field, the lit top lip, the object's own shadow (tighter
/// while pressed), monochrome grain and a specular highlight from the top
/// left. Grain and specular follow the system's opacity tokens (0 = off).
class DsObjectFace extends StatelessWidget {
  const DsObjectFace({
    required this.field,
    required this.shape,
    this.pressed = false,
    this.shiftTo,
    this.grain = true,
    this.specular = true,
    this.shadow,
    this.padding,
    this.child,
    super.key,
  });

  final DsFieldColors field;
  final ShapeBorder shape;
  final bool pressed;

  /// Monthly face shift: the end stop moves `opacity-shift` toward this
  /// field's face.
  final DsFieldColors? shiftTo;
  final bool grain;
  final bool specular;

  /// Overrides the resting shadow (cards behind a stack drop to contact).
  final DsShadow? shadow;
  final EdgeInsetsGeometry? padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final end = shiftTo == null
        ? field.end
        : Color.lerp(field.end, shiftTo!.face, ds.opacity.shift)!;
    final isGraphite = identical(field, ds.colors.graphite);
    final specularPeak = specular
        ? ds.opacity.specular * (isGraphite ? 1 / 3 : 1)
        : 0.0;
    final grainAmount = grain ? ds.opacity.grain : 0.0;
    return DsBox(
      shape: shape,
      gradient: LinearGradient(
        begin: const Alignment(-0.42, -1),
        end: const Alignment(0.42, 1),
        colors: [field.face, end],
      ),
      shadow: DsShadow([
        ...(pressed ? ds.shadows.objectPress : (shadow ?? field.shadow)).layers,
        ...ds.shadows.highlight.layers,
      ]),
      foreground: (specularPeak > 0 || grainAmount > 0)
          ? _MaterialPainter(grain: grainAmount, specular: specularPeak)
          : null,
      padding: padding,
      child: child,
    );
  }
}

/// Grain (seeded, so goldens are stable) and the specular highlight.
class _MaterialPainter extends CustomPainter {
  _MaterialPainter({required this.grain, required this.specular});

  final double grain;
  final double specular;

  static final Map<int, Float32List> _cache = {};

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (specular > 0) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.75, -0.95),
            radius: 1.1,
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: specular),
              const Color(0x00FFFFFF),
            ],
          ).createShader(rect),
      );
    }
    if (grain > 0) {
      final points = _points(size);
      canvas.drawRawPoints(
        ui.PointMode.points,
        points,
        Paint()
          ..color = const Color(0xFF000000).withValues(alpha: grain * 1.5)
          ..strokeWidth = 0.6,
      );
    }
  }

  static Float32List _points(Size size) {
    final key = size.width.round() << 16 | size.height.round();
    return _cache.putIfAbsent(key, () {
      final r = math.Random(7);
      final n = (size.width * size.height / 2).round();
      final list = Float32List(n * 2);
      for (var i = 0; i < n; i++) {
        list[i * 2] = r.nextDouble() * size.width;
        list[i * 2 + 1] = r.nextDouble() * size.height;
      }
      return list;
    });
  }

  @override
  bool shouldRepaint(_MaterialPainter old) =>
      old.grain != grain || old.specular != specular;
}

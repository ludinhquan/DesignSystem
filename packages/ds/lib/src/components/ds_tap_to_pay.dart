import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../foundation/ds_type.dart';
import '../primitives/ds_glyph.dart';
import '../primitives/ds_haptics.dart';
import '../theme/ds_tokens.dart';
import 'ds_account_card.dart';
import 'ds_money.dart';

/// Where a contactless payment is.
enum DsPayStatus { ready, success }

/// The signature moment. When [status] turns to success, once:
///
/// 1. 0–140ms the card dips toward the reader: tilts 9° and squashes to
///    0.94 × 0.925 while its shadow tightens.
/// 2. At 120ms one 3px accent ring in the card's shape ripples out and
///    fades over 760ms; the success haptic fires on that frame.
/// 3. The card returns on the object spring.
/// 4. At 260ms the status cross-fades in and the amount rolls into place.
///
/// Reduce Motion: no dip and no scaling ring; the ring fades in place.
class DsTapToPay extends StatefulWidget {
  const DsTapToPay({
    required this.card,
    required this.status,
    required this.amount,
    required this.readyLabel,
    required this.successLabel,
    this.merchant,
    super.key,
  });

  final DsCardData card;
  final DsPayStatus status;

  /// The payment, in đồng (positive; shown as an outflow).
  final int amount;

  /// "Giữ mặt sau điện thoại gần máy POS".
  final String readyLabel;

  /// "Đã thanh toán".
  final String successLabel;
  final String? merchant;

  static const _total = Duration(milliseconds: 900);

  @override
  State<DsTapToPay> createState() => _DsTapToPayState();
}

class _DsTapToPayState extends State<DsTapToPay>
    with SingleTickerProviderStateMixin {
  late final _t = AnimationController(vsync: this, duration: DsTapToPay._total);
  bool _hapticDone = false;

  double _ms(double ms) => ms / DsTapToPay._total.inMilliseconds;

  @override
  void initState() {
    super.initState();
    _t.addListener(() {
      if (!_hapticDone && _t.value >= _ms(120)) {
        _hapticDone = true;
        DsHaptics.success(context);
      }
    });
    // Already paid when shown (a receipt): no moment, no haptic.
    if (widget.status == DsPayStatus.success) {
      _hapticDone = true;
      _t.value = 1;
    }
  }

  @override
  void didUpdateWidget(DsTapToPay old) {
    super.didUpdateWidget(old);
    if (old.status != DsPayStatus.success &&
        widget.status == DsPayStatus.success) {
      _hapticDone = false;
      _t.forward(from: 0);
    } else if (widget.status == DsPayStatus.ready) {
      _t.value = 0;
    }
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final c = ds.colors;
    final reduce = context.dsReduceMotion;
    const press = Cubic(0.23, 1, 0.32, 1);
    final spring = ds.motion.object.curve;

    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        final t = _t.value;
        final running = _t.isAnimating;
        // Dip: 0 → 1 over 140ms, back to 0 on the spring by 640ms.
        double dip = 0;
        if (running && !reduce) {
          if (t < _ms(140)) {
            dip = press.transform(t / _ms(140));
          } else if (t < _ms(640)) {
            dip = 1 - spring.transform((t - _ms(140)) / _ms(500));
          }
        }
        // Ring: from 120ms over 760ms.
        final ringT = ((t - _ms(120)) / _ms(760)).clamp(0.0, 1.0);
        final ringOn = running && t >= _ms(120);
        final statusT = widget.status == DsPayStatus.success
            ? ((t - _ms(260)) / _ms(200)).clamp(0.0, 1.0)
            : 0.0;

        final card = Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateX(-9 * math.pi / 180 * dip)
            ..scaleByDouble(1 - 0.06 * dip, 1 - 0.075 * dip, 1, 1),
          child: DsAccountCard(data: widget.card),
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                card,
                if (ringOn)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _RingPainter(
                          shape: ds.shape(ds.radius.card),
                          color: c.accent,
                          scaleX: reduce
                              ? 1
                              : 1 + 0.22 * press.transform(ringT),
                          scaleY: reduce
                              ? 1
                              : 1 + 0.34 * press.transform(ringT),
                          opacity: reduce
                              ? math.sin(ringT * math.pi) * 0.95
                              : 0.95 * (1 - ringT),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: ds.spacing.s8),
            SizedBox(
              height: 120,
              child: widget.status == DsPayStatus.ready
                  ? Column(
                      children: [
                        DsGlyph(ds.icons.contactless, size: 32, color: c.text2),
                        SizedBox(height: ds.spacing.s2),
                        Text(
                          widget.readyLabel,
                          textAlign: TextAlign.center,
                          style: ds.text.subhead.copyWith(color: c.text2),
                        ),
                      ],
                    )
                  : Opacity(
                      opacity: statusT,
                      child: Transform.translate(
                        offset: Offset(0, 6 * (1 - statusT)),
                        child: Semantics(
                          liveRegion: true,
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: c.accent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: DsGlyph(
                                      ds.icons.check,
                                      weight: DsGlyphWeight.bold,
                                      size: 16,
                                      color: c.onAccent,
                                    ),
                                  ),
                                  SizedBox(width: ds.spacing.s2),
                                  Flexible(
                                    child: Text(
                                      widget.successLabel,
                                      style: ds.text.headline.copyWith(
                                        color: c.text1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: ds.spacing.s2),
                              DsMoney(
                                -widget.amount,
                                roll: true,
                                style: DsTypography.withWeight(
                                  ds.text.displayCard.copyWith(fontSize: 34),
                                  700,
                                ),
                              ),
                              if (widget.merchant != null)
                                Text(
                                  widget.merchant!,
                                  style: ds.text.footnote.copyWith(
                                    color: c.text2,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.shape,
    required this.color,
    required this.scaleX,
    required this.scaleY,
    required this.opacity,
  });

  final ShapeBorder shape;
  final Color color;
  final double scaleX;
  final double scaleY;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width * scaleX;
    final h = size.height * scaleY;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: w,
      height: h,
    );
    canvas.drawPath(
      shape.getOuterPath(rect),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = color.withValues(alpha: opacity.clamp(0, 1)),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.scaleX != scaleX || old.scaleY != scaleY || old.opacity != opacity;
}

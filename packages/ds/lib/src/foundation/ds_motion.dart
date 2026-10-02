import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';

/// A spring given by duration and bounce (the designer's terms).
///
/// stiffness = (2π ÷ duration)², damping = 4π × (1 − bounce) ÷ duration.
@immutable
class DsSpring {
  const DsSpring(this.duration, {this.bounce = 0});

  final Duration duration;
  final double bounce;

  SpringDescription get description {
    final d = duration.inMicroseconds / Duration.microsecondsPerSecond;
    return SpringDescription(
      mass: 1,
      stiffness: math.pow(2 * math.pi / d, 2).toDouble(),
      damping: 4 * math.pi * (1 - bounce) / d,
    );
  }

  SpringSimulation simulate(double from, double to, {double velocity = 0}) =>
      SpringSimulation(description, from, to, velocity);

  /// This spring as a [Curve] over [duration], for implicit animations
  /// (`AnimatedPositioned(duration: s.duration, curve: s.curve)`). It may
  /// overshoot 1 by the bounce, and ends exactly at 1.
  Curve get curve => _SpringCurve(this);
}

class _SpringCurve extends Curve {
  _SpringCurve(this.spring) : _sim = spring.simulate(0, 1);

  final DsSpring spring;
  final SpringSimulation _sim;

  @override
  double transformInternal(double t) => _sim.x(
    t * spring.duration.inMicroseconds / Duration.microsecondsPerSecond,
  );
}

/// The motion contract: springs, press feedback and fades.
@immutable
class DsMotion {
  const DsMotion({
    required this.snappy,
    required this.smooth,
    required this.object,
    required this.roll,
    this.pressIn = const Duration(milliseconds: 80),
    this.pressInObject = const Duration(milliseconds: 120),
    this.pressCurve = const Cubic(0.23, 1, 0.32, 1),
    this.pressScaleButton = 0.97,
    this.pressScaleTile = 0.92,
    this.pressScaleCard = 0.96,
    this.fade = const Duration(milliseconds: 150),
    this.fadeLong = const Duration(milliseconds: 250),
    this.rollStagger = const Duration(milliseconds: 24),
  });

  /// Release after press, toggles, thumbs, chips.
  final DsSpring snappy;

  /// Sheets, navigation, layout changes.
  final DsSpring smooth;

  /// Objects: card reorder, tilt return, the end of the pay dip.
  final DsSpring object;

  /// Odometer digits.
  final DsSpring roll;

  /// Press-in is never a spring: a short, strong ease-out.
  final Duration pressIn;
  final Duration pressInObject;
  final Curve pressCurve;
  final double pressScaleButton;
  final double pressScaleTile;
  final double pressScaleCard;
  final Duration fade;
  final Duration fadeLong;
  final Duration rollStagger;
}

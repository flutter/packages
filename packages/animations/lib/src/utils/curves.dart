// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// The easing curves of the Material Library
/// The standard easing curve in the Material specification.
///
/// Elements that begin and end at rest use standard easing.
/// They speed up quickly and slow down gradually, in order
/// to emphasize the end of the transition.
///
/// See also:
/// * <https://material.io/design/motion/speed.html#easing>
const Curve standardEasing = Cubic(0.4, 0.0, 0.2, 1);

/// The accelerate easing curve in the Material specification.
///
/// Elements exiting a screen use acceleration easing,
/// where they start at rest and end at peak velocity.
///
/// See also:
/// * <https://material.io/design/motion/speed.html#easing>
const Curve accelerateEasing = Cubic(0.4, 0.0, 1.0, 1.0);

/// The decelerate easing curve in the Material specification.
///
/// Incoming elements are animated using deceleration easing,
/// which starts a transition at peak velocity (the fastest
/// point of an element’s movement) and ends at rest.
///
/// See also:
/// * <https://material.io/design/motion/speed.html#easing>
const Curve decelerateEasing = Cubic(0.0, 0.0, 0.2, 1.0);

// A tween that starts from 1.0 and ends at 0.0.
final Tween<double> _flippedTween = Tween<double>(
  begin: 1.0,
  end: 0.0,
);

/// Enables creating a flipped [CurveTween].
///
/// This creates a [CurveTween] that evaluates to a result that flips the
/// tween vertically.
///
/// This tween sequence assumes that the evaluated result has to be a double
/// between 0.0 and 1.0.
class FlippedCurveTween extends CurveTween {
  /// Creates a vertically flipped [CurveTween].
  FlippedCurveTween({
    @required Curve curve,
  })  : assert(curve != null),
        super(curve: curve);

  @override
  double transform(double t) => 1.0 - super.transform(t);
}

/// Flips the incoming passed in [Animation] to start from 1.0 and end at 0.0.
Animation<double> flipTween(Animation<double> animation) {
  return _flippedTween.animate(animation);
}

// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'utils/curves.dart';
import 'utils/modal.dart';

class FadeTransitionConfiguration extends ModalConfiguration {
  FadeTransitionConfiguration({
    bool barrierDismissible = true,
    String barrierLabel,
  }) : super(
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
  );

  @override
  Color get barrierColor => Colors.black54;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 75);

  @override
  ModalTransitionBuilder get transitionBuilder => _modalFadeTransitionBuilder;
}

ModalTransitionBuilder _modalFadeTransitionBuilder = (
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget child) {
      switch (animation.status) {
        case AnimationStatus.forward:
          return _EnterTransition(
            animation: animation,
            child: child,
          );
        case AnimationStatus.dismissed:
        case AnimationStatus.reverse:
        case AnimationStatus.completed:
          return FadeTransition(
            opacity: animation,
            child: child,
          );
      }
      return null; // unreachable
    },
    child: child,
  );
};

class _EnterTransition extends StatelessWidget {
  const _EnterTransition({
    this.animation,
    this.child,
  });

  final Animation<double> animation;
  final Widget child;

  static Animatable<double> fadeInTransition = CurveTween(
    curve: const Interval(0.0, 0.3),
  );
  static Animatable<double> scaleInTransition = Tween<double>(
    begin: 0.80,
    end: 1.00,
  ).chain(CurveTween(curve: decelerateEasing));

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeInTransition.animate(animation),
      child: ScaleTransition(
        scale: scaleInTransition.animate(animation),
        child: child,
      ),
    );
  }
}

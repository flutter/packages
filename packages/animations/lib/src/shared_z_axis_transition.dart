// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'utils/curves.dart';

/// TODO: documentation
class SharedZAxisPageTransitionBuilder extends PageTransitionsBuilder {
  /// Construct a [SharedZAxisPageTransitionBuilder].
  const SharedZAxisPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _SharedZAxisPageTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

class _SharedZAxisPageTransition extends StatefulWidget {
  const _SharedZAxisPageTransition({
    Key key,
    this.animation,
    this.secondaryAnimation,
    this.child,
  }) : super(key: key);

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  __SharedZAxisPageTransitionState createState() => __SharedZAxisPageTransitionState();
}

class __SharedZAxisPageTransitionState extends State<_SharedZAxisPageTransition> {
  static final Tween<double> _flippedTween = Tween<double>(
    begin: 1.0,
    end: 0.0,
  );

  static Animation<double> _flip(Animation<double> animation) {
    return _flippedTween.animate(animation);
  }

  @override
  Widget build(BuildContext context) {
    // Scale Transitions
    final Animation<double> _forwardEndScreenScaleTransition = widget.animation.drive(
      Tween<double>(begin: 0.80, end: 1.00)
        .chain(standardEasing));

    final Animation<double> _forwardStartScreenScaleTransition = widget.secondaryAnimation.drive(
      Tween<double>(begin: 1.00, end: 1.10)
        .chain(standardEasing));

    // Fade Transitions
    final Animation<double> _forwardStartScreenFadeTransition = _flip(widget.secondaryAnimation).drive(
      accelerateEasing
        .chain(CurveTween(curve: const Interval(0.0, 0.3))));

    final Animation<double> _forwardEndScreenFadeTransition = widget.animation.drive(
      decelerateEasing
        .chain(CurveTween(curve: const Interval(0.3, 1.0))));

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: _forwardEndScreenFadeTransition,
          child: ScaleTransition(
            scale: _forwardEndScreenScaleTransition,
            child: child,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: widget.secondaryAnimation,
        builder: (BuildContext context, Widget child) {
          return Container(
            color: Theme.of(context).canvasColor,
            child: FadeTransition(
              opacity: _forwardStartScreenFadeTransition,
              child: ScaleTransition(
                scale: _forwardStartScreenScaleTransition,
                child: child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
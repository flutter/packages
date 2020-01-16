// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'modal.dart';
import 'utils/curves.dart';

/// The modal transition configuration for a Material fade transition.
///
/// The fade pattern is used for UI elements that enter or exit from within
/// the screen bounds. Elements that enter use a quick fade in and scale from
/// 80% to 100%. Elements that exit simply fade out. The scale animation is
/// only applied to entering elements to emphasize new content over old.
///
/// ```dart
/// /// Sample widget that uses [showModal] with [FadeTransitionConfiguration].
/// class MyHomePage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Center(
///         child: RaisedButton(
///           onPressed: () {
///             showModal(
///               context: context,
///               configuration: FadeTransitionConfiguration(),
///               builder: (BuildContext context) {
///                 return _CenteredFlutterLogo();
///               },
///             );
///           },
///           child: Icon(Icons.add),
///         ),
///       ),
///     );
///   }
/// }
///
/// /// Displays a centered Flutter logo with size constraints.
/// class _CenteredFlutterLogo extends StatelessWidget {
///   const _CenteredFlutterLogo();
///
///   @override
///   Widget build(BuildContext context) {
///     return Center(
///       child: SizedBox(
///         width: 250,
///         height: 250,
///         child: const Material(
///           child: Center(
///             child: FlutterLogo(size: 250),
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
class FadeTransitionConfiguration extends ModalConfiguration {
  /// Creates the Material fade transition configuration.
  ///
  /// [barrierDismissible] cannot be null.
  FadeTransitionConfiguration({
    bool barrierDismissible = true,
    String barrierLabel,
  })  : assert(barrierDismissible != null),
        super(
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
  Widget transitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _MaterialFadeTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

class _MaterialFadeTransition extends StatefulWidget {
  const _MaterialFadeTransition({
    Key key,
    @required this.animation,
    @required this.secondaryAnimation,
    this.child,
  })  : assert(animation != null),
        assert(secondaryAnimation != null),
        super(key: key);

  /// The animation that drives the [child]'s entrance and exit.
  ///
  /// See also:
  ///
  ///  * [TransitionRoute.animate], which is the value given to this property
  ///    when it is used as a page transition.
  final Animation<double> animation;

  /// The animation that transitions [child] when new content is pushed on top
  /// of it.
  ///
  /// See also:
  ///
  ///  * [TransitionRoute.secondaryAnimation], which is the value given to this
  ///    property when the it is used as a page transition.
  final Animation<double> secondaryAnimation;

  /// The widget below this widget in the tree.
  ///
  /// This widget will transition in and out as driven by [animation] and
  /// [secondaryAnimation].
  final Widget child;

  @override
  _MaterialFadeTransitionState createState() => _MaterialFadeTransitionState();
}

class _MaterialFadeTransitionState extends State<_MaterialFadeTransition> {
  AnimationStatus _effectiveAnimationStatus;

  @override
  void initState() {
    super.initState();
    _effectiveAnimationStatus = widget.animation.status;
    widget.animation.addStatusListener(_animationListener);
  }

  void _animationListener(AnimationStatus animationStatus) {
    _effectiveAnimationStatus = _calculateEffectiveAnimationStatus(
      lastEffective: _effectiveAnimationStatus,
      current: animationStatus,
    );
  }

  // When a transition is interrupted midway we just want to play the ongoing
  // animation in reverse. Switching to the actual reverse transition would
  // yield a disjoint experience since the forward and reverse transitions are
  // very different.
  AnimationStatus _calculateEffectiveAnimationStatus({
    @required AnimationStatus lastEffective,
    @required AnimationStatus current,
  }) {
    assert(current != null);
    assert(lastEffective != null);
    switch (current) {
      case AnimationStatus.dismissed:
      case AnimationStatus.completed:
        return current;
      case AnimationStatus.forward:
        switch (lastEffective) {
          case AnimationStatus.dismissed:
          case AnimationStatus.completed:
          case AnimationStatus.forward:
            return current;
          case AnimationStatus.reverse:
            return lastEffective;
        }
        break;
      case AnimationStatus.reverse:
        switch (lastEffective) {
          case AnimationStatus.dismissed:
          case AnimationStatus.completed:
          case AnimationStatus.reverse:
            return current;
          case AnimationStatus.forward:
            return lastEffective;
        }
        break;
    }
    return null; // unreachable
  }

  void _updateAnimationListener(
    Animation<double> oldAnimation,
    Animation<double> animation,
  ) {
    if (oldAnimation != animation) {
      oldAnimation.removeStatusListener(_animationListener);
      animation.addStatusListener(_animationListener);
      _animationListener(animation.status);
    }
  }

  @override
  void didUpdateWidget(_MaterialFadeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimationListener(
      oldWidget.animation,
      widget.animation,
    );
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_animationListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (BuildContext context, Widget child) {
        assert(_effectiveAnimationStatus != null);
        switch (_effectiveAnimationStatus) {
          case AnimationStatus.forward:
            return _EnterTransition(
              animation: widget.animation,
              child: child,
            );
          case AnimationStatus.dismissed:
          case AnimationStatus.reverse:
          case AnimationStatus.completed:
            return FadeTransition(
              opacity: widget.animation,
              child: child,
            );
        }
        return null; // unreachable
      },
      child: widget.child,
    );
  }
}

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

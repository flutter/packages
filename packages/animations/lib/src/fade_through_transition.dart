// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Used by [PageTransitionsTheme] to define a page route transition animation
/// in which the outgoing page fade out, then the incoming page fade in and
/// scale up.
///
/// This pattern is recommended for transition animation between UI elements
/// that do not have a strong relationship to one another.
///
/// Scale is only applied to incoming elements to emphasize new content over
/// old.
///
/// See also:
///
///  * [Fade-through](https://spec.googleplex.com/draft/mio-design/motion-new/the-motion-system.html#fade-through)
///    in the Material Design spec.
class FadeThroughPageTransitionsBuilder extends PageTransitionsBuilder {
  /// Creates a [FadeThroughPageTransitionsBuilder].
  const FadeThroughPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeThroughTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Defines a transition in which outgoing elements fade out, then incoming
/// elements fade in and scale up.
///
/// The Fade through pattern provides a transition animation between UI elements
/// that do not have a strong relationship to one another. As an example, the
/// [BottomNavigationBar] may use this animation to transition the currently
/// displayed content when a new [BottomNavigationBarItem] is selected.
///
/// Scale is only applied to incoming elements to emphasize new content over
/// old.
///
/// Consider using [FadeThroughPageTransitionsBuilder] within a
/// [PageTransitionsTheme] if you want to apply this kind of transition to
/// [MaterialPageRoute] transitions within a Navigator. Or use this transition
/// directly in a [PageTransitionSwitcher.transitionBuilder] to transition
/// from one widget to another.
///
/// See also:
///
///  * [Fade-through](https://spec.googleplex.com/draft/mio-design/motion-new/the-motion-system.html#fade-through)
///    in the Material Design spec.
class FadeThroughTransition extends StatefulWidget {
  /// Creates a [FadeThroughTransition].
  ///
  /// The [animation] and [secondaryAnimation] argument are required and must
  /// not be null.
  const FadeThroughTransition({
    @required this.animation,
    @required this.secondaryAnimation,
    this.child,
  })  : assert(animation != null),
        assert(secondaryAnimation != null);

  /// The animation that drives the [child]'s entrance and exit.
  ///
  /// See also:
  ///
  ///  * [TransitionRoute.animate], which is the value given to this property
  ///    when the [FadeThroughTransition] is used as a page transition.
  final Animation<double> animation;

  /// The animation that transitions [child] when new content is pushed on top
  /// of it.
  ///
  /// See also:
  ///
  ///  * [TransitionRoute.secondaryAnimation], which is the value given to this
  //     property when the [FadeThroughTransition] is used as a page transition.
  final Animation<double> secondaryAnimation;

  /// The widget below this widget in the tree.
  ///
  /// This widget will transition in and out as driven by [animation] and
  /// [secondaryAnimation].
  final Widget child;

  @override
  State<FadeThroughTransition> createState() => _FadeThroughTransitionState();
}

class _FadeThroughTransitionState extends State<FadeThroughTransition> {
  AnimationStatus _effectiveAnimationStatus;
  AnimationStatus _effectiveSecondaryAnimationStatus;

  @override
  void initState() {
    super.initState();
    _effectiveAnimationStatus = widget.animation.status;
    _effectiveSecondaryAnimationStatus = widget.secondaryAnimation.status;
    widget.animation.addStatusListener(_animationListener);
    widget.secondaryAnimation.addStatusListener(_secondaryAnimationListener);
  }

  void _animationListener(AnimationStatus animationStatus) {
    _effectiveAnimationStatus = _calculateEffectiveAnimationStatus(
      lastEffective: _effectiveAnimationStatus,
      current: animationStatus,
    );
  }

  void _secondaryAnimationListener(AnimationStatus animationStatus) {
    _effectiveSecondaryAnimationStatus = _calculateEffectiveAnimationStatus(
      lastEffective: _effectiveSecondaryAnimationStatus,
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

  @override
  void didUpdateWidget(FadeThroughTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeStatusListener(_animationListener);
      widget.animation.addStatusListener(_animationListener);
      _animationListener(widget.animation.status);
    }
    if (oldWidget.secondaryAnimation != widget.secondaryAnimation) {
      oldWidget.secondaryAnimation
          .removeStatusListener(_secondaryAnimationListener);
      widget.secondaryAnimation.addStatusListener(_secondaryAnimationListener);
      _secondaryAnimationListener(widget.secondaryAnimation.status);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.animation.removeStatusListener(_animationListener);
    widget.secondaryAnimation.removeStatusListener(_secondaryAnimationListener);
  }

  static final Tween<double> _flippedTween =
      Tween<double>(begin: 1.0, end: 0.0);
  static Animation<double> _flip(Animation<double> animation) {
    return _flippedTween.animate(animation);
  }

  // Since widget.child gets moved around in the tree a bit we associate a
  // global key with it to ensure that it's state doesn't get lost.
  final GlobalKey _childKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (BuildContext context, Widget child) {
        assert(_effectiveAnimationStatus != null);
        switch (_effectiveAnimationStatus) {
          case AnimationStatus.forward:
            return _ZoomedFadeIn(
              animation: widget.animation,
              child: child,
            );
          case AnimationStatus.dismissed:
          case AnimationStatus.reverse:
          case AnimationStatus.completed:
            return _FadeOut(
              animation: _flip(widget.animation),
              child: child,
            );
        }
        return null; // unreachable
      },
      child: Container(
        color: Theme.of(context).canvasColor,
        child: AnimatedBuilder(
          animation: widget.secondaryAnimation,
          builder: (BuildContext context, Widget child) {
            assert(_effectiveSecondaryAnimationStatus != null);
            switch (_effectiveSecondaryAnimationStatus) {
              case AnimationStatus.forward:
                return _FadeOut(
                  child: child,
                  animation: widget.secondaryAnimation,
                );
              case AnimationStatus.dismissed:
              case AnimationStatus.reverse:
              case AnimationStatus.completed:
                return _ZoomedFadeIn(
                  animation: _flip(widget.secondaryAnimation),
                  child: child,
                );
            }
            return null; // unreachable
          },
          child: KeyedSubtree(
            key: _childKey,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _ZoomedFadeIn extends StatelessWidget {
  const _ZoomedFadeIn({
    this.child,
    this.animation,
  });

  final Widget child;
  final Animation<double> animation;

  static final CurveTween _inCurve = CurveTween(
    curve: const Cubic(0.0, 0.0, 0.2, 1.0),
  );
  static final TweenSequence<double> _scaleIn = TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0.95),
        weight: 6 / 20,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.95, end: 1.0).chain(_inCurve),
        weight: 14 / 20,
      ),
    ],
  );
  static final TweenSequence<double> _fadeInOpacity = TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0.0),
        weight: 6 / 20,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(_inCurve),
        weight: 14 / 20,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInOpacity.animate(animation),
      child: ScaleTransition(
        scale: _scaleIn.animate(animation),
        child: child,
      ),
    );
  }
}

class _FadeOut extends StatelessWidget {
  const _FadeOut({
    this.child,
    this.animation,
  });

  final Widget child;
  final Animation<double> animation;

  static final CurveTween _outCurve = CurveTween(
    curve: const Cubic(0.4, 0.0, 1.0, 1.0),
  );
  static final TweenSequence<double> _fadeOutOpacity = TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(_outCurve),
        weight: 6 / 20,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0.0),
        weight: 14 / 20,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeOutOpacity.animate(animation),
      child: child,
    );
  }
}

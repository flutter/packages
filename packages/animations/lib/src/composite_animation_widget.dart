// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Function signature for building component transitions (forward and reverse)
/// for [CompositeAnimationWidget].
///
/// The function should return a widget which wraps the given `child`.
typedef ComponentTransitionBuilder = Widget Function(Widget, Animation<double>);

/// A widget that animate it's child with different transitions based on
/// [AnimationStatus] of [CompositeAnimationWidget.animation].
/// If the ([CompositeAnimationWidget.animation]) value goes forward,
/// only [CompositeAnimationWidget.forwardTransitionBuilder] animates
/// from 0.0 to 1.0 and If goes reverse, only
/// [CompositeAnimationWidget.reverseTransitionBuilder] animates from 1.0 to 0.0.
///
/// The following example shows how use this widget to compose different
/// animations when going forward or reverse driven by one [Animation] object
/// only. Fading in on forward and Scaling down on reverse.
///
/// ```dart
/// CompositeAnimationWidget(
///   animation: animation,
///   forwardTransitionBuilder: (Widget child, Animation<double> animation)
///     => FadeTransition(
///       opacity: animation,
///       child: child,
///     ),
///   reverseTransitionBuilder: (Widget child, Animation<double> animation)
///     => ScaleTransition(
///       scale: animation,
///       child: child,
///     ),
///   child: child,
/// )
/// ```
///
/// It is used in [FadeThroughTransition], [SharedAxisTransition],
/// and [FadeScaleTransition] widgets.
///
/// This widget also preserve it's child state by building it's transitions by
/// composition and only changing animation values of both transitions instead
/// of changing the shape of widget subtree levels in [AnimatedBuilder]
/// based on [AnimationStatus] that causes the state object in that particular
/// subtree level to get recreated.
///
/// To ensure the state of the child widget will survive, don't define
/// conditional logic to switch subtrees in both transition builders required
/// by this widget.
class CompositeAnimationWidget extends StatefulWidget {
  /// Creates a widget that animate it's child with different transitions based
  /// on [AnimationStatus] of [animation].
  ///
  /// If the ([animation]) value goes forward, only [forwardTransitionBuilder]
  /// animates from 0.0 to 1.0 and If goes reverse, only [reverseTransitionBuilder]
  /// animates from 1.0 to 0.0.
  ///
  /// [animation] is typically an [AnimationController] that drives the
  /// transitions. [animation], [forwardTransitionBuilder] and
  /// [reverseTransitionBuilder] cannot be null.
  const CompositeAnimationWidget({
    @required this.animation,
    @required this.forwardTransitionBuilder,
    @required this.reverseTransitionBuilder,
    this.child,
    this.visibleAtStart = false,
  })  : assert(animation != null),
        assert(forwardTransitionBuilder != null),
        assert(reverseTransitionBuilder != null);

  /// The animation that drives the [child]'s entrance and exit.
  final Animation<double> animation;

  /// The widget below this widget in the tree.
  ///
  /// This widget will transition in and out as driven by [animation].
  final Widget child;

  /// A builder that wraps [child] with an animation that will only play when
  /// [animation] goes forward.
  ///
  /// To ensure the state of the child widget will survive, don't define this
  /// builder with conditional logic to switch subtrees.
  final ComponentTransitionBuilder forwardTransitionBuilder;

  /// A builder that wraps [child] with an animation that will only play when
  /// [animation] goes reverse.
  ///
  /// To ensure the state of the child widget will survive, don't define this
  /// builder with conditional logic to switch subtrees.
  final ComponentTransitionBuilder reverseTransitionBuilder;

  /// A flag to determine if you defined your transition builders
  /// ([forwardTransitionBuilder] and
  /// [reverseTransitionBuilder]) to have a
  /// "visible-point" of animation at 0.0 ([AnimationStatus.dismissed]).
  ///
  /// This is usually set to true if you want to animate a widget to
  /// disappear but with different exit and reenter animation without enter
  /// animation (visible at start), which means you defined exit animation at
  /// [forwardTransitionBuilder] and reenter animation
  /// at [reverseTransitionBuilder].
  ///
  /// Some transition implementations like [FadeThroughTransition] and
  /// [SharedAxisTransition] used to set this to true to define their
  /// secondary animation.
  final bool visibleAtStart;

  @override
  _CompositeAnimationWidgetState createState() =>
      _CompositeAnimationWidgetState();
}

class _CompositeAnimationWidgetState extends State<CompositeAnimationWidget> {
  // Ensures the animation will not disjoint at midpoint time, since the
  // animation going forward and reverse is different
  AnimationStatus _effectiveAnimationStatus;

  // Animation to be passed in [forwardTransitionBuilder]
  // It animates when [_effectiveAnimationStatus] is [AnimationStatus.forward]
  Animation<double> _forwardAnimation;

  // Animation to be passed in [reverseTransitionBuilder]
  // It animates when [_effectiveAnimationStatus] is [AnimationStatus.reverse]
  Animation<double> _reverseAnimation;

  @override
  void initState() {
    super.initState();
    widget.animation.addStatusListener(_handleAnimationStatusListener);
    // Initial setup of internal animation objects and
    // [_effectiveAnimationStatus]
    _effectiveAnimationStatus = widget.animation.status;
    _setAnimationValues();
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_handleAnimationStatusListener);
    super.dispose();
  }

  void _handleAnimationStatusListener(AnimationStatus animationStatus) {
    _effectiveAnimationStatus = _calculateEffectiveAnimationStatus(
      lastEffective: _effectiveAnimationStatus,
      current: animationStatus,
    );
    // call this every change of [_effectiveAnimationStatus]
    _setAnimationValues();
  }

  // This is called at [initState], [didUpdateWidget], and [_animationListener]
  // It changes the animation values based on [_effectiveAnimationStatus].
  void _setAnimationValues() {
    assert(_effectiveAnimationStatus != null);

    // Set visible animation value.
    final Animation<double> visibleAnimation = widget.visibleAtStart
        ? const AlwaysStoppedAnimation<double>(0.0)
        : const AlwaysStoppedAnimation<double>(1.0);

    switch (_effectiveAnimationStatus) {
      case AnimationStatus.dismissed:
        _forwardAnimation = const AlwaysStoppedAnimation<double>(0.0);
        // When [visibleAtStart] is false, it doesn't matter if
        // [reverseTransitionBuilder] is visible or not.
        // But if [visibleAtStart] is true, it must be visible.
        _reverseAnimation = visibleAnimation;
        break;
      case AnimationStatus.forward:
        _forwardAnimation = widget.animation;
        // when playing forward, the [reverseTransitionBuilder] must be visible
        // while [forwardTransitionBuilder] is animating.
        _reverseAnimation = visibleAnimation;
        break;
      case AnimationStatus.reverse:
        // when playing reverse, the [forwardTransitionBuilder] must be visible
        // while [reverseTransitionBuilder] is animating.
        _forwardAnimation = visibleAnimation;
        _reverseAnimation = widget.animation;
        break;
      case AnimationStatus.completed:
        _forwardAnimation = const AlwaysStoppedAnimation<double>(1.0);
        _reverseAnimation = const AlwaysStoppedAnimation<double>(1.0);
    }

    assert(_forwardAnimation != null);
    assert(_reverseAnimation != null);
  }

  @override
  void didUpdateWidget(CompositeAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeStatusListener(_handleAnimationStatusListener);
      widget.animation.addStatusListener(_handleAnimationStatusListener);
      // no need to call _setAnimationValues here.
      // _handleAnimationStatusListener will take care of that.
      _handleAnimationStatusListener(widget.animation.status);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (BuildContext context, Widget child) {
        // It builds it's transition widgets by composition, no changing
        // subtrees here. It's just the animation values are changing.
        // And since the [reverseTransitionBuilder] is a child of
        // [forwardTransitionBuilder], [forwardTransitionBuilder] must be at
        // visible-point of animation (where animation value is 1.0
        // or 0.0 if [visibleAtStart] is true) in order to see the
        // [reverseTransitionBuilder] to animate. Go to [_setAnimationValues]
        // method to see how is this handled.
        return widget.forwardTransitionBuilder(
          widget.reverseTransitionBuilder(
            child,
            _reverseAnimation,
          ),
          _forwardAnimation,
        );
      },
      child: widget.child,
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
}

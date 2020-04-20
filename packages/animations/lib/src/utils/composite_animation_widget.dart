// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Signature for a function that creates a widget that builds a
/// enter transition.
///
/// Used by [CompositeAnimationWidget]
typedef _EnterTransitionBuilder = Widget Function(
    BuildContext, Animation<double>, Widget);

/// Signature for a function that creates a widget that builds a
/// exit transition.
///
/// Used by [CompositeAnimationWidget]
typedef _ExitTransitionBuilder = Widget Function(
    BuildContext, Animation<double>, Widget);

/// A widget that animate it's child with different transitions when the
/// [CompositeAnimationWidget.animation] value goes forward
/// (built by [CompositeAnimationWidget.enterTransitionBuilder])
/// and reverse
/// (built by [CompositeAnimationWidget.exitTransitionBuilder]).
///
/// It is used in [FadeThroughTransition], [SharedAxisTransition],
/// and [FadeScaleTransition] widgets.
///
/// This widget also preserve it's child state by building all of it's enter
/// and exit transitions stacked and only changing animation values of
/// both transitions instead of dynamically changing widget
/// subtrees levels in [AnimatedBuilder] based on effective [AnimationStatus]
/// causes the state object in that particular subtree level to get recreated.
///
/// The state preservation of the child will take effect if and only if you're
/// not changing subtree levels in defined transition builders.
class CompositeAnimationWidget extends StatefulWidget {
  /// Creates a widget that animate it's child with different transitions when
  /// the [animation] value goes forward
  /// (built by [enterTransitionBuilder])
  /// and reverse
  /// (built by [exitTransitionBuilder]).
  const CompositeAnimationWidget({
    @required this.animation,
    @required this.child,
    @required this.enterTransitionBuilder,
    @required this.exitTransitionBuilder,
    this.flip = false,
    this.syncVisibleStates = false,
  })  : assert(child != null),
        assert(animation != null),
        assert(enterTransitionBuilder != null),
        assert(exitTransitionBuilder != null);

  /// The animation that drives the [child]'s entrance and exit.
  final Animation<double> animation;

  /// The widget below this widget in the tree.
  ///
  /// This widget will transition in and out as driven by [animation].
  final Widget child;

  /// A function that wraps [child] with an animation set define how the
  /// child appears.
  ///
  /// It's animation widgets will only play when the [animation]'s effective
  /// [AnimationStatus] goes forward.
  ///
  /// The animation widgets defined here must have a visible state at
  /// [AnimationStatus.completed] (1.0).
  ///
  /// Must not change subtree levels.
  final _EnterTransitionBuilder enterTransitionBuilder;

  /// A function that wraps [child] with an animation set define how the
  /// child disappears.
  ///
  /// It's animation widgets will only play when the [animation]'s effective
  /// [AnimationStatus] goes reverse.
  ///
  /// The animation widgets defined here must have a visible state at
  /// [AnimationStatus.dismissed] (0.0).
  ///
  /// Must not change subtree levels.
  final _ExitTransitionBuilder exitTransitionBuilder;

  /// Indicates whether the animation values will be flipped.
  ///
  /// Flipping animation values will also flips visible states in defined
  /// transition builders.
  ///
  /// So when flipped, The visible state of widgets in [enterTransitionBuilder]
  /// and [exitTransitionBuilder] will be at [AnimationStatus.dismissed] (0.0)
  /// and [AnimationStatus.completed] (1.0) respectively.
  final bool flip;

  /// Sync visible state of [exitTransitionBuilder] to [enterTransitionBuilder].
  /// So when true, visible state of [exitTransitionBuilder] must be the same as
  /// [enterTransitionBuilder].
  ///
  /// Set it to true when the [exitTransitionBuilder]'s animation widget
  /// has visible state same as the animation widgets defined in
  /// [enterTransitionBuilder].
  ///
  /// Defined true at [FadeScaleTransition] since it only used one animation.
  final bool syncVisibleStates;

  @override
  _CompositeAnimationWidgetState createState() =>
      _CompositeAnimationWidgetState();
}

class _CompositeAnimationWidgetState extends State<CompositeAnimationWidget> {
  AnimationStatus _effectiveAnimationStatus;
  Animation<double> _enterAnimation;
  Animation<double> _exitAnimation;

  @override
  void initState() {
    super.initState();
    widget.animation.addStatusListener(_animationListener);
    _effectiveAnimationStatus = widget.animation.status;
    _setStartingAnimationValues(widget.flip);
  }

  void _animationListener(AnimationStatus animationStatus) {
    _effectiveAnimationStatus = _calculateEffectiveAnimationStatus(
      lastEffective: _effectiveAnimationStatus,
      current: animationStatus,
    );
    // change the animation values based on effectiveAnimationStatus.
    _setStartingAnimationValues(widget.flip);
  }

  // This is called at [initState], [didUpdateWidget], and [_animationListener]
  void _setStartingAnimationValues(bool flip) {
    final Animation<double> baseAnimation =
        flip ? _flip(widget.animation) : widget.animation;
    _enterAnimation = flip ? _flip(baseAnimation) : baseAnimation;
    if (widget.syncVisibleStates) {
      _exitAnimation = _enterAnimation;
    } else {
      _exitAnimation = flip ? baseAnimation : _flip(baseAnimation);
    }
    assert(_effectiveAnimationStatus != null);
    assert(_enterAnimation != null);
    assert(_exitAnimation != null);
    switch (_effectiveAnimationStatus) {
      case AnimationStatus.forward:
        // when playing forward, the exitTransition must be visible.
        if (widget.syncVisibleStates) {
          _exitAnimation = flip
              ? const AlwaysStoppedAnimation<double>(0.0)
              : const AlwaysStoppedAnimation<double>(1.0);
        } else {
          _exitAnimation = flip
              ? const AlwaysStoppedAnimation<double>(1.0)
              : const AlwaysStoppedAnimation<double>(0.0);
        }
        break;
      case AnimationStatus.dismissed:
      case AnimationStatus.reverse:
      case AnimationStatus.completed:
        // when playing reverse, the enterTransition must be visible.
        _enterAnimation = flip
            ? const AlwaysStoppedAnimation<double>(0.0)
            : const AlwaysStoppedAnimation<double>(1.0);
    }
  }

  @override
  void didUpdateWidget(CompositeAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeStatusListener(_animationListener);
      widget.animation.addStatusListener(_animationListener);
      _animationListener(widget.animation.status);
    }
    if (widget.flip != oldWidget.flip) {
      _setStartingAnimationValues(widget.flip);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (BuildContext context, Widget child) {
        // It's stacked, no changing of subtree levels here.
        // It's just the animation values changed.
        return widget.enterTransitionBuilder(
          context,
          _enterAnimation,
          widget.exitTransitionBuilder(
            context,
            _exitAnimation,
            child,
          ),
        );
      },
      child: widget.child,
    );
  }

  static final Tween<double> _flippedTween = Tween<double>(
    begin: 1.0,
    end: 0.0,
  );

  static Animation<double> _flip(Animation<double> animation) {
    return _flippedTween.animate(animation);
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

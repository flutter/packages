// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart'
    hide decelerateEasing; // ignore: undefined_hidden_name
// TODO(goderbauer): Remove implementation import when material properly exports the file.
import 'package:flutter/src/material/curves.dart'; // ignore: implementation_imports

// TODO(shihaohong): Remove DualTransitionBuilder once flutter/flutter's `stable`
// branch contains DualTransitionBuilder.
import 'dual_transition_builder.dart' as dual_transition_builder;
import 'modal.dart';

/// The modal transition configuration for a Material fade transition.
///
/// The fade pattern is used for UI elements that enter or exit from within
/// the screen bounds. Elements that enter use a quick fade in and scale from
/// 80% to 100%. Elements that exit simply fade out. The scale animation is
/// only applied to entering elements to emphasize new content over old.
///
/// ```dart
/// /// Sample widget that uses [showModal] with [FadeScaleTransitionConfiguration].
/// class MyHomePage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Center(
///         child: RaisedButton(
///           onPressed: () {
///             showModal(
///               context: context,
///               configuration: FadeScaleTransitionConfiguration(),
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
///
/// To modify scale alignment, `FadeScaleTransitionConfiguration` will
/// need to be extended and this new configuration class will need to be used instead:
/// ```dart
/// class _ModifiedFadeScaleTransitionConfiguration extends FadeScaleTransitionConfiguration {
///   const _ModifiedFadeScaleTransitionConfiguration();
///
///   @override
///   Widget transitionBuilder(
///     BuildContext context,
///     Animation<double> animation,
///     Animation<double> secondaryAnimation,
///     Widget child,
///   ) {
///     return FadeScaleTransition(
///       animation: animation,
///       alignment: Alignment.topRight, // add this line
///       child: child,
///     );
///   }
/// }
/// ```
class FadeScaleTransitionConfiguration extends ModalConfiguration {
  /// Creates the Material fade transition configuration.
  ///
  /// [barrierDismissible] configures whether or not tapping the modal's
  /// scrim dismisses the modal. [barrierLabel] sets the semantic label for
  /// a dismissible barrier. [barrierDismissible] cannot be null. If
  /// [barrierDismissible] is true, the [barrierLabel] cannot be null.
  const FadeScaleTransitionConfiguration({
    Color barrierColor = Colors.black54,
    bool barrierDismissible = true,
    Duration transitionDuration = const Duration(milliseconds: 150),
    Duration reverseTransitionDuration = const Duration(milliseconds: 75),
    String barrierLabel = 'Dismiss',
  }) : super(
          barrierColor: barrierColor,
          barrierDismissible: barrierDismissible,
          barrierLabel: barrierLabel,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
        );

  @override
  Widget transitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeScaleTransition(
      animation: animation,
      child: child,
    );
  }
}

/// A widget that implements the Material fade transition.
///
/// The fade pattern is used for UI elements that enter or exit from within
/// the screen bounds. Elements that enter use a quick fade in and scale from
/// 80% to 100%. Elements that exit simply fade out. The scale animation is
/// only applied to entering elements to emphasize new content over old.
///
/// This widget is not to be confused with Flutter's [FadeTransition] widget,
/// which animates only the opacity of its child widget.
class FadeScaleTransition extends StatelessWidget {
  /// Creates a widget that implements the Material fade transition.
  ///
  /// The fade pattern is used for UI elements that enter or exit from within
  /// the screen bounds. Elements that enter use a quick fade in and scale from
  /// 80% to 100%. Elements that exit simply fade out. The scale animation is
  /// only applied to entering elements to emphasize new content over old.
  ///
  /// This widget is not to be confused with Flutter's [FadeTransition] widget,
  /// which animates only the opacity of its child widget.
  ///
  /// [animation] is typically an [AnimationController] that drives the transition
  /// animation. [animation] cannot be null.
  ///
  /// The [alignment] defaults to [Alignment.center] and cannot be null.
  const FadeScaleTransition({
    Key key,
    @required this.animation,
    this.alignment = Alignment.center,
    this.child,
  })  : assert(animation != null),
        assert(alignment != null),
        super(key: key);

  /// The animation that drives the [child]'s entrance and exit.
  ///
  /// See also:
  ///
  ///  * [TransitionRoute.animate], which is the value given to this property
  ///    when it is used as a page transition.
  final Animation<double> animation;

  /// The alignment of scale anchor point, relative to it's child.
  ///
  /// By default, the child scales from it's center when fading in. In a
  /// variation on the default behavior, the scale anchor point can be
  /// repositioned from the center of a child to another location within
  /// the child.
  ///
  /// For example, when an overflow icon (the parent component) triggers a menu
  /// (the child component), the menu's anchor point can be positioned at the
  /// top right corner of the menu so that it appears to scale from the overflow
  /// icon during a transition.
  final Alignment alignment;

  /// The widget below this widget in the tree.
  ///
  /// This widget will transition in and out as driven by [animation] and
  /// [secondaryAnimation].
  final Widget child;

  static final Animatable<double> _fadeInTransition = CurveTween(
    curve: const Interval(0.0, 0.3),
  );
  static final Animatable<double> _scaleInTransition = Tween<double>(
    begin: 0.80,
    end: 1.00,
  ).chain(CurveTween(curve: decelerateEasing));
  static final Animatable<double> _fadeOutTransition = Tween<double>(
    begin: 1.0,
    end: 0.0,
  );

  @override
  Widget build(BuildContext context) {
    return dual_transition_builder.DualTransitionBuilder(
      animation: animation,
      forwardBuilder: (
        BuildContext context,
        Animation<double> animation,
        Widget child,
      ) {
        return FadeTransition(
          opacity: _fadeInTransition.animate(animation),
          child: ScaleTransition(
            scale: _scaleInTransition.animate(animation),
            alignment: alignment,
            child: child,
          ),
        );
      },
      reverseBuilder: (
        BuildContext context,
        Animation<double> animation,
        Widget child,
      ) {
        return FadeTransition(
          opacity: _fadeOutTransition.animate(animation),
          child: child,
        );
      },
      child: child,
    );
  }
}

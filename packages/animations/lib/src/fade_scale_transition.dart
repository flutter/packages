// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

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
///         child: ElevatedButton(
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
class FadeScaleTransitionConfiguration extends ModalConfiguration {
  /// Creates the Material fade transition configuration.
  ///
  /// [barrierDismissible] configures whether or not tapping the modal's
  /// scrim dismisses the modal. [barrierLabel] sets the semantic label for
  /// a dismissible barrier. [barrierDismissible] cannot be null. If
  /// [barrierDismissible] is true, the [barrierLabel] cannot be null.
  const FadeScaleTransitionConfiguration({
    super.barrierColor = Colors.black54,
    super.barrierDismissible = true,
    super.transitionDuration = const Duration(milliseconds: 150),
    super.reverseTransitionDuration = const Duration(milliseconds: 75),
    String super.barrierLabel = 'Dismiss',
  });

  @override
  Widget transitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeScaleTransition(animation: animation, child: child);
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
  const FadeScaleTransition({super.key, required this.animation, this.child});

  /// The animation that drives the [child]'s entrance and exit.
  ///
  /// See also:
  ///
  ///  * [TransitionRoute.animate], which is the value given to this property
  ///    when it is used as a page transition.
  final Animation<double> animation;

  /// The widget below this widget in the tree.
  ///
  /// This widget will transition in and out as driven by [animation] and
  /// [secondaryAnimation].
  final Widget? child;

  static final Animatable<double> _fadeInTransition = CurveTween(
    curve: const Interval(0.0, 0.3),
  );
  static final Animatable<double> _scaleInTransition = Tween<double>(
    begin: 0.80,
    end: 1.00,
  ).chain(CurveTween(curve: Easing.legacyDecelerate));
  static final Animatable<double> _fadeOutTransition = Tween<double>(
    begin: 1.0,
    end: 0.0,
  );

  @override
  Widget build(BuildContext context) {
    return DualTransitionBuilder(
      animation: animation,
      forwardBuilder:
          (BuildContext context, Animation<double> animation, Widget? child) {
            return FadeTransition(
              opacity: _fadeInTransition.animate(animation),
              child: ScaleTransition(
                scale: _scaleInTransition.animate(animation),
                child: child,
              ),
            );
          },
      reverseBuilder:
          (BuildContext context, Animation<double> animation, Widget? child) {
            return FadeTransition(
              opacity: _fadeOutTransition.animate(animation),
              child: child,
            );
          },
      child: child,
    );
  }
}

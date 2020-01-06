// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/src/utils/curves.dart';
import 'package:flutter/material.dart';

/// TODO: add documentation
Future<T> showDialogWithFadeTransition<T>({
  @required BuildContext context,
  bool barrierDismissible = true,
  String barrierLabel,
  bool useRootNavigator = true,
  Widget child,
}) {
  barrierLabel = barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel;
  // TODO: somehow control the scrim exit duration as well
  assert(useRootNavigator != null);
  assert(!barrierDismissible || barrierLabel != null);
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(FadeDialogRoute<T>(
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    child: child,
  ));
}

class FadeDialogRoute<T> extends PopupRoute<T> {
  FadeDialogRoute({
    bool barrierDismissible = true,
    String barrierLabel,
    RouteSettings settings,
    this.child,
  }) : assert(barrierDismissible != null),
       _barrierDismissible = barrierDismissible,
       _barrierLabel = barrierLabel,
       super(settings: settings);


  @override
  bool get barrierDismissible => _barrierDismissible;
  final bool _barrierDismissible;

  @override
  String get barrierLabel => _barrierLabel;
  final String _barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  final Widget child;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      child: SafeArea(
        child: Builder(
          builder: (BuildContext context) {
            return theme != null
              ? Theme(data: theme, child: child)
              : child;
          }
        ),
      ),
      scopesRoute: true,
      explicitChildNodes: true,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
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
              opacity: CurveTween(
                curve: const Interval(0.5, 1.0),
              ).animate(animation), // should be over 75ms
              child: child,
            );
        }
        return null; // unreachable
      },
      child: child,
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

  static Animatable<double> fadeInTransition = CurveTween(curve: const Interval(0.0, 0.3));
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

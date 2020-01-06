// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/src/utils/curves.dart';
import 'package:flutter/material.dart';

/// TODO: add documentation
Future<T> showDialogWithFadeTransition<T>({
  @required BuildContext context,
  @required Widget child,
  Color barrierColor = Colors.black54,
  String barrierLabel,
  bool barrierDismissible = true,
}) {
  final ThemeData theme = Theme.of(context);

  // TODO: somehow control the scrim exit duration as well
  return showGeneralDialog(
    context: context,
    barrierColor: Colors.black54,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 150),
    transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
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
                opacity: animation, // should be over 75ms
                child: child,
              );
          }
          return null; // unreachable
        },
        child: child,
      );
    },
    pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
      return SafeArea(
        child: Builder(
          builder: (BuildContext context) {
            return theme != null
              ? Theme(data: theme, child: child)
              : child;
          }
        ),
      );
    },
  );
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

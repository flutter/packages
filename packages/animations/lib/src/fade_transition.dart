// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/src/utils/curves.dart';
import 'package:flutter/material.dart';

/// Displays a modal above the current contents of the app.
///
/// This function displays the [FadeModalRoute], which transitions in
/// with the Material fade transition.
///
/// Content below the modal is dimmed with a [ModalBarrier].
///
/// ```dart
/// /// Sample widget that uses [showModalWithFadeTransition].
/// class MyHomePage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Center(
///         child: RaisedButton(
///           onPressed: () {
///             showModalWithFadeTransition(
///               context: context,
///               child: FlutterLogoModal(),
///             );
///           },
///           child: Icon(Icons.add),
///         ),
///       ),
///     );
///   }
/// }
///
/// /// Displays a modal with the FlutterLogo on it.
/// class FlutterLogoModal extends StatelessWidget {
///   const _FlutterLogoModal();
///
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       mainAxisAlignment: MainAxisAlignment.center,
///       children: <Widget>[
///         Center(
///           child: ConstrainedBox(
///             constraints: const BoxConstraints(
///               maxHeight: 300,
///               maxWidth: 300,
///               minHeight: 250,
///               minWidth: 250,
///             ),
///             child: const Material(
///               child: Center(child: FlutterLogo(size: 250)),
///             ),
///           ),
///         ),
///       ],
///     );
///   }
/// }
/// ```
///
/// The `context` argument is used to look up the [Navigator] for the
/// modal. It is only used when the method is called. Its corresponding widget
/// can be safely removed from the tree before the modal is closed.
///
/// The `useRootNavigator` argument is used to determine whether to push the
/// modal to the [Navigator] furthest from or nearest to the given `context`.
/// By default, `useRootNavigator` is `true` and the modal route created by
/// this method is pushed to the root navigator.
///
/// If the application has multiple [Navigator] objects, it may be necessary to
/// call `Navigator.of(context, rootNavigator: true).pop(result)` to close the
/// modal rather than just `Navigator.pop(context, result)`.
///
/// The `barrierDismissible` argument is used to determine whether this route
/// can be dismissed by tapping the modal barrier. This argument defaults
/// to true. If `barrierDismissible` is true, a non-null `barrierLabel` must be
/// provided.
///
/// The `barrierLabel` argument is the semantic label used for a dismissible
/// barrier. This argument defaults to "Dismiss".
///
/// Returns a [Future] that resolves to the value (if any) that was passed to
/// [Navigator.pop] when the modal was closed.
///
/// See also:
///
/// * [FadeModalRoute], which is the route that is built by this function.
Future<T> showModalWithFadeTransition<T>({
  @required BuildContext context,
  bool barrierDismissible = true,
  String barrierLabel,
  bool useRootNavigator = true,
  Widget child,
}) {
  barrierLabel = barrierLabel ??
      MaterialLocalizations.of(context).modalBarrierDismissLabel;
  assert(useRootNavigator != null);
  assert(!barrierDismissible || barrierLabel != null);
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    FadeModalRoute<T>(
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      child: child,
    ),
  );
}

/// A modal route that overlays a widget on the current route with the Material
/// fade transition.
///
/// The fade pattern is used for UI elements that enter or exit from within
/// the screen bounds. Elements that enter use a quick fade in and scale from
/// 80% to 100%. Elements that exit simply fade out. The scale animation is
/// only applied to entering elements to emphasize new content over old.
///
/// See also:
///
/// * [showModalWithFadeTransition], which displays the modal popup.
class FadeModalRoute<T> extends PopupRoute<T> {
  /// Creates a [FadeModalRoute] route with the Material fade transition.
  ///
  /// [barrierDismissible] is true by default.
  FadeModalRoute({
    bool barrierDismissible = true,
    String barrierLabel,
    @required this.child,
  })  : assert(barrierDismissible != null),
        _barrierDismissible = barrierDismissible,
        _barrierLabel = barrierLabel;

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

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 75);

  /// The primary contents of the modal.
  final Widget child;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      child: SafeArea(
        child: Builder(
          builder: (BuildContext context) {
            return theme != null ? Theme(data: theme, child: child) : child;
          },
        ),
      ),
      scopesRoute: true,
      explicitChildNodes: true,
    );
  }

  @override
  Widget buildTransitions(
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

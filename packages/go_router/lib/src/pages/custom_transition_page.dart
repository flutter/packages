// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// Page with custom transition functionality.
///
/// To be used instead of MaterialPage or CupertinoPage, which provide
/// their own transitions.
class CustomTransitionPage<T> extends Page<T> {
  /// Constructor for a page with custom transition functionality.
  ///
  /// To be used instead of MaterialPage or CupertinoPage, which provide
  /// their own transitions.
  const CustomTransitionPage({
    required this.child,
    required this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  /// The content to be shown in the Route created by this page.
  final Widget child;

  /// A duration argument to customize the duration of the custom page
  /// transition.
  ///
  /// Defaults to 300ms.
  final Duration transitionDuration;

  /// A duration argument to customize the duration of the custom page
  /// transition on pop.
  ///
  /// Defaults to 300ms.
  final Duration reverseTransitionDuration;

  /// Whether the route should remain in memory when it is inactive.
  ///
  /// If this is true, then the route is maintained, so that any futures it is
  /// holding from the next route will properly resolve when the next route
  /// pops. If this is not necessary, this can be set to false to allow the
  /// framework to entirely discard the route's widget hierarchy when it is
  /// not visible.
  final bool maintainState;

  /// Whether this page route is a full-screen dialog.
  ///
  /// In Material and Cupertino, being fullscreen has the effects of making the
  /// app bars have a close button instead of a back button. On iOS, dialogs
  /// transitions animate differently and are also not closeable with the
  /// back swipe gesture.
  final bool fullscreenDialog;

  /// Whether the route obscures previous routes when the transition is
  /// complete.
  ///
  /// When an opaque route's entrance transition is complete, the routes
  /// behind the opaque route will not be built to save resources.
  final bool opaque;

  /// Whether you can dismiss this route by tapping the modal barrier.
  final bool barrierDismissible;

  /// The color to use for the modal barrier.
  ///
  /// If this is null, the barrier will be transparent.
  final Color? barrierColor;

  /// The semantic label used for a dismissible barrier.
  ///
  /// If the barrier is dismissible, this label will be read out if
  /// accessibility tools (like VoiceOver on iOS) focus on the barrier.
  final String? barrierLabel;

  /// Override this method to wrap the child with one or more transition
  /// widgets that define how the route arrives on and leaves the screen.
  ///
  /// By default, the child (which contains the widget returned by buildPage) is
  /// not wrapped in any transition widgets.
  ///
  /// The transitionsBuilder method, is called each time the Route's state
  /// changes while it is visible (e.g. if the value of canPop changes on the
  /// active route).
  ///
  /// The transitionsBuilder method is typically used to define transitions
  /// that animate the new topmost route's comings and goings. When the
  /// Navigator pushes a route on the top of its stack, the new route's
  /// primary animation runs from 0.0 to 1.0. When the Navigator pops the
  /// topmost route, e.g. because the use pressed the back button, the primary
  /// animation runs from 1.0 to 0.0.
  final Widget Function(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) transitionsBuilder;

  @override
  Route<T> createRoute(BuildContext context) =>
      _CustomTransitionPageRoute<T>(this);
}

class _CustomTransitionPageRoute<T> extends PageRoute<T> {
  _CustomTransitionPageRoute(CustomTransitionPage<T> page)
      : super(settings: page);

  CustomTransitionPage<T> get _page => settings as CustomTransitionPage<T>;

  @override
  bool get barrierDismissible => _page.barrierDismissible;

  @override
  Color? get barrierColor => _page.barrierColor;

  @override
  String? get barrierLabel => _page.barrierLabel;

  @override
  Duration get transitionDuration => _page.transitionDuration;

  @override
  Duration get reverseTransitionDuration => _page.reverseTransitionDuration;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  bool get opaque => _page.opaque;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: _page.child,
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      _page.transitionsBuilder(
        context,
        animation,
        secondaryAnimation,
        child,
      );
}

/// Custom transition page with no transition.
class NoTransitionPage<T> extends CustomTransitionPage<T> {
  /// Constructor for a page with no transition functionality.
  const NoTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: _transitionsBuilder,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );

  static Widget _transitionsBuilder(
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) =>
      child;
}

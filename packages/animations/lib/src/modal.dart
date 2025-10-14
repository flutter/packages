// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'fade_scale_transition.dart';

/// Signature for a function that creates a widget that builds a
/// transition.
///
/// Used by [PopupRoute].
typedef _ModalTransitionBuilder =
    Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    );

/// Displays a modal above the current contents of the app.
///
/// Content below the modal is dimmed with a [ModalBarrier].
///
/// The `context` argument is used to look up the [Navigator] for the
/// modal. It is only used when the method is called. Its corresponding widget
/// can be safely removed from the tree before the modal is closed.
///
/// The `configuration` argument is used to determine characteristics of the
/// modal route that will be displayed, such as the enter and exit
/// transitions, the duration of the transitions, and modal barrier
/// properties. By default, `configuration` is
/// [FadeScaleTransitionConfiguration].
///
/// The `useRootNavigator` argument is used to determine whether to push the
/// modal to the [Navigator] furthest from or nearest to the given `context`.
/// By default, `useRootNavigator` is `true` and the modal route created by
/// this method is pushed to the root navigator. If the application has
/// multiple [Navigator] objects, it may be necessary to call
/// `Navigator.of(context, rootNavigator: true).pop(result)` to close the
/// modal rather than just `Navigator.pop(context, result)`.
///
/// Returns a [Future] that resolves to the value (if any) that was passed to
/// [Navigator.pop] when the modal was closed.
///
/// See also:
///
/// * [ModalConfiguration], which is the configuration object used to define
/// the modal's characteristics.
Future<T?> showModal<T>({
  required BuildContext context,
  ModalConfiguration configuration = const FadeScaleTransitionConfiguration(),
  bool useRootNavigator = true,
  required WidgetBuilder builder,
  RouteSettings? routeSettings,
  ui.ImageFilter? filter,
}) {
  String? barrierLabel = configuration.barrierLabel;
  // Avoid looking up [MaterialLocalizations.of(context).modalBarrierDismissLabel]
  // if there is no dismissible barrier.
  if (configuration.barrierDismissible && configuration.barrierLabel == null) {
    barrierLabel = MaterialLocalizations.of(context).modalBarrierDismissLabel;
  }
  assert(!configuration.barrierDismissible || barrierLabel != null);
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    _ModalRoute<T>(
      barrierColor: configuration.barrierColor,
      barrierDismissible: configuration.barrierDismissible,
      barrierLabel: barrierLabel,
      transitionBuilder: configuration.transitionBuilder,
      transitionDuration: configuration.transitionDuration,
      reverseTransitionDuration: configuration.reverseTransitionDuration,
      builder: builder,
      routeSettings: routeSettings,
      filter: filter,
    ),
  );
}

// A modal route that overlays a widget on the current route.
class _ModalRoute<T> extends PopupRoute<T> {
  /// Creates a route with general modal route.
  ///
  /// [barrierDismissible] configures whether or not tapping the modal's
  /// scrim dismisses the modal. [barrierLabel] sets the semantic label for
  /// a dismissible barrier. [barrierDismissible] cannot be null. If
  /// [barrierDismissible] is true, the [barrierLabel] cannot be null.
  ///
  /// [transitionBuilder] takes in a function that creates a widget. This
  /// widget is typically used to configure the modal's transition.
  _ModalRoute({
    this.barrierColor,
    this.barrierDismissible = true,
    this.barrierLabel,
    required this.transitionDuration,
    required this.reverseTransitionDuration,
    required _ModalTransitionBuilder transitionBuilder,
    required this.builder,
    RouteSettings? routeSettings,
    super.filter,
  }) : assert(!barrierDismissible || barrierLabel != null),
       _transitionBuilder = transitionBuilder,
       super(settings: routeSettings);

  @override
  final Color? barrierColor;

  @override
  final bool barrierDismissible;

  @override
  final String? barrierLabel;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  /// The primary contents of the modal.
  final WidgetBuilder builder;

  final _ModalTransitionBuilder _transitionBuilder;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: SafeArea(
        child: Builder(
          builder: (BuildContext context) {
            final Widget child = Builder(builder: builder);
            return Theme(data: theme, child: child);
          },
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _transitionBuilder(context, animation, secondaryAnimation, child);
  }
}

/// A configuration object containing the properties needed to implement a
/// modal route.
///
/// The `barrierDismissible` argument is used to determine whether this route
/// can be dismissed by tapping the modal barrier. This argument defaults
/// to true. If `barrierDismissible` is true, a non-null `barrierLabel` must be
/// provided.
///
/// The `barrierLabel` argument is the semantic label used for a dismissible
/// barrier. This argument defaults to "Dismiss".
abstract class ModalConfiguration {
  /// Creates a modal configuration object that provides the necessary
  /// properties to implement a modal route.
  ///
  /// [barrierDismissible] configures whether or not tapping the modal's
  /// scrim dismisses the modal. [barrierLabel] sets the semantic label for
  /// a dismissible barrier. [barrierDismissible] cannot be null. If
  /// [barrierDismissible] is true, the [barrierLabel] cannot be null.
  ///
  /// [transitionDuration] and [reverseTransitionDuration] determine the
  /// duration of the transitions when the modal enters and exits the
  /// application. [transitionDuration] and [reverseTransitionDuration]
  /// cannot be null.
  const ModalConfiguration({
    required this.barrierColor,
    required this.barrierDismissible,
    this.barrierLabel,
    required this.transitionDuration,
    required this.reverseTransitionDuration,
  }) : assert(!barrierDismissible || barrierLabel != null);

  /// The color to use for the modal barrier. If this is null, the barrier will
  /// be transparent.
  final Color barrierColor;

  /// Whether you can dismiss this route by tapping the modal barrier.
  final bool barrierDismissible;

  /// The semantic label used for a dismissible barrier.
  final String? barrierLabel;

  /// The duration of the transition running forwards.
  final Duration transitionDuration;

  /// The duration of the transition running in reverse.
  final Duration reverseTransitionDuration;

  /// A builder that defines how the route arrives on and leaves the screen.
  ///
  /// The [buildTransitions] method is typically used to define transitions
  /// that animate the new topmost route's comings and goings. When the
  /// [Navigator] pushes a route on the top of its stack, the new route's
  /// primary [animation] runs from 0.0 to 1.0. When the [Navigator] pops the
  /// topmost route, e.g. because the use pressed the back button, the
  /// primary animation runs from 1.0 to 0.0.
  Widget transitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  );
}

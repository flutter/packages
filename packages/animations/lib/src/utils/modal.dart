import 'package:flutter/material.dart';

/// Signature for a function that creates a widget that builds a
/// transition.
///
/// Used by [PopupRoute.buildTransitions].
typedef ModalTransitionBuilder = Widget Function(
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
Future<T> showModal<T>({
  @required BuildContext context,
  @required ModalConfiguration configuration,
  bool useRootNavigator = true,
  WidgetBuilder builder,
}) {
  assert(configuration != null);
  assert(useRootNavigator != null);
  String barrierLabel = configuration.barrierLabel;
  // Avoid looking up [MaterialLocalizations.of(context).modalBarrierDismissLabel]
  // if there is no dismissible barrier.
  if (configuration.barrierDismissible == true && configuration.barrierLabel == null) {
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
    ),
  );
}

// A modal route that overlays a widget on the current route.
class _ModalRoute<T> extends PopupRoute<T> {
  /// Creates a [_ModalRoute] route with the Material fade transition.
  ///
  /// [barrierDismissible] is true by default.
  _ModalRoute({
    Color barrierColor,
    bool barrierDismissible = true,
    String barrierLabel,
    ModalTransitionBuilder transitionBuilder,
    Duration transitionDuration,
    Duration reverseTransitionDuration,
    @required this.builder,
  })  : assert(barrierDismissible != null),
        _barrierColor = barrierColor,
        _barrierDismissible = barrierDismissible,
        _barrierLabel = barrierLabel,
        _transitionBuilder = transitionBuilder,
        _transitionDuration = transitionDuration,
        _reverseTransitionDuration = reverseTransitionDuration;

  @override
  Color get barrierColor => _barrierColor;
  final Color _barrierColor;

  @override
  bool get barrierDismissible => _barrierDismissible;
  final bool _barrierDismissible;

  @override
  String get barrierLabel => _barrierLabel;
  final String _barrierLabel;

  @override
  Duration get transitionDuration => _transitionDuration;
  final Duration _transitionDuration;

  @override
  Duration get reverseTransitionDuration => _reverseTransitionDuration;
  final Duration _reverseTransitionDuration;

  /// The primary contents of the modal.
  final WidgetBuilder builder;

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
            final Widget child = Builder(builder: builder);
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
  ) => _transitionBuilder(context, animation, secondaryAnimation, child);
  final ModalTransitionBuilder _transitionBuilder;
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
  ModalConfiguration({
    this.barrierColor,
    this.barrierDismissible,
    this.barrierLabel,
    this.transitionBuilder,
    this.transitionDuration,
    this.reverseTransitionDuration,
  });

  /// The color to use for the modal barrier. If this is null, the barrier will
  /// be transparent.
  final Color barrierColor;

  /// Whether you can dismiss this route by tapping the modal barrier.
  final bool barrierDismissible;

  /// The semantic label used for a dismissible barrier.
  final String barrierLabel;

  /// A builder that defines how the route arrives on and leaves the screen.
  ///
  /// The [buildTransitions] method is typically used to define transitions
  /// that animate the new topmost route's comings and goings. When the
  /// [Navigator] pushes a route on the top of its stack, the new route's
  /// primary [animation] runs from 0.0 to 1.0. When the [Navigator] pops the
  /// topmost route, e.g. because the use pressed the back button, the
  /// primary animation runs from 1.0 to 0.0.
  final ModalTransitionBuilder transitionBuilder;

  /// The duration of the transition running forwards.
  final Duration transitionDuration;

  /// The duration of the transition running in reverse.
  final Duration reverseTransitionDuration;
}

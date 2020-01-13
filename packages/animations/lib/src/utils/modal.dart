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
///               builder: (BuildContext context) {
///                 return CenteredFlutterLogo(),
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
/// class CenteredFlutterLogo extends StatelessWidget {
///   const _CenteredFlutterLogo();
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
/// this method is pushed to the root navigator. If the application has
/// multiple [Navigator] objects, it may be necessary to call
/// `Navigator.of(context, rootNavigator: true).pop(result)` to close the
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
Future<T> showModal<T>({
  @required BuildContext context,
  ModalConfiguration configuration,
  bool useRootNavigator = true,
  WidgetBuilder builder,
}) {
  String barrierLabel = configuration.barrierLabel;
  // Avoid looking up [MaterialLocalizations.of(context).modalBarrierDismissLabel]
  // if there is no dismissible barrier.
  if (configuration.barrierDismissible == true && configuration.barrierLabel == null) {
    barrierLabel = MaterialLocalizations.of(context).modalBarrierDismissLabel;
  }
  assert(useRootNavigator != null);
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

abstract class ModalConfiguration {
  ModalConfiguration({
    this.barrierColor,
    this.barrierDismissible,
    this.barrierLabel,
    this.transitionBuilder,
    this.transitionDuration,
    this.reverseTransitionDuration,
  });

  final Color barrierColor;

  final bool barrierDismissible;

  final String barrierLabel;

  final ModalTransitionBuilder transitionBuilder;

  final Duration transitionDuration;

  final Duration reverseTransitionDuration;
}

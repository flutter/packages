import 'package:flutter/widgets.dart';

/// A [NavigatorObserver] that merges the observers of the current 
/// route with the observers of the previous route.
class MergedNavigatorObserver extends NavigatorObserver {
  /// Default constructor for the merged navigator observer.
  MergedNavigatorObserver(this.observers);

  /// The observers to be merged.
  final List<NavigatorObserver> observers;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final NavigatorObserver observer in observers) {
      observer.didPush(route, previousRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final NavigatorObserver observer in observers) {
      observer.didPop(route, previousRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final NavigatorObserver observer in observers) {
      observer.didRemove(route, previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    for (final NavigatorObserver observer in observers) {
      observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    }
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    for (final NavigatorObserver observer in observers) {
      observer.didChangeTop(topRoute, previousTopRoute);
    }
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final NavigatorObserver observer in observers) {
      observer.didStartUserGesture(route, previousRoute);
    }
  }

  @override
  void didStopUserGesture() {
    for (final NavigatorObserver observer in observers) {
      observer.didStopUserGesture();
    }
  }
}

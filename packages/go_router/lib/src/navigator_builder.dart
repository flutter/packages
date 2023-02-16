import 'package:flutter/cupertino.dart';

import '../go_router.dart';
import 'builder.dart';
import 'configuration.dart';
import 'match.dart';
import 'matching.dart';
import 'parser.dart';

/// Provides support for building Navigators for routes.
class RouteNavigatorBuilder extends ShellNavigatorBuilder {
  /// Constructs a NavigatorBuilder.
  RouteNavigatorBuilder(
      this.routeBuilder,
      this.currentRoute,
      this.heroController,
      this.navigatorKeyForCurrentRoute,
      this.pages,
      this.onPopPage);

  /// The route builder.
  final RouteBuilder routeBuilder;

  @override
  final ShellRouteBase currentRoute;

  final HeroController heroController;

  @override
  final GlobalKey<NavigatorState> navigatorKeyForCurrentRoute;

  /// The pages for the current route.
  final List<Page<Object?>> pages;

  /// The callback for popping a page.
  final PopPageCallback onPopPage;

  /// Builds a navigator.
  static Navigator buildNavigator(
    PopPageCallback onPopPage,
    List<Page<Object?>> pages,
    Key? navigatorKey, {
    List<NavigatorObserver>? observers,
    String? restorationScopeId,
  }) {
    return Navigator(
      key: navigatorKey,
      restorationScopeId: restorationScopeId,
      pages: pages,
      observers: observers ?? const <NavigatorObserver>[],
      onPopPage: onPopPage,
    );
  }

  @override
  Widget buildNavigatorForCurrentRoute({
    List<NavigatorObserver>? observers,
    String? restorationScopeId,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    return HeroControllerScope(
        controller: heroController,
        child: buildNavigator(
          onPopPage,
          pages,
          navigatorKey ?? navigatorKeyForCurrentRoute,
          observers: observers,
          restorationScopeId: restorationScopeId,
        ));
  }

  @override
  Future<Widget> buildPreloadedShellNavigator({
    required BuildContext context,
    required String location,
    Object? extra,
    required GlobalKey<NavigatorState> navigatorKey,
    required ShellRouteBase parentShellRoute,
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
    String? restorationScopeId,
  }) {
    // Parse a RouteMatchList from location and handle any redirects
    final GoRouteInformationParser parser =
        GoRouter.of(context).routeInformationParser;
    final Future<RouteMatchList> routeMatchList =
        parser.parseRouteInformationWithDependencies(
      RouteInformation(location: location, state: extra),
      context,
    );

    Widget buildNavigator(RouteMatchList matchList) {
      // Find the index of fromRoute in the match list
      final int parentShellRouteIndex = matchList.matches
          .indexWhere((RouteMatch e) => e.route == parentShellRoute);
      assert(parentShellRouteIndex >= 0);

      return routeBuilder.buildPreloadedNestedNavigator(
        context,
        matchList,
        parentShellRouteIndex + 1,
        onPopPage,
        true,
        navigatorKey,
        restorationScopeId: restorationScopeId,
      );
    }

    return routeMatchList.then(buildNavigator);
  }
}

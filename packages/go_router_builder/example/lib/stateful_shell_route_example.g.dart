// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'stateful_shell_route_example.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $myShellRouteData,
    ];

RouteBase get $myShellRouteData => StatefulShellRouteData.$route(
      restorationScopeId: MyShellRouteData.$restorationScopeId,
      navigatorContainerBuilder: MyShellRouteData.$navigatorContainerBuilder,
      factory: $MyShellRouteDataExtension._fromState,
      branches: [
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/detailsA',
              factory: $DetailsARouteDataExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          navigatorKey: BranchBData.$navigatorKey,
          restorationScopeId: BranchBData.$restorationScopeId,
          routes: [
            GoRouteData.$route(
              path: '/detailsB',
              factory: $DetailsBRouteDataExtension._fromState,
            ),
          ],
        ),
      ],
    );

extension $MyShellRouteDataExtension on MyShellRouteData {
  static MyShellRouteData _fromState(GoRouterState state) =>
      const MyShellRouteData();
}

extension $DetailsARouteDataExtension on DetailsARouteData {
  static DetailsARouteData _fromState(GoRouterState state) =>
      const DetailsARouteData();

  String get location => GoRouteData.$location(
        '/detailsA',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $DetailsBRouteDataExtension on DetailsBRouteData {
  static DetailsBRouteData _fromState(GoRouterState state) =>
      const DetailsBRouteData();

  String get location => GoRouteData.$location(
        '/detailsB',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

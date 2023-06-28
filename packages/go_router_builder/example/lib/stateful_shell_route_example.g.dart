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

extension $BranchADataExtension on BranchAData {
  static BranchAData _fromState(GoRouterState state) => const BranchAData();
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
}

extension $BranchBDataExtension on BranchBData {
  static BranchBData _fromState(GoRouterState state) => const BranchBData();
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
}

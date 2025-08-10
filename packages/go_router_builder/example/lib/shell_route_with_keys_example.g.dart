// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'shell_route_with_keys_example.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $myShellRouteData,
    ];

RouteBase get $myShellRouteData => ShellRouteData.$route(
      navigatorKey: MyShellRouteData.$navigatorKey,
      factory: $MyShellRouteDataExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/home',
          factory: _$HomeRouteData._fromState,
        ),
        GoRouteData.$route(
          path: '/users',
          factory: _$UsersRouteData._fromState,
          routes: [
            GoRouteData.$route(
              path: ':id',
              parentNavigatorKey: UserRouteData.$parentNavigatorKey,
              factory: _$UserRouteData._fromState,
            ),
          ],
        ),
      ],
    );

extension $MyShellRouteDataExtension on MyShellRouteData {
  static MyShellRouteData _fromState(GoRouterState state) =>
      const MyShellRouteData();
}

mixin _$HomeRouteData on GoRouteData {
  static HomeRouteData _fromState(GoRouterState state) => const HomeRouteData();

  @override
  String get location => GoRouteData.$location(
        '/home',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$UsersRouteData on GoRouteData {
  static UsersRouteData _fromState(GoRouterState state) =>
      const UsersRouteData();

  @override
  String get location => GoRouteData.$location(
        '/users',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$UserRouteData on GoRouteData {
  static UserRouteData _fromState(GoRouterState state) => UserRouteData(
        id: int.parse(state.pathParameters['id']!)!,
      );

  UserRouteData get _self => this as UserRouteData;

  @override
  String get location => GoRouteData.$location(
        '/users/${Uri.encodeComponent(_self.id.toString())}',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

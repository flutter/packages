// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'go_relative.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $homeRoute,
    ];

RouteBase get $homeRoute => GoRouteData.$route(
      path: '/',
      factory: _$HomeRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: '/dashboard',
          factory: _$DashboardRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'details/:detailId',
              factory: _$DetailsRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'settings/:settingId',
                  factory: _$SettingsRoute._fromState,
                ),
              ],
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'details/:detailId',
          factory: _$DetailsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'settings/:settingId',
              factory: _$SettingsRoute._fromState,
            ),
          ],
        ),
      ],
    );

mixin _$HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => HomeRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

mixin _$DashboardRoute on GoRouteData {
  static DashboardRoute _fromState(GoRouterState state) => DashboardRoute();

  String get location => GoRouteData.$location(
        '/dashboard',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

mixin _$DetailsRoute on GoRouteData {
  static DetailsRoute _fromState(GoRouterState state) => DetailsRoute(
        detailId: state.pathParameters['detailId']!,
      );

  DetailsRoute get _self => this as DetailsRoute;

  String get location => GoRouteData.$location(
        'details/${Uri.encodeComponent(_self.detailId)}',
      );

  String get relativeLocation => './$location';

  void goRelative(BuildContext context) => context.go(relativeLocation);

  Future<T?> pushRelative<T>(BuildContext context) =>
      context.push<T>(relativeLocation);

  void pushReplacementRelative(BuildContext context) =>
      context.pushReplacement(relativeLocation);

  void replaceRelative(BuildContext context) =>
      context.replace(relativeLocation);
}

mixin _$SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => SettingsRoute(
        settingId: state.pathParameters['settingId']!,
      );

  SettingsRoute get _self => this as SettingsRoute;

  String get location => GoRouteData.$location(
        'settings/${Uri.encodeComponent(_self.settingId)}',
      );

  String get relativeLocation => './$location';

  void goRelative(BuildContext context) => context.go(relativeLocation);

  Future<T?> pushRelative<T>(BuildContext context) =>
      context.push<T>(relativeLocation);

  void pushReplacementRelative(BuildContext context) =>
      context.pushReplacement(relativeLocation);

  void replaceRelative(BuildContext context) =>
      context.replace(relativeLocation);
}

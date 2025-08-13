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
            RelativeGoRouteData.$route(
              path: 'details/:detailId',
              factory: _$DetailsRoute._fromState,
              routes: [
                RelativeGoRouteData.$route(
                  path: 'settings/:settingId',
                  factory: _$SettingsRoute._fromState,
                ),
              ],
            ),
          ],
        ),
        RelativeGoRouteData.$route(
          path: 'details/:detailId',
          factory: _$DetailsRoute._fromState,
          routes: [
            RelativeGoRouteData.$route(
              path: 'settings/:settingId',
              factory: _$SettingsRoute._fromState,
            ),
          ],
        ),
      ],
    );

mixin _$HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => HomeRoute();

  @override
  String get location => GoRouteData.$location(
        '/',
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

mixin _$DashboardRoute on GoRouteData {
  static DashboardRoute _fromState(GoRouterState state) => DashboardRoute();

  @override
  String get location => GoRouteData.$location(
        '/dashboard',
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

mixin _$DetailsRoute on RelativeGoRouteData {
  static DetailsRoute _fromState(GoRouterState state) => DetailsRoute(
        detailId: state.pathParameters['detailId']!,
      );

  DetailsRoute get _self => this as DetailsRoute;

  @override
  String get location => RelativeGoRouteData.$location(
        'details/${Uri.encodeComponent(_self.detailId)}',
      );

  @override
  String get relativeLocation => './$location';

  @override
  void goRelative(BuildContext context) => context.go(relativeLocation);

  @override
  Future<T?> pushRelative<T>(BuildContext context) =>
      context.push<T>(relativeLocation);

  @override
  void pushReplacementRelative(BuildContext context) =>
      context.pushReplacement(relativeLocation);

  @override
  void replaceRelative(BuildContext context) =>
      context.replace(relativeLocation);
}

mixin _$SettingsRoute on RelativeGoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => SettingsRoute(
        settingId: state.pathParameters['settingId']!,
      );

  SettingsRoute get _self => this as SettingsRoute;

  @override
  String get location => RelativeGoRouteData.$location(
        'settings/${Uri.encodeComponent(_self.settingId)}',
      );

  @override
  String get relativeLocation => './$location';

  @override
  void goRelative(BuildContext context) => context.go(relativeLocation);

  @override
  Future<T?> pushRelative<T>(BuildContext context) =>
      context.push<T>(relativeLocation);

  @override
  void pushReplacementRelative(BuildContext context) =>
      context.pushReplacement(relativeLocation);

  @override
  void replaceRelative(BuildContext context) =>
      context.replace(relativeLocation);
}

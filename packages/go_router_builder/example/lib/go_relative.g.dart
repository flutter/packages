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
      factory: $HomeRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/dashboard',
          factory: $DashboardRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: 'details/:detailId',
              factory: $DetailsRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'settings/:settingId',
                  factory: $SettingsRouteExtension._fromState,
                ),
              ],
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'details/:detailId',
          factory: $DetailsRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: 'settings/:settingId',
              factory: $SettingsRouteExtension._fromState,
            ),
          ],
        ),
      ],
    );

extension $HomeRouteExtension on HomeRoute {
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

extension $DashboardRouteExtension on DashboardRoute {
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

extension $DetailsRouteExtension on DetailsRoute {
  static DetailsRoute _fromState(GoRouterState state) => DetailsRoute(
        detailId: state.pathParameters['detailId']!,
      );

  String get location => GoRouteData.$location(
        'details/${Uri.encodeComponent(detailId)}',
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

extension $SettingsRouteExtension on SettingsRoute {
  static SettingsRoute _fromState(GoRouterState state) => SettingsRoute(
        settingId: state.pathParameters['settingId']!,
      );

  String get location => GoRouteData.$location(
        'settings/${Uri.encodeComponent(settingId)}',
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

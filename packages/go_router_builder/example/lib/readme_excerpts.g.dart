// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'readme_excerpts.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $homeRoute,
      $loginRoute,
      $myRoute,
      $personRouteWithExtra,
      $hotdogRouteWithEverything,
    ];

RouteBase get $homeRoute => GoRouteData.$route(
      path: '/',
      factory: $HomeRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'family/:fid',
          factory: $FamilyRouteExtension._fromState,
        ),
      ],
    );

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $FamilyRouteExtension on FamilyRoute {
  static FamilyRoute _fromState(GoRouterState state) => FamilyRoute(
        fid: state.pathParameters['fid'],
      );

  String get location => GoRouteData.$location(
        '/family/${Uri.encodeComponent(fid ?? '')}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $loginRoute => GoRouteData.$route(
      path: '/login',
      factory: $LoginRouteExtension._fromState,
    );

extension $LoginRouteExtension on LoginRoute {
  static LoginRoute _fromState(GoRouterState state) => LoginRoute(
        from: state.uri.queryParameters['from'],
      );

  String get location => GoRouteData.$location(
        '/login',
        queryParams: {
          if (from != null) 'from': from,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $myRoute => GoRouteData.$route(
      path: '/my-route',
      factory: $MyRouteExtension._fromState,
    );

extension $MyRouteExtension on MyRoute {
  static MyRoute _fromState(GoRouterState state) => MyRoute(
        queryParameter:
            state.uri.queryParameters['query-parameter'] ?? 'defaultValue',
      );

  String get location => GoRouteData.$location(
        '/my-route',
        queryParams: {
          if (queryParameter != 'defaultValue')
            'query-parameter': queryParameter,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $personRouteWithExtra => GoRouteData.$route(
      path: '/person',
      factory: $PersonRouteWithExtraExtension._fromState,
    );

extension $PersonRouteWithExtraExtension on PersonRouteWithExtra {
  static PersonRouteWithExtra _fromState(GoRouterState state) =>
      PersonRouteWithExtra(
        state.extra as Person?,
      );

  String get location => GoRouteData.$location(
        '/person',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

RouteBase get $hotdogRouteWithEverything => GoRouteData.$route(
      path: '/:ketchup',
      factory: $HotdogRouteWithEverythingExtension._fromState,
    );

extension $HotdogRouteWithEverythingExtension on HotdogRouteWithEverything {
  static HotdogRouteWithEverything _fromState(GoRouterState state) =>
      HotdogRouteWithEverything(
        _$boolConverter(state.pathParameters['ketchup']!)!,
        state.uri.queryParameters['mustard'],
        state.extra as Sauce,
      );

  String get location => GoRouteData.$location(
        '/${Uri.encodeComponent(ketchup.toString())}',
        queryParams: {
          if (mustard != null) 'mustard': mustard,
        },
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

bool _$boolConverter(String value) {
  switch (value) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw UnsupportedError('Cannot convert "$value" into a bool.');
  }
}

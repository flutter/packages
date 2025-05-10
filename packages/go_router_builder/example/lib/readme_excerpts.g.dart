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
      factory: _$HomeRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'family/:fid',
          factory: _$FamilyRoute._fromState,
        ),
      ],
    );

mixin _$HomeRoute {
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

mixin _$FamilyRoute {
  static FamilyRoute _fromState(GoRouterState state) => FamilyRoute(
        fid: state.pathParameters['fid'],
      );

  FamilyRoute get _self => this as FamilyRoute;

  String get location => GoRouteData.$location(
        '/family/${Uri.encodeComponent(_self.fid ?? '')}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $loginRoute => GoRouteData.$route(
      path: '/login',
      factory: _$LoginRoute._fromState,
    );

mixin _$LoginRoute {
  static LoginRoute _fromState(GoRouterState state) => LoginRoute(
        from: state.uri.queryParameters['from'],
      );

  LoginRoute get _self => this as LoginRoute;

  String get location => GoRouteData.$location(
        '/login',
        queryParams: {
          if (_self.from != null) 'from': _self.from,
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
      factory: _$MyRoute._fromState,
    );

mixin _$MyRoute {
  static MyRoute _fromState(GoRouterState state) => MyRoute(
        queryParameter:
            state.uri.queryParameters['query-parameter'] ?? 'defaultValue',
      );

  MyRoute get _self => this as MyRoute;

  String get location => GoRouteData.$location(
        '/my-route',
        queryParams: {
          if (_self.queryParameter != 'defaultValue')
            'query-parameter': _self.queryParameter,
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
      factory: _$PersonRouteWithExtra._fromState,
    );

mixin _$PersonRouteWithExtra {
  static PersonRouteWithExtra _fromState(GoRouterState state) =>
      PersonRouteWithExtra(
        state.extra as Person?,
      );

  PersonRouteWithExtra get _self => this as PersonRouteWithExtra;

  String get location => GoRouteData.$location(
        '/person',
      );

  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

RouteBase get $hotdogRouteWithEverything => GoRouteData.$route(
      path: '/:ketchup',
      factory: _$HotdogRouteWithEverything._fromState,
    );

mixin _$HotdogRouteWithEverything {
  static HotdogRouteWithEverything _fromState(GoRouterState state) =>
      HotdogRouteWithEverything(
        _$boolConverter(state.pathParameters['ketchup']!)!,
        state.uri.queryParameters['mustard'],
        state.extra as Sauce,
      );

  HotdogRouteWithEverything get _self => this as HotdogRouteWithEverything;

  String get location => GoRouteData.$location(
        '/${Uri.encodeComponent(_self.ketchup.toString())}',
        queryParams: {
          if (_self.mustard != null) 'mustard': _self.mustard,
        },
      );

  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
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

// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'main.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $homeRoute,
      $loginRoute,
    ];

RouteBase get $homeRoute => GoRouteData.$route(
      path: '/',
      factory: _$HomeRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'family/:fid',
          factory: _$FamilyRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'person/:pid',
              factory: _$PersonRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'details/:details',
                  factory: _$PersonDetailsRoute._fromState,
                ),
              ],
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'family-count/:count',
          factory: _$FamilyCountRoute._fromState,
        ),
      ],
    );

mixin _$HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

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

mixin _$FamilyRoute on GoRouteData {
  static FamilyRoute _fromState(GoRouterState state) => FamilyRoute(
        state.pathParameters['fid']!,
      );

  FamilyRoute get _self => this as FamilyRoute;

  @override
  String get location => GoRouteData.$location(
        '/family/${Uri.encodeComponent(_self.fid)}',
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

mixin _$PersonRoute on GoRouteData {
  static PersonRoute _fromState(GoRouterState state) => PersonRoute(
        state.pathParameters['fid']!,
        int.parse(state.pathParameters['pid']!)!,
      );

  PersonRoute get _self => this as PersonRoute;

  @override
  String get location => GoRouteData.$location(
        '/family/${Uri.encodeComponent(_self.fid)}/person/${Uri.encodeComponent(_self.pid.toString())}',
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

mixin _$PersonDetailsRoute on GoRouteData {
  static PersonDetailsRoute _fromState(GoRouterState state) =>
      PersonDetailsRoute(
        state.pathParameters['fid']!,
        int.parse(state.pathParameters['pid']!)!,
        _$PersonDetailsEnumMap._$fromName(state.pathParameters['details']!)!,
        $extra: state.extra as int?,
      );

  PersonDetailsRoute get _self => this as PersonDetailsRoute;

  @override
  String get location => GoRouteData.$location(
        '/family/${Uri.encodeComponent(_self.fid)}/person/${Uri.encodeComponent(_self.pid.toString())}/details/${Uri.encodeComponent(_$PersonDetailsEnumMap[_self.details]!)}',
      );

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

const _$PersonDetailsEnumMap = {
  PersonDetails.hobbies: 'hobbies',
  PersonDetails.favoriteFood: 'favorite-food',
  PersonDetails.favoriteSport: 'favorite-sport',
};

mixin _$FamilyCountRoute on GoRouteData {
  static FamilyCountRoute _fromState(GoRouterState state) => FamilyCountRoute(
        int.parse(state.pathParameters['count']!)!,
      );

  FamilyCountRoute get _self => this as FamilyCountRoute;

  @override
  String get location => GoRouteData.$location(
        '/family-count/${Uri.encodeComponent(_self.count.toString())}',
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

extension<T extends Enum> on Map<T, String> {
  T? _$fromName(String? value) =>
      entries.where((element) => element.value == value).firstOrNull?.key;
}

RouteBase get $loginRoute => GoRouteData.$route(
      path: '/login',
      factory: _$LoginRoute._fromState,
    );

mixin _$LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) => LoginRoute(
        fromPage: state.uri.queryParameters['from-page'],
      );

  LoginRoute get _self => this as LoginRoute;

  @override
  String get location => GoRouteData.$location(
        '/login',
        queryParams: {
          if (_self.fromPage != null) 'from-page': _self.fromPage,
        },
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

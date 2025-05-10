// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'simple_example.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $homeRoute,
    ];

RouteBase get $homeRoute => GoRouteData.$route(
      path: '/',
      name: 'Home',
      factory: _$HomeRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'family/:familyId',
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
        state.pathParameters['familyId']!,
      );

  FamilyRoute get _self => this as FamilyRoute;

  String get location => GoRouteData.$location(
        '/family/${Uri.encodeComponent(_self.familyId)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

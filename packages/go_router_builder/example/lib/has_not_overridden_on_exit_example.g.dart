// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'has_not_overridden_on_exit_example.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$homeRoute, $sub1Route, $sub2Route];

RouteBase get $homeRoute =>
    GoRouteData.$route(path: '/', factory: $HomeRoute._fromState);

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/');

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

RouteBase get $sub1Route =>
    GoRouteData.$route(path: '/sub-1-route', factory: $Sub1Route._fromState);

mixin $Sub1Route on GoRouteData {
  static Sub1Route _fromState(GoRouterState state) => const Sub1Route();

  @override
  String get location => GoRouteData.$location('/sub-1-route');

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

RouteBase get $sub2Route =>
    GoRouteData.$route(path: '/sub-2-route', factory: $Sub2Route._fromState);

mixin $Sub2Route on GoRouteData {
  static Sub2Route _fromState(GoRouterState state) => const Sub2Route();

  @override
  String get location => GoRouteData.$location('/sub-2-route');

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

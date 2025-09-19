// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'custom_encoder_example.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$homeRoute];

RouteBase get $homeRoute => GoRouteData.$route(
  path: '/',
  name: 'Home',
  factory: $HomeRoute._fromState,
  routes: [
    GoRouteData.$route(path: 'encoded', factory: $EncodedRoute._fromState),
  ],
);

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

mixin $EncodedRoute on GoRouteData {
  static EncodedRoute _fromState(GoRouterState state) =>
      EncodedRoute(fromBase64(state.uri.queryParameters['token']!));

  EncodedRoute get _self => this as EncodedRoute;

  @override
  String get location => GoRouteData.$location(
    '/encoded',
    queryParams: {'token': toBase64(_self.token)},
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

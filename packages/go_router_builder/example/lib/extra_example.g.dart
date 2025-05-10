// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'extra_example.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $requiredExtraRoute,
      $optionalExtraRoute,
      $splashRoute,
    ];

RouteBase get $requiredExtraRoute => GoRouteData.$route(
      path: '/requiredExtra',
      factory: _$RequiredExtraRoute._fromState,
    );

mixin _$RequiredExtraRoute {
  static RequiredExtraRoute _fromState(GoRouterState state) =>
      RequiredExtraRoute(
        $extra: state.extra as Extra,
      );

  RequiredExtraRoute get _self => this as RequiredExtraRoute;

  String get location => GoRouteData.$location(
        '/requiredExtra',
      );

  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

RouteBase get $optionalExtraRoute => GoRouteData.$route(
      path: '/optionalExtra',
      factory: _$OptionalExtraRoute._fromState,
    );

mixin _$OptionalExtraRoute {
  static OptionalExtraRoute _fromState(GoRouterState state) =>
      OptionalExtraRoute(
        $extra: state.extra as Extra?,
      );

  OptionalExtraRoute get _self => this as OptionalExtraRoute;

  String get location => GoRouteData.$location(
        '/optionalExtra',
      );

  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

RouteBase get $splashRoute => GoRouteData.$route(
      path: '/splash',
      factory: _$SplashRoute._fromState,
    );

mixin _$SplashRoute {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  String get location => GoRouteData.$location(
        '/splash',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

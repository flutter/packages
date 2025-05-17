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

mixin _$RequiredExtraRoute on GoRouteData {
  static RequiredExtraRoute _fromState(GoRouterState state) =>
      RequiredExtraRoute(
        $extra: state.extra as Extra,
      );

  RequiredExtraRoute get _self => this as RequiredExtraRoute;

  @override
  String get location => GoRouteData.$location(
        '/requiredExtra',
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

RouteBase get $optionalExtraRoute => GoRouteData.$route(
      path: '/optionalExtra',
      factory: _$OptionalExtraRoute._fromState,
    );

mixin _$OptionalExtraRoute on GoRouteData {
  static OptionalExtraRoute _fromState(GoRouterState state) =>
      OptionalExtraRoute(
        $extra: state.extra as Extra?,
      );

  OptionalExtraRoute get _self => this as OptionalExtraRoute;

  @override
  String get location => GoRouteData.$location(
        '/optionalExtra',
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

RouteBase get $splashRoute => GoRouteData.$route(
      path: '/splash',
      factory: _$SplashRoute._fromState,
    );

mixin _$SplashRoute on GoRouteData {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  @override
  String get location => GoRouteData.$location(
        '/splash',
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

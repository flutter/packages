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
      factory: $RequiredExtraRouteExtension._fromState,
    );

extension $RequiredExtraRouteExtension on RequiredExtraRoute {
  static RequiredExtraRoute _fromState(GoRouterState state) =>
      RequiredExtraRoute(
        $extra: state.extra as Extra,
      );

  String get location => GoRouteData.$location(
        '/requiredExtra',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

RouteBase get $optionalExtraRoute => GoRouteData.$route(
      path: '/optionalExtra',
      factory: $OptionalExtraRouteExtension._fromState,
    );

extension $OptionalExtraRouteExtension on OptionalExtraRoute {
  static OptionalExtraRoute _fromState(GoRouterState state) =>
      OptionalExtraRoute(
        $extra: state.extra as Extra?,
      );

  String get location => GoRouteData.$location(
        '/optionalExtra',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

RouteBase get $splashRoute => GoRouteData.$route(
      path: '/splash',
      factory: $SplashRouteExtension._fromState,
    );

extension $SplashRouteExtension on SplashRoute {
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

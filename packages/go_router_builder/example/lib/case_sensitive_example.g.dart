// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'case_sensitive_example.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $caseSensitiveRoute,
      $notCaseSensitiveRoute,
    ];

RouteBase get $caseSensitiveRoute => GoRouteData.$route(
      path: '/case-sensitive',
      factory: _$CaseSensitiveRoute._fromState,
    );

mixin _$CaseSensitiveRoute {
  static CaseSensitiveRoute _fromState(GoRouterState state) =>
      const CaseSensitiveRoute();

  String get location => GoRouteData.$location(
        '/case-sensitive',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $notCaseSensitiveRoute => GoRouteData.$route(
      path: '/not-case-sensitive',
      caseSensitive: false,
      factory: _$NotCaseSensitiveRoute._fromState,
    );

mixin _$NotCaseSensitiveRoute {
  static NotCaseSensitiveRoute _fromState(GoRouterState state) =>
      const NotCaseSensitiveRoute();

  String get location => GoRouteData.$location(
        '/not-case-sensitive',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

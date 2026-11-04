// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'route_metadata.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$libraryRoute];

RouteBase get $libraryRoute => GoRouteData.$route(
  path: '/library/:id',
  hasOverriddenOnExit: false,
  metadata: const <String, Object?>{
    'section': 'library',
    'requiresAuth': true,
    'labels': <String>{'books'},
  },
  factory: $LibraryRoute._fromState,
  routes: [
    RelativeGoRouteData.$route(
      path: 'preview',
      hasOverriddenOnExit: false,
      metadata: const <String, Object?>{
        'requiresAuth': false,
        'title': 'Preview',
        'codes': <int>[],
        'options': <String, bool>{},
        'nullableLists': <List<int>?>[
          null,
          <int>[1],
        ],
      },
      factory: $PreviewRoute._fromState,
    ),
  ],
);

mixin $LibraryRoute on GoRouteData {
  static LibraryRoute _fromState(GoRouterState state) =>
      LibraryRoute(state.pathParameters['id']!);

  LibraryRoute get _self => this as LibraryRoute;

  @override
  String get location =>
      GoRouteData.$location('/library/${Uri.encodeComponent(_self.id)}');

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

mixin $PreviewRoute on RelativeGoRouteData {
  static PreviewRoute _fromState(GoRouterState state) => const PreviewRoute();

  @override
  String get subLocation => RelativeGoRouteData.$location('preview');

  @override
  String get relativeLocation => './$subLocation';

  @override
  void goRelative(BuildContext context) => context.go(relativeLocation);

  @override
  Future<T?> pushRelative<T>(BuildContext context) =>
      context.push<T>(relativeLocation);

  @override
  void pushReplacementRelative(BuildContext context) =>
      context.pushReplacement(relativeLocation);

  @override
  void replaceRelative(BuildContext context) =>
      context.replace(relativeLocation);
}

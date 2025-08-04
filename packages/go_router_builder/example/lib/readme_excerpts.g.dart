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
      $booksRoute,
      $myMaterialRouteWithKey,
      $fancyRoute,
      $myShellRouteData,
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

mixin _$HomeRoute on GoRouteData {
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

mixin _$FamilyRoute on GoRouteData {
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

mixin _$LoginRoute on GoRouteData {
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

mixin _$MyRoute on GoRouteData {
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

mixin _$PersonRouteWithExtra on GoRouteData {
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

mixin _$HotdogRouteWithEverything on GoRouteData {
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

RouteBase get $booksRoute => GoRouteData.$route(
      path: '/books',
      factory: _$BooksRoute._fromState,
    );

mixin _$BooksRoute on GoRouteData {
  static BooksRoute _fromState(GoRouterState state) => BooksRoute(
        kind: _$convertMapValue('kind', state.uri.queryParameters,
                _$BookKindEnumMap._$fromName) ??
            BookKind.popular,
      );

  BooksRoute get _self => this as BooksRoute;

  String get location => GoRouteData.$location(
        '/books',
        queryParams: {
          if (_self.kind != BookKind.popular)
            'kind': _$BookKindEnumMap[_self.kind],
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

const _$BookKindEnumMap = {
  BookKind.all: 'all',
  BookKind.popular: 'popular',
  BookKind.recent: 'recent',
};

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

extension<T extends Enum> on Map<T, String> {
  T? _$fromName(String? value) =>
      entries.where((element) => element.value == value).firstOrNull?.key;
}

RouteBase get $myMaterialRouteWithKey => GoRouteData.$route(
      path: '/my-material-route-with-key',
      factory: _$MyMaterialRouteWithKey._fromState,
    );

mixin _$MyMaterialRouteWithKey on GoRouteData {
  static MyMaterialRouteWithKey _fromState(GoRouterState state) =>
      const MyMaterialRouteWithKey();

  String get location => GoRouteData.$location(
        '/my-material-route-with-key',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $fancyRoute => GoRouteData.$route(
      path: '/fancy',
      factory: _$FancyRoute._fromState,
    );

mixin _$FancyRoute on GoRouteData {
  static FancyRoute _fromState(GoRouterState state) => const FancyRoute();

  String get location => GoRouteData.$location(
        '/fancy',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $myShellRouteData => ShellRouteData.$route(
      navigatorKey: MyShellRouteData.$navigatorKey,
      factory: $MyShellRouteDataExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'my-go-route',
          parentNavigatorKey: MyGoRouteData.$parentNavigatorKey,
          factory: _$MyGoRouteData._fromState,
        ),
      ],
    );

extension $MyShellRouteDataExtension on MyShellRouteData {
  static MyShellRouteData _fromState(GoRouterState state) =>
      const MyShellRouteData();
}

mixin _$MyGoRouteData on GoRouteData {
  static MyGoRouteData _fromState(GoRouterState state) => const MyGoRouteData();

  String get location => GoRouteData.$location(
        'my-go-route',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

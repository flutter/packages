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
  $detailsRoute,
];

RouteBase get $homeRoute => GoRouteData.$route(
  path: '/',
  factory: $HomeRoute._fromState,
  routes: [
    GoRouteData.$route(path: 'family/:fid', factory: $FamilyRoute._fromState),
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

mixin $FamilyRoute on GoRouteData {
  static FamilyRoute _fromState(GoRouterState state) =>
      FamilyRoute(fid: state.pathParameters['fid']);

  FamilyRoute get _self => this as FamilyRoute;

  @override
  String get location =>
      GoRouteData.$location('/family/${Uri.encodeComponent(_self.fid ?? '')}');

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

RouteBase get $loginRoute =>
    GoRouteData.$route(path: '/login', factory: $LoginRoute._fromState);

mixin $LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) =>
      LoginRoute(from: state.uri.queryParameters['from']);

  LoginRoute get _self => this as LoginRoute;

  @override
  String get location => GoRouteData.$location(
    '/login',
    queryParams: {if (_self.from != null) 'from': _self.from},
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

RouteBase get $myRoute =>
    GoRouteData.$route(path: '/my-route', factory: $MyRoute._fromState);

mixin $MyRoute on GoRouteData {
  static MyRoute _fromState(GoRouterState state) => MyRoute(
    queryParameter:
        state.uri.queryParameters['query-parameter'] ?? 'defaultValue',
  );

  MyRoute get _self => this as MyRoute;

  @override
  String get location => GoRouteData.$location(
    '/my-route',
    queryParams: {
      if (_self.queryParameter != 'defaultValue')
        'query-parameter': _self.queryParameter,
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

RouteBase get $personRouteWithExtra => GoRouteData.$route(
  path: '/person',
  factory: $PersonRouteWithExtra._fromState,
);

mixin $PersonRouteWithExtra on GoRouteData {
  static PersonRouteWithExtra _fromState(GoRouterState state) =>
      PersonRouteWithExtra(state.extra as Person?);

  PersonRouteWithExtra get _self => this as PersonRouteWithExtra;

  @override
  String get location => GoRouteData.$location('/person');

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

RouteBase get $hotdogRouteWithEverything => GoRouteData.$route(
  path: '/:ketchup',
  factory: $HotdogRouteWithEverything._fromState,
);

mixin $HotdogRouteWithEverything on GoRouteData {
  static HotdogRouteWithEverything _fromState(GoRouterState state) =>
      HotdogRouteWithEverything(
        _$boolConverter(state.pathParameters['ketchup']!),
        state.uri.queryParameters['mustard'],
        state.extra as Sauce,
      );

  HotdogRouteWithEverything get _self => this as HotdogRouteWithEverything;

  @override
  String get location => GoRouteData.$location(
    '/${Uri.encodeComponent(_self.ketchup.toString())}',
    queryParams: {if (_self.mustard != null) 'mustard': _self.mustard},
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

RouteBase get $booksRoute =>
    GoRouteData.$route(path: '/books', factory: $BooksRoute._fromState);

mixin $BooksRoute on GoRouteData {
  static BooksRoute _fromState(GoRouterState state) => BooksRoute(
    kind:
        _$convertMapValue(
          'kind',
          state.uri.queryParameters,
          _$BookKindEnumMap._$fromName,
        ) ??
        BookKind.popular,
  );

  BooksRoute get _self => this as BooksRoute;

  @override
  String get location => GoRouteData.$location(
    '/books',
    queryParams: {
      if (_self.kind != BookKind.popular) 'kind': _$BookKindEnumMap[_self.kind],
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
  factory: $MyMaterialRouteWithKey._fromState,
);

mixin $MyMaterialRouteWithKey on GoRouteData {
  static MyMaterialRouteWithKey _fromState(GoRouterState state) =>
      const MyMaterialRouteWithKey();

  @override
  String get location => GoRouteData.$location('/my-material-route-with-key');

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

RouteBase get $fancyRoute =>
    GoRouteData.$route(path: '/fancy', factory: $FancyRoute._fromState);

mixin $FancyRoute on GoRouteData {
  static FancyRoute _fromState(GoRouterState state) => const FancyRoute();

  @override
  String get location => GoRouteData.$location('/fancy');

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

RouteBase get $myShellRouteData => ShellRouteData.$route(
  navigatorKey: MyShellRouteData.$navigatorKey,
  factory: $MyShellRouteDataExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: 'my-go-route',
      parentNavigatorKey: MyGoRouteData.$parentNavigatorKey,
      factory: $MyGoRouteData._fromState,
    ),
  ],
);

extension $MyShellRouteDataExtension on MyShellRouteData {
  static MyShellRouteData _fromState(GoRouterState state) =>
      const MyShellRouteData();
}

mixin $MyGoRouteData on GoRouteData {
  static MyGoRouteData _fromState(GoRouterState state) => const MyGoRouteData();

  @override
  String get location => GoRouteData.$location('my-go-route');

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

RouteBase get $detailsRoute => RelativeGoRouteData.$route(
  path: 'details',
  factory: $DetailsRoute._fromState,
);

mixin $DetailsRoute on RelativeGoRouteData {
  static DetailsRoute _fromState(GoRouterState state) => const DetailsRoute();

  @override
  String get subLocation => RelativeGoRouteData.$location('details');

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

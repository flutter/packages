// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'readme_excerpts.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $myRoute,
      $hotdogRouteWithEverything,
      $booksRoute,
    ];

RouteBase get $myRoute => GoRouteData.$route(
      path: '/my-route',
      factory: $MyRouteExtension._fromState,
    );

extension $MyRouteExtension on MyRoute {
  static MyRoute _fromState(GoRouterState state) => MyRoute(
        queryParameter:
            state.uri.queryParameters['query-parameter'] ?? 'defaultValue',
      );

  String get location => GoRouteData.$location(
        '/my-route',
        queryParams: {
          if (queryParameter != 'defaultValue')
            'query-parameter': queryParameter,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $hotdogRouteWithEverything => GoRouteData.$route(
      path: '/:ketchup',
      factory: $HotdogRouteWithEverythingExtension._fromState,
    );

extension $HotdogRouteWithEverythingExtension on HotdogRouteWithEverything {
  static HotdogRouteWithEverything _fromState(GoRouterState state) =>
      HotdogRouteWithEverything(
        _$boolConverter(state.pathParameters['ketchup']!),
        state.uri.queryParameters['mustard'],
        state.extra as Sauce,
      );

  String get location => GoRouteData.$location(
        '/${Uri.encodeComponent(ketchup.toString())}',
        queryParams: {
          if (mustard != null) 'mustard': mustard,
        },
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
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
      factory: $BooksRouteExtension._fromState,
    );

extension $BooksRouteExtension on BooksRoute {
  static BooksRoute _fromState(GoRouterState state) => BooksRoute(
        kind: _$convertMapValue('kind', state.uri.queryParameters,
                _$BookKindEnumMap._$fromName) ??
            BookKind.popular,
      );

  String get location => GoRouteData.$location(
        '/books',
        queryParams: {
          if (kind != BookKind.popular) 'kind': _$BookKindEnumMap[kind],
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
  T Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

extension<T extends Enum> on Map<T, String> {
  T _$fromName(String value) =>
      entries.singleWhere((element) => element.value == value).key;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'all_types.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<GoRoute> get $appRoutes => [
      $allTypesBaseRoute,
    ];

GoRoute get $allTypesBaseRoute => GoRouteData.$route(
      path: '/',
      factory: $AllTypesBaseRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'big-int-route/:requiredBigIntField',
          factory: $BigIntRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'bool-route/:requiredBoolField',
          factory: $BoolRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'date-time-route/:requiredDateTimeField',
          factory: $DateTimeRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'double-route/:requiredDoubleField',
          factory: $DoubleRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'int-route/:requiredIntField',
          factory: $IntRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'num-route/:requiredNumField',
          factory: $NumRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'double-route/:requiredDoubleField',
          factory: $DoubleRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'enum-route/:requiredEnumField',
          factory: $EnumRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'enhanced-enum-route/:requiredEnumField',
          factory: $EnhancedEnumRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'string-route/:requiredStringField',
          factory: $StringRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'uri-route/:requiredUriField',
          factory: $UriRouteExtension._fromState,
        ),
      ],
    );

extension $AllTypesBaseRouteExtension on AllTypesBaseRoute {
  static AllTypesBaseRoute _fromState(GoRouterState state) =>
      const AllTypesBaseRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context, {Object? extra}) =>
      context.go(location, extra: extra);

  void push(BuildContext context, {Object? extra}) =>
      context.push(location, extra: extra);
}

extension $BigIntRouteExtension on BigIntRoute {
  static BigIntRoute _fromState(GoRouterState state) => BigIntRoute(
        requiredBigIntField: BigInt.parse(state.params['requiredBigIntField']!),
        bigIntField:
            _$convertMapValue('big-int-field', state.queryParams, BigInt.parse),
      );

  String get location => GoRouteData.$location(
        '/big-int-route/${Uri.encodeComponent(requiredBigIntField.toString())}',
        queryParams: {
          if (bigIntField != null) 'big-int-field': bigIntField!.toString(),
        },
      );

  void go(BuildContext context, {Object? extra}) =>
      context.go(location, extra: extra);

  void push(BuildContext context, {Object? extra}) =>
      context.push(location, extra: extra);
}

extension $BoolRouteExtension on BoolRoute {
  static BoolRoute _fromState(GoRouterState state) => BoolRoute(
        requiredBoolField: _$boolConverter(state.params['requiredBoolField']!),
        boolField:
            _$convertMapValue('bool-field', state.queryParams, _$boolConverter),
      );

  String get location => GoRouteData.$location(
        '/bool-route/${Uri.encodeComponent(requiredBoolField.toString())}',
        queryParams: {
          if (boolField != null) 'bool-field': boolField!.toString(),
        },
      );

  void go(BuildContext context, {Object? extra}) =>
      context.go(location, extra: extra);

  void push(BuildContext context, {Object? extra}) =>
      context.push(location, extra: extra);
}

extension $DateTimeRouteExtension on DateTimeRoute {
  static DateTimeRoute _fromState(GoRouterState state) => DateTimeRoute(
        requiredDateTimeField:
            DateTime.parse(state.params['requiredDateTimeField']!),
        dateTimeField: _$convertMapValue(
            'date-time-field', state.queryParams, DateTime.parse),
      );

  String get location => GoRouteData.$location(
        '/date-time-route/${Uri.encodeComponent(requiredDateTimeField.toString())}',
        queryParams: {
          if (dateTimeField != null)
            'date-time-field': dateTimeField!.toString(),
        },
      );

  void go(BuildContext context, {Object? extra}) =>
      context.go(location, extra: extra);

  void push(BuildContext context, {Object? extra}) =>
      context.push(location, extra: extra);
}

extension $DoubleRouteExtension on DoubleRoute {
  static DoubleRoute _fromState(GoRouterState state) => DoubleRoute(
        requiredDoubleField: double.parse(state.params['requiredDoubleField']!),
        doubleField:
            _$convertMapValue('double-field', state.queryParams, double.parse),
      );

  String get location => GoRouteData.$location(
        '/double-route/${Uri.encodeComponent(requiredDoubleField.toString())}',
        queryParams: {
          if (doubleField != null) 'double-field': doubleField!.toString(),
        },
      );

  void go(BuildContext context, {Object? extra}) =>
      context.go(location, extra: extra);

  void push(BuildContext context, {Object? extra}) =>
      context.push(location, extra: extra);
}

extension $IntRouteExtension on IntRoute {
  static IntRoute _fromState(GoRouterState state) => IntRoute(
        requiredIntField: int.parse(state.params['requiredIntField']!),
        intField: _$convertMapValue('int-field', state.queryParams, int.parse),
      );

  String get location => GoRouteData.$location(
        '/int-route/${Uri.encodeComponent(requiredIntField.toString())}',
        queryParams: {
          if (intField != null) 'int-field': intField!.toString(),
        },
      );

  void go(BuildContext context, {Object? extra}) =>
      context.go(location, extra: extra);

  void push(BuildContext context, {Object? extra}) =>
      context.push(location, extra: extra);
}

extension $NumRouteExtension on NumRoute {
  static NumRoute _fromState(GoRouterState state) => NumRoute(
        requiredNumField: num.parse(state.params['requiredNumField']!),
        numField: _$convertMapValue('num-field', state.queryParams, num.parse),
      );

  String get location => GoRouteData.$location(
        '/num-route/${Uri.encodeComponent(requiredNumField.toString())}',
        queryParams: {
          if (numField != null) 'num-field': numField!.toString(),
        },
      );

  void go(BuildContext context, {Object? extra}) =>
      context.go(location, extra: extra);

  void push(BuildContext context, {Object? extra}) =>
      context.push(location, extra: extra);
}

extension $EnumRouteExtension on EnumRoute {
  static EnumRoute _fromState(GoRouterState state) => EnumRoute(
        requiredEnumField: _$PersonDetailsEnumMap
            ._$fromName(state.params['requiredEnumField']!),
        enumField: _$convertMapValue(
            'enum-field', state.queryParams, _$PersonDetailsEnumMap._$fromName),
      );

  String get location => GoRouteData.$location(
        '/enum-route/${Uri.encodeComponent(_$PersonDetailsEnumMap[requiredEnumField]!)}',
        queryParams: {
          if (enumField != null)
            'enum-field': _$PersonDetailsEnumMap[enumField!]!,
        },
      );

  void go(BuildContext context, {Object? extra}) =>
      context.go(location, extra: extra);

  void push(BuildContext context, {Object? extra}) =>
      context.push(location, extra: extra);
}

extension $EnhancedEnumRouteExtension on EnhancedEnumRoute {
  static EnhancedEnumRoute _fromState(GoRouterState state) => EnhancedEnumRoute(
        requiredEnumField: _$SportDetailsEnumMap
            ._$fromName(state.params['requiredEnumField']!),
        enumField: _$convertMapValue(
            'enum-field', state.queryParams, _$SportDetailsEnumMap._$fromName),
      );

  String get location => GoRouteData.$location(
        '/enhanced-enum-route/${Uri.encodeComponent(_$SportDetailsEnumMap[requiredEnumField]!)}',
        queryParams: {
          if (enumField != null)
            'enum-field': _$SportDetailsEnumMap[enumField!]!,
        },
      );

  void go(BuildContext context, {Object? extra}) =>
      context.go(location, extra: extra);

  void push(BuildContext context, {Object? extra}) =>
      context.push(location, extra: extra);
}

extension $StringRouteExtension on StringRoute {
  static StringRoute _fromState(GoRouterState state) => StringRoute(
        requiredStringField: state.params['requiredStringField']!,
        stringField: state.queryParams['string-field'],
      );

  String get location => GoRouteData.$location(
        '/string-route/${Uri.encodeComponent(requiredStringField)}',
        queryParams: {
          if (stringField != null) 'string-field': stringField!,
        },
      );

  void go(BuildContext context, {Object? extra}) =>
      context.go(location, extra: extra);

  void push(BuildContext context, {Object? extra}) =>
      context.push(location, extra: extra);
}

extension $UriRouteExtension on UriRoute {
  static UriRoute _fromState(GoRouterState state) => UriRoute(
        requiredUriField: Uri.parse(state.params['requiredUriField']!),
        uriField: _$convertMapValue('uri-field', state.queryParams, Uri.parse),
      );

  String get location => GoRouteData.$location(
        '/uri-route/${Uri.encodeComponent(requiredUriField.toString())}',
        queryParams: {
          if (uriField != null) 'uri-field': uriField!.toString(),
        },
      );

  void go(BuildContext context, {Object? extra}) =>
      context.go(location, extra: extra);

  void push(BuildContext context, {Object? extra}) =>
      context.push(location, extra: extra);
}

const _$PersonDetailsEnumMap = {
  PersonDetails.hobbies: 'hobbies',
  PersonDetails.favoriteFood: 'favorite-food',
  PersonDetails.favoriteSport: 'favorite-sport',
};

const _$SportDetailsEnumMap = {
  SportDetails.volleyball: 'volleyball',
  SportDetails.football: 'football',
  SportDetails.tennis: 'tennis',
  SportDetails.hockey: 'hockey',
};

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
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

extension<T extends Enum> on Map<T, String> {
  T _$fromName(String value) =>
      entries.singleWhere((element) => element.value == value).key;
}

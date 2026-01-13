// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'all_extension_types.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$allTypesBaseRoute];

RouteBase get $allTypesBaseRoute => GoRouteData.$route(
  path: '/',
  factory: $AllTypesBaseRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'big-int-route/:requiredBigIntField',
      factory: $BigIntExtensionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'bool-route/:requiredBoolField',
      factory: $BoolExtensionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'date-time-route/:requiredDateTimeField',
      factory: $DateTimeExtensionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'double-route/:requiredDoubleField',
      factory: $DoubleExtensionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'int-route/:requiredIntField',
      factory: $IntExtensionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'num-route/:requiredNumField',
      factory: $NumExtensionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'double-route/:requiredDoubleField',
      factory: $DoubleExtensionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'enum-route/:requiredEnumField',
      factory: $EnumExtensionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'enhanced-enum-route/:requiredEnumField',
      factory: $EnhancedEnumExtensionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'string-route/:requiredStringField',
      factory: $StringExtensionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'uri-route/:requiredUriField',
      factory: $UriExtensionRoute._fromState,
    ),
  ],
);

mixin $AllTypesBaseRoute on GoRouteData {
  static AllTypesBaseRoute _fromState(GoRouterState state) =>
      const AllTypesBaseRoute();

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

mixin $BigIntExtensionRoute on GoRouteData {
  static BigIntExtensionRoute _fromState(GoRouterState state) =>
      BigIntExtensionRoute(
        requiredBigIntField:
            BigInt.parse(state.pathParameters['requiredBigIntField']!)
                as BigIntExtension,
        bigIntField:
            BigInt.tryParse(state.uri.queryParameters['big-int-field'] ?? '')
                as BigIntExtension?,
      );

  BigIntExtensionRoute get _self => this as BigIntExtensionRoute;

  @override
  String get location => GoRouteData.$location(
    '/big-int-route/${Uri.encodeComponent(_self.requiredBigIntField.toString())}',
    queryParams: {
      if (_self.bigIntField != null)
        'big-int-field': _self.bigIntField!.toString(),
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

mixin $BoolExtensionRoute on GoRouteData {
  static BoolExtensionRoute _fromState(
    GoRouterState state,
  ) => BoolExtensionRoute(
    requiredBoolField:
        bool.parse(state.pathParameters['requiredBoolField']!) as BoolExtension,
    boolField:
        bool.tryParse(state.uri.queryParameters['bool-field'] ?? '')
            as BoolExtension?,
    boolFieldWithDefaultValue:
        bool.tryParse(
              state.uri.queryParameters['bool-field-with-default-value'] ?? '',
            )
            as BoolExtension? ??
        const BoolExtension(true),
  );

  BoolExtensionRoute get _self => this as BoolExtensionRoute;

  @override
  String get location => GoRouteData.$location(
    '/bool-route/${Uri.encodeComponent(_self.requiredBoolField.toString())}',
    queryParams: {
      if (_self.boolField != null) 'bool-field': _self.boolField!.toString(),
      if (_self.boolFieldWithDefaultValue != const BoolExtension(true))
        'bool-field-with-default-value': _self.boolFieldWithDefaultValue
            .toString(),
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

mixin $DateTimeExtensionRoute on GoRouteData {
  static DateTimeExtensionRoute _fromState(GoRouterState state) =>
      DateTimeExtensionRoute(
        requiredDateTimeField:
            DateTime.parse(state.pathParameters['requiredDateTimeField']!)
                as DateTimeExtension,
        dateTimeField:
            DateTime.tryParse(
                  state.uri.queryParameters['date-time-field'] ?? '',
                )
                as DateTimeExtension?,
      );

  DateTimeExtensionRoute get _self => this as DateTimeExtensionRoute;

  @override
  String get location => GoRouteData.$location(
    '/date-time-route/${Uri.encodeComponent(_self.requiredDateTimeField.toString())}',
    queryParams: {
      if (_self.dateTimeField != null)
        'date-time-field': _self.dateTimeField!.toString(),
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

mixin $DoubleExtensionRoute on GoRouteData {
  static DoubleExtensionRoute _fromState(
    GoRouterState state,
  ) => DoubleExtensionRoute(
    requiredDoubleField:
        double.parse(state.pathParameters['requiredDoubleField']!)
            as DoubleExtension,
    doubleField:
        double.tryParse(state.uri.queryParameters['double-field'] ?? '')
            as DoubleExtension?,
    doubleFieldWithDefaultValue:
        double.tryParse(
              state.uri.queryParameters['double-field-with-default-value'] ??
                  '',
            )
            as DoubleExtension? ??
        const DoubleExtension(1.0),
  );

  DoubleExtensionRoute get _self => this as DoubleExtensionRoute;

  @override
  String get location => GoRouteData.$location(
    '/double-route/${Uri.encodeComponent(_self.requiredDoubleField.toString())}',
    queryParams: {
      if (_self.doubleField != null)
        'double-field': _self.doubleField!.toString(),
      if (_self.doubleFieldWithDefaultValue != const DoubleExtension(1.0))
        'double-field-with-default-value': _self.doubleFieldWithDefaultValue
            .toString(),
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

mixin $IntExtensionRoute on GoRouteData {
  static IntExtensionRoute _fromState(GoRouterState state) => IntExtensionRoute(
    requiredIntField:
        int.parse(state.pathParameters['requiredIntField']!) as IntExtension,
    intField:
        int.tryParse(state.uri.queryParameters['int-field'] ?? '')
            as IntExtension?,
    intFieldWithDefaultValue:
        int.tryParse(
              state.uri.queryParameters['int-field-with-default-value'] ?? '',
            )
            as IntExtension? ??
        const IntExtension(1),
  );

  IntExtensionRoute get _self => this as IntExtensionRoute;

  @override
  String get location => GoRouteData.$location(
    '/int-route/${Uri.encodeComponent(_self.requiredIntField.toString())}',
    queryParams: {
      if (_self.intField != null) 'int-field': _self.intField!.toString(),
      if (_self.intFieldWithDefaultValue != const IntExtension(1))
        'int-field-with-default-value': _self.intFieldWithDefaultValue
            .toString(),
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

mixin $NumExtensionRoute on GoRouteData {
  static NumExtensionRoute _fromState(GoRouterState state) => NumExtensionRoute(
    requiredNumField:
        num.parse(state.pathParameters['requiredNumField']!) as NumExtension,
    numField:
        num.tryParse(state.uri.queryParameters['num-field'] ?? '')
            as NumExtension?,
    numFieldWithDefaultValue:
        num.tryParse(
              state.uri.queryParameters['num-field-with-default-value'] ?? '',
            )
            as NumExtension? ??
        const NumExtension(1),
  );

  NumExtensionRoute get _self => this as NumExtensionRoute;

  @override
  String get location => GoRouteData.$location(
    '/num-route/${Uri.encodeComponent(_self.requiredNumField.toString())}',
    queryParams: {
      if (_self.numField != null) 'num-field': _self.numField!.toString(),
      if (_self.numFieldWithDefaultValue != const NumExtension(1))
        'num-field-with-default-value': _self.numFieldWithDefaultValue
            .toString(),
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

mixin $EnumExtensionRoute on GoRouteData {
  static EnumExtensionRoute _fromState(GoRouterState state) =>
      EnumExtensionRoute(
        requiredEnumField:
            _$PersonDetailsEnumMap._$fromName(
                  state.pathParameters['requiredEnumField']!,
                )
                as PersonDetailsExtension,
        enumField:
            _$PersonDetailsEnumMap._$fromName(
                  state.uri.queryParameters['enum-field'],
                )
                as PersonDetailsExtension?,
        enumFieldWithDefaultValue:
            _$PersonDetailsEnumMap._$fromName(
                  state.uri.queryParameters['enum-field-with-default-value'],
                )
                as PersonDetailsExtension? ??
            const PersonDetailsExtension(PersonDetails.favoriteFood),
      );

  EnumExtensionRoute get _self => this as EnumExtensionRoute;

  @override
  String get location => GoRouteData.$location(
    '/enum-route/${Uri.encodeComponent(_$PersonDetailsEnumMap[_self.requiredEnumField as PersonDetails]!)}',
    queryParams: {
      if (_self.enumField != null)
        'enum-field':
            _$PersonDetailsEnumMap[_self.enumField! as PersonDetails]!,
      if (_self.enumFieldWithDefaultValue !=
          const PersonDetailsExtension(PersonDetails.favoriteFood))
        'enum-field-with-default-value':
            _$PersonDetailsEnumMap[_self.enumFieldWithDefaultValue
                as PersonDetails]!,
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

const _$PersonDetailsEnumMap = {
  PersonDetails.hobbies: 'hobbies',
  PersonDetails.favoriteFood: 'favorite-food',
  PersonDetails.favoriteSport: 'favorite-sport',
};

mixin $EnhancedEnumExtensionRoute on GoRouteData {
  static EnhancedEnumExtensionRoute _fromState(GoRouterState state) =>
      EnhancedEnumExtensionRoute(
        requiredEnumField:
            _$SportDetailsEnumMap._$fromName(
                  state.pathParameters['requiredEnumField']!,
                )
                as SportDetailsExtension,
        enumField:
            _$SportDetailsEnumMap._$fromName(
                  state.uri.queryParameters['enum-field'],
                )
                as SportDetailsExtension?,
        enumFieldWithDefaultValue:
            _$SportDetailsEnumMap._$fromName(
                  state.uri.queryParameters['enum-field-with-default-value'],
                )
                as SportDetailsExtension? ??
            const SportDetailsExtension(SportDetails.football),
      );

  EnhancedEnumExtensionRoute get _self => this as EnhancedEnumExtensionRoute;

  @override
  String get location => GoRouteData.$location(
    '/enhanced-enum-route/${Uri.encodeComponent(_$SportDetailsEnumMap[_self.requiredEnumField as SportDetails]!)}',
    queryParams: {
      if (_self.enumField != null)
        'enum-field': _$SportDetailsEnumMap[_self.enumField! as SportDetails]!,
      if (_self.enumFieldWithDefaultValue !=
          const SportDetailsExtension(SportDetails.football))
        'enum-field-with-default-value':
            _$SportDetailsEnumMap[_self.enumFieldWithDefaultValue
                as SportDetails]!,
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

const _$SportDetailsEnumMap = {
  SportDetails.volleyball: 'volleyball',
  SportDetails.football: 'football',
  SportDetails.tennis: 'tennis',
  SportDetails.hockey: 'hockey',
};

mixin $StringExtensionRoute on GoRouteData {
  static StringExtensionRoute _fromState(GoRouterState state) =>
      StringExtensionRoute(
        requiredStringField:
            state.pathParameters['requiredStringField']! as StringExtension,
        stringField:
            state.uri.queryParameters['string-field'] as StringExtension?,
        stringFieldWithDefaultValue:
            state.uri.queryParameters['string-field-with-default-value']
                as StringExtension? ??
            const StringExtension('defaultValue'),
      );

  StringExtensionRoute get _self => this as StringExtensionRoute;

  @override
  String get location => GoRouteData.$location(
    '/string-route/${Uri.encodeComponent(_self.requiredStringField as String)}',
    queryParams: {
      if (_self.stringField != null)
        'string-field': _self.stringField! as String,
      if (_self.stringFieldWithDefaultValue !=
          const StringExtension('defaultValue'))
        'string-field-with-default-value':
            _self.stringFieldWithDefaultValue as String,
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

mixin $UriExtensionRoute on GoRouteData {
  static UriExtensionRoute _fromState(GoRouterState state) => UriExtensionRoute(
    requiredUriField:
        Uri.parse(state.pathParameters['requiredUriField']!) as UriExtension,
    uriField:
        Uri.tryParse(state.uri.queryParameters['uri-field'] ?? '')
            as UriExtension?,
  );

  UriExtensionRoute get _self => this as UriExtensionRoute;

  @override
  String get location => GoRouteData.$location(
    '/uri-route/${Uri.encodeComponent(_self.requiredUriField.toString())}',
    queryParams: {
      if (_self.uriField != null) 'uri-field': _self.uriField!.toString(),
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

extension<T extends Enum> on Map<T, String> {
  T? _$fromName(String? value) =>
      entries.where((element) => element.value == value).firstOrNull?.key;
}

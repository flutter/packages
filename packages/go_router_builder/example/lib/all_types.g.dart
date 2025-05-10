// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'all_types.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $allTypesBaseRoute,
    ];

RouteBase get $allTypesBaseRoute => GoRouteData.$route(
      path: '/',
      factory: _$AllTypesBaseRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'big-int-route/:requiredBigIntField',
          factory: _$BigIntRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'bool-route/:requiredBoolField',
          factory: _$BoolRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'date-time-route/:requiredDateTimeField',
          factory: _$DateTimeRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'double-route/:requiredDoubleField',
          factory: _$DoubleRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'int-route/:requiredIntField',
          factory: _$IntRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'num-route/:requiredNumField',
          factory: _$NumRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'double-route/:requiredDoubleField',
          factory: _$DoubleRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'enum-route/:requiredEnumField',
          factory: _$EnumRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'enhanced-enum-route/:requiredEnumField',
          factory: _$EnhancedEnumRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'string-route/:requiredStringField',
          factory: _$StringRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'uri-route/:requiredUriField',
          factory: _$UriRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'iterable-route',
          factory: _$IterableRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'iterable-route-with-default-values',
          factory: _$IterableRouteWithDefaultValues._fromState,
        ),
      ],
    );

mixin _$AllTypesBaseRoute on GoRouteData {
  static AllTypesBaseRoute _fromState(GoRouterState state) =>
      const AllTypesBaseRoute();

  @override
  String get location => GoRouteData.$location(
        '/',
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

mixin _$BigIntRoute on GoRouteData {
  static BigIntRoute _fromState(GoRouterState state) => BigIntRoute(
        requiredBigIntField:
            BigInt.parse(state.pathParameters['requiredBigIntField']!)!,
        bigIntField: _$convertMapValue(
            'big-int-field', state.uri.queryParameters, BigInt.tryParse),
      );

  BigIntRoute get _self => this as BigIntRoute;

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

mixin _$BoolRoute on GoRouteData {
  static BoolRoute _fromState(GoRouterState state) => BoolRoute(
        requiredBoolField:
            _$boolConverter(state.pathParameters['requiredBoolField']!)!,
        boolField: _$convertMapValue(
            'bool-field', state.uri.queryParameters, _$boolConverter),
        boolFieldWithDefaultValue: _$convertMapValue(
                'bool-field-with-default-value',
                state.uri.queryParameters,
                _$boolConverter) ??
            true,
      );

  BoolRoute get _self => this as BoolRoute;

  @override
  String get location => GoRouteData.$location(
        '/bool-route/${Uri.encodeComponent(_self.requiredBoolField.toString())}',
        queryParams: {
          if (_self.boolField != null)
            'bool-field': _self.boolField!.toString(),
          if (_self.boolFieldWithDefaultValue != true)
            'bool-field-with-default-value':
                _self.boolFieldWithDefaultValue.toString(),
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

mixin _$DateTimeRoute on GoRouteData {
  static DateTimeRoute _fromState(GoRouterState state) => DateTimeRoute(
        requiredDateTimeField:
            DateTime.parse(state.pathParameters['requiredDateTimeField']!)!,
        dateTimeField: _$convertMapValue(
            'date-time-field', state.uri.queryParameters, DateTime.tryParse),
      );

  DateTimeRoute get _self => this as DateTimeRoute;

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

mixin _$DoubleRoute on GoRouteData {
  static DoubleRoute _fromState(GoRouterState state) => DoubleRoute(
        requiredDoubleField:
            double.parse(state.pathParameters['requiredDoubleField']!)!,
        doubleField: _$convertMapValue(
            'double-field', state.uri.queryParameters, double.tryParse),
        doubleFieldWithDefaultValue: _$convertMapValue(
                'double-field-with-default-value',
                state.uri.queryParameters,
                double.parse) ??
            1.0,
      );

  DoubleRoute get _self => this as DoubleRoute;

  @override
  String get location => GoRouteData.$location(
        '/double-route/${Uri.encodeComponent(_self.requiredDoubleField.toString())}',
        queryParams: {
          if (_self.doubleField != null)
            'double-field': _self.doubleField!.toString(),
          if (_self.doubleFieldWithDefaultValue != 1.0)
            'double-field-with-default-value':
                _self.doubleFieldWithDefaultValue.toString(),
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

mixin _$IntRoute on GoRouteData {
  static IntRoute _fromState(GoRouterState state) => IntRoute(
        requiredIntField: int.parse(state.pathParameters['requiredIntField']!)!,
        intField: _$convertMapValue(
            'int-field', state.uri.queryParameters, int.tryParse),
        intFieldWithDefaultValue: _$convertMapValue(
                'int-field-with-default-value',
                state.uri.queryParameters,
                int.parse) ??
            1,
      );

  IntRoute get _self => this as IntRoute;

  @override
  String get location => GoRouteData.$location(
        '/int-route/${Uri.encodeComponent(_self.requiredIntField.toString())}',
        queryParams: {
          if (_self.intField != null) 'int-field': _self.intField!.toString(),
          if (_self.intFieldWithDefaultValue != 1)
            'int-field-with-default-value':
                _self.intFieldWithDefaultValue.toString(),
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

mixin _$NumRoute on GoRouteData {
  static NumRoute _fromState(GoRouterState state) => NumRoute(
        requiredNumField: num.parse(state.pathParameters['requiredNumField']!)!,
        numField: _$convertMapValue(
            'num-field', state.uri.queryParameters, num.tryParse),
        numFieldWithDefaultValue: _$convertMapValue(
                'num-field-with-default-value',
                state.uri.queryParameters,
                num.parse) ??
            1,
      );

  NumRoute get _self => this as NumRoute;

  @override
  String get location => GoRouteData.$location(
        '/num-route/${Uri.encodeComponent(_self.requiredNumField.toString())}',
        queryParams: {
          if (_self.numField != null) 'num-field': _self.numField!.toString(),
          if (_self.numFieldWithDefaultValue != 1)
            'num-field-with-default-value':
                _self.numFieldWithDefaultValue.toString(),
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

mixin _$EnumRoute on GoRouteData {
  static EnumRoute _fromState(GoRouterState state) => EnumRoute(
        requiredEnumField: _$PersonDetailsEnumMap
            ._$fromName(state.pathParameters['requiredEnumField']!)!,
        enumField: _$convertMapValue('enum-field', state.uri.queryParameters,
            _$PersonDetailsEnumMap._$fromName),
        enumFieldWithDefaultValue: _$convertMapValue(
                'enum-field-with-default-value',
                state.uri.queryParameters,
                _$PersonDetailsEnumMap._$fromName) ??
            PersonDetails.favoriteFood,
      );

  EnumRoute get _self => this as EnumRoute;

  @override
  String get location => GoRouteData.$location(
        '/enum-route/${Uri.encodeComponent(_$PersonDetailsEnumMap[_self.requiredEnumField]!)}',
        queryParams: {
          if (_self.enumField != null)
            'enum-field': _$PersonDetailsEnumMap[_self.enumField!],
          if (_self.enumFieldWithDefaultValue != PersonDetails.favoriteFood)
            'enum-field-with-default-value':
                _$PersonDetailsEnumMap[_self.enumFieldWithDefaultValue],
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

mixin _$EnhancedEnumRoute on GoRouteData {
  static EnhancedEnumRoute _fromState(GoRouterState state) => EnhancedEnumRoute(
        requiredEnumField: _$SportDetailsEnumMap
            ._$fromName(state.pathParameters['requiredEnumField']!)!,
        enumField: _$convertMapValue('enum-field', state.uri.queryParameters,
            _$SportDetailsEnumMap._$fromName),
        enumFieldWithDefaultValue: _$convertMapValue(
                'enum-field-with-default-value',
                state.uri.queryParameters,
                _$SportDetailsEnumMap._$fromName) ??
            SportDetails.football,
      );

  EnhancedEnumRoute get _self => this as EnhancedEnumRoute;

  @override
  String get location => GoRouteData.$location(
        '/enhanced-enum-route/${Uri.encodeComponent(_$SportDetailsEnumMap[_self.requiredEnumField]!)}',
        queryParams: {
          if (_self.enumField != null)
            'enum-field': _$SportDetailsEnumMap[_self.enumField!],
          if (_self.enumFieldWithDefaultValue != SportDetails.football)
            'enum-field-with-default-value':
                _$SportDetailsEnumMap[_self.enumFieldWithDefaultValue],
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

mixin _$StringRoute on GoRouteData {
  static StringRoute _fromState(GoRouterState state) => StringRoute(
        requiredStringField: state.pathParameters['requiredStringField']!,
        stringField: state.uri.queryParameters['string-field'],
        stringFieldWithDefaultValue:
            state.uri.queryParameters['string-field-with-default-value'] ??
                'defaultValue',
      );

  StringRoute get _self => this as StringRoute;

  @override
  String get location => GoRouteData.$location(
        '/string-route/${Uri.encodeComponent(_self.requiredStringField)}',
        queryParams: {
          if (_self.stringField != null) 'string-field': _self.stringField,
          if (_self.stringFieldWithDefaultValue != 'defaultValue')
            'string-field-with-default-value':
                _self.stringFieldWithDefaultValue,
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

mixin _$UriRoute on GoRouteData {
  static UriRoute _fromState(GoRouterState state) => UriRoute(
        requiredUriField: Uri.parse(state.pathParameters['requiredUriField']!)!,
        uriField: _$convertMapValue(
            'uri-field', state.uri.queryParameters, Uri.tryParse),
      );

  UriRoute get _self => this as UriRoute;

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

mixin _$IterableRoute on GoRouteData {
  static IterableRoute _fromState(GoRouterState state) => IterableRoute(
        intIterableField: (state.uri.queryParametersAll['int-iterable-field']
            ?.map(int.parse)
            .cast<int>() as Iterable<int>?),
        doubleIterableField: (state
            .uri.queryParametersAll['double-iterable-field']
            ?.map(double.parse)
            .cast<double>() as Iterable<double>?),
        stringIterableField: (state
            .uri.queryParametersAll['string-iterable-field']
            ?.map((e) => e)),
        boolIterableField: (state.uri.queryParametersAll['bool-iterable-field']
            ?.map(_$boolConverter)
            .cast<bool>() as Iterable<bool>?),
        enumIterableField: (state.uri.queryParametersAll['enum-iterable-field']
            ?.map(_$SportDetailsEnumMap._$fromName)
            .cast<SportDetails>() as Iterable<SportDetails>?),
        enumOnlyInIterableField: (state
            .uri.queryParametersAll['enum-only-in-iterable-field']
            ?.map(_$CookingRecipeEnumMap._$fromName)
            .cast<CookingRecipe>() as Iterable<CookingRecipe>?),
        intListField: (state.uri.queryParametersAll['int-list-field']
                ?.map(int.parse)
                .cast<int>()
                ?.toList() as List<int>?)
            ?.toList(),
        doubleListField: (state.uri.queryParametersAll['double-list-field']
                ?.map(double.parse)
                .cast<double>()
                ?.toList() as List<double>?)
            ?.toList(),
        stringListField: (state.uri.queryParametersAll['string-list-field']
            ?.map((e) => e))?.toList(),
        boolListField: (state.uri.queryParametersAll['bool-list-field']
                ?.map(_$boolConverter)
                .cast<bool>()
                ?.toList() as List<bool>?)
            ?.toList(),
        enumListField: (state.uri.queryParametersAll['enum-list-field']
                ?.map(_$SportDetailsEnumMap._$fromName)
                .cast<SportDetails>()
                ?.toList() as List<SportDetails>?)
            ?.toList(),
        enumOnlyInListField: (state
                .uri.queryParametersAll['enum-only-in-list-field']
                ?.map(_$CookingRecipeEnumMap._$fromName)
                .cast<CookingRecipe>()
                ?.toList() as List<CookingRecipe>?)
            ?.toList(),
        intSetField: (state.uri.queryParametersAll['int-set-field']
                ?.map(int.parse)
                .cast<int>()
                ?.toSet() as Set<int>?)
            ?.toSet(),
        doubleSetField: (state.uri.queryParametersAll['double-set-field']
                ?.map(double.parse)
                .cast<double>()
                ?.toSet() as Set<double>?)
            ?.toSet(),
        stringSetField: (state.uri.queryParametersAll['string-set-field']
            ?.map((e) => e))?.toSet(),
        boolSetField: (state.uri.queryParametersAll['bool-set-field']
                ?.map(_$boolConverter)
                .cast<bool>()
                ?.toSet() as Set<bool>?)
            ?.toSet(),
        enumSetField: (state.uri.queryParametersAll['enum-set-field']
                ?.map(_$SportDetailsEnumMap._$fromName)
                .cast<SportDetails>()
                ?.toSet() as Set<SportDetails>?)
            ?.toSet(),
        enumOnlyInSetField: (state
                .uri.queryParametersAll['enum-only-in-set-field']
                ?.map(_$CookingRecipeEnumMap._$fromName)
                .cast<CookingRecipe>()
                ?.toSet() as Set<CookingRecipe>?)
            ?.toSet(),
      );

  IterableRoute get _self => this as IterableRoute;

  @override
  String get location => GoRouteData.$location(
        '/iterable-route',
        queryParams: {
          if (_self.intIterableField != null)
            'int-iterable-field':
                _self.intIterableField?.map((e) => e.toString()).toList(),
          if (_self.doubleIterableField != null)
            'double-iterable-field':
                _self.doubleIterableField?.map((e) => e.toString()).toList(),
          if (_self.stringIterableField != null)
            'string-iterable-field':
                _self.stringIterableField?.map((e) => e).toList(),
          if (_self.boolIterableField != null)
            'bool-iterable-field':
                _self.boolIterableField?.map((e) => e.toString()).toList(),
          if (_self.enumIterableField != null)
            'enum-iterable-field': _self.enumIterableField
                ?.map((e) => _$SportDetailsEnumMap[e])
                .toList(),
          if (_self.enumOnlyInIterableField != null)
            'enum-only-in-iterable-field': _self.enumOnlyInIterableField
                ?.map((e) => _$CookingRecipeEnumMap[e])
                .toList(),
          if (_self.intListField != null)
            'int-list-field':
                _self.intListField?.map((e) => e.toString()).toList(),
          if (_self.doubleListField != null)
            'double-list-field':
                _self.doubleListField?.map((e) => e.toString()).toList(),
          if (_self.stringListField != null)
            'string-list-field': _self.stringListField?.map((e) => e).toList(),
          if (_self.boolListField != null)
            'bool-list-field':
                _self.boolListField?.map((e) => e.toString()).toList(),
          if (_self.enumListField != null)
            'enum-list-field': _self.enumListField
                ?.map((e) => _$SportDetailsEnumMap[e])
                .toList(),
          if (_self.enumOnlyInListField != null)
            'enum-only-in-list-field': _self.enumOnlyInListField
                ?.map((e) => _$CookingRecipeEnumMap[e])
                .toList(),
          if (_self.intSetField != null)
            'int-set-field':
                _self.intSetField?.map((e) => e.toString()).toList(),
          if (_self.doubleSetField != null)
            'double-set-field':
                _self.doubleSetField?.map((e) => e.toString()).toList(),
          if (_self.stringSetField != null)
            'string-set-field': _self.stringSetField?.map((e) => e).toList(),
          if (_self.boolSetField != null)
            'bool-set-field':
                _self.boolSetField?.map((e) => e.toString()).toList(),
          if (_self.enumSetField != null)
            'enum-set-field': _self.enumSetField
                ?.map((e) => _$SportDetailsEnumMap[e])
                .toList(),
          if (_self.enumOnlyInSetField != null)
            'enum-only-in-set-field': _self.enumOnlyInSetField
                ?.map((e) => _$CookingRecipeEnumMap[e])
                .toList(),
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

const _$CookingRecipeEnumMap = {
  CookingRecipe.burger: 'burger',
  CookingRecipe.pizza: 'pizza',
  CookingRecipe.tacos: 'tacos',
};

mixin _$IterableRouteWithDefaultValues on GoRouteData {
  static IterableRouteWithDefaultValues _fromState(GoRouterState state) =>
      IterableRouteWithDefaultValues(
        intIterableField: (state.uri.queryParametersAll['int-iterable-field']
                ?.map(int.parse)
                .cast<int>() as Iterable<int>?) ??
            const <int>[0],
        doubleIterableField: (state
                .uri.queryParametersAll['double-iterable-field']
                ?.map(double.parse)
                .cast<double>() as Iterable<double>?) ??
            const <double>[0, 1, 2],
        stringIterableField: (state
                .uri.queryParametersAll['string-iterable-field']
                ?.map((e) => e)) ??
            const <String>['defaultValue'],
        boolIterableField: (state.uri.queryParametersAll['bool-iterable-field']
                ?.map(_$boolConverter)
                .cast<bool>() as Iterable<bool>?) ??
            const <bool>[false],
        enumIterableField: (state.uri.queryParametersAll['enum-iterable-field']
                ?.map(_$SportDetailsEnumMap._$fromName)
                .cast<SportDetails>() as Iterable<SportDetails>?) ??
            const <SportDetails>[SportDetails.tennis, SportDetails.hockey],
        intListField: (state.uri.queryParametersAll['int-list-field']
                    ?.map(int.parse)
                    .cast<int>()
                    ?.toList() as List<int>?)
                ?.toList() ??
            const <int>[0],
        doubleListField: (state.uri.queryParametersAll['double-list-field']
                    ?.map(double.parse)
                    .cast<double>()
                    ?.toList() as List<double>?)
                ?.toList() ??
            const <double>[1, 2, 3],
        stringListField: (state.uri.queryParametersAll['string-list-field']
                ?.map((e) => e))?.toList() ??
            const <String>['defaultValue0', 'defaultValue1'],
        boolListField: (state.uri.queryParametersAll['bool-list-field']
                    ?.map(_$boolConverter)
                    .cast<bool>()
                    ?.toList() as List<bool>?)
                ?.toList() ??
            const <bool>[true],
        enumListField: (state.uri.queryParametersAll['enum-list-field']
                    ?.map(_$SportDetailsEnumMap._$fromName)
                    .cast<SportDetails>()
                    ?.toList() as List<SportDetails>?)
                ?.toList() ??
            const <SportDetails>[SportDetails.football],
        intSetField: (state.uri.queryParametersAll['int-set-field']
                    ?.map(int.parse)
                    .cast<int>()
                    ?.toSet() as Set<int>?)
                ?.toSet() ??
            const <int>{0, 1},
        doubleSetField: (state.uri.queryParametersAll['double-set-field']
                    ?.map(double.parse)
                    .cast<double>()
                    ?.toSet() as Set<double>?)
                ?.toSet() ??
            const <double>{},
        stringSetField: (state.uri.queryParametersAll['string-set-field']
                ?.map((e) => e))?.toSet() ??
            const <String>{'defaultValue'},
        boolSetField: (state.uri.queryParametersAll['bool-set-field']
                    ?.map(_$boolConverter)
                    .cast<bool>()
                    ?.toSet() as Set<bool>?)
                ?.toSet() ??
            const <bool>{true, false},
        enumSetField: (state.uri.queryParametersAll['enum-set-field']
                    ?.map(_$SportDetailsEnumMap._$fromName)
                    .cast<SportDetails>()
                    ?.toSet() as Set<SportDetails>?)
                ?.toSet() ??
            const <SportDetails>{SportDetails.hockey},
      );

  IterableRouteWithDefaultValues get _self =>
      this as IterableRouteWithDefaultValues;

  @override
  String get location => GoRouteData.$location(
        '/iterable-route-with-default-values',
        queryParams: {
          if (!_$iterablesEqual(_self.intIterableField, const <int>[0]))
            'int-iterable-field':
                _self.intIterableField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(
              _self.doubleIterableField, const <double>[0, 1, 2]))
            'double-iterable-field':
                _self.doubleIterableField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(
              _self.stringIterableField, const <String>['defaultValue']))
            'string-iterable-field':
                _self.stringIterableField.map((e) => e).toList(),
          if (!_$iterablesEqual(_self.boolIterableField, const <bool>[false]))
            'bool-iterable-field':
                _self.boolIterableField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(_self.enumIterableField,
              const <SportDetails>[SportDetails.tennis, SportDetails.hockey]))
            'enum-iterable-field': _self.enumIterableField
                .map((e) => _$SportDetailsEnumMap[e])
                .toList(),
          if (!_$iterablesEqual(_self.intListField, const <int>[0]))
            'int-list-field':
                _self.intListField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(_self.doubleListField, const <double>[1, 2, 3]))
            'double-list-field':
                _self.doubleListField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(_self.stringListField,
              const <String>['defaultValue0', 'defaultValue1']))
            'string-list-field': _self.stringListField.map((e) => e).toList(),
          if (!_$iterablesEqual(_self.boolListField, const <bool>[true]))
            'bool-list-field':
                _self.boolListField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(
              _self.enumListField, const <SportDetails>[SportDetails.football]))
            'enum-list-field': _self.enumListField
                .map((e) => _$SportDetailsEnumMap[e])
                .toList(),
          if (!_$iterablesEqual(_self.intSetField, const <int>{0, 1}))
            'int-set-field':
                _self.intSetField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(_self.doubleSetField, const <double>{}))
            'double-set-field':
                _self.doubleSetField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(
              _self.stringSetField, const <String>{'defaultValue'}))
            'string-set-field': _self.stringSetField.map((e) => e).toList(),
          if (!_$iterablesEqual(_self.boolSetField, const <bool>{true, false}))
            'bool-set-field':
                _self.boolSetField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(
              _self.enumSetField, const <SportDetails>{SportDetails.hockey}))
            'enum-set-field': _self.enumSetField
                .map((e) => _$SportDetailsEnumMap[e])
                .toList(),
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

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
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
  T? _$fromName(String? value) =>
      entries.where((element) => element.value == value).firstOrNull?.key;
}

bool _$iterablesEqual<T>(Iterable<T>? iterable1, Iterable<T>? iterable2) {
  if (identical(iterable1, iterable2)) return true;
  if (iterable1 == null || iterable2 == null) return false;
  final iterator1 = iterable1.iterator;
  final iterator2 = iterable2.iterator;
  while (true) {
    final hasNext1 = iterator1.moveNext();
    final hasNext2 = iterator2.moveNext();
    if (hasNext1 != hasNext2) return false;
    if (!hasNext1) return true;
    if (iterator1.current != iterator2.current) return false;
  }
}

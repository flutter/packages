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
        GoRouteData.$route(
          path: 'iterable-route',
          factory: $IterableRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'iterable-route-with-default-values',
          factory: $IterableRouteWithDefaultValuesExtension._fromState,
        ),
      ],
    );

extension $AllTypesBaseRouteExtension on AllTypesBaseRoute {
  static AllTypesBaseRoute _fromState(GoRouterState state) =>
      const AllTypesBaseRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $BigIntRouteExtension on BigIntRoute {
  static BigIntRoute _fromState(GoRouterState state) => BigIntRoute(
        requiredBigIntField:
            BigInt.parse(state.pathParameters['requiredBigIntField']!)!,
        bigIntField: _$convertMapValue(
            'big-int-field', state.uri.queryParameters, BigInt.tryParse),
      );

  String get location => GoRouteData.$location(
        '/big-int-route/${Uri.encodeComponent(requiredBigIntField.toString())}',
        queryParams: {
          if (bigIntField != null) 'big-int-field': bigIntField!.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $BoolRouteExtension on BoolRoute {
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

  String get location => GoRouteData.$location(
        '/bool-route/${Uri.encodeComponent(requiredBoolField.toString())}',
        queryParams: {
          if (boolField != null) 'bool-field': boolField!.toString(),
          if (boolFieldWithDefaultValue != true)
            'bool-field-with-default-value':
                boolFieldWithDefaultValue.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $DateTimeRouteExtension on DateTimeRoute {
  static DateTimeRoute _fromState(GoRouterState state) => DateTimeRoute(
        requiredDateTimeField:
            DateTime.parse(state.pathParameters['requiredDateTimeField']!)!,
        dateTimeField: _$convertMapValue(
            'date-time-field', state.uri.queryParameters, DateTime.tryParse),
      );

  String get location => GoRouteData.$location(
        '/date-time-route/${Uri.encodeComponent(requiredDateTimeField.toString())}',
        queryParams: {
          if (dateTimeField != null)
            'date-time-field': dateTimeField!.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $DoubleRouteExtension on DoubleRoute {
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

  String get location => GoRouteData.$location(
        '/double-route/${Uri.encodeComponent(requiredDoubleField.toString())}',
        queryParams: {
          if (doubleField != null) 'double-field': doubleField!.toString(),
          if (doubleFieldWithDefaultValue != 1.0)
            'double-field-with-default-value':
                doubleFieldWithDefaultValue.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $IntRouteExtension on IntRoute {
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

  String get location => GoRouteData.$location(
        '/int-route/${Uri.encodeComponent(requiredIntField.toString())}',
        queryParams: {
          if (intField != null) 'int-field': intField!.toString(),
          if (intFieldWithDefaultValue != 1)
            'int-field-with-default-value': intFieldWithDefaultValue.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $NumRouteExtension on NumRoute {
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

  String get location => GoRouteData.$location(
        '/num-route/${Uri.encodeComponent(requiredNumField.toString())}',
        queryParams: {
          if (numField != null) 'num-field': numField!.toString(),
          if (numFieldWithDefaultValue != 1)
            'num-field-with-default-value': numFieldWithDefaultValue.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $EnumRouteExtension on EnumRoute {
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

  String get location => GoRouteData.$location(
        '/enum-route/${Uri.encodeComponent(_$PersonDetailsEnumMap[requiredEnumField]!)}',
        queryParams: {
          if (enumField != null)
            'enum-field': _$PersonDetailsEnumMap[enumField!],
          if (enumFieldWithDefaultValue != PersonDetails.favoriteFood)
            'enum-field-with-default-value':
                _$PersonDetailsEnumMap[enumFieldWithDefaultValue],
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

const _$PersonDetailsEnumMap = {
  PersonDetails.hobbies: 'hobbies',
  PersonDetails.favoriteFood: 'favorite-food',
  PersonDetails.favoriteSport: 'favorite-sport',
};

extension $EnhancedEnumRouteExtension on EnhancedEnumRoute {
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

  String get location => GoRouteData.$location(
        '/enhanced-enum-route/${Uri.encodeComponent(_$SportDetailsEnumMap[requiredEnumField]!)}',
        queryParams: {
          if (enumField != null)
            'enum-field': _$SportDetailsEnumMap[enumField!],
          if (enumFieldWithDefaultValue != SportDetails.football)
            'enum-field-with-default-value':
                _$SportDetailsEnumMap[enumFieldWithDefaultValue],
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

const _$SportDetailsEnumMap = {
  SportDetails.volleyball: 'volleyball',
  SportDetails.football: 'football',
  SportDetails.tennis: 'tennis',
  SportDetails.hockey: 'hockey',
};

extension $StringRouteExtension on StringRoute {
  static StringRoute _fromState(GoRouterState state) => StringRoute(
        requiredStringField: state.pathParameters['requiredStringField']!,
        stringField: state.uri.queryParameters['string-field'],
        stringFieldWithDefaultValue:
            state.uri.queryParameters['string-field-with-default-value'] ??
                'defaultValue',
      );

  String get location => GoRouteData.$location(
        '/string-route/${Uri.encodeComponent(requiredStringField)}',
        queryParams: {
          if (stringField != null) 'string-field': stringField,
          if (stringFieldWithDefaultValue != 'defaultValue')
            'string-field-with-default-value': stringFieldWithDefaultValue,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $UriRouteExtension on UriRoute {
  static UriRoute _fromState(GoRouterState state) => UriRoute(
        requiredUriField: Uri.parse(state.pathParameters['requiredUriField']!)!,
        uriField: _$convertMapValue(
            'uri-field', state.uri.queryParameters, Uri.tryParse),
      );

  String get location => GoRouteData.$location(
        '/uri-route/${Uri.encodeComponent(requiredUriField.toString())}',
        queryParams: {
          if (uriField != null) 'uri-field': uriField!.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $IterableRouteExtension on IterableRoute {
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

  String get location => GoRouteData.$location(
        '/iterable-route',
        queryParams: {
          if (intIterableField != null)
            'int-iterable-field':
                intIterableField?.map((e) => e.toString()).toList(),
          if (doubleIterableField != null)
            'double-iterable-field':
                doubleIterableField?.map((e) => e.toString()).toList(),
          if (stringIterableField != null)
            'string-iterable-field':
                stringIterableField?.map((e) => e).toList(),
          if (boolIterableField != null)
            'bool-iterable-field':
                boolIterableField?.map((e) => e.toString()).toList(),
          if (enumIterableField != null)
            'enum-iterable-field': enumIterableField
                ?.map((e) => _$SportDetailsEnumMap[e])
                .toList(),
          if (enumOnlyInIterableField != null)
            'enum-only-in-iterable-field': enumOnlyInIterableField
                ?.map((e) => _$CookingRecipeEnumMap[e])
                .toList(),
          if (intListField != null)
            'int-list-field': intListField?.map((e) => e.toString()).toList(),
          if (doubleListField != null)
            'double-list-field':
                doubleListField?.map((e) => e.toString()).toList(),
          if (stringListField != null)
            'string-list-field': stringListField?.map((e) => e).toList(),
          if (boolListField != null)
            'bool-list-field': boolListField?.map((e) => e.toString()).toList(),
          if (enumListField != null)
            'enum-list-field':
                enumListField?.map((e) => _$SportDetailsEnumMap[e]).toList(),
          if (enumOnlyInListField != null)
            'enum-only-in-list-field': enumOnlyInListField
                ?.map((e) => _$CookingRecipeEnumMap[e])
                .toList(),
          if (intSetField != null)
            'int-set-field': intSetField?.map((e) => e.toString()).toList(),
          if (doubleSetField != null)
            'double-set-field':
                doubleSetField?.map((e) => e.toString()).toList(),
          if (stringSetField != null)
            'string-set-field': stringSetField?.map((e) => e).toList(),
          if (boolSetField != null)
            'bool-set-field': boolSetField?.map((e) => e.toString()).toList(),
          if (enumSetField != null)
            'enum-set-field':
                enumSetField?.map((e) => _$SportDetailsEnumMap[e]).toList(),
          if (enumOnlyInSetField != null)
            'enum-only-in-set-field': enumOnlyInSetField
                ?.map((e) => _$CookingRecipeEnumMap[e])
                .toList(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

const _$CookingRecipeEnumMap = {
  CookingRecipe.burger: 'burger',
  CookingRecipe.pizza: 'pizza',
  CookingRecipe.tacos: 'tacos',
};

extension $IterableRouteWithDefaultValuesExtension
    on IterableRouteWithDefaultValues {
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

  String get location => GoRouteData.$location(
        '/iterable-route-with-default-values',
        queryParams: {
          if (!_$iterablesEqual(intIterableField, const <int>[0]))
            'int-iterable-field':
                intIterableField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(doubleIterableField, const <double>[0, 1, 2]))
            'double-iterable-field':
                doubleIterableField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(
              stringIterableField, const <String>['defaultValue']))
            'string-iterable-field': stringIterableField.map((e) => e).toList(),
          if (!_$iterablesEqual(boolIterableField, const <bool>[false]))
            'bool-iterable-field':
                boolIterableField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(enumIterableField,
              const <SportDetails>[SportDetails.tennis, SportDetails.hockey]))
            'enum-iterable-field':
                enumIterableField.map((e) => _$SportDetailsEnumMap[e]).toList(),
          if (!_$iterablesEqual(intListField, const <int>[0]))
            'int-list-field': intListField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(doubleListField, const <double>[1, 2, 3]))
            'double-list-field':
                doubleListField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(stringListField,
              const <String>['defaultValue0', 'defaultValue1']))
            'string-list-field': stringListField.map((e) => e).toList(),
          if (!_$iterablesEqual(boolListField, const <bool>[true]))
            'bool-list-field': boolListField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(
              enumListField, const <SportDetails>[SportDetails.football]))
            'enum-list-field':
                enumListField.map((e) => _$SportDetailsEnumMap[e]).toList(),
          if (!_$iterablesEqual(intSetField, const <int>{0, 1}))
            'int-set-field': intSetField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(doubleSetField, const <double>{}))
            'double-set-field':
                doubleSetField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(stringSetField, const <String>{'defaultValue'}))
            'string-set-field': stringSetField.map((e) => e).toList(),
          if (!_$iterablesEqual(boolSetField, const <bool>{true, false}))
            'bool-set-field': boolSetField.map((e) => e.toString()).toList(),
          if (!_$iterablesEqual(
              enumSetField, const <SportDetails>{SportDetails.hockey}))
            'enum-set-field':
                enumSetField.map((e) => _$SportDetailsEnumMap[e]).toList(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

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

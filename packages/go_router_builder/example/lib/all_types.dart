// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, unreachable_from_main

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/data.dart';

part 'all_types.g.dart';

@TypedGoRoute<AllTypesBaseRoute>(path: '/', routes: <TypedGoRoute<GoRouteData>>[
  TypedGoRoute<BigIntRoute>(path: 'big-int-route/:requiredBigIntField'),
  TypedGoRoute<BoolRoute>(path: 'bool-route/:requiredBoolField'),
  TypedGoRoute<DateTimeRoute>(path: 'date-time-route/:requiredDateTimeField'),
  TypedGoRoute<DoubleRoute>(path: 'double-route/:requiredDoubleField'),
  TypedGoRoute<IntRoute>(path: 'int-route/:requiredIntField'),
  TypedGoRoute<NumRoute>(path: 'num-route/:requiredNumField'),
  TypedGoRoute<DoubleRoute>(path: 'double-route/:requiredDoubleField'),
  TypedGoRoute<EnumRoute>(path: 'enum-route/:requiredEnumField'),
  TypedGoRoute<EnhancedEnumRoute>(
      path: 'enhanced-enum-route/:requiredEnumField'),
  TypedGoRoute<StringRoute>(path: 'string-route/:requiredStringField'),
  TypedGoRoute<UriRoute>(path: 'uri-route/:requiredUriField'),
  TypedGoRoute<IterableRoute>(path: 'iterable-route'),
  TypedGoRoute<IterableRouteWithDefaultValues>(
      path: 'iterable-route-with-default-values'),
])
@immutable
class AllTypesBaseRoute extends GoRouteData with _$AllTypesBaseRoute {
  const AllTypesBaseRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BasePage<void>(
        dataTitle: 'Root',
      );
}

class BigIntRoute extends GoRouteData with _$BigIntRoute {
  BigIntRoute({
    required this.requiredBigIntField,
    this.bigIntField,
  });

  final BigInt requiredBigIntField;
  final BigInt? bigIntField;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<BigInt>(
        dataTitle: 'BigIntRoute',
        param: requiredBigIntField,
        queryParam: bigIntField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('BigIntRoute'),
        onTap: () => go(context),
        selected: GoRouterState.of(context).uri.path == location,
      );
}

class BoolRoute extends GoRouteData with _$BoolRoute {
  BoolRoute({
    required this.requiredBoolField,
    this.boolField,
    this.boolFieldWithDefaultValue = true,
  });

  final bool requiredBoolField;
  final bool? boolField;
  final bool boolFieldWithDefaultValue;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<bool>(
        dataTitle: 'BoolRoute',
        param: requiredBoolField,
        queryParam: boolField,
        queryParamWithDefaultValue: boolFieldWithDefaultValue,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('BoolRoute'),
        onTap: () => go(context),
        selected: GoRouterState.of(context).uri.path == location,
      );
}

class DateTimeRoute extends GoRouteData with _$DateTimeRoute {
  DateTimeRoute({
    required this.requiredDateTimeField,
    this.dateTimeField,
  });

  final DateTime requiredDateTimeField;
  final DateTime? dateTimeField;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<DateTime>(
        dataTitle: 'DateTimeRoute',
        param: requiredDateTimeField,
        queryParam: dateTimeField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('DateTimeRoute'),
        onTap: () => go(context),
        selected: GoRouterState.of(context).uri.path == location,
      );
}

class DoubleRoute extends GoRouteData with _$DoubleRoute {
  DoubleRoute({
    required this.requiredDoubleField,
    this.doubleField,
    this.doubleFieldWithDefaultValue = 1.0,
  });

  final double requiredDoubleField;
  final double? doubleField;
  final double doubleFieldWithDefaultValue;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<double>(
        dataTitle: 'DoubleRoute',
        param: requiredDoubleField,
        queryParam: doubleField,
        queryParamWithDefaultValue: doubleFieldWithDefaultValue,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('DoubleRoute'),
        onTap: () => go(context),
        selected: GoRouterState.of(context).uri.path == location,
      );
}

class IntRoute extends GoRouteData with _$IntRoute {
  IntRoute({
    required this.requiredIntField,
    this.intField,
    this.intFieldWithDefaultValue = 1,
  });

  final int requiredIntField;
  final int? intField;
  final int intFieldWithDefaultValue;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<int>(
        dataTitle: 'IntRoute',
        param: requiredIntField,
        queryParam: intField,
        queryParamWithDefaultValue: intFieldWithDefaultValue,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('IntRoute'),
        onTap: () => go(context),
        selected: GoRouterState.of(context).uri.path == location,
      );
}

class NumRoute extends GoRouteData with _$NumRoute {
  NumRoute({
    required this.requiredNumField,
    this.numField,
    this.numFieldWithDefaultValue = 1,
  });

  final num requiredNumField;
  final num? numField;
  final num numFieldWithDefaultValue;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<num>(
        dataTitle: 'NumRoute',
        param: requiredNumField,
        queryParam: numField,
        queryParamWithDefaultValue: numFieldWithDefaultValue,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('NumRoute'),
        onTap: () => go(context),
        selected: GoRouterState.of(context).uri.path == location,
      );
}

class EnumRoute extends GoRouteData with _$EnumRoute {
  EnumRoute({
    required this.requiredEnumField,
    this.enumField,
    this.enumFieldWithDefaultValue = PersonDetails.favoriteFood,
  });

  final PersonDetails requiredEnumField;
  final PersonDetails? enumField;
  final PersonDetails enumFieldWithDefaultValue;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BasePage<PersonDetails>(
        dataTitle: 'EnumRoute',
        param: requiredEnumField,
        queryParam: enumField,
        queryParamWithDefaultValue: enumFieldWithDefaultValue,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('EnumRoute'),
        onTap: () => go(context),
        selected: GoRouterState.of(context).uri.path == location,
      );
}

class EnhancedEnumRoute extends GoRouteData with _$EnhancedEnumRoute {
  EnhancedEnumRoute({
    required this.requiredEnumField,
    this.enumField,
    this.enumFieldWithDefaultValue = SportDetails.football,
  });

  final SportDetails requiredEnumField;
  final SportDetails? enumField;
  final SportDetails enumFieldWithDefaultValue;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BasePage<SportDetails>(
        dataTitle: 'EnhancedEnumRoute',
        param: requiredEnumField,
        queryParam: enumField,
        queryParamWithDefaultValue: enumFieldWithDefaultValue,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('EnhancedEnumRoute'),
        onTap: () => go(context),
        selected: GoRouterState.of(context).uri.path == location,
      );
}

class StringRoute extends GoRouteData with _$StringRoute {
  StringRoute({
    required this.requiredStringField,
    this.stringField,
    this.stringFieldWithDefaultValue = 'defaultValue',
  });

  final String requiredStringField;
  final String? stringField;
  final String stringFieldWithDefaultValue;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<String>(
        dataTitle: 'StringRoute',
        param: requiredStringField,
        queryParam: stringField,
        queryParamWithDefaultValue: stringFieldWithDefaultValue,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('StringRoute'),
        onTap: () => go(context),
        selected: GoRouterState.of(context).uri.path == location,
      );
}

class UriRoute extends GoRouteData with _$UriRoute {
  UriRoute({
    required this.requiredUriField,
    this.uriField,
  });

  final Uri requiredUriField;
  final Uri? uriField;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<Uri>(
        dataTitle: 'UriRoute',
        param: requiredUriField,
        queryParam: uriField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('UriRoute'),
        onTap: () => go(context),
        selected: GoRouterState.of(context).uri.path == location,
      );
}

class IterableRoute extends GoRouteData with _$IterableRoute {
  IterableRoute({
    this.intIterableField,
    this.doubleIterableField,
    this.stringIterableField,
    this.boolIterableField,
    this.enumIterableField,
    this.enumOnlyInIterableField,
    this.intListField,
    this.doubleListField,
    this.stringListField,
    this.boolListField,
    this.enumListField,
    this.enumOnlyInListField,
    this.intSetField,
    this.doubleSetField,
    this.stringSetField,
    this.boolSetField,
    this.enumSetField,
    this.enumOnlyInSetField,
  });

  final Iterable<int>? intIterableField;
  final List<int>? intListField;
  final Set<int>? intSetField;

  final Iterable<double>? doubleIterableField;
  final List<double>? doubleListField;
  final Set<double>? doubleSetField;

  final Iterable<String>? stringIterableField;
  final List<String>? stringListField;
  final Set<String>? stringSetField;

  final Iterable<bool>? boolIterableField;
  final List<bool>? boolListField;
  final Set<bool>? boolSetField;

  final Iterable<SportDetails>? enumIterableField;
  final List<SportDetails>? enumListField;
  final Set<SportDetails>? enumSetField;

  final Iterable<CookingRecipe>? enumOnlyInIterableField;
  final List<CookingRecipe>? enumOnlyInListField;
  final Set<CookingRecipe>? enumOnlyInSetField;

  @override
  Widget build(BuildContext context, GoRouterState state) => IterablePage(
        dataTitle: 'IterableRoute',
        intIterableField: intIterableField,
        doubleIterableField: doubleIterableField,
        stringIterableField: stringIterableField,
        boolIterableField: boolIterableField,
        enumIterableField: enumIterableField,
        intListField: intListField,
        doubleListField: doubleListField,
        stringListField: stringListField,
        boolListField: boolListField,
        enumListField: enumListField,
        intSetField: intSetField,
        doubleSetField: doubleSetField,
        stringSetField: stringSetField,
        boolSetField: boolSetField,
        enumSetField: enumSetField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('IterableRoute'),
        onTap: () => go(context),
        selected: GoRouterState.of(context).uri.path == location,
      );
}

class IterableRouteWithDefaultValues extends GoRouteData
    with _$IterableRouteWithDefaultValues {
  const IterableRouteWithDefaultValues({
    this.intIterableField = const <int>[0],
    this.doubleIterableField = const <double>[0, 1, 2],
    this.stringIterableField = const <String>['defaultValue'],
    this.boolIterableField = const <bool>[false],
    this.enumIterableField = const <SportDetails>[
      SportDetails.tennis,
      SportDetails.hockey,
    ],
    this.intListField = const <int>[0],
    this.doubleListField = const <double>[1, 2, 3],
    this.stringListField = const <String>['defaultValue0', 'defaultValue1'],
    this.boolListField = const <bool>[true],
    this.enumListField = const <SportDetails>[SportDetails.football],
    this.intSetField = const <int>{0, 1},
    this.doubleSetField = const <double>{},
    this.stringSetField = const <String>{'defaultValue'},
    this.boolSetField = const <bool>{true, false},
    this.enumSetField = const <SportDetails>{SportDetails.hockey},
  });

  final Iterable<int> intIterableField;
  final List<int> intListField;
  final Set<int> intSetField;

  final Iterable<double> doubleIterableField;
  final List<double> doubleListField;
  final Set<double> doubleSetField;

  final Iterable<String> stringIterableField;
  final List<String> stringListField;
  final Set<String> stringSetField;

  final Iterable<bool> boolIterableField;
  final List<bool> boolListField;
  final Set<bool> boolSetField;

  final Iterable<SportDetails> enumIterableField;
  final List<SportDetails> enumListField;
  final Set<SportDetails> enumSetField;

  @override
  Widget build(BuildContext context, GoRouterState state) => IterablePage(
        dataTitle: 'IterableRouteWithDefaultValues',
        intIterableField: intIterableField,
        doubleIterableField: doubleIterableField,
        stringIterableField: stringIterableField,
        boolIterableField: boolIterableField,
        enumIterableField: enumIterableField,
        intListField: intListField,
        doubleListField: doubleListField,
        stringListField: stringListField,
        boolListField: boolListField,
        enumListField: enumListField,
        intSetField: intSetField,
        doubleSetField: doubleSetField,
        stringSetField: stringSetField,
        boolSetField: boolSetField,
        enumSetField: enumSetField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('IterableRouteWithDefaultValues'),
        onTap: () => go(context),
        selected: GoRouterState.of(context).uri.path == location,
      );
}

class BasePage<T> extends StatelessWidget {
  const BasePage({
    required this.dataTitle,
    this.param,
    this.queryParam,
    this.queryParamWithDefaultValue,
    super.key,
  });

  final String dataTitle;
  final T? param;
  final T? queryParam;
  final T? queryParamWithDefaultValue;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Go router typed routes'),
        ),
        drawer: Drawer(
            child: ListView(
          children: <Widget>[
            BigIntRoute(
              requiredBigIntField: BigInt.two,
              bigIntField: BigInt.zero,
            ).drawerTile(context),
            BoolRoute(
              requiredBoolField: true,
              boolField: false,
            ).drawerTile(context),
            DateTimeRoute(
              requiredDateTimeField: DateTime(1970),
              dateTimeField: DateTime(0),
            ).drawerTile(context),
            DoubleRoute(
              requiredDoubleField: 3.14,
              doubleField: -3.14,
            ).drawerTile(context),
            IntRoute(
              requiredIntField: 42,
              intField: -42,
            ).drawerTile(context),
            NumRoute(
              requiredNumField: 2.71828,
              numField: -2.71828,
            ).drawerTile(context),
            StringRoute(
              requiredStringField: r'$!/#bob%%20',
              stringField: r'$!/#bob%%20',
            ).drawerTile(context),
            EnumRoute(
              requiredEnumField: PersonDetails.favoriteSport,
              enumField: PersonDetails.favoriteFood,
            ).drawerTile(context),
            EnhancedEnumRoute(
              requiredEnumField: SportDetails.football,
              enumField: SportDetails.volleyball,
            ).drawerTile(context),
            UriRoute(
              requiredUriField: Uri.parse('https://dart.dev'),
              uriField: Uri.parse('https://dart.dev'),
            ).drawerTile(context),
            IterableRoute(
              intIterableField: <int>[1, 2, 3],
              doubleIterableField: <double>[.3, .4, .5],
              stringIterableField: <String>['quo usque tandem'],
              boolIterableField: <bool>[true, false, false],
              enumIterableField: <SportDetails>[
                SportDetails.football,
                SportDetails.hockey,
              ],
              intListField: <int>[1, 2, 3],
              doubleListField: <double>[.3, .4, .5],
              stringListField: <String>['quo usque tandem'],
              boolListField: <bool>[true, false, false],
              enumListField: <SportDetails>[
                SportDetails.football,
                SportDetails.hockey,
              ],
              intSetField: <int>{1, 2, 3},
              doubleSetField: <double>{.3, .4, .5},
              stringSetField: <String>{'quo usque tandem'},
              boolSetField: <bool>{true, false},
              enumSetField: <SportDetails>{
                SportDetails.football,
                SportDetails.hockey,
              },
            ).drawerTile(context),
            const IterableRouteWithDefaultValues().drawerTile(context),
          ],
        )),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Built!'),
              Text(dataTitle),
              Text('Param: $param'),
              Text('Query param: $queryParam'),
              Text(
                'Query param with default value: $queryParamWithDefaultValue',
              ),
              SelectableText(GoRouterState.of(context).uri.path),
              SelectableText(
                  GoRouterState.of(context).uri.queryParameters.toString()),
            ],
          ),
        ),
      );
}

void main() => runApp(AllTypesApp());

class AllTypesApp extends StatelessWidget {
  AllTypesApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: _router,
      );

  late final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    routes: $appRoutes,
    initialLocation: const AllTypesBaseRoute().location,
  );
}

class IterablePage extends StatelessWidget {
  const IterablePage({
    required this.dataTitle,
    this.intIterableField,
    this.doubleIterableField,
    this.stringIterableField,
    this.boolIterableField,
    this.enumIterableField,
    this.intListField,
    this.doubleListField,
    this.stringListField,
    this.boolListField,
    this.enumListField,
    this.intSetField,
    this.doubleSetField,
    this.stringSetField,
    this.boolSetField,
    this.enumSetField,
    super.key,
  });

  final String dataTitle;

  final Iterable<int>? intIterableField;
  final List<int>? intListField;
  final Set<int>? intSetField;

  final Iterable<double>? doubleIterableField;
  final List<double>? doubleListField;
  final Set<double>? doubleSetField;

  final Iterable<String>? stringIterableField;
  final List<String>? stringListField;
  final Set<String>? stringSetField;

  final Iterable<bool>? boolIterableField;
  final List<bool>? boolListField;
  final Set<bool>? boolSetField;

  final Iterable<SportDetails>? enumIterableField;
  final List<SportDetails>? enumListField;
  final Set<SportDetails>? enumSetField;

  @override
  Widget build(BuildContext context) {
    return BasePage<String>(
      dataTitle: dataTitle,
      queryParamWithDefaultValue: <String, Iterable<dynamic>?>{
        'intIterableField': intIterableField,
        'intListField': intListField,
        'intSetField': intSetField,
        'doubleIterableField': doubleIterableField,
        'doubleListField': doubleListField,
        'doubleSetField': doubleSetField,
        'stringIterableField': stringIterableField,
        'stringListField': stringListField,
        'stringSetField': stringSetField,
        'boolIterableField': boolIterableField,
        'boolListField': boolListField,
        'boolSetField': boolSetField,
        'enumIterableField': enumIterableField,
        'enumListField': enumListField,
        'enumSetField': enumSetField,
      }.toString(),
    );
  }
}

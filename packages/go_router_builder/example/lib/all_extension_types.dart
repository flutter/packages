// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, unreachable_from_main

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/data.dart';

part 'all_extension_types.g.dart';

@TypedGoRoute<AllTypesBaseRoute>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<BigIntExtensionRoute>(
      path: 'big-int-route/:requiredBigIntField',
    ),
    TypedGoRoute<BoolExtensionRoute>(path: 'bool-route/:requiredBoolField'),
    TypedGoRoute<DateTimeExtensionRoute>(
      path: 'date-time-route/:requiredDateTimeField',
    ),
    TypedGoRoute<DoubleExtensionRoute>(
      path: 'double-route/:requiredDoubleField',
    ),
    TypedGoRoute<IntExtensionRoute>(path: 'int-route/:requiredIntField'),
    TypedGoRoute<NumExtensionRoute>(path: 'num-route/:requiredNumField'),
    TypedGoRoute<DoubleExtensionRoute>(
      path: 'double-route/:requiredDoubleField',
    ),
    TypedGoRoute<EnumExtensionRoute>(path: 'enum-route/:requiredEnumField'),
    TypedGoRoute<EnhancedEnumExtensionRoute>(
      path: 'enhanced-enum-route/:requiredEnumField',
    ),
    TypedGoRoute<StringExtensionRoute>(
      path: 'string-route/:requiredStringField',
    ),
    TypedGoRoute<UriExtensionRoute>(path: 'uri-route/:requiredUriField'),
  ],
)
@immutable
class AllTypesBaseRoute extends GoRouteData with $AllTypesBaseRoute {
  const AllTypesBaseRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BasePage<void>(dataTitle: 'Root');
}

extension type const BigIntExtension(BigInt value) {}
extension type const BoolExtension(bool value) {}
extension type const DateTimeExtension(DateTime value) {}
extension type const DoubleExtension(double value) {}
extension type const IntExtension(int value) {}
extension type const NumExtension(num value) {}
extension type const StringExtension(String value) {}
extension type const UriExtension(Uri value) {}
extension type const PersonDetailsExtension(PersonDetails value) {}
extension type const SportDetailsExtension(SportDetails value) {}

class BigIntExtensionRoute extends GoRouteData with $BigIntExtensionRoute {
  const BigIntExtensionRoute({
    required this.requiredBigIntField,
    this.bigIntField,
  });

  final BigIntExtension requiredBigIntField;
  final BigIntExtension? bigIntField;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<BigInt>(
    dataTitle: 'BigIntExtensionRoute',
    param: requiredBigIntField.value,
    queryParam: bigIntField?.value,
  );

  Widget drawerTile(BuildContext context) => ListTile(
    title: const Text('BigIntExtensionRoute'),
    onTap: () => go(context),
    selected: GoRouterState.of(context).uri.path == location,
  );
}

class BoolExtensionRoute extends GoRouteData with $BoolExtensionRoute {
  const BoolExtensionRoute({
    required this.requiredBoolField,
    this.boolField,
    this.boolFieldWithDefaultValue = const BoolExtension(true),
  });

  final BoolExtension requiredBoolField;
  final BoolExtension? boolField;
  final BoolExtension boolFieldWithDefaultValue;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<bool>(
    dataTitle: 'BoolExtensionRoute',
    param: requiredBoolField.value,
    queryParam: boolField?.value,
    queryParamWithDefaultValue: boolFieldWithDefaultValue.value,
  );

  Widget drawerTile(BuildContext context) => ListTile(
    title: const Text('BoolExtensionRoute'),
    onTap: () => go(context),
    selected: GoRouterState.of(context).uri.path == location,
  );
}

class DateTimeExtensionRoute extends GoRouteData with $DateTimeExtensionRoute {
  const DateTimeExtensionRoute({
    required this.requiredDateTimeField,
    this.dateTimeField,
  });

  final DateTimeExtension requiredDateTimeField;
  final DateTimeExtension? dateTimeField;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<DateTime>(
    dataTitle: 'DateTimeExtensionRoute',
    param: requiredDateTimeField.value,
    queryParam: dateTimeField?.value,
  );

  Widget drawerTile(BuildContext context) => ListTile(
    title: const Text('DateTimeExtensionRoute'),
    onTap: () => go(context),
    selected: GoRouterState.of(context).uri.path == location,
  );
}

class DoubleExtensionRoute extends GoRouteData with $DoubleExtensionRoute {
  const DoubleExtensionRoute({
    required this.requiredDoubleField,
    this.doubleField,
    this.doubleFieldWithDefaultValue = const DoubleExtension(1.0),
  });

  final DoubleExtension requiredDoubleField;
  final DoubleExtension? doubleField;
  final DoubleExtension doubleFieldWithDefaultValue;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<double>(
    dataTitle: 'DoubleExtensionRoute',
    param: requiredDoubleField.value,
    queryParam: doubleField?.value,
    queryParamWithDefaultValue: doubleFieldWithDefaultValue.value,
  );

  Widget drawerTile(BuildContext context) => ListTile(
    title: const Text('DoubleExtensionRoute'),
    onTap: () => go(context),
    selected: GoRouterState.of(context).uri.path == location,
  );
}

class IntExtensionRoute extends GoRouteData with $IntExtensionRoute {
  const IntExtensionRoute({
    required this.requiredIntField,
    this.intField,
    this.intFieldWithDefaultValue = const IntExtension(1),
  });

  final IntExtension requiredIntField;
  final IntExtension? intField;
  final IntExtension intFieldWithDefaultValue;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<int>(
    dataTitle: 'IntExtensionRoute',
    param: requiredIntField.value,
    queryParam: intField?.value,
    queryParamWithDefaultValue: intFieldWithDefaultValue.value,
  );

  Widget drawerTile(BuildContext context) => ListTile(
    title: const Text('IntExtensionRoute'),
    onTap: () => go(context),
    selected: GoRouterState.of(context).uri.path == location,
  );
}

class NumExtensionRoute extends GoRouteData with $NumExtensionRoute {
  const NumExtensionRoute({
    required this.requiredNumField,
    this.numField,
    this.numFieldWithDefaultValue = const NumExtension(1),
  });

  final NumExtension requiredNumField;
  final NumExtension? numField;
  final NumExtension numFieldWithDefaultValue;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<num>(
    dataTitle: 'NumExtensionRoute',
    param: requiredNumField.value,
    queryParam: numField?.value,
    queryParamWithDefaultValue: numFieldWithDefaultValue.value,
  );

  Widget drawerTile(BuildContext context) => ListTile(
    title: const Text('NumExtensionRoute'),
    onTap: () => go(context),
    selected: GoRouterState.of(context).uri.path == location,
  );
}

class EnumExtensionRoute extends GoRouteData with $EnumExtensionRoute {
  const EnumExtensionRoute({
    required this.requiredEnumField,
    this.enumField,
    this.enumFieldWithDefaultValue = const PersonDetailsExtension(
      PersonDetails.favoriteFood,
    ),
  });

  final PersonDetailsExtension requiredEnumField;
  final PersonDetailsExtension? enumField;
  final PersonDetailsExtension enumFieldWithDefaultValue;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BasePage<PersonDetails>(
        dataTitle: 'EnumExtensionRoute',
        param: requiredEnumField.value,
        queryParam: enumField?.value,
        queryParamWithDefaultValue: enumFieldWithDefaultValue.value,
      );

  Widget drawerTile(BuildContext context) => ListTile(
    title: const Text('EnumExtensionRoute'),
    onTap: () => go(context),
    selected: GoRouterState.of(context).uri.path == location,
  );
}

class EnhancedEnumExtensionRoute extends GoRouteData
    with $EnhancedEnumExtensionRoute {
  const EnhancedEnumExtensionRoute({
    required this.requiredEnumField,
    this.enumField,
    this.enumFieldWithDefaultValue = const SportDetailsExtension(
      SportDetails.football,
    ),
  });

  final SportDetailsExtension requiredEnumField;
  final SportDetailsExtension? enumField;
  final SportDetailsExtension enumFieldWithDefaultValue;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BasePage<SportDetails>(
        dataTitle: 'EnhancedEnumExtensionRoute',
        param: requiredEnumField.value,
        queryParam: enumField?.value,
        queryParamWithDefaultValue: enumFieldWithDefaultValue.value,
      );

  Widget drawerTile(BuildContext context) => ListTile(
    title: const Text('EnhancedEnumExtensionRoute'),
    onTap: () => go(context),
    selected: GoRouterState.of(context).uri.path == location,
  );
}

class StringExtensionRoute extends GoRouteData with $StringExtensionRoute {
  const StringExtensionRoute({
    required this.requiredStringField,
    this.stringField,
    this.stringFieldWithDefaultValue = const StringExtension('defaultValue'),
  });

  final StringExtension requiredStringField;
  final StringExtension? stringField;
  final StringExtension stringFieldWithDefaultValue;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<String>(
    dataTitle: 'StringExtensionRoute',
    param: requiredStringField.value,
    queryParam: stringField?.value,
    queryParamWithDefaultValue: stringFieldWithDefaultValue.value,
  );

  Widget drawerTile(BuildContext context) => ListTile(
    title: const Text('StringExtensionRoute'),
    onTap: () => go(context),
    selected: GoRouterState.of(context).uri.path == location,
  );
}

class UriExtensionRoute extends GoRouteData with $UriExtensionRoute {
  const UriExtensionRoute({required this.requiredUriField, this.uriField});

  final UriExtension requiredUriField;
  final UriExtension? uriField;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<Uri>(
    dataTitle: 'UriExtensionRoute',
    param: requiredUriField.value,
    queryParam: uriField?.value,
  );

  Widget drawerTile(BuildContext context) => ListTile(
    title: const Text('UriExtensionRoute'),
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
    appBar: AppBar(title: const Text('Go router extension types')),
    drawer: Drawer(
      child: ListView(
        children: <Widget>[
          BigIntExtensionRoute(
            requiredBigIntField: BigIntExtension(BigInt.two),
            bigIntField: BigIntExtension(BigInt.zero),
          ).drawerTile(context),
          const BoolExtensionRoute(
            requiredBoolField: BoolExtension(true),
            boolField: BoolExtension(false),
          ).drawerTile(context),
          DateTimeExtensionRoute(
            requiredDateTimeField: DateTimeExtension(DateTime(1970)),
            dateTimeField: DateTimeExtension(DateTime(0)),
          ).drawerTile(context),
          const DoubleExtensionRoute(
            requiredDoubleField: DoubleExtension(3.14),
            doubleField: DoubleExtension(-3.14),
          ).drawerTile(context),
          const IntExtensionRoute(
            requiredIntField: IntExtension(42),
            intField: IntExtension(-42),
          ).drawerTile(context),
          const NumExtensionRoute(
            requiredNumField: NumExtension(2.71828),
            numField: NumExtension(-2.71828),
          ).drawerTile(context),
          const StringExtensionRoute(
            requiredStringField: StringExtension(r'$!/#bob%%20'),
            stringField: StringExtension(r'$!/#bob%%20'),
          ).drawerTile(context),
          const EnumExtensionRoute(
            requiredEnumField: PersonDetailsExtension(
              PersonDetails.favoriteSport,
            ),
            enumField: PersonDetailsExtension(PersonDetails.favoriteFood),
          ).drawerTile(context),
          const EnhancedEnumExtensionRoute(
            requiredEnumField: SportDetailsExtension(SportDetails.football),
            enumField: SportDetailsExtension(SportDetails.volleyball),
          ).drawerTile(context),
          UriExtensionRoute(
            requiredUriField: UriExtension(Uri.parse('https://dart.dev')),
            uriField: UriExtension(Uri.parse('https://dart.dev')),
          ).drawerTile(context),
        ],
      ),
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Built with Extension Types!'),
          Text(dataTitle),
          Text('Param: $param'),
          Text('Query param: $queryParam'),
          Text('Query param with default value: $queryParamWithDefaultValue'),
          SelectableText(GoRouterState.of(context).uri.path),
          SelectableText(
            GoRouterState.of(context).uri.queryParameters.toString(),
          ),
        ],
      ),
    ),
  );
}

void main() => runApp(AllExtensionTypesApp());

class AllExtensionTypesApp extends StatelessWidget {
  AllExtensionTypesApp({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: _router);

  late final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    routes: $appRoutes,
    initialLocation: const AllTypesBaseRoute().location,
  );
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

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
])
@immutable
class AllTypesBaseRoute extends GoRouteData {
  const AllTypesBaseRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BasePage<void>(
        dataTitle: 'Root',
        param: null,
      );
}

class BigIntRoute extends GoRouteData {
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
        selected: GoRouter.of(context).location == location,
      );
}

class BoolRoute extends GoRouteData {
  BoolRoute({
    required this.requiredBoolField,
    this.boolField,
  });

  final bool requiredBoolField;
  final bool? boolField;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<bool>(
        dataTitle: 'BoolRoute',
        param: requiredBoolField,
        queryParam: boolField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('BoolRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class DateTimeRoute extends GoRouteData {
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
        selected: GoRouter.of(context).location == location,
      );
}

class DoubleRoute extends GoRouteData {
  DoubleRoute({
    required this.requiredDoubleField,
    this.doubleField,
  });

  final double requiredDoubleField;
  final double? doubleField;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<double>(
        dataTitle: 'DoubleRoute',
        param: requiredDoubleField,
        queryParam: doubleField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('DoubleRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class IntRoute extends GoRouteData {
  IntRoute({
    required this.requiredIntField,
    this.intField,
  });

  final int requiredIntField;
  final int? intField;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<int>(
        dataTitle: 'IntRoute',
        param: requiredIntField,
        queryParam: intField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('IntRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class NumRoute extends GoRouteData {
  NumRoute({
    required this.requiredNumField,
    this.numField,
  });

  final num requiredNumField;
  final num? numField;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<num>(
        dataTitle: 'NumRoute',
        param: requiredNumField,
        queryParam: numField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('NumRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class EnumRoute extends GoRouteData {
  EnumRoute({
    required this.requiredEnumField,
    this.enumField,
  });

  final PersonDetails requiredEnumField;
  final PersonDetails? enumField;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BasePage<PersonDetails>(
        dataTitle: 'EnumRoute',
        param: requiredEnumField,
        queryParam: enumField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('EnumRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class EnhancedEnumRoute extends GoRouteData {
  EnhancedEnumRoute({
    required this.requiredEnumField,
    this.enumField,
  });

  final SportDetails requiredEnumField;
  final SportDetails? enumField;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BasePage<SportDetails>(
        dataTitle: 'EnhancedEnumRoute',
        param: requiredEnumField,
        queryParam: enumField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('EnhancedEnumRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class StringRoute extends GoRouteData {
  StringRoute({
    required this.requiredStringField,
    this.stringField,
  });

  final String requiredStringField;
  final String? stringField;

  @override
  Widget build(BuildContext context, GoRouterState state) => BasePage<String>(
        dataTitle: 'StringRoute',
        param: requiredStringField,
        queryParam: stringField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: const Text('StringRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class UriRoute extends GoRouteData {
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
        selected: GoRouter.of(context).location == location,
      );
}

class BasePage<T> extends StatelessWidget {
  const BasePage({
    required this.dataTitle,
    required this.param,
    this.queryParam,
    super.key,
  });

  final String dataTitle;
  final T param;
  final T? queryParam;

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
              SelectableText(GoRouter.of(context).location),
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
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        routeInformationProvider: _router.routeInformationProvider,
      );

  late final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    routes: $appRoutes,
    initialLocation: const AllTypesBaseRoute().location,
  );
}

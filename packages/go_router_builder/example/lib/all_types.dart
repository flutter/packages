// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/data.dart';

part 'all_types.g.dart';

@TypedGoRoute<AllTypesBaseRoute>(path: '/', routes: [
  TypedGoRoute<BigIntRoute>(path: 'big-int-route/:requiredBigIntField'),
  TypedGoRoute<BoolRoute>(path: 'bool-route/:requiredBoolField'),
  TypedGoRoute<DateTimeRoute>(path: 'date-time-route/:requiredDateTimeField'),
  TypedGoRoute<DoubleRoute>(path: 'double-route/:requiredDoubleField'),
  TypedGoRoute<IntRoute>(path: 'int-route/:requiredIntField'),
  TypedGoRoute<NumRoute>(path: 'num-route/:requiredNumField'),
  TypedGoRoute<DoubleRoute>(path: 'double-route/:requiredDoubleField'),
  TypedGoRoute<EnumRoute>(path: 'enum-route/:requiredEnumFieldField'),
  TypedGoRoute<EnhancedEnumRoute>(
      path: 'enhanced-enum-route/:requiredEnumFieldField'),
  TypedGoRoute<StringRoute>(path: 'string-route/:requiredStringFieldField'),
  TypedGoRoute<UriRoute>(path: 'uri-route/:requiredUriFieldField'),
])
@immutable
class AllTypesBaseRoute extends GoRouteData {
  const AllTypesBaseRoute();

  @override
  Widget build(BuildContext context) => BasePage<void>(
        dataTitle: 'Root',
        param: null,
      );
}

class BigIntRoute extends GoRouteData {
  final BigInt requiredBigIntField;
  final BigInt? bigIntField;

  BigIntRoute({
    required this.requiredBigIntField,
    this.bigIntField,
  });

  @override
  Widget build(BuildContext context) => BasePage<BigInt>(
        dataTitle: 'BigIntRoute',
        param: requiredBigIntField,
        queryParam: bigIntField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: Text('BigIntRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class BoolRoute extends GoRouteData {
  final bool requiredBoolField;
  final bool? boolField;

  BoolRoute({
    required this.requiredBoolField,
    this.boolField,
  });

  @override
  Widget build(BuildContext context) => BasePage<bool>(
        dataTitle: 'BoolRoute',
        param: requiredBoolField,
        queryParam: boolField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: Text('BoolRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class DateTimeRoute extends GoRouteData {
  final DateTime requiredDateTimeField;
  final DateTime? dateTimeField;

  DateTimeRoute({
    required this.requiredDateTimeField,
    this.dateTimeField,
  });

  @override
  Widget build(BuildContext context) => BasePage<DateTime>(
        dataTitle: 'DateTimeRoute',
        param: requiredDateTimeField,
        queryParam: dateTimeField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: Text('DateTimeRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class DoubleRoute extends GoRouteData {
  final double requiredDoubleField;
  final double? doubleField;

  DoubleRoute({
    required this.requiredDoubleField,
    this.doubleField,
  });

  @override
  Widget build(BuildContext context) => BasePage<double>(
        dataTitle: 'DoubleRoute',
        param: requiredDoubleField,
        queryParam: doubleField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: Text('DoubleRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class IntRoute extends GoRouteData {
  final int requiredIntField;
  final int? intField;

  IntRoute({
    required this.requiredIntField,
    this.intField,
  });

  @override
  Widget build(BuildContext context) => BasePage<int>(
        dataTitle: 'IntRoute',
        param: requiredIntField,
        queryParam: intField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: Text('IntRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class NumRoute extends GoRouteData {
  final num requiredNumField;
  final num? numField;

  NumRoute({
    required this.requiredNumField,
    this.numField,
  });

  @override
  Widget build(BuildContext context) => BasePage<num>(
        dataTitle: 'NumRoute',
        param: requiredNumField,
        queryParam: numField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: Text('NumRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class EnumRoute extends GoRouteData {
  final PersonDetails requiredEnumFieldField;
  final PersonDetails? enumFieldField;

  EnumRoute({
    required this.requiredEnumFieldField,
    this.enumFieldField,
  });

  @override
  Widget build(BuildContext context) => BasePage<PersonDetails>(
        dataTitle: 'EnumRoute',
        param: requiredEnumFieldField,
        queryParam: enumFieldField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: Text('EnumRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class EnhancedEnumRoute extends GoRouteData {
  final SportDetails requiredEnumFieldField;
  final SportDetails? enumFieldField;

  EnhancedEnumRoute({
    required this.requiredEnumFieldField,
    this.enumFieldField,
  });

  @override
  Widget build(BuildContext context) => BasePage<SportDetails>(
        dataTitle: 'EnhancedEnumRoute',
        param: requiredEnumFieldField,
        queryParam: enumFieldField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: Text('EnhancedEnumRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class StringRoute extends GoRouteData {
  final String requiredStringFieldField;
  final String? stringFieldField;

  StringRoute({
    required this.requiredStringFieldField,
    this.stringFieldField,
  });

  @override
  Widget build(BuildContext context) => BasePage<String>(
        dataTitle: 'StringRoute',
        param: requiredStringFieldField,
        queryParam: stringFieldField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: Text('StringRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class UriRoute extends GoRouteData {
  final Uri requiredUriFieldField;
  final Uri? uriFieldField;

  UriRoute({
    required this.requiredUriFieldField,
    this.uriFieldField,
  });

  @override
  Widget build(BuildContext context) => BasePage<Uri>(
        dataTitle: 'UriRoute',
        param: requiredUriFieldField,
        queryParam: uriFieldField,
      );

  Widget drawerTile(BuildContext context) => ListTile(
        title: Text('UriRoute'),
        onTap: () => go(context),
        selected: GoRouter.of(context).location == location,
      );
}

class BasePage<T> extends StatelessWidget {
  final String dataTitle;
  final T param;
  final T? queryParam;

  BasePage({
    required this.dataTitle,
    required this.param,
    this.queryParam,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Go router typed routes'),
        ),
        drawer: Drawer(
            child: ListView(
          children: [
            BigIntRoute(
              requiredBigIntField: BigInt.two,
              bigIntField: BigInt.zero,
            ).drawerTile(context),
            BoolRoute(
              requiredBoolField: true,
              boolField: false,
            ).drawerTile(context),
            DateTimeRoute(
              requiredDateTimeField: DateTime(1970, 1, 1),
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
              requiredStringFieldField: r'$!/#bob%%20',
              stringFieldField: r'$!/#bob%%20',
            ).drawerTile(context),
            EnumRoute(
              requiredEnumFieldField: PersonDetails.favoriteSport,
              enumFieldField: PersonDetails.favoriteFood,
            ).drawerTile(context),
            EnhancedEnumRoute(
              requiredEnumFieldField: SportDetails.football,
              enumFieldField: SportDetails.volleyball,
            ).drawerTile(context),
            UriRoute(
              requiredUriFieldField: Uri.parse('https://dart.dev'),
              uriFieldField: Uri.parse('https://dart.dev'),
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
  AllTypesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        routeInformationProvider: _router.routeInformationProvider,
      );

  late final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    routes: $appRoutes,
    initialLocation: AllTypesBaseRoute().location,
  );
}

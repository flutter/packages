// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/data.dart';

part 'all_types.g.dart';

@TypedGoRoute<AllTypesRoute>(
  path: '/:requiredBigIntField/:requiredBoolField/:requiredDateTimeField'
      '/:requiredDoubleField/:requiredEnumField/:requiredIntField'
      '/:requiredNumField/:requiredStringField/:requiredUriField',
)
@immutable
class AllTypesRoute extends GoRouteData {
  const AllTypesRoute({
    required this.requiredBigIntField,
    required this.requiredBoolField,
    required this.requiredDateTimeField,
    required this.requiredDoubleField,
    required this.requiredEnumField,
    required this.requiredIntField,
    required this.requiredNumField,
    required this.requiredStringField,
    required this.requiredUriField,
    this.bigIntField,
    this.boolField,
    this.dateTimeField,
    this.doubleField,
    this.enumField,
    this.intField,
    this.numField,
    this.stringField,
    this.uriField,
  });

  final BigInt requiredBigIntField;
  final bool requiredBoolField;
  final DateTime requiredDateTimeField;
  final double requiredDoubleField;
  final PersonDetails requiredEnumField;
  final int requiredIntField;
  final num requiredNumField;
  final String requiredStringField;
  final Uri requiredUriField;

  final BigInt? bigIntField;
  final bool? boolField;
  final DateTime? dateTimeField;
  final double? doubleField;
  final PersonDetails? enumField;
  final int? intField;
  final num? numField;
  final String? stringField;
  final Uri? uriField;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('built!'),
              SelectableText(location),
            ],
          ),
        ),
      );

  @override
  int get hashCode => Object.hashAll(_items);

  @override
  bool operator ==(Object other) {
    if (other is AllTypesRoute) {
      final List<Object?> mine = _items;
      final List<Object?> theirs = other._items;
      for (int i = 0; i < mine.length; i++) {
        if (mine[i] != theirs[i]) {
          return false;
        }
      }
    }
    return true;
  }

  List<Object?> get _items => <Object?>[
        requiredBigIntField,
        requiredBoolField,
        requiredDateTimeField,
        requiredDoubleField,
        requiredEnumField,
        requiredIntField,
        requiredNumField,
        requiredStringField,
        requiredUriField,
        bigIntField,
        boolField,
        dateTimeField,
        doubleField,
        enumField,
        intField,
        numField,
        stringField,
        uriField,
      ];
}

void main() => runApp(AllTypesApp());

class AllTypesApp extends StatelessWidget {
  AllTypesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
      );

  late final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    routes: $appRoutes,

    // redirect to the login page if the user is not logged in
    redirect: (GoRouterState state) {
      if (state.location == '/') {
        final String location = AllTypesRoute(
          requiredBigIntField: BigInt.two,
          requiredBoolField: true,
          requiredDateTimeField: DateTime.now(),
          requiredDoubleField: 3.14,
          requiredEnumField: PersonDetails.favoriteSport,
          requiredIntField: -42,
          requiredNumField: 3.15,
          requiredStringField: r'$!/#bob%%20',
          requiredUriField: Uri.parse('https://dart.dev'),
          bigIntField: BigInt.zero,
          boolField: false,
          dateTimeField: DateTime(0),
          doubleField: 3.14,
          enumField: PersonDetails.favoriteSport,
          intField: -42,
          numField: 3.15,
          stringField: r'$!/#bob%%20',
          uriField: Uri.parse('https://dart.dev'),
        ).location;

        return location;
      }

      // no need to redirect at all
      return null;
    },
  );
}

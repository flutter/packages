// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/all_types.dart';
import 'package:go_router_builder_example/shared/data.dart';

void main() {
  testWidgets('Test typed route navigation', (WidgetTester tester) async {
    await tester.pumpWidget(AllTypesApp());

    final ScaffoldState scaffoldState =
        tester.firstState(find.byType(Scaffold));

    BigIntRoute(
      requiredBigIntField: BigInt.from(4),
      bigIntField: BigInt.from(8),
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('BigIntRoute'), findsOneWidget);
    expect(find.text('Param: 4'), findsOneWidget);
    expect(find.text('Query param: 8'), findsOneWidget);

    BoolRoute(
      requiredBoolField: false,
      boolField: true,
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('BoolRoute'), findsOneWidget);
    expect(find.text('Param: false'), findsOneWidget);
    expect(find.text('Query param: true'), findsOneWidget);

    final DateTime param = DateTime.now();
    final DateTime query = DateTime(2017, 9, 7, 17, 30);
    DateTimeRoute(
      requiredDateTimeField: param,
      dateTimeField: query,
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('DateTimeRoute'), findsOneWidget);
    expect(find.text('Param: $param'), findsOneWidget);
    expect(find.text('Query param: $query'), findsOneWidget);

    DoubleRoute(
      requiredDoubleField: 3.14,
      doubleField: -3.14,
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('DoubleRoute'), findsOneWidget);
    expect(find.text('Param: 3.14'), findsOneWidget);
    expect(find.text('Query param: -3.14'), findsOneWidget);

    IntRoute(
      requiredIntField: 65,
      intField: -65,
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('IntRoute'), findsOneWidget);
    expect(find.text('Param: 65'), findsOneWidget);
    expect(find.text('Query param: -65'), findsOneWidget);

    NumRoute(
      requiredNumField: 987.32,
      numField: -987.32,
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('NumRoute'), findsOneWidget);
    expect(find.text('Param: 987.32'), findsOneWidget);
    expect(find.text('Query param: -987.32'), findsOneWidget);

    StringRoute(
      requiredStringField: r'Tytire tu patulae recubans sub tegmine fagi.',
      stringField: r'Tytire tu patulae recubans sub tegmine fagi.',
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('StringRoute'), findsOneWidget);
    expect(find.text('Param: Tytire tu patulae recubans sub tegmine fagi.'),
        findsOneWidget);
    expect(
        find.text('Query param: Tytire tu patulae recubans sub tegmine fagi.'),
        findsOneWidget);

    EnumRoute(
      requiredEnumField: PersonDetails.favoriteFood,
      enumField: PersonDetails.favoriteSport,
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('EnumRoute'), findsOneWidget);
    expect(find.text('Param: PersonDetails.favoriteFood'), findsOneWidget);
    expect(
        find.text('Query param: PersonDetails.favoriteSport'), findsOneWidget);

    EnhancedEnumRoute(
      requiredEnumField: SportDetails.football,
      enumField: SportDetails.hockey,
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('EnhancedEnumRoute'), findsOneWidget);
    expect(find.text('Param: SportDetails.football'), findsOneWidget);
    expect(find.text('Query param: SportDetails.hockey'), findsOneWidget);

    UriRoute(
      requiredUriField: Uri.parse('https://dart.dev'),
      uriField: Uri.parse('https://dart.dev'),
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('UriRoute'), findsOneWidget);
    expect(find.text('Param: https://dart.dev'), findsOneWidget);
    expect(find.text('Query param: https://dart.dev'), findsOneWidget);
  });
}

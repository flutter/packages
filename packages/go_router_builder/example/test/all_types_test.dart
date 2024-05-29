// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    expect(find.text('Query param with default value: true'), findsOneWidget);

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
    expect(find.text('Query param: -3.14'), findsOneWidget);
    expect(find.text('Query param with default value: 1.0'), findsOneWidget);

    IntRoute(
      requiredIntField: 65,
      intField: -65,
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('IntRoute'), findsOneWidget);
    expect(find.text('Param: 65'), findsOneWidget);
    expect(find.text('Query param: -65'), findsOneWidget);
    expect(find.text('Query param with default value: 1'), findsOneWidget);

    NumRoute(
      requiredNumField: 987.32,
      numField: -987.32,
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('NumRoute'), findsOneWidget);
    expect(find.text('Param: 987.32'), findsOneWidget);
    expect(find.text('Query param: -987.32'), findsOneWidget);
    expect(find.text('Query param with default value: 1'), findsOneWidget);

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
    expect(find.text('Query param with default value: defaultValue'),
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
    expect(
      find.text('Query param with default value: PersonDetails.favoriteFood'),
      findsOneWidget,
    );

    EnhancedEnumRoute(
      requiredEnumField: SportDetails.football,
      enumField: SportDetails.hockey,
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('EnhancedEnumRoute'), findsOneWidget);
    expect(find.text('Param: SportDetails.football'), findsOneWidget);
    expect(find.text('Query param: SportDetails.hockey'), findsOneWidget);
    expect(
      find.text('Query param with default value: SportDetails.football'),
      findsOneWidget,
    );

    UriRoute(
      requiredUriField: Uri.parse('https://dart.dev'),
      uriField: Uri.parse('https://dart.dev'),
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('UriRoute'), findsOneWidget);
    expect(find.text('Param: https://dart.dev'), findsOneWidget);
    expect(find.text('Query param: https://dart.dev'), findsOneWidget);

    IterableRoute(
      enumIterableField: <SportDetails>[SportDetails.football],
      intListField: <int>[1, 2, 3],
      enumOnlyInSetField: <CookingRecipe>{
        CookingRecipe.burger,
        CookingRecipe.pizza,
      },
    ).go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('IterableRoute'), findsOneWidget);
    expect(find.text('/iterable-route'), findsOneWidget);
    expect(
        find.text(
            '{enum-iterable-field: football, int-list-field: 3, enum-only-in-set-field: pizza}'),
        findsOneWidget);
  });

  testWidgets(
      'It should navigate to the iterable route with its default values',
      (WidgetTester tester) async {
    await tester.pumpWidget(AllTypesApp());

    final ScaffoldState scaffoldState =
        tester.firstState(find.byType(Scaffold));

    const IterableRouteWithDefaultValues().go(scaffoldState.context);
    await tester.pumpAndSettle();
    expect(find.text('IterableRouteWithDefaultValues'), findsOneWidget);
    final IterablePage page =
        tester.widget<IterablePage>(find.byType(IterablePage));
    expect(
      page,
      isA<IterablePage>().having(
        (IterablePage page) => page.intIterableField,
        'intIterableField',
        const <int>[0],
      ).having(
        (IterablePage page) => page.intListField,
        'intListField',
        const <int>[0],
      ).having(
        (IterablePage page) => page.intSetField,
        'intSetField',
        const <int>{0, 1},
      ).having(
        (IterablePage page) => page.doubleIterableField,
        'doubleIterableField',
        const <double>[0, 1, 2],
      ).having(
        (IterablePage page) => page.doubleListField,
        'doubleListField',
        const <double>[1, 2, 3],
      ).having(
        (IterablePage page) => page.doubleSetField,
        'doubleSetField',
        const <double>{},
      ).having(
        (IterablePage page) => page.stringIterableField,
        'stringIterableField',
        const <String>['defaultValue'],
      ).having(
        (IterablePage page) => page.stringListField,
        'stringListField',
        const <String>['defaultValue0', 'defaultValue1'],
      ).having(
        (IterablePage page) => page.stringSetField,
        'stringSetField',
        const <String>{'defaultValue'},
      ).having(
        (IterablePage page) => page.boolIterableField,
        'boolIterableField',
        const <bool>[false],
      ).having(
        (IterablePage page) => page.boolListField,
        'boolListField',
        const <bool>[true],
      ).having(
        (IterablePage page) => page.boolSetField,
        'boolSetField',
        const <bool>{true, false},
      ).having(
        (IterablePage page) => page.enumIterableField,
        'enumIterableField',
        const <SportDetails>[SportDetails.tennis, SportDetails.hockey],
      ).having(
        (IterablePage page) => page.enumListField,
        'enumListField',
        const <SportDetails>[SportDetails.football],
      ).having(
        (IterablePage page) => page.enumSetField,
        'enumSetField',
        const <SportDetails>{SportDetails.hockey},
      ),
    );
    expect(find.text('/iterable-route-with-default-values'), findsOneWidget);
  });
}

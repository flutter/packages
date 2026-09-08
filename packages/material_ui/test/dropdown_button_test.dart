// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// TODO(navaronbracke): port tests from dropdown_button_form_field_test.dart to plain DropdownButton tests as well

void main() {
  testWidgets('DropdownButton value should only appear in one menu item', (
    WidgetTester tester,
  ) async {
    final List<DropdownMenuItem<String>> itemsWithDuplicateValues = <String>['a', 'b', 'c', 'd']
        .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        })
        .toList();

    await expectLater(
      () => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownButton<String>(
              value: 'e',
              onChanged: (String? newValue) {},
              items: itemsWithDuplicateValues,
            ),
          ),
        ),
      ),
      throwsA(
        isAssertionError.having(
          (AssertionError error) => error.toString(),
          '.toString()',
          contains("There should be exactly one item with [DropdownButton]'s value"),
        ),
      ),
    );
  });

  testWidgets('DropdownButton - selectedItemBuilder builds custom buttons', (
    WidgetTester tester,
  ) async {
    const items = <String>['One', 'Two', 'Three'];
    String? selectedItem = items[0];

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return MaterialApp(
            home: Scaffold(
              body: DropdownButton<String>(
                value: selectedItem,
                onChanged: (String? string) => setState(() => selectedItem = string),
                selectedItemBuilder: (BuildContext context) {
                  var index = 0;
                  return items.map((String string) {
                    index += 1;
                    return Text('$string as an Arabic numeral: $index');
                  }).toList();
                },
                items: items.map((String string) {
                  return DropdownMenuItem<String>(value: string, child: Text(string));
                }).toList(),
              ),
            ),
          );
        },
      ),
    );

    expect(find.text('One as an Arabic numeral: 1'), findsOneWidget);
    await tester.tap(find.text('One as an Arabic numeral: 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();
    expect(find.text('Two as an Arabic numeral: 2'), findsOneWidget);
  });

  testWidgets('DropdownButton selectedItemBuilder length must match items length', (
    WidgetTester tester,
  ) async {
    // Regression test for https://github.com/flutter/flutter/issues/92773
    final List<DropdownMenuItem<String>> items = <String>['a', 'b']
        .map<DropdownMenuItem<String>>(
          (String value) => DropdownMenuItem<String>(value: value, child: Text(value)),
        )
        .toList();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox.shrink(
              child: DropdownButton<String>(
                onChanged: (_) {},
                items: items,
                selectedItemBuilder: (BuildContext context) {
                  return <Widget>[const Text('a')];
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      (tester.takeException() as AssertionError).message,
      'The selectedItemBuilder must return a list of widgets with the same length as the items list.\n'
      'Currently, selectedItemBuilder returns a list of length 1, but items has length 2.',
    );
  });

  testWidgets('BorderRadius property works properly for DropdownButton', (
    WidgetTester tester,
  ) async {
    const radius = 20.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: DropdownButton(
              borderRadius: const BorderRadius.all(Radius.circular(radius)),
              value: 'One',
              items: <String>['One', 'Two', 'Three', 'Four'].map<DropdownMenuItem<String>>((
                String value,
              ) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();

    expect(
      find.ancestor(of: find.text('One').last, matching: find.byType(CustomPaint)).at(2),
      paints
        ..save()
        ..rrect()
        ..rrect()
        ..rrect()
        ..rrect(rrect: const RRect.fromLTRBXY(0.0, 0.0, 800.0, 208.0, radius, radius)),
    );
  });

  testWidgets('DropdownButton in ListView', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/12053
    // Positions a DropdownButton at the left and right edges of the screen,
    // forcing it to be sized down to the viewport width
    const value = 'foo';
    final itemKey = UniqueKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ListView(
            children: <Widget>[
              DropdownButton<String>(
                value: value,
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(key: itemKey, value: value, child: const Text(value)),
                ],
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text(value));
    await tester.pump();
    final List<RenderBox> itemBoxes = tester
        .renderObjectList<RenderBox>(find.byKey(itemKey))
        .toList();
    expect(itemBoxes[0].localToGlobal(Offset.zero).dx, equals(0.0));
    expect(itemBoxes[1].localToGlobal(Offset.zero).dx, equals(16.0));
    expect(itemBoxes[1].size.width, equals(800.0 - 16.0 * 2));
  });

  testWidgets('DropdownButton does not allow duplicate item values', (WidgetTester tester) async {
    final List<DropdownMenuItem<String>> itemsWithDuplicateValues = <String>['a', 'b', 'c', 'c']
        .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        })
        .toList();

    await expectLater(
      () => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownButton<String>(
              value: 'c',
              onChanged: (String? newValue) {},
              items: itemsWithDuplicateValues,
            ),
          ),
        ),
      ),
      throwsA(
        isAssertionError.having(
          (AssertionError error) => error.toString(),
          '.toString()',
          contains("There should be exactly one item with [DropdownButton]'s value"),
        ),
      ),
    );
  });
}

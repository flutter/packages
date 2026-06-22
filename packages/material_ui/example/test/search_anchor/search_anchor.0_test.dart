// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/search_anchor/search_anchor.0.dart'
    as example;

void main() {
  testWidgets(
    'Search a color in the search bar and choosing an option changes the color scheme',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.SearchBarApp());

      expect(find.widgetWithText(AppBar, 'Search Bar Sample'), findsOne);

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Card && widget.color == const Color(0xff6750a4),
        ),
        findsOne,
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.text('No search history.'), findsOne);
      await tester.enterText(find.byType(SearchBar).last, 're');
      await tester.pump();

      expect(find.widgetWithText(ListTile, 'red'), findsOne);
      expect(find.widgetWithText(ListTile, 'green'), findsOne);
      expect(find.widgetWithText(ListTile, 'grey'), findsOne);

      await tester.tap(find.widgetWithText(ListTile, 'red'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Card && widget.color == const Color(0xff904a42),
        ),
        findsOne,
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(
        find.widgetWithText(ListTile, 'red'),
        findsOne,
        reason: 'The search history should be displayed',
      );
      expect(find.widgetWithIcon(ListTile, Icons.history), findsOne);

      await tester.enterText(find.byType(SearchBar).last, 'b');
      await tester.pump();

      expect(find.widgetWithText(ListTile, 'blue'), findsOne);
      expect(find.widgetWithText(ListTile, 'beige'), findsOne);
      expect(find.widgetWithText(ListTile, 'brown'), findsOne);
      expect(find.widgetWithText(ListTile, 'black'), findsOne);

      await tester.tap(find.widgetWithText(ListTile, 'blue'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Card && widget.color == const Color(0xff36618e),
        ),
        findsOne,
      );
    },
  );
}

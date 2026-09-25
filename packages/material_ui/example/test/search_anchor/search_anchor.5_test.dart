// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/search_anchor/search_anchor.5.dart'
    as example;

void main() {
  testWidgets(
    'SearchAnchor with enableTapHandling = false opens view on SearchBar tap',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.SearchAnchorCustomSearchBarApp());

      expect(
        find.widgetWithText(AppBar, 'Custom Search Bar Anchor Sample'),
        findsOne,
      );
      expect(find.text('No item selected'), findsOne);

      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();

      for (int i = 0; i < 5; i++) {
        expect(find.widgetWithText(ListTile, 'Item $i'), findsOne);
      }

      await tester.tap(find.text('Item 2'));
      await tester.pumpAndSettle();

      expect(find.text('Selected item: Item 2'), findsOne);
    },
  );
}

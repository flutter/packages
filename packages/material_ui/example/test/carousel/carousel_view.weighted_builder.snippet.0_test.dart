// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/carousel/carousel_view.weighted_builder.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'CarouselView.weightedBuilder lays out items with 1:7:1 weights and builds lazily',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.ExampleApp());

      final Finder carouselFinder = find.byType(CarouselView);
      expect(carouselFinder, findsOneWidget);

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 99'), findsNothing);

      Finder itemContainer(String label) => find
          .ancestor(of: find.text(label), matching: find.byType(ColoredBox))
          .first;

      // Move one step forward so Item 0, Item 1, and Item 2 occupy the 1:7:1 slots.
      final ScrollPosition position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      position.jumpTo(800.0 / 9.0);
      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);

      expect(
        tester.getSize(itemContainer('Item 0')).width,
        closeTo(800.0 / 9.0, 0.1),
      );
      expect(
        tester.getSize(itemContainer('Item 1')).width,
        closeTo(800.0 * 7.0 / 9.0, 0.1),
      );
      expect(
        tester.getSize(itemContainer('Item 2')).width,
        closeTo(800.0 / 9.0, 0.1),
      );

      final ColoredBox item1Box = tester.widget<ColoredBox>(
        itemContainer('Item 1'),
      );
      expect(item1Box.color, Colors.primaries[1]);

      // Scroll further to verify lazy building of later items and disposal of earlier items.
      await tester.drag(carouselFinder, const Offset(-2000, 0));
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsNothing);
    },
  );
}

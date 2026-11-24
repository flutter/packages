// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/carousel/carousel_view.snippet.1.dart'
    as example;

void main() {
  testWidgets(
    'CarouselView.weighted with single flexWeight displays vertical full-screen items',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.ExampleApp());

      final Finder carouselFinder = find.byType(CarouselView);
      final CarouselView carousel = tester.widget<CarouselView>(carouselFinder);
      expect(carousel.scrollDirection, Axis.vertical);

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsNothing);

      final Size viewportSize = tester.getSize(carouselFinder);
      Finder itemContainer(String label) => find
          .ancestor(of: find.text(label), matching: find.byType(Padding))
          .first;

      expect(
        tester.getRect(itemContainer('Item 0')),
        Offset.zero & viewportSize,
      );

      final ScrollPosition position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      position.jumpTo(viewportSize.height);
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(
        tester.getRect(itemContainer('Item 1')),
        Offset.zero & viewportSize,
      );
    },
  );
}

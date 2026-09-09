// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/carousel/carousel.1.dart' as example;

void main() {
  testWidgets('CarouselView.builder creates items lazily', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.CarouselBuilderExampleApp());

    expect(find.byType(CarouselView), findsOneWidget);
    expect(find.text('Item 0'), findsOneWidget);

    expect(find.text('Item 999'), findsNothing);

    final Finder carousel = find.byType(CarouselView);
    await tester.drag(carousel, const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 0'), findsNothing);

    for (int i = 0; i < 5; i++) {
      await tester.drag(carousel, const Offset(-400, 0));
      await tester.pumpAndSettle();
    }

    expect(find.text('Item 6'), findsOneWidget);
  });

  testWidgets('CarouselView.builder items are wrapped with default properties', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.CarouselBuilderExampleApp());

    expect(find.byType(CarouselView), findsOneWidget);

    final Finder itemMaterialFinder = find.descendant(
      of: find.byType(CarouselView),
      matching: find.byType(Material),
    ).first;
    
    final Material material = tester.widget<Material>(itemMaterialFinder);
    expect(material.clipBehavior, Clip.antiAlias);
    expect(
      material.shape, 
      const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28.0))),
    );

    final Finder paddingFinder = find.ancestor(
      of: itemMaterialFinder,
      matching: find.byType(Padding),
    ).first;
    
    final Padding padding = tester.widget<Padding>(paddingFinder);
    expect(padding.padding, const EdgeInsets.all(4.0));
  });
}

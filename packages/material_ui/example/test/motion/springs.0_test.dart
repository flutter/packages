// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/motion/springs.0.dart' as example;

void main() {
  testWidgets('Springs example compares the standard and expressive springs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.SpringsExampleApp());

    expect(find.text('Material 3 Expressive Springs Sample'), findsOne);
    expect(find.text('Standard'), findsOne);
    expect(find.text('Expressive'), findsOne);

    // The standard box comes first.
    final Finder standardBox = find.byIcon(Icons.star).first;
    final Finder expressiveBox = find.byIcon(Icons.star).last;
    final ColorScheme colors = Theme.of(
      tester.element(find.byType(example.SpringsExample)),
    ).colorScheme;
    Color? boxColor(Finder box) {
      final DecoratedBox decoratedBox = tester.widget<DecoratedBox>(
        find.ancestor(of: box, matching: find.byType(DecoratedBox)).first,
      );
      return (decoratedBox.decoration as BoxDecoration).color;
    }

    // The spatial springs of the default speed are shown at first.
    expect(
      find.text('Spatial spring: stiffness 700, damping ratio 0.90'),
      findsOne,
    );
    expect(
      find.text('Spatial spring: stiffness 380, damping ratio 0.80'),
      findsOne,
    );

    // Spatial springs move the boxes without changing their color.
    final double startX = tester.getCenter(standardBox).dx;
    expect(tester.getCenter(expressiveBox).dx, startX);
    await tester.tap(find.text('Animate'));
    await tester.pumpAndSettle();
    final double endX = tester.getCenter(standardBox).dx;
    expect(endX, greaterThan(startX));
    expect(tester.getCenter(expressiveBox).dx, endX);
    expect(boxColor(standardBox), colors.secondaryContainer);
    expect(boxColor(expressiveBox), colors.secondaryContainer);

    // With the fast speed, only the expressive box overshoots the start of the
    // track before it settles there.
    await tester.tap(find.text('Fast'));
    await tester.pump();
    expect(
      find.text('Spatial spring: stiffness 1400, damping ratio 0.90'),
      findsOne,
    );
    expect(
      find.text('Spatial spring: stiffness 800, damping ratio 0.60'),
      findsOne,
    );
    await tester.tap(find.text('Animate'));
    await tester.pump();
    double standardMinX = endX;
    double expressiveMinX = endX;
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      standardMinX = math.min(standardMinX, tester.getCenter(standardBox).dx);
      expressiveMinX = math.min(
        expressiveMinX,
        tester.getCenter(expressiveBox).dx,
      );
    }
    expect(standardMinX, greaterThan(startX - 2.0));
    expect(expressiveMinX, lessThan(startX - 10.0));
    await tester.pumpAndSettle();
    expect(
      tester.getCenter(standardBox).dx,
      moreOrLessEquals(startX, epsilon: 1.0),
    );
    expect(
      tester.getCenter(expressiveBox).dx,
      moreOrLessEquals(startX, epsilon: 1.0),
    );

    // Effects springs change the color of the boxes without moving them. Both
    // schemes use the same effects springs, so the boxes change color the same
    // way.
    await tester.tap(find.text('Effects'));
    await tester.pump();
    expect(
      find.text('Effects spring: stiffness 3800, damping ratio 1.00'),
      findsNWidgets(2),
    );
    final double effectsX = tester.getCenter(standardBox).dx;
    expect(tester.getCenter(expressiveBox).dx, effectsX);
    expect(boxColor(standardBox), colors.secondaryContainer);
    expect(boxColor(expressiveBox), colors.secondaryContainer);
    await tester.tap(find.text('Animate'));
    await tester.pump();
    for (var frame = 0; frame < 10; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.getCenter(standardBox).dx, effectsX);
      expect(tester.getCenter(expressiveBox).dx, effectsX);
      expect(boxColor(expressiveBox), boxColor(standardBox));
    }
    await tester.pumpAndSettle();
    expect(boxColor(standardBox), colors.primary);
    expect(boxColor(expressiveBox), colors.primary);
  });
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/motion/springs.0.dart' as example;

void main() {
  testWidgets('Springs example animates with the selected springs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.SpringsExampleApp());

    expect(find.text('Material 3 Expressive Springs Sample'), findsOne);

    // The standard scheme and the default speed are selected at first.
    expect(
      find.text('Spatial spring: stiffness 700, damping ratio 0.90'),
      findsOne,
    );
    expect(
      find.text('Effects spring: stiffness 1600, damping ratio 1.00'),
      findsOne,
    );

    final Finder box = find.byIcon(Icons.star);
    final double startX = tester.getCenter(box).dx;
    final ColorScheme colors = Theme.of(
      tester.element(find.byType(example.SpringsExample)),
    ).colorScheme;
    Color? boxColor() {
      final DecoratedBox decoratedBox = tester.widget<DecoratedBox>(
        find.ancestor(of: box, matching: find.byType(DecoratedBox)).first,
      );
      return (decoratedBox.decoration as BoxDecoration).color;
    }

    expect(boxColor(), colors.secondaryContainer);

    // Moving the box carries it to the end of the track and changes its color.
    await tester.tap(find.text('Move'));
    await tester.pumpAndSettle();
    final double endX = tester.getCenter(box).dx;
    expect(endX, greaterThan(startX));
    expect(boxColor(), colors.primary);
    expect(find.text('Move back'), findsOne);

    // Switching to the expressive scheme and the fast speed selects the
    // matching springs.
    await tester.tap(find.text('Expressive'));
    await tester.tap(find.text('Fast'));
    await tester.pump();
    expect(
      find.text('Spatial spring: stiffness 800, damping ratio 0.60'),
      findsOne,
    );
    expect(
      find.text('Effects spring: stiffness 3800, damping ratio 1.00'),
      findsOne,
    );

    // The expressive spatial spring overshoots the start of the track before
    // it settles there.
    await tester.tap(find.text('Move back'));
    await tester.pump();
    double minX = endX;
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      minX = math.min(minX, tester.getCenter(box).dx);
    }
    expect(minX, lessThan(startX - 10.0));

    await tester.pumpAndSettle();
    expect(tester.getCenter(box).dx, moreOrLessEquals(startX, epsilon: 1.0));
    expect(boxColor(), colors.secondaryContainer);
    expect(find.text('Move'), findsOne);
  });
}

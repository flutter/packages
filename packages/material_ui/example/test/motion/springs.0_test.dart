// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/motion/springs.0.dart' as example;

void main() {
  testWidgets('Springs example compares spatial schemes and effects speeds', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.SpringsExampleApp());

    expect(find.text('Material 3 Expressive Springs Sample'), findsOne);
    expect(find.text('Standard'), findsOne);
    expect(find.text('Expressive'), findsOne);

    // The standard puck comes first.
    final Finder standardPuck = find.byIcon(Icons.star_rounded).first;
    final Finder expressivePuck = find.byIcon(Icons.star_rounded).last;
    final ColorScheme colors = Theme.of(
      tester.element(find.byType(example.SpringsExample)),
    ).colorScheme;
    Color? decoratedBoxColor(Finder finder) {
      final DecoratedBox box = tester.widget<DecoratedBox>(finder);
      return (box.decoration as BoxDecoration).color;
    }

    Finder puckBox(Finder icon) {
      return find.ancestor(of: icon, matching: find.byType(DecoratedBox)).first;
    }

    // The spatial springs of the default speed are shown at first.
    expect(find.text('stiffness 700 · damping ratio 0.90'), findsOne);
    expect(find.text('stiffness 380 · damping ratio 0.80'), findsOne);

    // Spatial springs move the pucks without changing their color.
    final double startX = tester.getCenter(standardPuck).dx;
    expect(tester.getCenter(expressivePuck).dx, startX);
    await tester.tap(find.text('Animate'));
    await tester.pumpAndSettle();
    final double endX = tester.getCenter(standardPuck).dx;
    expect(endX, greaterThan(startX));
    expect(tester.getCenter(expressivePuck).dx, endX);
    expect(decoratedBoxColor(puckBox(standardPuck)), colors.primary);
    expect(decoratedBoxColor(puckBox(expressivePuck)), colors.primary);

    // With the fast speed, only the expressive puck overshoots the start slot
    // before settling back into place.
    await tester.tap(find.text('Fast'));
    await tester.pump();
    expect(find.text('stiffness 1400 · damping ratio 0.90'), findsOne);
    expect(find.text('stiffness 800 · damping ratio 0.60'), findsOne);
    await tester.tap(find.text('Animate'));
    await tester.pump();
    double standardMinX = endX;
    double expressiveMinX = endX;
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      standardMinX = math.min(standardMinX, tester.getCenter(standardPuck).dx);
      expressiveMinX = math.min(
        expressiveMinX,
        tester.getCenter(expressivePuck).dx,
      );
    }
    expect(standardMinX, greaterThan(startX - 2.0));
    expect(expressiveMinX, lessThan(startX - 10.0));
    await tester.pumpAndSettle();
    expect(
      tester.getCenter(standardPuck).dx,
      moreOrLessEquals(startX, epsilon: 1.0),
    );
    expect(
      tester.getCenter(expressivePuck).dx,
      moreOrLessEquals(startX, epsilon: 1.0),
    );

    // Effects mode compares Fast, Default, and Slow stationary color swatches
    // side by side without moving them.
    await tester.tap(find.text('Effects'));
    await tester.pump();
    expect(find.text('stiffness 3800 · damping ratio 1.00'), findsOne);
    expect(find.text('stiffness 1600 · damping ratio 1.00'), findsOne);
    expect(find.text('stiffness 800 · damping ratio 1.00'), findsOne);

    final Finder fastSwatch = find.byKey(
      const ValueKey<String>('effects-swatch-Fast'),
    );
    final Finder defaultSwatch = find.byKey(
      const ValueKey<String>('effects-swatch-Default'),
    );
    final Finder slowSwatch = find.byKey(
      const ValueKey<String>('effects-swatch-Slow'),
    );
    final Rect fastRect = tester.getRect(fastSwatch);
    final Rect defaultRect = tester.getRect(defaultSwatch);
    final Rect slowRect = tester.getRect(slowSwatch);
    expect(decoratedBoxColor(fastSwatch), colors.surfaceContainerHighest);
    expect(decoratedBoxColor(defaultSwatch), colors.surfaceContainerHighest);
    expect(decoratedBoxColor(slowSwatch), colors.surfaceContainerHighest);

    await tester.tap(find.text('Animate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 48));
    // All three swatches remain completely stationary.
    expect(tester.getRect(fastSwatch), fastRect);
    expect(tester.getRect(defaultSwatch), defaultRect);
    expect(tester.getRect(slowSwatch), slowRect);
    // At 48ms, Fast is closer to colors.primary (darker) than Default, which is
    // closer than Slow.
    final double fastLuminance = decoratedBoxColor(
      fastSwatch,
    )!.computeLuminance();
    final double defaultLuminance = decoratedBoxColor(
      defaultSwatch,
    )!.computeLuminance();
    final double slowLuminance = decoratedBoxColor(
      slowSwatch,
    )!.computeLuminance();
    expect(fastLuminance, lessThan(defaultLuminance));
    expect(defaultLuminance, lessThan(slowLuminance));

    await tester.pumpAndSettle();
    expect(decoratedBoxColor(fastSwatch), colors.primary);
    expect(decoratedBoxColor(defaultSwatch), colors.primary);
    expect(decoratedBoxColor(slowSwatch), colors.primary);
  });
}

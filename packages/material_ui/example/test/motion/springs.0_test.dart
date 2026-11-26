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

    Color? swatchColor(Finder finder) {
      return tester.widget<Card>(finder).color;
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
    final Rect expressiveCardRect = tester.getRect(
      find.ancestor(of: expressivePuck, matching: find.byType(Card)).first,
    );
    await tester.tap(find.text('Animate'));
    await tester.pump();
    double standardMinX = endX;
    double expressiveMinX = endX;
    double expressiveMinLeft = endX;
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      standardMinX = math.min(standardMinX, tester.getCenter(standardPuck).dx);
      expressiveMinX = math.min(
        expressiveMinX,
        tester.getCenter(expressivePuck).dx,
      );
      expressiveMinLeft = math.min(
        expressiveMinLeft,
        tester.getTopLeft(puckBox(expressivePuck)).dx,
      );
    }
    expect(standardMinX, greaterThan(startX - 2.0));
    expect(expressiveMinX, lessThan(startX - 10.0));
    expect(expressiveMinLeft, greaterThanOrEqualTo(expressiveCardRect.left));
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

    Finder effectsSwatch(String label) {
      return find.descendant(
        of: find.ancestor(of: find.text(label), matching: find.byType(Card)),
        matching: find.byType(Card),
      );
    }

    final Finder fastSwatch = effectsSwatch('Fast');
    final Finder defaultSwatch = effectsSwatch('Default');
    final Finder slowSwatch = effectsSwatch('Slow');
    final Rect fastRect = tester.getRect(fastSwatch);
    final Rect defaultRect = tester.getRect(defaultSwatch);
    final Rect slowRect = tester.getRect(slowSwatch);
    expect(swatchColor(fastSwatch), colors.surfaceContainerHighest);
    expect(swatchColor(defaultSwatch), colors.surfaceContainerHighest);
    expect(swatchColor(slowSwatch), colors.surfaceContainerHighest);

    await tester.tap(find.text('Animate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 48));
    // All three swatches remain completely stationary.
    expect(tester.getRect(fastSwatch), fastRect);
    expect(tester.getRect(defaultSwatch), defaultRect);
    expect(tester.getRect(slowSwatch), slowRect);
    // At 48ms, Fast is closer to colors.primary (darker) than Default, which is
    // closer than Slow.
    final double fastLuminance = swatchColor(fastSwatch)!.computeLuminance();
    final double defaultLuminance = swatchColor(
      defaultSwatch,
    )!.computeLuminance();
    final double slowLuminance = swatchColor(slowSwatch)!.computeLuminance();
    expect(fastLuminance, lessThan(defaultLuminance));
    expect(defaultLuminance, lessThan(slowLuminance));

    await tester.pumpAndSettle();
    expect(swatchColor(fastSwatch), colors.primary);
    expect(swatchColor(defaultSwatch), colors.primary);
    expect(swatchColor(slowSwatch), colors.primary);

    // Slow motion (0.25x speed) stretches out the spring animations while
    // keeping their relative ordering and settling cleanly on the target.
    await tester.tap(find.text('0.25x speed'));
    await tester.pump();
    await tester.tap(find.text('Animate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 48));
    final double slowModeFastLuminance = swatchColor(
      fastSwatch,
    )!.computeLuminance();
    final double slowModeDefaultLuminance = swatchColor(
      defaultSwatch,
    )!.computeLuminance();
    final double slowModeSlowLuminance = swatchColor(
      slowSwatch,
    )!.computeLuminance();
    // At 48ms in 0.25x mode, Fast has only progressed ~17% back toward
    // surfaceContainerHighest (still much darker than at 1x speed).
    expect(slowModeFastLuminance, lessThan(0.25));
    expect(slowModeFastLuminance, greaterThan(slowModeDefaultLuminance));
    expect(slowModeDefaultLuminance, greaterThan(slowModeSlowLuminance));

    await tester.pumpAndSettle();
    expect(swatchColor(fastSwatch), colors.surfaceContainerHighest);
    expect(swatchColor(defaultSwatch), colors.surfaceContainerHighest);
    expect(swatchColor(slowSwatch), colors.surfaceContainerHighest);
  });

  testWidgets('Toggling 0.25x speed mid-flight updates speed without spiking', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.SpringsExampleApp());

    final Finder expressivePuck = find.byIcon(Icons.star_rounded).last;
    final Finder expressiveBox = find
        .ancestor(of: expressivePuck, matching: find.byType(DecoratedBox))
        .first;
    final Rect expressiveCardRect = tester.getRect(
      find.ancestor(of: expressivePuck, matching: find.byType(Card)).first,
    );

    // Toggle 0.25x speed ON during a 1x Fast spatial animation, then reverse:
    // the physics velocity must not be amplified by 4x and push the puck past
    // the card's right edge.
    await tester.tap(find.text('Fast'));
    await tester.pump();
    final double startX = tester.getCenter(expressivePuck).dx;
    await tester.tap(find.text('Animate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 48));

    await tester.tap(find.text('0.25x speed'));
    await tester.pump();
    await tester.tap(find.text('Animate'));
    await tester.pump();

    double maxRight = 0.0;
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      maxRight = math.max(maxRight, tester.getTopRight(expressiveBox).dx);
    }
    expect(maxRight, lessThanOrEqualTo(expressiveCardRect.right));
    await tester.pumpAndSettle();
    expect(
      tester.getCenter(expressivePuck).dx,
      moreOrLessEquals(startX, epsilon: 1.0),
    );

    // Toggle 0.25x speed OFF during a slow-motion Effects animation: the
    // running animation immediately resumes 1x speed and finishes within 220ms
    // (at 0.25x it would still be partway through).
    await tester.tap(find.text('Effects'));
    await tester.pump();
    final ColorScheme colors = Theme.of(
      tester.element(find.byType(example.SpringsExample)),
    ).colorScheme;
    final Finder fastSwatch = find.descendant(
      of: find.ancestor(of: find.text('Fast'), matching: find.byType(Card)),
      matching: find.byType(Card),
    );

    await tester.tap(find.text('Animate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    await tester.tap(find.text('0.25x speed'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(tester.widget<Card>(fastSwatch).color, colors.primary);
  });
}

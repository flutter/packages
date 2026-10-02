// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/material_shapes/material_shapes.0.dart'
    as example;

void main() {
  /// Comfortably longer than it takes either of the example's springs to
  /// settle.
  const Duration morphDuration = Duration(seconds: 3);

  /// Samples points on a grid over the unit square that are clearly [inside]
  /// (or outside) of [path].
  List<Offset> samplePoints(Path path, {required bool inside}) {
    const step = 0.09;
    const margin = 0.02;

    final List<Offset> points = <Offset>[];
    for (var x = step; x < 1; x += step) {
      for (var y = step; y < 1; y += step) {
        final bool clearlyInOrOut = <Offset>[
          Offset(x, y),
          Offset(x - margin, y),
          Offset(x + margin, y),
          Offset(x, y - margin),
          Offset(x, y + margin),
        ].every((Offset point) => path.contains(point) == inside);
        if (clearlyInOrOut) {
          points.add(Offset(x, y));
        }
      }
    }
    return points;
  }

  testWidgets('Material shapes morph through every shape and wrap around', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.MaterialShapesExampleApp());

    expect(find.text('Material Shapes Sample'), findsOne);

    final Finder shape = find.byWidgetPredicate(
      (Widget widget) => widget is CustomPaint && widget.willChange,
    );
    expect(tester.getSize(shape), const Size.square(300));

    final ThemeData theme = Theme.of(
      tester.element(find.byType(example.MaterialShapesExample)),
    );

    // The circle is painted first, scaled up to fill the paint area, and is
    // held still before the morphing starts.
    expect(
      shape,
      paints
        ..scale(x: 300)
        ..path(
          color: theme.colorScheme.primary,
          style: PaintingStyle.fill,
          includes: const <Offset>[Offset(0.5, 0.5)],
          excludes: const <Offset>[Offset(0.1, 0.1)],
        ),
    );
    expect(tester.hasRunningAnimations, isFalse);

    // The morphing starts after holding the first shape for a second.
    await tester.pump(const Duration(seconds: 1));

    // Morph through the whole list of shapes, wrapping around from the last
    // shape back to the first one.
    final shapeCount = MaterialShapes.all.length;
    for (var i = 0; i < shapeCount; i++) {
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pump(morphDuration);

      final RoundedPolygon target = MaterialShapes.all[(i + 1) % shapeCount];
      final Path targetPath = target.toPath();
      expect(
        shape,
        paints..path(
          color: theme.colorScheme.primary,
          style: PaintingStyle.fill,
          includes: samplePoints(targetPath, inside: true),
          excludes: samplePoints(targetPath, inside: false),
        ),
        reason:
            'Morph $i should have settled on shape ${(i + 1) % shapeCount}.',
      );
    }

    // Disposing the example stops the animation.
    await tester.pumpWidget(const SizedBox());
    expect(tester.hasRunningAnimations, isFalse);
  });
}

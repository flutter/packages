// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final namedShapes = <String, RoundedPolygon>{
    'circle': MaterialShapes.circle,
    'square': MaterialShapes.square,
    'slanted': MaterialShapes.slanted,
    'arch': MaterialShapes.arch,
    'semiCircle': MaterialShapes.semiCircle,
    'oval': MaterialShapes.oval,
    'pill': MaterialShapes.pill,
    'triangle': MaterialShapes.triangle,
    'arrow': MaterialShapes.arrow,
    'fan': MaterialShapes.fan,
    'diamond': MaterialShapes.diamond,
    'clamShell': MaterialShapes.clamShell,
    'pentagon': MaterialShapes.pentagon,
    'gem': MaterialShapes.gem,
    'sunny': MaterialShapes.sunny,
    'verySunny': MaterialShapes.verySunny,
    'cookie4Sided': MaterialShapes.cookie4Sided,
    'cookie6Sided': MaterialShapes.cookie6Sided,
    'cookie7Sided': MaterialShapes.cookie7Sided,
    'cookie9Sided': MaterialShapes.cookie9Sided,
    'cookie12Sided': MaterialShapes.cookie12Sided,
    'clover4Leaf': MaterialShapes.clover4Leaf,
    'clover8Leaf': MaterialShapes.clover8Leaf,
    'burst': MaterialShapes.burst,
    'softBurst': MaterialShapes.softBurst,
    'boom': MaterialShapes.boom,
    'softBoom': MaterialShapes.softBoom,
    'flower': MaterialShapes.flower,
    'puffy': MaterialShapes.puffy,
    'puffyDiamond': MaterialShapes.puffyDiamond,
    'ghostish': MaterialShapes.ghostish,
    'pixelCircle': MaterialShapes.pixelCircle,
    'pixelTriangle': MaterialShapes.pixelTriangle,
    'bun': MaterialShapes.bun,
    'heart': MaterialShapes.heart,
  };

  test('every shape in MaterialShapes.all has a golden test', () {
    expect(
      namedShapes.values,
      hasLength(MaterialShapes.all.length),
      reason:
          'Every shape in MaterialShapes.all must have a named entry in '
          'namedShapes so that it gets a golden test.',
    );
    expect(
      namedShapes.values,
      orderedEquals(MaterialShapes.all),
      reason:
          'namedShapes must list the same shapes as MaterialShapes.all, in '
          'the same order.',
    );
  });

  for (final MapEntry<String, RoundedPolygon> entry in namedShapes.entries) {
    testWidgets('MaterialShapes.${entry.key} golden', (WidgetTester tester) async {
      await tester.pumpWidget(
        Center(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _ShapePainter(entry.value),
              child: const SizedBox.square(dimension: 200),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('material_shapes.${entry.key}.png'),
      );
    });
  }
}

class _ShapePainter extends CustomPainter {
  const _ShapePainter(this.shape);

  final RoundedPolygon shape;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width, size.height)
      ..drawPath(shape.toPath(), Paint()..color = const Color(0xFF6750A4))
      ..restore();
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) => oldDelegate.shape != shape;
}

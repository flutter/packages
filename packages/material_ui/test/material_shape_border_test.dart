// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('$MaterialShapeBorder', () {
    final unitSquare = RoundedPolygon.rectangle(
      width: 1,
      height: 1,
      center: const Offset(0.5, 0.5),
    );

    test('== compares lerped cubics by value', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final ShapeBorder? first = start.lerpTo(end, 0.5);
      final ShapeBorder? second = start.lerpTo(end, 0.5);
      final ShapeBorder? reverse = end.lerpFrom(start, 0.5);

      expect(identical(first, second), isFalse);
      expect(first, second);
      expect(reverse, first);
    });

    test('hashCode hashes lerped cubics by value', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final ShapeBorder? first = start.lerpTo(end, 0.5);
      final ShapeBorder? second = start.lerpTo(end, 0.5);
      final ShapeBorder? reverse = end.lerpFrom(start, 0.5);

      expect(first.hashCode, second.hashCode);
      expect(reverse.hashCode, first.hashCode);
    });

    test('== distinguishes lerp progress', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      expect(start.lerpTo(end, 0.25), isNot(start.lerpTo(end, 0.75)));
    });

    test('== compares lerped side and squash', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);
      final thickEnd = MaterialShapeBorder(
        shape: MaterialShapes.square,
        side: const BorderSide(width: 4.0),
        squash: 1.0,
      );

      expect(start.lerpTo(end, 0.5), isNot(start.lerpTo(thickEnd, 0.5)));
    });

    test('hashCode agrees with == for equal shapes', () {
      final List<Feature> features = MaterialShapes.circle.features;
      final border = MaterialShapeBorder(shape: RoundedPolygon.fromFeatures(features));
      final other = MaterialShapeBorder(
        shape: RoundedPolygon.fromFeatures(List<Feature>.of(features)),
      );

      expect(border, other);
      expect(border.hashCode, other.hashCode);
    });

    test('== compares shapes by value', () {
      final border = MaterialShapeBorder(shape: RoundedPolygon.circle());
      final other = MaterialShapeBorder(shape: RoundedPolygon.circle());

      expect(border, other);
      expect(border.hashCode, other.hashCode);
    });

    test('copyWith, ==, hashCode', () {
      final border = MaterialShapeBorder(
        shape: MaterialShapes.circle,
        side: const BorderSide(width: 2.0),
        squash: 0.5,
      );

      expect(border, border.copyWith());
      expect(border.hashCode, border.copyWith().hashCode);

      expect(border, isNot(border.copyWith(shape: MaterialShapes.square)));
      expect(border, isNot(border.copyWith(side: const BorderSide(width: 3.0))));
      expect(border, isNot(border.copyWith(squash: 1.0)));
    });

    test('defaults', () {
      final border = MaterialShapeBorder(shape: unitSquare);

      expect(border.shape, same(unitSquare));
      expect(border.side, BorderSide.none);
      expect(border.squash, 0.0);
    });

    test('asserts that squash is between zero and one', () {
      expect(() => MaterialShapeBorder(shape: unitSquare, squash: -0.1), throwsAssertionError);
      expect(() => MaterialShapeBorder(shape: unitSquare, squash: 1.1), throwsAssertionError);
    });

    test('toString', () {
      expect(
        MaterialShapeBorder(shape: unitSquare, squash: 0.5).toString(),
        'MaterialShapeBorder(side: BorderSide(width: 0.0, style: none), squash: 0.5)',
      );
    });

    test('getOuterPath and getInnerPath inset the shape by the side', () {
      const rect = Rect.fromLTWH(0.0, 0.0, 200.0, 100.0);

      final border = MaterialShapeBorder(shape: unitSquare, squash: 1.0);
      expect(border.getOuterPath(rect).getBounds(), rect);
      expect(border.getInnerPath(rect).getBounds(), rect);

      // The default stroke alignment is inside, so the whole stroke width lies
      // within the outer path and nothing lies outside it.
      final inside = MaterialShapeBorder(
        shape: unitSquare,
        side: const BorderSide(width: 10.0),
        squash: 1.0,
      );
      expect(inside.getOuterPath(rect).getBounds(), rect);
      expect(inside.getInnerPath(rect).getBounds(), const Rect.fromLTWH(10.0, 10.0, 180.0, 80.0));

      final outside = MaterialShapeBorder(
        shape: unitSquare,
        side: const BorderSide(width: 10.0, strokeAlign: BorderSide.strokeAlignOutside),
        squash: 1.0,
      );
      expect(
        outside.getOuterPath(rect).getBounds(),
        const Rect.fromLTWH(-10.0, -10.0, 220.0, 120.0),
      );
      expect(outside.getInnerPath(rect).getBounds(), rect);
    });

    test('squash takes on the aspect ratio of a wide rect', () {
      const rect = Rect.fromLTWH(0.0, 0.0, 200.0, 100.0);

      // Zero squash draws a centered square the size of the shortest side.
      expect(
        MaterialShapeBorder(shape: unitSquare).getOuterPath(rect).getBounds(),
        const Rect.fromLTWH(50.0, 0.0, 100.0, 100.0),
      );
      expect(
        MaterialShapeBorder(shape: unitSquare, squash: 0.5).getOuterPath(rect).getBounds(),
        const Rect.fromLTWH(25.0, 0.0, 150.0, 100.0),
      );
      expect(
        MaterialShapeBorder(shape: unitSquare, squash: 1.0).getOuterPath(rect).getBounds(),
        rect,
      );
    });

    test('squash takes on the aspect ratio of a tall rect', () {
      const rect = Rect.fromLTWH(0.0, 0.0, 100.0, 200.0);

      expect(
        MaterialShapeBorder(shape: unitSquare).getOuterPath(rect).getBounds(),
        const Rect.fromLTWH(0.0, 50.0, 100.0, 100.0),
      );
      expect(
        MaterialShapeBorder(shape: unitSquare, squash: 0.5).getOuterPath(rect).getBounds(),
        const Rect.fromLTWH(0.0, 25.0, 100.0, 150.0),
      );
      expect(
        MaterialShapeBorder(shape: unitSquare, squash: 1.0).getOuterPath(rect).getBounds(),
        rect,
      );
    });

    test('squash has no effect on a square rect', () {
      const rect = Rect.fromLTWH(10.0, 20.0, 100.0, 100.0);

      expect(MaterialShapeBorder(shape: unitSquare).getOuterPath(rect).getBounds(), rect);
      expect(
        MaterialShapeBorder(shape: unitSquare, squash: 1.0).getOuterPath(rect).getBounds(),
        rect,
      );
    });

    test('paint strokes the shape with the side', () {
      const rect = Rect.fromLTWH(0.0, 0.0, 100.0, 100.0);
      final border = MaterialShapeBorder(
        shape: unitSquare,
        side: const BorderSide(color: Color(0xFF00FF00), width: 4.0),
        squash: 1.0,
      );

      expect(
        (Canvas canvas) => border.paint(canvas, rect),
        paints..path(
          color: const Color(0xFF00FF00),
          strokeWidth: 4.0,
          style: PaintingStyle.stroke,
          // The stroke is centered on the painted path, which the inside
          // stroke alignment pulls half a stroke width in from the rect.
          includes: const <Offset>[Offset(3.0, 50.0), Offset(97.0, 50.0)],
          excludes: const <Offset>[Offset(1.0, 50.0), Offset(99.0, 50.0)],
        ),
      );
    });

    test('paint draws nothing without a solid side', () {
      const rect = Rect.fromLTWH(0.0, 0.0, 100.0, 100.0);

      expect(
        (Canvas canvas) => MaterialShapeBorder(shape: unitSquare).paint(canvas, rect),
        paintsNothing,
      );
      expect(
        (Canvas canvas) => MaterialShapeBorder(
          shape: unitSquare,
          side: const BorderSide(width: 4.0, style: BorderStyle.none),
        ).paint(canvas, rect),
        paintsNothing,
      );
    });

    test('scale scales the side and leaves the shape alone', () {
      final border = MaterialShapeBorder(
        shape: unitSquare,
        side: const BorderSide(width: 2.0),
        squash: 0.5,
      );
      final scaled = border.scale(2.0) as MaterialShapeBorder;

      expect(scaled.shape, same(unitSquare));
      expect(scaled.side, const BorderSide(width: 4.0));
      // Squash is a ratio, so scaling it would take it out of range.
      expect(scaled.squash, 0.5);
    });

    test('scale keeps the cubics of a lerped border', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(
        shape: MaterialShapes.square,
        side: const BorderSide(width: 2.0),
      );

      final lerped = start.lerpTo(end, 0.5)! as MaterialShapeBorder;
      final scaled = lerped.scale(2.0) as MaterialShapeBorder;

      expect(scaled.shape, isNull);
      expect(scaled.side, lerped.side.scale(2.0));
      expect(scaled.squash, lerped.squash);
      // The cubics survive the scale, so restoring the side restores the
      // border.
      expect(scaled.copyWith(side: lerped.side), lerped);
    });

    test('copyWith keeps the cubics of a lerped border', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final lerped = start.lerpTo(end, 0.5)! as MaterialShapeBorder;
      final MaterialShapeBorder copy = lerped.copyWith(
        side: const BorderSide(width: 3.0),
        squash: 0.5,
      );

      expect(copy.shape, isNull);
      expect(copy.side, const BorderSide(width: 3.0));
      expect(copy.squash, 0.5);
      expect(copy, isNot(lerped));
      expect(copy.copyWith(side: lerped.side, squash: lerped.squash), lerped);
    });

    test('copyWith with a shape makes a lerped border lerpable again', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final lerped = start.lerpTo(end, 0.5)! as MaterialShapeBorder;
      final MaterialShapeBorder restored = lerped.copyWith(shape: MaterialShapes.square);

      expect(restored.shape, same(MaterialShapes.square));
      expect(() => restored.lerpTo(end, 0.5), returnsNormally);
    });

    test('lerp returns the endpoints at zero and one', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      expect(start.lerpTo(end, 0.0), same(start));
      expect(start.lerpTo(end, 1.0), same(end));
      expect(end.lerpFrom(start, 0.0), same(start));
      expect(end.lerpFrom(start, 1.0), same(end));

      // Those checks come before the shapes are read, so an already-lerped
      // border passes through instead of throwing.
      final lerped = start.lerpTo(end, 0.5)! as MaterialShapeBorder;
      expect(lerped.lerpTo(end, 0.0), same(lerped));
      expect(lerped.lerpFrom(start, 1.0), same(lerped));
    });

    test('lerp interpolates the side and the squash', () {
      final start = MaterialShapeBorder(
        shape: MaterialShapes.circle,
        side: const BorderSide(width: 2.0),
      );
      final end = MaterialShapeBorder(
        shape: MaterialShapes.square,
        side: const BorderSide(width: 6.0),
        squash: 1.0,
      );

      final forward = start.lerpTo(end, 0.25)! as MaterialShapeBorder;
      expect(forward.shape, isNull);
      expect(forward.side, const BorderSide(width: 3.0));
      expect(forward.squash, 0.25);

      final backward = end.lerpFrom(start, 0.25)! as MaterialShapeBorder;
      expect(backward.side, const BorderSide(width: 3.0));
      expect(backward.squash, 0.25);
    });

    test('lerp throws when a border is already the result of a lerp', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final lerped = start.lerpTo(end, 0.5)! as MaterialShapeBorder;
      expect(lerped.shape, isNull);

      expect(() => lerped.lerpTo(end, 0.5), throwsStateError);
      expect(() => lerped.lerpFrom(start, 0.5), throwsStateError);
      expect(() => start.lerpTo(lerped, 0.5), throwsStateError);
      expect(() => end.lerpFrom(lerped, 0.5), throwsStateError);
      // ShapeBorder.lerp tries lerpFrom on the second border first.
      expect(() => ShapeBorder.lerp(lerped, end, 0.5), throwsStateError);
    });

    test('lerp falls back to the superclass for other border types', () {
      final border = MaterialShapeBorder(shape: unitSquare, side: const BorderSide(width: 4.0));

      expect(border.lerpFrom(const CircleBorder(), 0.5), isNull);
      expect(border.lerpTo(const CircleBorder(), 0.5), isNull);

      // OutlinedBorder scales towards a missing border instead of
      // interpolating.
      expect(border.lerpFrom(null, 0.25), border.scale(0.25));
      expect(border.lerpTo(null, 0.25), border.scale(0.75));
    });
  });
}

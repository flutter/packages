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

    test('copyWith with a shape turns a lerped border back into a shaped one', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final lerped = start.lerpTo(end, 0.5)! as MaterialShapeBorder;
      final MaterialShapeBorder restored = lerped.copyWith(shape: MaterialShapes.square);

      expect(restored.shape, same(MaterialShapes.square));
      // A lerped border interpolates on its own now, so this is a way of
      // discarding the morph rather than the only way of escaping it.
      expect(restored.lerpTo(end, 0.5), end.lerpFrom(restored, 0.5));
    });

    test('scale and copyWith keep a lerped border on its morph', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final lerped = start.lerpTo(end, 0.5)! as MaterialShapeBorder;
      final expected = start.lerpTo(end, 0.25)! as MaterialShapeBorder;

      // Both carry the morph through, so a transition interrupted after its
      // current value was scaled or copied still resumes instead of snapping.
      // The side and the squash are normalized away because those are what
      // scale and copyWith set out to change.
      final scaled = lerped.scale(2.0) as MaterialShapeBorder;
      final resumedFromScale = scaled.lerpTo(start, 0.5)! as MaterialShapeBorder;
      expect(resumedFromScale.copyWith(side: expected.side), expected);

      final MaterialShapeBorder copy = lerped.copyWith(squash: 1.0);
      final resumedFromCopy = copy.lerpTo(start, 0.5)! as MaterialShapeBorder;
      expect(resumedFromCopy.copyWith(squash: expected.squash), expected);
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

    test('lerp resumes the morph of an already lerped border', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final lerped = start.lerpTo(end, 0.5)! as MaterialShapeBorder;
      expect(lerped.shape, isNull);

      // Halfway from progress 0.5 back to the start is progress 0.25 on the
      // same morph, which is what the uninterrupted transition drew there.
      // ShapeBorder.lerp reaches this through lerpFrom on the second border.
      expect(lerped.lerpTo(start, 0.5), start.lerpTo(end, 0.25));
      expect(ShapeBorder.lerp(lerped, start, 0.5), start.lerpTo(end, 0.25));

      // The lerped border can sit on either side of the call, and the target
      // can be either endpoint of its morph, so there are four orderings and
      // each has its own direction to get backwards.
      expect(lerped.lerpTo(end, 0.5), start.lerpTo(end, 0.75));
      expect(start.lerpTo(lerped, 0.5), start.lerpTo(end, 0.25));
      expect(end.lerpTo(lerped, 0.5), start.lerpTo(end, 0.75));
    });

    test('lerp interpolates between two results of the same morph', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final quarter = start.lerpTo(end, 0.25)! as MaterialShapeBorder;
      final threeQuarters = start.lerpTo(end, 0.75)! as MaterialShapeBorder;

      expect(quarter.lerpTo(threeQuarters, 0.5), start.lerpTo(end, 0.5));
    });

    test('lerp resumes the morph for an equal but freshly built shape', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final lerped = start.lerpTo(end, 0.5)! as MaterialShapeBorder;

      // A widget that builds its border inline hands over a new polygon on
      // every build, so matching the endpoints by identity would snap here.
      final rebuilt = MaterialShapeBorder(
        shape: RoundedPolygon.fromFeatures(List<Feature>.of(MaterialShapes.circle.features)),
      );

      expect(rebuilt.shape, isNot(same(MaterialShapes.circle)));
      expect(lerped.lerpTo(rebuilt, 0.5), start.lerpTo(end, 0.25));
    });

    test('lerp keeps the morph across a second interruption', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final first = start.lerpTo(end, 0.5)! as MaterialShapeBorder;
      final second = first.lerpTo(start, 0.5)! as MaterialShapeBorder;

      expect(second, start.lerpTo(end, 0.25));
      // The result of the first interruption is on the morph too, so a second
      // one resumes instead of falling off it.
      expect(second.lerpTo(end, 0.5), start.lerpTo(end, 0.625));
    });

    test('lerp snaps instead of throwing when there is no shared morph', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);
      final third = MaterialShapeBorder(shape: MaterialShapes.triangle);

      final lerped = start.lerpTo(end, 0.5)! as MaterialShapeBorder;
      final other = start.lerpTo(third, 0.5)! as MaterialShapeBorder;

      // A third shape is on neither end of the morph, and the two lerped
      // borders are on different morphs. All four of ShapeBorder.lerp's
      // attempts decline, which is what lets it reach its own fallback.
      expect(lerped.lerpTo(third, 0.5), isNull);
      expect(third.lerpFrom(lerped, 0.5), isNull);
      expect(lerped.lerpFrom(third, 0.5), isNull);
      expect(third.lerpTo(lerped, 0.5), isNull);
      expect(lerped.lerpTo(other, 0.5), isNull);

      expect(ShapeBorder.lerp(lerped, third, 0.25), same(lerped));
      expect(ShapeBorder.lerp(lerped, third, 0.75), same(third));
    });

    testWidgets('an interrupted AnimatedContainer transition does not throw', (
      WidgetTester tester,
    ) async {
      Widget buildFrame(RoundedPolygon shape) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 100,
            height: 100,
            decoration: ShapeDecoration(
              color: const Color(0xFF00FF00),
              shape: MaterialShapeBorder(shape: shape),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildFrame(MaterialShapes.circle));
      await tester.pumpWidget(buildFrame(MaterialShapes.square));
      await tester.pump(const Duration(milliseconds: 150));

      // Each of these restarts the tween from the half-morphed border that is
      // on screen, which is the value that used to have no shape to lerp with.
      await tester.pumpWidget(buildFrame(MaterialShapes.circle));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpWidget(buildFrame(MaterialShapes.triangle));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    test('lerp keeps a separate morph for each pair of shapes', () {
      final circle = MaterialShapeBorder(shape: MaterialShapes.circle);
      final square = MaterialShapeBorder(shape: MaterialShapes.square);
      final triangle = MaterialShapeBorder(shape: MaterialShapes.triangle);

      final ShapeBorder? toSquare = circle.lerpTo(square, 0.5);
      final ShapeBorder? toTriangle = circle.lerpTo(triangle, 0.5);

      expect(toSquare, isNot(toTriangle));
      // Both pairs are cached at once, and neither hands back the other's
      // morph.
      expect(circle.lerpTo(square, 0.5), toSquare);
      expect(circle.lerpTo(triangle, 0.5), toTriangle);
    });

    test('lerp keeps a separate morph for each direction', () {
      final circle = MaterialShapeBorder(shape: MaterialShapes.circle);
      final square = MaterialShapeBorder(shape: MaterialShapes.square);

      final ShapeBorder? forward = circle.lerpTo(square, 0.25);
      final ShapeBorder? backward = square.lerpTo(circle, 0.25);

      expect(forward, isNot(backward));
      expect(circle.lerpTo(square, 0.25), forward);
      expect(square.lerpTo(circle, 0.25), backward);
    });

    test('lerp stays correct once the morph cache evicts entries', () {
      final circle = MaterialShapeBorder(shape: MaterialShapes.circle);
      final square = MaterialShapeBorder(shape: MaterialShapes.square);

      final ShapeBorder? expected = circle.lerpTo(square, 0.5);

      // More distinct pairs than the cache holds, so the pair above is pushed
      // out of it.
      for (final RoundedPolygon shape in MaterialShapes.all.take(10)) {
        circle.lerpTo(MaterialShapeBorder(shape: shape), 0.5);
      }

      expect(circle.lerpTo(square, 0.5), expected);
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

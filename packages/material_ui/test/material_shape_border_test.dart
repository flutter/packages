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

    test('== compares lerp results by value', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final ShapeBorder? first = start.lerpTo(end, 0.5);
      final ShapeBorder? second = start.lerpTo(end, 0.5);
      final ShapeBorder? reverse = end.lerpFrom(start, 0.5);

      expect(identical(first, second), isFalse);
      expect(first, second);
      expect(reverse, first);
    });

    test('hashCode hashes lerp results by value', () {
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
      final List<PolygonFeature> features = MaterialShapes.circle.features;
      final border = MaterialShapeBorder(shape: RoundedPolygon.fromFeatures(features));
      final other = MaterialShapeBorder(
        shape: RoundedPolygon.fromFeatures(List<PolygonFeature>.of(features)),
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
        'MaterialShapeBorder(shape: $unitSquare, '
        'side: BorderSide(width: 0.0, style: none), squash: 0.5)',
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

    test('getInnerPath returns an empty path when the side swallows the rect', () {
      const rect = Rect.fromLTWH(0.0, 0.0, 16.0, 16.0);

      // The stroke inset (10.0) is larger than half of the rect's size
      // (16.0 / 2), so deflating the rect by it produces negative dimensions.
      final border = MaterialShapeBorder(shape: unitSquare, side: const BorderSide(width: 10.0));

      final Path path = border.getInnerPath(rect);
      expect(path.getBounds(), Rect.zero);
      expect(path.computeMetrics(), isEmpty);
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

    test('lerping different shapes does not return a MaterialShapeBorder', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      // The shape in between is not a RoundedPolygon, so it can't be
      // represented by a MaterialShapeBorder.
      expect(start.lerpTo(end, 0.5), isA<OutlinedBorder>());
      expect(start.lerpTo(end, 0.5), isNot(isA<MaterialShapeBorder>()));
      expect(end.lerpFrom(start, 0.5), isNot(isA<MaterialShapeBorder>()));
    });

    test('lerp result toString', () {
      final start = MaterialShapeBorder(shape: unitSquare);
      final end = MaterialShapeBorder(shape: MaterialShapes.circle, squash: 1.0);

      expect(
        start.lerpTo(end, 0.25).toString(),
        'MaterialShapeBorder(side: BorderSide(width: 0.0, style: none), squash: 0.25, '
        '25.0% of the way from $unitSquare to ${MaterialShapes.circle})',
      );
    });

    test('scale keeps the morph of a lerped border', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(
        shape: MaterialShapes.square,
        side: const BorderSide(width: 2.0),
      );

      final lerped = start.lerpTo(end, 0.5)! as OutlinedBorder;
      final scaled = lerped.scale(2.0) as OutlinedBorder;

      expect(scaled, isNot(isA<MaterialShapeBorder>()));
      expect(scaled.side, lerped.side.scale(2.0));
      // The morph survives the scale, so restoring the side restores the
      // border.
      expect(scaled.copyWith(side: lerped.side), lerped);
    });

    test('copyWith keeps the morph of a lerped border', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final lerped = start.lerpTo(end, 0.5)! as OutlinedBorder;
      final OutlinedBorder copy = lerped.copyWith(side: const BorderSide(width: 3.0));

      expect(copy, isNot(isA<MaterialShapeBorder>()));
      expect(copy.side, const BorderSide(width: 3.0));
      expect(copy, isNot(lerped));
      expect(copy.copyWith(side: lerped.side), lerped);
    });

    test('scale and copyWith keep a lerped border on its morph', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final lerped = start.lerpTo(end, 0.5)! as OutlinedBorder;
      final expected = start.lerpTo(end, 0.25)! as OutlinedBorder;

      // Both carry the morph through, so a transition interrupted after its
      // current value was scaled or copied still resumes instead of snapping.
      // The side is normalized away because that is what scale and copyWith
      // set out to change.
      final scaled = lerped.scale(2.0) as OutlinedBorder;
      final resumedFromScale = scaled.lerpTo(start, 0.5)! as OutlinedBorder;
      expect(resumedFromScale.copyWith(side: expected.side), expected);

      final OutlinedBorder copy = lerped.copyWith(side: const BorderSide(width: 3.0));
      final resumedFromCopy = copy.lerpTo(start, 0.5)! as OutlinedBorder;
      expect(resumedFromCopy.copyWith(side: expected.side), expected);
    });

    test('lerp returns the endpoints at zero and one', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      expect(start.lerpTo(end, 0.0), same(start));
      expect(start.lerpTo(end, 1.0), same(end));
      expect(end.lerpFrom(start, 0.0), same(start));
      expect(end.lerpFrom(start, 1.0), same(end));

      // The same holds for a border that is already the result of a lerp.
      final lerped = start.lerpTo(end, 0.5)! as OutlinedBorder;
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

      final forward = start.lerpTo(end, 0.25)! as OutlinedBorder;
      expect(forward.side, const BorderSide(width: 3.0));

      final backward = end.lerpFrom(start, 0.25)! as OutlinedBorder;
      expect(backward.side, const BorderSide(width: 3.0));

      // A lerp result doesn't expose its squash, so compare it with a lerp
      // whose side and squash stay at the expected values throughout.
      final ShapeBorder? expected =
          MaterialShapeBorder(
            shape: MaterialShapes.circle,
            side: const BorderSide(width: 3.0),
            squash: 0.25,
          ).lerpTo(
            MaterialShapeBorder(
              shape: MaterialShapes.square,
              side: const BorderSide(width: 3.0),
              squash: 0.25,
            ),
            0.25,
          );
      expect(forward, expected);
      expect(backward, expected);
    });

    test('lerp between borders with equal shapes keeps the shape', () {
      final start = MaterialShapeBorder(
        shape: MaterialShapes.circle,
        side: const BorderSide(width: 2.0),
      );
      final end = MaterialShapeBorder(
        shape: MaterialShapes.circle,
        side: const BorderSide(width: 4.0),
        squash: 1.0,
      );

      // Only the side and the squash animate, so no morph is needed and the
      // result keeps the shape instead of becoming a lerp result.
      final lerped = start.lerpTo(end, 0.25)! as MaterialShapeBorder;
      expect(lerped.shape, MaterialShapes.circle);
      expect(lerped.side, const BorderSide(width: 2.5));
      expect(lerped.squash, 0.25);

      // Interrupting the animation and redirecting it toward another border
      // with the same shape continues from the current state instead of
      // restarting.
      final redirected = lerped.lerpTo(end, 0.5)! as MaterialShapeBorder;
      expect(redirected.shape, MaterialShapes.circle);
      expect(redirected.side, const BorderSide(width: 3.25));
      expect(redirected.squash, 0.625);
    });

    test('lerp clamps the squash when t overshoots', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.circle, squash: 1.0);

      final overshot = start.lerpTo(end, 1.5)! as MaterialShapeBorder;
      expect(overshot.squash, 1.0);

      final undershot = start.lerpTo(end, -0.5)! as MaterialShapeBorder;
      expect(undershot.squash, 0.0);

      // A morph clamps the same way, so it draws like the in-range border.
      final square = MaterialShapeBorder(shape: MaterialShapes.square, squash: 1.0);
      final expected = MaterialShapeBorder(shape: MaterialShapes.circle, squash: 1.0);
      expect(start.lerpTo(square, 1.5), expected.lerpTo(square, 1.5));
    });

    test('lerp resumes the morph of an already lerped border', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final lerped = start.lerpTo(end, 0.5)! as OutlinedBorder;

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

      final quarter = start.lerpTo(end, 0.25)! as OutlinedBorder;
      final threeQuarters = start.lerpTo(end, 0.75)! as OutlinedBorder;

      expect(quarter.lerpTo(threeQuarters, 0.5), start.lerpTo(end, 0.5));
    });

    test('lerp resumes between morphs of the same shapes in opposite directions', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final forward = start.lerpTo(end, 0.25)! as OutlinedBorder;
      final backward = end.lerpTo(start, 0.25)! as OutlinedBorder;

      // backward sits at 0.75 of the morph forward is on, so lerping between
      // the two resumes along that shared morph instead of snapping.
      expect(forward.lerpTo(backward, 0.5), start.lerpTo(end, 0.5));
      expect(backward.lerpTo(forward, 0.5), end.lerpTo(start, 0.5));
    });

    test('lerp resumes the morph for an equal but freshly built shape', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final lerped = start.lerpTo(end, 0.5)! as OutlinedBorder;

      // A widget that builds its border inline hands over a new polygon on
      // every build, so matching the endpoints by identity would snap here.
      final rebuilt = MaterialShapeBorder(
        shape: RoundedPolygon.fromFeatures(
          List<PolygonFeature>.of(MaterialShapes.circle.features),
          center: MaterialShapes.circle.center,
        ),
      );

      expect(rebuilt.shape, isNot(same(MaterialShapes.circle)));
      expect(lerped.lerpTo(rebuilt, 0.5), start.lerpTo(end, 0.25));
    });

    test('lerp keeps the morph across a second interruption', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);

      final first = start.lerpTo(end, 0.5)! as OutlinedBorder;
      final second = first.lerpTo(start, 0.5)! as OutlinedBorder;

      expect(second, start.lerpTo(end, 0.25));
      // The result of the first interruption is on the morph too, so a second
      // one resumes instead of falling off it.
      expect(second.lerpTo(end, 0.5), start.lerpTo(end, 0.625));
    });

    test('lerp snaps instead of throwing when there is no shared morph', () {
      final start = MaterialShapeBorder(shape: MaterialShapes.circle);
      final end = MaterialShapeBorder(shape: MaterialShapes.square);
      final third = MaterialShapeBorder(shape: MaterialShapes.triangle);

      final lerped = start.lerpTo(end, 0.5)! as OutlinedBorder;
      final other = start.lerpTo(third, 0.5)! as OutlinedBorder;

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

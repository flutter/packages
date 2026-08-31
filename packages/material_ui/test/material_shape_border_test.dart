// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('$MaterialShapeBorder', () {
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
  });
}

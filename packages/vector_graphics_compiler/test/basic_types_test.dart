// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  test('Point tests', () {
    expect(Point.zero.x, 0);
    expect(Point.zero.y, 0);

    expect(const Point(5, 5) / 2, const Point(2.5, 2.5));
    expect(const Point(5, 5) * 2, const Point(10, 10));
  });

  test('Point distance', () {
    expect(Point.distance(Point.zero, Point.zero), 0);
    expect(Point.distance(Point.zero, const Point(1, 0)), 1);
    expect(Point.distance(Point.zero, const Point(0, 1)), 1);
    expect(Point.distance(Point.zero, const Point(1, 1)), 1.4142135623730951);
  });

  test('Point lerp', () {
    expect(Point.lerp(Point.zero, Point.zero, .3), Point.zero);
    expect(Point.lerp(Point.zero, const Point(1, 0), .5), const Point(.5, 0));
  });

  test('Rect tests', () {
    expect(Rect.zero.left, 0);
    expect(Rect.zero.top, 0);
    expect(Rect.zero.right, 0);
    expect(Rect.zero.bottom, 0);

    expect(
      const Rect.fromLTRB(1, 2, 3, 4)
          .expanded(const Rect.fromLTRB(0, 0, 10, 10)),
      const Rect.fromLTRB(0, 0, 10, 10),
    );

    expect(
      const Rect.fromCircle(10, 10, 5),
      const Rect.fromLTWH(5, 5, 10, 10),
    );
  });
}

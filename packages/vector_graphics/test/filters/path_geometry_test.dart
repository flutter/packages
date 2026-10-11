// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/filters/path_geometry.dart';

void main() {
  final identity = Float64List.fromList(<double>[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
  test('empty paths have no geometry and moves retain zero-length subpaths', () {
    final path = FilterPathGeometry();
    expect(path.bounds(identity), isNull);
    path.moveTo(100, 100);
    expect(path.bounds(identity), const Rect.fromLTRB(100, 100, 100, 100));
  });
  test('line contours preserve zero dimensions and isolated moves', () {
    final path = FilterPathGeometry()
      ..moveTo(10, 20)
      ..lineTo(30, 20)
      ..close()
      ..moveTo(100, 100);
    expect(path.bounds(identity), const Rect.fromLTRB(10, 20, 100, 100));
  });
  test('cubic extrema with a linear derivative exclude control points', () {
    final path = FilterPathGeometry()
      ..moveTo(16, 112)
      ..cubicTo(16, -16, 112, -16, 112, 112)
      ..close();
    expect(path.bounds(identity), const Rect.fromLTRB(16, 16, 112, 112));
  });
  test('cubic with two interior extrema includes both', () {
    final path = FilterPathGeometry()..cubicTo(1, 3, 2, -3, 3, 0);
    final Rect bounds = path.bounds(identity)!;
    expect(bounds.left, 0);
    expect(bounds.right, 3);
    expect(bounds.top, closeTo(-math.sqrt(3) / 2, 1e-12));
    expect(bounds.bottom, closeTo(math.sqrt(3) / 2, 1e-12));
  });
  test('monotone and constant cubic coordinates need no interior extrema', () {
    final path = FilterPathGeometry()
      ..moveTo(2, 5)
      ..cubicTo(4, 5, 6, 5, 8, 5);
    expect(path.bounds(identity), const Rect.fromLTRB(2, 5, 8, 5));
  });
  test('rotation computes extrema in the target coordinate space', () {
    final path = FilterPathGeometry()
      ..moveTo(0, 0)
      ..cubicTo(0, 4, 4, 4, 4, 0);
    final transform = Float64List.fromList(identity);
    final double a = math.sqrt(.5);
    transform[0] = transform[1] = transform[5] = a;
    transform[4] = -a;
    final Rect bounds = path.bounds(transform)!;
    expect(bounds.left, closeTo(a * (4 - 4 * math.sqrt(2)), 1e-12));
    expect(bounds.bottom, closeTo(a * 4 * math.sqrt(2), 1e-12));
    expect(bounds.top, 0);
    expect(bounds.right, closeTo(4 * a, 1e-12));
  });
}

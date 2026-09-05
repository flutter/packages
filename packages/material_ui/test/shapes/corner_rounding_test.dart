// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/corner_rounding.dart';

void main() {
  test('$CornerRounding()', () {
    // ignore: use_named_constants
    const defaultCorner = CornerRounding();
    expect(defaultCorner.radius, 0);
    expect(defaultCorner.smoothing, 0);

    const CornerRounding unrounded = CornerRounding.unrounded;
    expect(unrounded.radius, 0);
    expect(unrounded.smoothing, 0);

    const rounded = CornerRounding(radius: 5);
    expect(rounded.radius, 5);
    expect(rounded.smoothing, 0);

    const smoothed = CornerRounding(smoothing: 0.5);
    expect(smoothed.radius, 0);
    expect(smoothed.smoothing, 0.5);

    const roundedAndSmoothed = CornerRounding(radius: 5, smoothing: 0.5);
    expect(roundedAndSmoothed.radius, 5);
    expect(roundedAndSmoothed.smoothing, 0.5);
  });

  test('$CornerRounding rejects out of range values', () {
    expect(() => CornerRounding(radius: -1), throwsAssertionError);
    expect(() => CornerRounding(smoothing: -1), throwsAssertionError);
    expect(() => CornerRounding(smoothing: 1.1), throwsAssertionError);
  });

  test('$CornerRounding equality', () {
    expect(
      const CornerRounding(radius: 5, smoothing: 0.5),
      const CornerRounding(radius: 5, smoothing: 0.5),
    );
    expect(
      const CornerRounding(radius: 5, smoothing: 0.5).hashCode,
      const CornerRounding(radius: 5, smoothing: 0.5).hashCode,
    );

    // ignore: use_named_constants
    expect(const CornerRounding(), CornerRounding.unrounded);

    expect(const CornerRounding(radius: 5), isNot(const CornerRounding(radius: 6)));
    expect(const CornerRounding(smoothing: 0.5), isNot(const CornerRounding(smoothing: 0.6)));
    expect(const CornerRounding(radius: 1), isNot(const CornerRounding(smoothing: 1)));

    expect(
      const CornerRounding(radius: 1, smoothing: 0.5).hashCode,
      isNot(const CornerRounding(radius: 1, smoothing: 0.6).hashCode),
    );
    expect(
      const CornerRounding(radius: 1, smoothing: 0.5).hashCode,
      isNot(const CornerRounding(radius: 2, smoothing: 0.5).hashCode),
    );
  });

  test('$CornerRounding toString', () {
    expect(
      const CornerRounding(radius: 5, smoothing: 0.5).toString(),
      'CornerRounding(radius: 5.0, smoothing: 0.5)',
    );
  });
}

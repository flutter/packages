// ignore_for_file: document_ignores

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/shapes/shapes.dart';

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
}

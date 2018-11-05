import 'dart:ui' show PathFillType;

import 'package:flutter_svg/src/svg/parsers.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  test('SVG value parser tests', () {
    expect(() => parseTransform('invalid'), throwsStateError);
    expect(() => parseTransform('transformunsupported(0,0)'), throwsStateError);

    expect(parseTransform('skewX(60)'), Matrix4.skewX(60.0));
    expect(parseTransform('skewY(60)'), Matrix4.skewY(60.0));
    expect(parseTransform('translate(10)'),
        Matrix4.translationValues(10.0, 10.0, 0.0));
    expect(parseTransform('translate(10, 15)'),
        Matrix4.translationValues(10.0, 15.0, 0.0));

    expect(parseTransform('scale(10)'),
        Matrix4.identity()..scale(10.0, 10.0, 1.0));
    expect(parseTransform('scale(10, 15)'),
        Matrix4.identity()..scale(10.0, 15.0, 1.0));

    expect(parseTransform('rotate(20)'), Matrix4.rotationZ(radians(20.0)));
    expect(
        parseTransform('rotate(20, 30)'),
        Matrix4.identity()
          ..translate(30.0, 30.0)
          ..rotateZ(radians(20.0))
          ..translate(-30.0, -30.0));
    expect(
        parseTransform('rotate(20, 30, 40)'),
        Matrix4.identity()
          ..translate(30.0, 40.0)
          ..rotateZ(radians(20.0))
          ..translate(-30.0, -40.0));

    expect(
        parseTransform('matrix(1.5, 2.0, 3.0, 4.0, 5.0, 6.0)'),
        Matrix4.fromList(<double>[
          1.5,
          2.0,
          0.0,
          0.0,
          3.0,
          4.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          5.0,
          6.0,
          0.0,
          1.0
        ]));

    expect(parseRawFillRule(''), PathFillType.nonZero);
    expect(parseRawFillRule(null), isNull);
    expect(parseRawFillRule('inherit'), isNull);
    expect(parseRawFillRule('nonzero'), PathFillType.nonZero);
    expect(parseRawFillRule('evenodd'), PathFillType.evenOdd);
    expect(parseRawFillRule('invalid'), PathFillType.nonZero);
  });
}

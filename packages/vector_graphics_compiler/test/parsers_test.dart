import 'package:vector_graphics_compiler/src/svg/numbers.dart';
import 'package:vector_graphics_compiler/src/svg/parsers.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'package:test/test.dart';

void main() {
  test('Multiple matrix translates', () {
    final AffineMatrix expected = AffineMatrix.identity
        .translated(0.338957, 0.010104)
        .translated(-0.5214, 0.125)
        .translated(0.987, 0.789);
    expect(
      parseTransform(
        'translate(0.338957,0.010104), translate(-0.5214,0.125),translate(0.987,0.789)',
      ),
      expected,
    );
  });

  test('Translate and scale matrix', () {
    final AffineMatrix expected = AffineMatrix.identity
        .translated(0.338957, 0.010104)
        .scaled(0.869768, 1.000000);
    expect(
      parseTransform(
        'translate(0.338957,0.010104),scale(0.869768,1.000000)',
      ),
      expected,
    );
  });

  test('SVG Transform parser tests', () {
    expect(() => parseTransform('invalid'), throwsStateError);
    expect(() => parseTransform('transformunsupported(0,0)'), throwsStateError);

    expect(
      parseTransform('skewX(60)'),
      AffineMatrix.identity.xSkewed(60.0),
    );
    expect(
      parseTransform('skewY(60)'),
      AffineMatrix.identity.ySkewed(60.0),
    );
    expect(
      parseTransform('translate(10,0.0)'),
      AffineMatrix.identity.translated(10.0, 0.0),
    );

    expect(
      parseTransform('scale(10)'),
      AffineMatrix.identity.scaled(10.0, 10.0),
    );
    expect(
      parseTransform('scale(10, 15)'),
      AffineMatrix.identity.scaled(10.0, 15.0),
    );

    expect(
      parseTransform('rotate(20)'),
      AffineMatrix.identity.rotated(radians(20.0)),
    );
    expect(
      parseTransform('rotate(20, 30)'),
      AffineMatrix.identity
          .translated(30.0, 30.0)
          .rotated(radians(20.0))
          .translated(-30.0, -30.0),
    );
    expect(
      parseTransform('rotate(20, 30, 40)'),
      AffineMatrix.identity
          .translated(30.0, 40.0)
          .rotated(radians(20.0))
          .translated(-30.0, -40.0),
    );

    expect(
      parseTransform('matrix(1.5, 2.0, 3.0, 4.0, 5.0, 6.0)'),
      const AffineMatrix(1.5, 2.0, 3.0, 4.0, 5.0, 6.0),
    );

    expect(
      parseTransform('matrix(1.5, 2.0, 3.0, 4.0, 5.0, 6.0 )'),
      const AffineMatrix(1.5, 2.0, 3.0, 4.0, 5.0, 6.0),
    );

    expect(
      parseTransform('rotate(20)\n\tscale(10)'),
      AffineMatrix.identity.rotated(radians(20.0)).scaled(10.0, 10.0),
    );
  });

  test('FillRule tests', () {
    expect(parseRawFillRule(''), PathFillType.nonZero);
    expect(parseRawFillRule(null), isNull);
    expect(parseRawFillRule('inherit'), isNull);
    expect(parseRawFillRule('nonzero'), PathFillType.nonZero);
    expect(parseRawFillRule('evenodd'), PathFillType.evenOdd);
    expect(parseRawFillRule('invalid'), PathFillType.nonZero);
  });
}

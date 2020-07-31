import 'dart:ui' show PathFillType;

import 'package:flutter_svg/parser.dart';
import 'package:flutter_svg/src/svg/parsers.dart';
import 'package:flutter_svg/src/vector_drawable.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  test('SVG Multiple transform parser tests', () {
    Matrix4 expected = Matrix4.identity();
    expected.translate(0.338957, 0.010104, 0);
    expected.translate(-0.5214, 0.125, 0);
    expected.translate(0.987, 0.789, 0);
    expect(
        parseTransform(
            'translate(0.338957,0.010104), translate(-0.5214,0.125),translate(0.987,0.789)'),
        expected);

    expected = Matrix4.translationValues(0.338957, 0.010104, 0);
    expected.scale(0.869768, 1.000000, 1.0);
    expect(
        parseTransform('translate(0.338957,0.010104),scale(0.869768,1.000000)'),
        expected);
  });

  test('SVG Transform parser tests', () {
    expect(() => parseTransform('invalid'), throwsStateError);
    expect(() => parseTransform('transformunsupported(0,0)'), throwsStateError);

    expect(parseTransform('skewX(60)'), Matrix4.skewX(60.0));
    expect(parseTransform('skewY(60)'), Matrix4.skewY(60.0));
    expect(parseTransform('translate(10,0.0)'),
        Matrix4.translationValues(10.0, 0.0, 0.0));
    expect(parseTransform('skewX(60)'), Matrix4.skewX(60.0));

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
          1.5, 2.0, 0.0, 0.0, //
          3.0, 4.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0,
          5.0, 6.0, 0.0, 1.0
        ]));

    expect(
        parseTransform('matrix(1.5, 2.0, 3.0, 4.0, 5.0, 6.0 )'),
        Matrix4.fromList(<double>[
          1.5, 2.0, 0.0, 0.0, //
          3.0, 4.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0,
          5.0, 6.0, 0.0, 1.0
        ]));

    expect(parseTransform('rotate(20)\n\tscale(10)'),
        Matrix4.rotationZ(radians(20.0))..scale(10.0, 10.0, 1.0));
  });

  test('FillRule tests', () {
    expect(parseRawFillRule(''), PathFillType.nonZero);
    expect(parseRawFillRule(null), isNull);
    expect(parseRawFillRule('inherit'), isNull);
    expect(parseRawFillRule('nonzero'), PathFillType.nonZero);
    expect(parseRawFillRule('evenodd'), PathFillType.evenOdd);
    expect(parseRawFillRule('invalid'), PathFillType.nonZero);
  });

  test('TextAnchor tests', () {
    expect(parseTextAnchor(''), DrawableTextAnchorPosition.start);
    expect(parseTextAnchor(null), DrawableTextAnchorPosition.start);
    expect(parseTextAnchor('inherit'), isNull);
    expect(parseTextAnchor('start'), DrawableTextAnchorPosition.start);
    expect(parseTextAnchor('middle'), DrawableTextAnchorPosition.middle);
    expect(parseTextAnchor('end'), DrawableTextAnchorPosition.end);
  });

  test('Font size parsing tests', () {
    expect(parseFontSize(null), isNull);
    expect(parseFontSize(''), isNull);
    expect(parseFontSize('1'), 1);
    expect(parseFontSize('  1 '), 1);
    expect(parseFontSize('xx-small'), 10);
    expect(parseFontSize('x-small'), 12);
    expect(parseFontSize('small'), 14);
    expect(parseFontSize('medium'), 18);
    expect(parseFontSize('large'), 22);
    expect(parseFontSize('x-large'), 26);
    expect(parseFontSize('xx-large'), 32);

    expect(parseFontSize('larger'), parseFontSize('large'));
    expect(parseFontSize('larger', parentValue: parseFontSize('large')),
        parseFontSize('large') * 1.2);
    expect(parseFontSize('smaller'), parseFontSize('small'));
    expect(parseFontSize('smaller', parentValue: parseFontSize('large')),
        parseFontSize('large') / 1.2);

    expect(() => parseFontSize('invalid'),
        throwsA(const TypeMatcher<StateError>()));
  });

  test('Empty text', () async {
    final SvgParser parser = SvgParser();
    final DrawableRoot root =
        await parser.parse('<svg viewBox="0 0 10 10"><text /></svg>');
    expect(root.children.isEmpty, true);
  });
}

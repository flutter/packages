// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/src/svg/node.dart';
import 'package:vector_graphics_compiler/src/svg/numbers.dart';
import 'package:vector_graphics_compiler/src/svg/parser.dart';
import 'package:vector_graphics_compiler/src/svg/parsers.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  test('Colors', () {
    final parser = SvgParser('', const SvgTheme(), 'test_key', true, null);
    expect(parser.parseColor('null', attributeName: 'foo', id: null), null);
    expect(
      parser.parseColor('red', attributeName: 'foo', id: null),
      const Color.fromARGB(255, 255, 0, 0),
    );
    expect(
      parser.parseColor('#ABCDEF', attributeName: 'foo', id: null),
      const Color.fromARGB(255, 0xAB, 0xCD, 0xEF),
    );
  });

  group('Colors - svg/css', () {
    final parser = SvgParser('', const SvgTheme(), 'test_key', true, null);

    group('with no opacity', () {
      const rgbContentVariations = [
        // Legacy syntax (comma-separated)
        '171, 205, 239',
        '171,205,239',
        // Modern syntax (space-separated)
        '171 205 239',
        // Percentage values
        '67% 80.5% 93.7%',
        // Mixed percentage and decimal (space-separated)
        '67% 205 93.7%',
        // Decimal RGB values
        '171.1 205.1 238.9',
      ];

      final List<String> rgbaVariations = [
        '#ABCDEF',
        ...rgbContentVariations.map((rgb) => 'rgba($rgb)'),
        ...rgbContentVariations.map((rgb) => 'rgb($rgb)'),
      ];

      for (final rgba in rgbaVariations) {
        test(rgba, () {
          expect(
            parser.parseColor(rgba, attributeName: 'foo', id: null),
            const Color.fromARGB(0xFF, 0xAB, 0xCD, 0xEF),
          );
        });
      }
    });

    group('with opacity', () {
      const rgbContentVariations = [
        // Legacy syntax (comma-separated)
        '171, 205, 239, 0.53',
        '171,205,239,0.53',
        // Modern syntax (space-separated with slash before alpha)
        '171 205 239 / 53%',
        '171 205 239 /  0.53',
        '171 205 239 /  .53', // leading dot
        '171 205 239 / 0.53',
        // Percentage RGB with slash alpha
        '67% 80.5% 93.7% / 53%',
        // Mixed percentage and decimal RGB (space-separated) with slash alpha
        '67% 205 93.7% / 53%',
        // Decimal RGB values with percentage alpha
        '171.1 205.1 238.9 / 53%',
        // Decimal RGB values with decimal alpha
        '171.1 205.1 238.9 / 0.53',
      ];

      final List<String> rgbaVariations = [
        '#ABCDEF87',
        ...rgbContentVariations.map((rgb) => 'rgba($rgb)'),
        ...rgbContentVariations.map((rgb) => 'rgb($rgb)'),
      ];

      for (final rgba in rgbaVariations) {
        test(rgba, () {
          expect(
            parser.parseColor(rgba, attributeName: 'foo', id: null),
            const Color.fromARGB(0x87, 0xAB, 0xCD, 0xEF),
          );
        });
      }
    });

    group('with values out of bounds', () {
      // RGB values > 255 clamp to 255, negative values clamp to 0
      // Percentages > 100% clamp to 100%, negative percentages clamp to 0%
      // Alpha values > 1 clamp to 1, negative alpha clamps to 0

      test('rgb(256.9, 0, 256) clamps RGB to 255', () {
        expect(
          parser.parseColor(
            'rgb(256.9, 0, 256)',
            attributeName: 'foo',
            id: null,
          ),
          const Color.fromARGB(255, 255, 0, 255),
        );
      });

      test('rgb(-50, 300, -100) clamps negative to 0 and >255 to 255', () {
        expect(
          parser.parseColor(
            'rgb(-50, 300, -100)',
            attributeName: 'foo',
            id: null,
          ),
          const Color.fromARGB(255, 0, 255, 0),
        );
      });

      test('rgb(120%, -10%, 200%) clamps percentages', () {
        expect(
          parser.parseColor(
            'rgb(120%, -10%, 200%)',
            attributeName: 'foo',
            id: null,
          ),
          const Color.fromARGB(255, 255, 0, 255),
        );
      });

      test('rgb(255, 0, 255, -0.5) negative alpha clamps to 0', () {
        expect(
          parser.parseColor(
            'rgb(255, 0, 255, -0.5)',
            attributeName: 'foo',
            id: null,
          ),
          const Color.fromARGB(0, 255, 0, 255),
        );
      });

      test('rgb(128, 128, 128, 2.5) alpha > 1 clamps to 1', () {
        expect(
          parser.parseColor(
            'rgb(128, 128, 128, 2.5)',
            attributeName: 'foo',
            id: null,
          ),
          const Color.fromARGB(255, 128, 128, 128),
        );
      });

      test('rgb(999 -50 300 / 150%) clamps all values', () {
        expect(
          parser.parseColor(
            'rgb(999 -50 300 / 150%)',
            attributeName: 'foo',
            id: null,
          ),
          const Color.fromARGB(255, 255, 0, 255),
        );
      });
    });

    group('invalid syntax', () {
      const rgbContentVariations = [
        // 4 space-separated values without slash (modern syntax requires slash before alpha)
        '171.1 205.1 238.9 53%',
        '255 255 255 0.5',
        '255 122 127 80%',
        // Mixed comma and slash separators (not allowed)
        '171.1,205.1 238.9/53%',
        '255, 255, 255 / 0.5',
        // Space-separated values after comma (not allowed)
        '171.1,205.1 238.9, 53%',
        '129% ,09% 255%,5.5',
        // Single comma with 4 values (legacy alpha needs 2+ commas)
        '129% 09% 255%,5.5',
        // Empty values (double comma, leading comma, trailing comma)
        '67%,,93.7%, 53%',
        '10,,10',
        '50,90,,0',
        '255, 128, 0,',
        // Slash between RGB values (slash only allowed before alpha)
        '255 / 255 / 255',
        // Too few values
        '255 255',
        // Too many values
        '255 255 255 128 64',
        // Missing alpha after slash
        '255 255 255 /',
        // Mixed separators: spaces before first comma, then commas (no alpha)
        //  Note: This actually parses correctly on css(web) but it's not valid as per the spec.
        '171 205,239',
        // Mixed separators: spaces before first comma, then commas (decimal alpha)
        //  Note: This actually parses correctly on css(web) but it's not valid as per the spec.
        '171 205,239, 0.53',
        // Mixed separators: spaces before first comma, then commas (percentage alpha)
        //  Note: This actually parses correctly on css(web) but it's not valid as per the spec.
        '171   205,239, 53%',
      ];

      final List<String> rgbaVariations = [
        ...rgbContentVariations.map((rgb) => 'rgba($rgb)'),
        ...rgbContentVariations.map((rgb) => 'rgb($rgb)'),
      ];

      for (final rgba in rgbaVariations) {
        test(rgba, () {
          expect(
            () => parser.parseColor(rgba, attributeName: 'foo', id: null),
            throwsArgumentError,
          );
        });
      }
    });
  });

  test('Colors - mapped', () async {
    final mapper = TestColorMapper();
    final parser =
        SvgParser(
            '<svg viewBox="0 0 10 10"><rect id="rect1" x="1" y="1" width="5" height="5" fill="red" /></svg>',
            const SvgTheme(),
            'test_key',
            true,
            mapper,
          )
          ..enableMaskingOptimizer = false
          ..enableClippingOptimizer = false
          ..enableOverdrawOptimizer = false;
    final VectorInstructions instructions = parser.parse();

    // TestMapper just always returns this color.
    expect(
      instructions.paints.single.fill!.color,
      const Color.fromARGB(255, 255, 0, 255),
    );

    // TestMapper should have gotten the ID/element name/attribute name from the rect.
    expect(mapper.lastId, 'rect1');
    expect(mapper.lastElementName, 'rect');
    expect(mapper.lastAttributeName, 'fill');
    expect(mapper.lastColor, const Color.fromARGB(255, 255, 0, 0));
  });

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

  test('Transform has whitespace in params', () {
    expect(
      parseTransform('translate( 50   ,     1160   )'),
      AffineMatrix.identity.translated(50, 1160),
    );
  });

  test('Translate and scale matrix', () {
    final AffineMatrix expected = AffineMatrix.identity
        .translated(0.338957, 0.010104)
        .scaled(0.869768, 1.000000);
    expect(
      parseTransform('translate(0.338957,0.010104),scale(0.869768,1.000000)'),
      expected,
    );
  });

  test('SVG Transform parser tests', () {
    expect(() => parseTransform('invalid'), throwsStateError);
    expect(() => parseTransform('transformunsupported(0,0)'), throwsStateError);

    expect(parseTransform('skewX(60)'), AffineMatrix.identity.xSkewed(60.0));
    expect(parseTransform('skewY(60)'), AffineMatrix.identity.ySkewed(60.0));
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
      const AffineMatrix(1.5, 2.0, 3.0, 4.0, 5.0, 6.0, 1.0),
    );

    expect(
      parseTransform('matrix(1.5, 2.0, 3.0, 4.0, 5.0, 6.0 )'),
      const AffineMatrix(1.5, 2.0, 3.0, 4.0, 5.0, 6.0, 1.0),
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

  test('Parses pattern units to double correctly', () {
    final viewportNode = ViewportNode(
      SvgAttributes.empty,
      width: 100,
      height: 1000,
      transform: AffineMatrix.identity,
    );
    expect(parsePatternUnitToDouble('25.0', 'width'), 25.0);
    expect(
      parsePatternUnitToDouble('0.25', 'width', viewBox: viewportNode),
      25.0,
    );
    expect(
      parsePatternUnitToDouble('25%', 'width', viewBox: viewportNode),
      25.0,
    );
    expect(parsePatternUnitToDouble('25', 'width'), 25.0);
    expect(
      parsePatternUnitToDouble('0.1%', 'height', viewBox: viewportNode),
      1.0,
    );
  });

  test('Point conversion', () {
    expect(parseDoubleWithUnits('1pt', theme: const SvgTheme()), 1 + 1 / 3);
  });

  test('Parse a transform with scientific notation', () {
    expect(
      parseTransform('translate(9e-6,6.5e-4)'),
      AffineMatrix.identity.translated(9e-6, 6.5e-4),
    );

    expect(
      parseTransform('translate(9E-6,6.5E-4)'),
      AffineMatrix.identity.translated(9e-6, 6.5e-4),
    );
  });

  test('Parse a transform with a missing space', () {
    expect(
      parseTransform('translate(0-70)'),
      AffineMatrix.identity.translated(0, -70),
    );
  });

  test('Parse a transform with doubled periods', () {
    expect(
      parseTransform('matrix(.70711-.70711.70711.70711-640.89 452.68)'),
      const AffineMatrix(
        0.70711,
        -0.70711, //
        0.70711,
        0.70711, //
        -640.89,
        452.68, //
        1.0, //
      ),
    );
  });
}

class TestColorMapper extends ColorMapper {
  String? lastId;
  late String lastElementName;
  late String lastAttributeName;
  late Color lastColor;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    lastId = id;
    lastElementName = elementName;
    lastAttributeName = attributeName;
    lastColor = color;
    return const Color.fromARGB(255, 255, 0, 255);
  }
}

import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/src/svg/parser_state.dart';
import 'package:flutter_svg/src/utilities/xml.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:test/test.dart';
import 'package:xml/xml_events.dart';

class TestSvgParserState extends SvgParserState {
  TestSvgParserState({double fontSize = 14, double? xHeight})
      : super(
          <XmlEvent>[],
          SvgTheme(fontSize: fontSize, xHeight: xHeight),
          'testKey',
          false,
        );

  @override
  late Map<String, String> attributes;
}

void main() {
  test('Xlink href tests', () {
    final XmlStartElementEvent el =
        parseEvents('<test href="http://localhost" />').first
            as XmlStartElementEvent;

    final XmlStartElementEvent elXlink =
        parseEvents('<test xmlns:xlink="$kXlinkNamespace" '
                'xlink:href="http://localhost" />')
            .first as XmlStartElementEvent;

    expect(
        getHrefAttribute(el.attributes.toAttributeMap()), 'http://localhost');
    expect(getHrefAttribute(elXlink.attributes.toAttributeMap()),
        'http://localhost');
  });

  test('Attribute and style tests', () {
    final XmlStartElementEvent el =
        parseEvents('<test stroke="#fff" fill="#eee" stroke-dashpattern="1 2" '
                'style="stroke-opacity:1;fill-opacity:.23" />')
            .first as XmlStartElementEvent;

    final Map<String, String> attributes = el.attributes.toAttributeMap();
    expect(getAttribute(attributes, 'stroke'), '#fff');
    expect(getAttribute(attributes, 'fill'), '#eee');
    expect(getAttribute(attributes, 'stroke-dashpattern'), '1 2');
    expect(getAttribute(attributes, 'stroke-opacity'), '1');
    expect(getAttribute(attributes, 'stroke-another'), '');
    expect(getAttribute(attributes, 'fill-opacity'), '.23');

    expect(getAttribute(attributes, 'fill-opacity', checkStyle: false), '');
    expect(getAttribute(attributes, 'fill', checkStyle: false), '#eee');
  });

  // if the parsing logic changes, we can simplify some methods.  for now assert that whitespace in attributes is preserved
  test('Attribute WhiteSpace test', () {
    final XmlStartElementEvent xd =
        parseEvents('<test attr="  asdf" attr2="asdf  " attr3="asdf" />').first
            as XmlStartElementEvent;

    expect(
      xd.attributes[0].value,
      '  asdf',
      reason:
          'XML Parsing implementation no longer preserves leading whitespace in attributes!',
    );
    expect(
      xd.attributes[1].value,
      'asdf  ',
      reason:
          'XML Parsing implementation no longer preserves trailing whitespace in attributes!',
    );
  });

  test('viewBox tests', () {
    const Rect rect = Rect.fromLTWH(0.0, 0.0, 100.0, 100.0);

    final XmlStartElementEvent svgWithViewBox =
        parseEvents('<svg viewBox="0 0 100 100" />').first
            as XmlStartElementEvent;
    final XmlStartElementEvent svgWithViewBoxAndWidthHeight =
        parseEvents('<svg width="50px" height="50px" viewBox="0 0 100 100" />')
            .first as XmlStartElementEvent;
    final XmlStartElementEvent svgWithWidthHeight =
        parseEvents('<svg width="100" height="100" />').first
            as XmlStartElementEvent;
    final XmlStartElementEvent svgWithViewBoxMinXMinY =
        parseEvents('<svg viewBox="42 56 100 100" />').first
            as XmlStartElementEvent;
    final XmlStartElementEvent svgWithNoSizeInfo =
        parseEvents('<svg />').first as XmlStartElementEvent;

    final TestSvgParserState parserState = TestSvgParserState();

    parserState.attributes =
        svgWithViewBoxAndWidthHeight.attributes.toAttributeMap();
    expect(parserState.parseViewBox()!.size, const Size(50, 50));

    parserState.attributes = svgWithViewBox.attributes.toAttributeMap();
    expect(parserState.parseViewBox()!.viewBoxRect, rect);

    parserState.attributes = svgWithViewBox.attributes.toAttributeMap();
    expect(parserState.parseViewBox()!.viewBoxOffset, Offset.zero);

    parserState.attributes =
        svgWithViewBoxAndWidthHeight.attributes.toAttributeMap();
    expect(parserState.parseViewBox()!.viewBoxRect, rect);

    parserState.attributes = svgWithWidthHeight.attributes.toAttributeMap();
    expect(parserState.parseViewBox()!.viewBoxRect, rect);

    parserState.attributes = svgWithNoSizeInfo.attributes.toAttributeMap();
    expect(parserState.parseViewBox(nullOk: true), null);

    parserState.attributes = svgWithNoSizeInfo.attributes.toAttributeMap();
    expect(() => parserState.parseViewBox(), throwsStateError);

    parserState.attributes = svgWithViewBoxMinXMinY.attributes.toAttributeMap();
    expect(parserState.parseViewBox()!.viewBoxRect, rect);

    parserState.attributes = svgWithViewBoxMinXMinY.attributes.toAttributeMap();
    expect(
      parserState.parseViewBox()!.viewBoxOffset,
      const Offset(-42.0, -56.0),
    );
  });

  test('TileMode tests', () {
    final XmlStartElementEvent pad =
        parseEvents('<linearGradient spreadMethod="pad" />').first
            as XmlStartElementEvent;
    final XmlStartElementEvent reflect =
        parseEvents('<linearGradient spreadMethod="reflect" />').first
            as XmlStartElementEvent;
    final XmlStartElementEvent repeat =
        parseEvents('<linearGradient spreadMethod="repeat" />').first
            as XmlStartElementEvent;
    final XmlStartElementEvent invalid =
        parseEvents('<linearGradient spreadMethod="invalid" />').first
            as XmlStartElementEvent;

    final XmlStartElementEvent none =
        parseEvents('<linearGradient />').first as XmlStartElementEvent;

    final TestSvgParserState parserState = TestSvgParserState();
    parserState.attributes = pad.attributes.toAttributeMap();
    expect(parserState.parseTileMode(), TileMode.clamp);

    parserState.attributes = invalid.attributes.toAttributeMap();
    expect(parserState.parseTileMode(), TileMode.clamp);

    parserState.attributes = none.attributes.toAttributeMap();
    expect(parserState.parseTileMode(), TileMode.clamp);

    parserState.attributes = reflect.attributes.toAttributeMap();
    expect(parserState.parseTileMode(), TileMode.mirror);

    parserState.attributes = repeat.attributes.toAttributeMap();
    expect(parserState.parseTileMode(), TileMode.repeated);
  });

  test('@stroke-dashoffset tests', () {
    final XmlStartElementEvent abs =
        parseEvents('<stroke stroke-dashoffset="20" />').first
            as XmlStartElementEvent;
    final XmlStartElementEvent pct =
        parseEvents('<stroke stroke-dashoffset="20%" />').first
            as XmlStartElementEvent;

    final TestSvgParserState parserState = TestSvgParserState();
    parserState.attributes = abs.attributes.toAttributeMap();
    expect(
      parserState.parseDashOffset(),
      equals(const DashOffset.absolute(20.0)),
    );

    parserState.attributes = pct.attributes.toAttributeMap();
    expect(
      parserState.parseDashOffset(),
      equals(DashOffset.percentage(0.2)),
    );
  });

  test('font-weight tests', () {
    final TestSvgParserState parserState = TestSvgParserState();
    expect(parserState.parseFontWeight('100'), FontWeight.w100);
    expect(parserState.parseFontWeight('200'), FontWeight.w200);
    expect(parserState.parseFontWeight('300'), FontWeight.w300);
    expect(parserState.parseFontWeight('400'), FontWeight.w400);
    expect(parserState.parseFontWeight('500'), FontWeight.w500);
    expect(parserState.parseFontWeight('600'), FontWeight.w600);
    expect(parserState.parseFontWeight('700'), FontWeight.w700);
    expect(parserState.parseFontWeight('800'), FontWeight.w800);
    expect(parserState.parseFontWeight('900'), FontWeight.w900);

    expect(parserState.parseFontWeight('normal'), FontWeight.normal);
    expect(parserState.parseFontWeight('bold'), FontWeight.bold);

    expect(
        () => parserState.parseFontWeight('invalid'), throwsUnsupportedError);
  });

  test('font-style tests', () {
    final TestSvgParserState parserState = TestSvgParserState();
    expect(parserState.parseFontStyle('normal'), FontStyle.normal);
    expect(parserState.parseFontStyle('italic'), FontStyle.italic);
    expect(parserState.parseFontStyle('oblique'), FontStyle.italic);

    expect(parserState.parseFontStyle(null), isNull);
    expect(() => parserState.parseFontStyle('invalid'), throwsUnsupportedError);
  });

  test('text-decoration tests', () {
    final TestSvgParserState parserState = TestSvgParserState();
    expect(parserState.parseTextDecoration('none'), TextDecoration.none);
    expect(parserState.parseTextDecoration('line-through'),
        TextDecoration.lineThrough);
    expect(
        parserState.parseTextDecoration('overline'), TextDecoration.overline);
    expect(
        parserState.parseTextDecoration('underline'), TextDecoration.underline);

    expect(parserState.parseTextDecoration(null), isNull);
    expect(() => parserState.parseTextDecoration('invalid'),
        throwsUnsupportedError);
  });

  test('text-decoration-style tests', () {
    final TestSvgParserState parserState = TestSvgParserState();
    expect(parserState.parseTextDecorationStyle('solid'),
        TextDecorationStyle.solid);
    expect(parserState.parseTextDecorationStyle('dashed'),
        TextDecorationStyle.dashed);
    expect(parserState.parseTextDecorationStyle('dotted'),
        TextDecorationStyle.dotted);
    expect(parserState.parseTextDecorationStyle('double'),
        TextDecorationStyle.double);
    expect(
        parserState.parseTextDecorationStyle('wavy'), TextDecorationStyle.wavy);

    expect(parserState.parseTextDecorationStyle(null), isNull);
    expect(() => parserState.parseTextDecorationStyle('invalid'),
        throwsUnsupportedError);
  });

  group('parseStyle', () {
    test('uses currentColor for stroke color', () {
      const Color currentColor = Color(0xFFB0E3BE);
      final XmlStartElementEvent svg =
          parseEvents('<svg stroke="currentColor" />').first
              as XmlStartElementEvent;

      final TestSvgParserState parserState = TestSvgParserState();
      parserState.attributes = svg.attributes.toAttributeMap();
      final DrawableStyle svgStyle = parserState.parseStyle(
        Rect.zero,
        null,
        currentColor: currentColor,
      );

      expect(
        svgStyle.stroke?.color,
        equals(currentColor),
      );
    });

    test('uses currentColor for fill color', () {
      const Color currentColor = Color(0xFFB0E3BE);
      final XmlStartElementEvent svg =
          parseEvents('<svg fill="currentColor" />').first
              as XmlStartElementEvent;

      final TestSvgParserState parserState = TestSvgParserState();
      parserState.attributes = svg.attributes.toAttributeMap();
      final DrawableStyle svgStyle = parserState.parseStyle(
        Rect.zero,
        null,
        currentColor: currentColor,
      );

      expect(
        svgStyle.fill?.color,
        equals(currentColor),
      );
    });

    group('calculates em units based on the font size for', () {
      test('stroke width', () {
        final XmlStartElementEvent svg =
            parseEvents('<circle stroke="green" stroke-width="2em" />').first
                as XmlStartElementEvent;

        const double fontSize = 26.0;

        final TestSvgParserState parserState = TestSvgParserState(
          fontSize: fontSize,
        );
        parserState.attributes = svg.attributes.toAttributeMap();
        final DrawableStyle svgStyle = parserState.parseStyle(Rect.zero, null);

        expect(
          svgStyle.stroke?.strokeWidth,
          equals(fontSize * 2),
        );
      });

      test('dash array', () {
        final XmlStartElementEvent svg = parseEvents(
          '<line x2="10" y2="10" stroke="black" stroke-dasharray="0.2em 0.5em 10" />',
        ).first as XmlStartElementEvent;

        const double fontSize = 26.0;

        final TestSvgParserState parserState = TestSvgParserState(
          fontSize: fontSize,
        );
        parserState.attributes = svg.attributes.toAttributeMap();
        final DrawableStyle svgStyle = parserState.parseStyle(Rect.zero, null);

        expect(
          <double>[
            svgStyle.dashArray!.next,
            svgStyle.dashArray!.next,
            svgStyle.dashArray!.next,
          ],
          equals(<double>[
            fontSize * 0.2,
            fontSize * 0.5,
            10,
          ]),
        );
      });

      test('dash offset', () {
        final XmlStartElementEvent svg = parseEvents(
          '<line x2="5" y2="30" stroke="black" stroke-dasharray="3 1" stroke-dashoffset="0.15em" />',
        ).first as XmlStartElementEvent;

        const double fontSize = 26.0;

        final TestSvgParserState parserState = TestSvgParserState(
          fontSize: fontSize,
        );
        parserState.attributes = svg.attributes.toAttributeMap();
        final DrawableStyle svgStyle = parserState.parseStyle(Rect.zero, null);

        expect(
          svgStyle.dashOffset,
          equals(const DashOffset.absolute(fontSize * 0.15)),
        );
      });
    });

    group('calculates ex units based on the x-height for', () {
      test('stroke width', () {
        final XmlStartElementEvent svg =
            parseEvents('<circle stroke="green" stroke-width="2ex" />').first
                as XmlStartElementEvent;

        const double fontSize = 26.0;
        const double xHeight = 11.0;

        final TestSvgParserState parserState = TestSvgParserState(
          fontSize: fontSize,
          xHeight: xHeight,
        );
        parserState.attributes = svg.attributes.toAttributeMap();
        final DrawableStyle svgStyle = parserState.parseStyle(Rect.zero, null);

        expect(
          svgStyle.stroke?.strokeWidth,
          equals(xHeight * 2),
        );
      });

      test('dash array', () {
        final XmlStartElementEvent svg = parseEvents(
          '<line x2="10" y2="10" stroke="black" stroke-dasharray="0.2ex 0.5ex 10" />',
        ).first as XmlStartElementEvent;

        const double fontSize = 26.0;
        const double xHeight = 11.0;

        final TestSvgParserState parserState = TestSvgParserState(
          fontSize: fontSize,
          xHeight: xHeight,
        );
        parserState.attributes = svg.attributes.toAttributeMap();
        final DrawableStyle svgStyle = parserState.parseStyle(Rect.zero, null);

        expect(
          <double>[
            svgStyle.dashArray!.next,
            svgStyle.dashArray!.next,
            svgStyle.dashArray!.next,
          ],
          equals(<double>[
            xHeight * 0.2,
            xHeight * 0.5,
            10,
          ]),
        );
      });

      test('dash offset', () {
        final XmlStartElementEvent svg = parseEvents(
          '<line x2="5" y2="30" stroke="black" stroke-dasharray="3 1" stroke-dashoffset="0.15ex" />',
        ).first as XmlStartElementEvent;

        const double fontSize = 26.0;
        const double xHeight = 11.0;

        final TestSvgParserState parserState = TestSvgParserState(
          fontSize: fontSize,
          xHeight: xHeight,
        );
        parserState.attributes = svg.attributes.toAttributeMap();
        final DrawableStyle svgStyle = parserState.parseStyle(Rect.zero, null);

        expect(
          svgStyle.dashOffset,
          equals(const DashOffset.absolute(xHeight * 0.15)),
        );
      });
    });
  });
}

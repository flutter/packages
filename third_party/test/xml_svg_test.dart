import 'dart:ui';

import 'package:flutter_svg/src/svg/xml_parsers.dart';
import 'package:flutter_svg/src/utilities/xml.dart';
import 'package:test/test.dart';
import 'package:xml/xml_events.dart';

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

    expect(
        parseViewBox(svgWithViewBoxAndWidthHeight.attributes.toAttributeMap())!
            .size,
        const Size(50, 50));
    expect(
        parseViewBox(svgWithViewBox.attributes.toAttributeMap())!.viewBoxRect,
        rect);
    expect(
        parseViewBox(svgWithViewBox.attributes.toAttributeMap())!.viewBoxOffset,
        Offset.zero);
    expect(
        parseViewBox(svgWithViewBoxAndWidthHeight.attributes.toAttributeMap())!
            .viewBoxRect,
        rect);
    expect(
        parseViewBox(svgWithWidthHeight.attributes.toAttributeMap())!
            .viewBoxRect,
        rect);
    expect(
        parseViewBox(svgWithNoSizeInfo.attributes.toAttributeMap(),
            nullOk: true),
        null);
    expect(() => parseViewBox(svgWithNoSizeInfo.attributes.toAttributeMap()),
        throwsStateError);
    expect(
        parseViewBox(svgWithViewBoxMinXMinY.attributes.toAttributeMap())!
            .viewBoxRect,
        rect);
    expect(
        parseViewBox(svgWithViewBoxMinXMinY.attributes.toAttributeMap())!
            .viewBoxOffset,
        const Offset(-42.0, -56.0));
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

    expect(parseTileMode(pad.attributes.toAttributeMap()), TileMode.clamp);
    expect(parseTileMode(invalid.attributes.toAttributeMap()), TileMode.clamp);
    expect(parseTileMode(none.attributes.toAttributeMap()), TileMode.clamp);

    expect(parseTileMode(reflect.attributes.toAttributeMap()), TileMode.mirror);
    expect(
        parseTileMode(repeat.attributes.toAttributeMap()), TileMode.repeated);
  });

  test('@stroke-dashoffset tests', () {
    final XmlStartElementEvent abs =
        parseEvents('<stroke stroke-dashoffset="20" />').first
            as XmlStartElementEvent;
    final XmlStartElementEvent pct =
        parseEvents('<stroke stroke-dashoffset="20%" />').first
            as XmlStartElementEvent;

    // TODO(dnfield): DashOffset is completely opaque right now, maybe expose the raw value?
    expect(parseDashOffset(abs.attributes.toAttributeMap()), isNotNull);
    expect(parseDashOffset(pct.attributes.toAttributeMap()), isNotNull);
  });

  test('font-weight tests', () {
    expect(parseFontWeight('100'), FontWeight.w100);
    expect(parseFontWeight('200'), FontWeight.w200);
    expect(parseFontWeight('300'), FontWeight.w300);
    expect(parseFontWeight('400'), FontWeight.w400);
    expect(parseFontWeight('500'), FontWeight.w500);
    expect(parseFontWeight('600'), FontWeight.w600);
    expect(parseFontWeight('700'), FontWeight.w700);
    expect(parseFontWeight('800'), FontWeight.w800);
    expect(parseFontWeight('900'), FontWeight.w900);

    expect(parseFontWeight('normal'), FontWeight.normal);
    expect(parseFontWeight('bold'), FontWeight.bold);

    expect(() => parseFontWeight('invalid'), throwsUnsupportedError);
  });

  test('font-style tests', () {
    expect(parseFontStyle('normal'), FontStyle.normal);
    expect(parseFontStyle('italic'), FontStyle.italic);
    expect(parseFontStyle('oblique'), FontStyle.italic);

    expect(parseFontStyle(null), isNull);
    expect(() => parseFontStyle('invalid'), throwsUnsupportedError);
  });

  test('text-decoration tests', () {
    expect(parseTextDecoration('none'), TextDecoration.none);
    expect(parseTextDecoration('line-through'), TextDecoration.lineThrough);
    expect(parseTextDecoration('overline'), TextDecoration.overline);
    expect(parseTextDecoration('underline'), TextDecoration.underline);

    expect(parseTextDecoration(null), isNull);
    expect(() => parseTextDecoration('invalid'), throwsUnsupportedError);
  });

  test('text-decoration-style tests', () {
    expect(parseTextDecorationStyle('solid'), TextDecorationStyle.solid);
    expect(parseTextDecorationStyle('dashed'), TextDecorationStyle.dashed);
    expect(parseTextDecorationStyle('dotted'), TextDecorationStyle.dotted);
    expect(parseTextDecorationStyle('double'), TextDecorationStyle.double);
    expect(parseTextDecorationStyle('wavy'), TextDecorationStyle.wavy);

    expect(parseTextDecorationStyle(null), isNull);
    expect(() => parseTextDecorationStyle('invalid'), throwsUnsupportedError);
  });
}

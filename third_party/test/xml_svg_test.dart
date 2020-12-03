import 'dart:ui';

import 'package:test/test.dart';
import 'package:xml/xml_events.dart';

import 'package:flutter_svg/src/svg/xml_parsers.dart';
import 'package:flutter_svg/src/utilities/xml.dart';

void main() {
  test('Xlink href tests', () {
    final XmlStartElementEvent el =
        parseEvents('<test href="http://localhost" />').first
            as XmlStartElementEvent;

    final XmlStartElementEvent elXlink =
        parseEvents('<test xmlns:xlink="$kXlinkNamespace" '
                'xlink:href="http://localhost" />')
            .first as XmlStartElementEvent;

    expect(getHrefAttribute(el.attributes), 'http://localhost');
    expect(getHrefAttribute(elXlink.attributes), 'http://localhost');
  });

  test('Attribute and style tests', () {
    final XmlStartElementEvent el =
        parseEvents('<test stroke="#fff" fill="#eee" stroke-dashpattern="1 2" '
                'style="stroke-opacity:1;fill-opacity:.23" />')
            .first as XmlStartElementEvent;

    expect(getAttribute(el.attributes, 'stroke'), '#fff');
    expect(getAttribute(el.attributes, 'fill'), '#eee');
    expect(getAttribute(el.attributes, 'stroke-dashpattern'), '1 2');
    expect(getAttribute(el.attributes, 'stroke-opacity'), '1');
    expect(getAttribute(el.attributes, 'stroke-another'), '');
    expect(getAttribute(el.attributes, 'fill-opacity'), '.23');

    expect(getAttribute(el.attributes, 'fill-opacity', checkStyle: false), '');
    expect(getAttribute(el.attributes, 'fill', checkStyle: false), '#eee');
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

    expect(parseViewBox(svgWithViewBoxAndWidthHeight.attributes)!.size,
        const Size(50, 50));
    expect(parseViewBox(svgWithViewBox.attributes)!.viewBoxRect, rect);
    expect(parseViewBox(svgWithViewBox.attributes)!.viewBoxOffset, Offset.zero);
    expect(parseViewBox(svgWithViewBoxAndWidthHeight.attributes)!.viewBoxRect,
        rect);
    expect(parseViewBox(svgWithWidthHeight.attributes)!.viewBoxRect, rect);
    expect(parseViewBox(svgWithNoSizeInfo.attributes, nullOk: true), null);
    expect(() => parseViewBox(svgWithNoSizeInfo.attributes), throwsStateError);
    expect(parseViewBox(svgWithViewBoxMinXMinY.attributes)!.viewBoxRect, rect);
    expect(parseViewBox(svgWithViewBoxMinXMinY.attributes)!.viewBoxOffset,
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

    expect(parseTileMode(pad.attributes), TileMode.clamp);
    expect(parseTileMode(invalid.attributes), TileMode.clamp);
    expect(parseTileMode(none.attributes), TileMode.clamp);

    expect(parseTileMode(reflect.attributes), TileMode.mirror);
    expect(parseTileMode(repeat.attributes), TileMode.repeated);
  });

  test('@stroke-dashoffset tests', () {
    final XmlStartElementEvent abs =
        parseEvents('<stroke stroke-dashoffset="20" />').first
            as XmlStartElementEvent;
    final XmlStartElementEvent pct =
        parseEvents('<stroke stroke-dashoffset="20%" />').first
            as XmlStartElementEvent;

    // TODO(dnfield): DashOffset is completely opaque right now, maybe expose the raw value?
    expect(parseDashOffset(abs.attributes), isNotNull);
    expect(parseDashOffset(pct.attributes), isNotNull);
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
}

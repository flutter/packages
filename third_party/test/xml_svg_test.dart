import 'dart:ui';

import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'package:flutter_svg/src/svg/xml_parsers.dart';
import 'package:flutter_svg/src/utilities/xml.dart';

void main() {
  test('Xlink href tests', () {
    final XmlElement el = parse('<test href="http://localhost" />').rootElement;

    final XmlElement elXlink = parse('<test xmlns:xlink="$kXlinkNamespace" '
            'xlink:href="http://localhost" />')
        .rootElement;

    expect(getHrefAttribute(el.attributes), 'http://localhost');
    expect(getHrefAttribute(elXlink.attributes), 'http://localhost');
  });

  test('Attribute and style tests', () {
    final List<XmlAttribute> el =
        parse('<test stroke="#fff" fill="#eee" stroke-dashpattern="1 2" '
                'style="stroke-opacity:1;fill-opacity:.23" />')
            .rootElement
            .attributes;

    expect(getAttribute(el, 'stroke'), '#fff');
    expect(getAttribute(el, 'fill'), '#eee');
    expect(getAttribute(el, 'stroke-dashpattern'), '1 2');
    expect(getAttribute(el, 'stroke-opacity'), '1');
    expect(getAttribute(el, 'stroke-another'), '');
    expect(getAttribute(el, 'fill-opacity'), '.23');

    expect(getAttribute(el, 'fill-opacity', checkStyle: false), '');
    expect(getAttribute(el, 'fill', checkStyle: false), '#eee');
  });

  // if the parsing logic changes, we can simplify some methods.  for now assert that whitespace in attributes is preserved
  test('Attribute WhiteSpace test', () {
    final XmlDocument xd =
        parse('<test attr="  asdf" attr2="asdf  " attr3="asdf" />');

    expect(
      xd.rootElement.getAttribute('attr'),
      '  asdf',
      reason:
          'XML Parsing implementation no longer preserves leading whitespace in attributes!',
    );
    expect(
      xd.rootElement.getAttribute('attr2'),
      'asdf  ',
      reason:
          'XML Parsing implementation no longer preserves trailing whitespace in attributes!',
    );
  });

  test('viewBox tests', () {
    final Rect rect = Rect.fromLTWH(0.0, 0.0, 100.0, 100.0);

    final List<XmlAttribute> svgWithViewBox =
        parse('<svg viewBox="0 0 100 100" />').rootElement.attributes;
    final List<XmlAttribute> svgWithViewBoxAndWidthHeight =
        parse('<svg width="50px" height="50px" viewBox="0 0 100 100" />')
            .rootElement
            .attributes;
    final List<XmlAttribute> svgWithWidthHeight =
        parse('<svg width="100" height="100" />').rootElement.attributes;
    final List<XmlAttribute> svgWithViewBoxMinXMinY =
        parse('<svg viewBox="42 56 100 100" />').rootElement.attributes;
    final List<XmlAttribute> svgWithNoSizeInfo =
        parse('<svg />').rootElement.attributes;

    expect(parseViewBox(svgWithViewBoxAndWidthHeight).size, const Size(50, 50));
    expect(parseViewBox(svgWithViewBox).viewBoxRect, rect);
    expect(parseViewBox(svgWithViewBox).viewBoxOffset, Offset.zero);
    expect(parseViewBox(svgWithViewBoxAndWidthHeight).viewBoxRect, rect);
    expect(parseViewBox(svgWithWidthHeight).viewBoxRect, rect);
    expect(parseViewBox(svgWithNoSizeInfo, nullOk: true), null);
    expect(() => parseViewBox(svgWithNoSizeInfo), throwsStateError);
    expect(parseViewBox(svgWithViewBoxMinXMinY).viewBoxRect, rect);
    expect(parseViewBox(svgWithViewBoxMinXMinY).viewBoxOffset,
        const Offset(-42.0, -56.0));
  });

  test('TileMode tests', () {
    final XmlElement pad =
        parse('<linearGradient spreadMethod="pad" />').rootElement;
    final XmlElement reflect =
        parse('<linearGradient spreadMethod="reflect" />').rootElement;
    final XmlElement repeat =
        parse('<linearGradient spreadMethod="repeat" />').rootElement;
    final XmlElement invalid =
        parse('<linearGradient spreadMethod="invalid" />').rootElement;

    final XmlElement none = parse('<linearGradient />').rootElement;

    expect(parseTileMode(pad.attributes), TileMode.clamp);
    expect(parseTileMode(invalid.attributes), TileMode.clamp);
    expect(parseTileMode(none.attributes), TileMode.clamp);

    expect(parseTileMode(reflect.attributes), TileMode.mirror);
    expect(parseTileMode(repeat.attributes), TileMode.repeated);
  });

  test('@stroke-dashoffset tests', () {
    final XmlElement abs =
        parse('<stroke stroke-dashoffset="20" />').rootElement;
    final XmlElement pct =
        parse('<stroke stroke-dashoffset="20%" />').rootElement;

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

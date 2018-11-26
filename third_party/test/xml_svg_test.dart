import 'dart:ui';

import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'package:flutter_svg/src/svg/xml_parsers.dart';
import 'package:flutter_svg/src/utilities/xml.dart';

void main() {
  test('Attribute and style tests', () {
    final XmlElement el = parse(
            '<test stroke="#fff" fill="#eee" stroke-dashpattern="1 2" style="stroke-opacity:1;fill-opacity:.23" />')
        .rootElement;

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

    final XmlElement svgWithViewBox =
        parse('<svg viewBox="0 0 100 100" />').rootElement;
    final XmlElement svgWithViewBoxAndWidthHeight =
        parse('<svg width="50px" height="50px" viewBox="0 0 100 100" />')
            .rootElement;
    final XmlElement svgWithWidthHeight =
        parse('<svg width="100" height="100" />').rootElement;
    final XmlElement svgWithViewBoxMinXMinY =
        parse('<svg viewBox="42 56 100 100" />').rootElement;
    final XmlElement svgWithNoSizeInfo = parse('<svg />').rootElement;

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

    expect(parseTileMode(pad), TileMode.clamp);
    expect(parseTileMode(invalid), TileMode.clamp);
    expect(parseTileMode(none), TileMode.clamp);

    expect(parseTileMode(reflect), TileMode.mirror);
    expect(parseTileMode(repeat), TileMode.repeated);
  });

  test('@stroke-dashoffset tests', () {
    final XmlElement abs =
        parse('<stroke stroke-dashoffset="20" />').rootElement;
    final XmlElement pct =
        parse('<stroke stroke-dashoffset="20%" />').rootElement;

    // TODO(dnfield): DashOffset is completely opaque right now, maybe expose the raw value?
    expect(parseDashOffset(abs), isNotNull);
    expect(parseDashOffset(pct), isNotNull);
  });
}

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
    final Rect rect = new Rect.fromLTWH(0.0, 0.0, 100.0, 100.0);

    final XmlElement svgWithViewBox =
        parse('<svg viewBox="0 0 100 100" />').rootElement;
    final XmlElement svgWithViewBoxAndWidthHeight =
        parse('<svg width="50cm" height="50cm" viewBox="0 0 100 100" />')
            .rootElement;
    final XmlElement svgWithWidthHeight =
        parse('<svg width="100cm" height="100cm" />').rootElement;

    expect(parseViewBox(svgWithViewBox), rect);
    expect(parseViewBox(svgWithViewBoxAndWidthHeight), rect);
    expect(parseViewBox(svgWithWidthHeight), rect);
  });
}

import 'dart:ui';

import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'package:flutter_svg/src/svg/xml_parsers.dart';

void main() {
  // if the parsing logic changes, we can simplify some methods.  for now assert that whitespace in attributes is preserved
  test('Attribute WhiteSpace test', () {
    XmlDocument xd =
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

    XmlElement svgWithViewBox =
        parse('<svg viewBox="0 0 100 100" />').rootElement;
    XmlElement svgWithViewBoxAndWidthHeight =
        parse('<svg width="50cm" height="50cm" viewBox="0 0 100 100" />')
            .rootElement;
    XmlElement svgWithWidthHeight =
        parse('<svg width="100cm" height="100cm" />').rootElement;

    expect(parseViewBox(svgWithViewBox), rect);
    expect(parseViewBox(svgWithViewBoxAndWidthHeight), rect);
    expect(parseViewBox(svgWithWidthHeight), rect);
  });
}

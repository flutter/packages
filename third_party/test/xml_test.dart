import 'package:test/test.dart';
import 'package:xml/xml.dart';

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
}

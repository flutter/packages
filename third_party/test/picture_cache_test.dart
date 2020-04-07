import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/src/picture_cache.dart';
import 'package:flutter_svg/src/picture_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

class MockPictureStreamCompleter extends PictureStreamCompleter {}

void main() {
  PictureCache cache;

  setUp(() {
    cache = PictureCache();
  });

  testWidgets('Precache test', (WidgetTester tester) async {
    const String svgString = '''<svg viewBox="0 0 10 10">
<rect x="1" y="1" width="5" height="5" fill="black" />
</svg>''';
    const String svgString2 = '''<svg viewBox="0 0 10 10">
<rect x="1" y="1" width="6" height="5" fill="black" />
</svg>''';
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Text('test_text'),
      ),
    );

    expect(PictureProvider.cacheCount, 0);
    await precachePicture(
      StringPicture(
        SvgPicture.svgStringDecoder,
        svgString,
      ),
      tester.element(find.text('test_text')),
    );
    expect(PictureProvider.cacheCount, 1);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SvgPicture.string(svgString),
      ),
    );
    expect(PictureProvider.cacheCount, 1);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SvgPicture.string(svgString2),
      ),
    );
    expect(PictureProvider.cacheCount, 2);

    PictureProvider.clearCache();
    expect(PictureProvider.cacheCount, 0);
  });

  testWidgets('Precache - null context', (WidgetTester tester) async {
    const String svgString = '''<svg viewBox="0 0 10 10">
<rect x="1" y="1" width="5" height="5" fill="black" />
</svg>''';

    expect(PictureProvider.cacheCount, 0);
    await precachePicture(
      StringPicture(
        SvgPicture.svgStringDecoder,
        svgString,
      ),
      null,
    );
    expect(PictureProvider.cacheCount, 1);
  });

  testWidgets('Precache with error', (WidgetTester tester) async {
    const String svgString = '<svg';
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Text('test_text'),
      ),
    );

    bool gotError = false;
    void errorListener(dynamic error, StackTrace stackTrace) {
      gotError = true;
      expect(error, isInstanceOf<XmlParserException>());
    }

    await precachePicture(
      StringPicture(
        SvgPicture.svgStringDecoder,
        svgString,
      ),
      tester.element(find.text('test_text')),
      onError: errorListener,
    );
    expect(tester.takeException(), isInstanceOf<XmlParserException>());
    expect(gotError, isTrue);
  });

  test('Cache Tests', () {
    expect(cache.maximumSize, equals(1000));
    cache.maximumSize = 1;
    expect(cache.maximumSize, equals(1));

    expect(() => cache.maximumSize = -1, throwsAssertionError);
    expect(() => cache.maximumSize = null, throwsAssertionError);

    expect(() => cache.putIfAbsent(null, null), throwsAssertionError);
    expect(() => cache.putIfAbsent(1, null), throwsAssertionError);

    final MockPictureStreamCompleter completer1 = MockPictureStreamCompleter();
    final MockPictureStreamCompleter completer2 = MockPictureStreamCompleter();
    expect(cache.putIfAbsent(1, () => completer1), completer1);
    expect(cache.putIfAbsent(1, () => completer1), completer1);
    expect(cache.putIfAbsent(2, () => completer2), completer2);

    cache.clear();
  });
}

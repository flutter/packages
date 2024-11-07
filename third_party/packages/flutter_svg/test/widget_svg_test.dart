import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (!result.passed) {
      final String error = await generateFailureOutput(result, golden, basedir);
      if (result.diffPercent >= .06) {
        throw FlutterError(error);
      } else {
        // ignore: avoid_print
        print(
            'Warning - golden differed less than .06% (${result.diffPercent}%), '
            'ignoring failure but producing output\n'
            '$error');
      }
    }
    return true;
  }
}

Future<void> _checkWidgetAndGolden(Key key, String filename) async {
  final Finder widgetFinder = find.byKey(key);
  expect(widgetFinder, findsOneWidget);
  await expectLater(widgetFinder, matchesGoldenFile('golden_widget/$filename'));
}

void main() {
  final MediaQueryData mediaQueryData =
      MediaQueryData.fromView(PlatformDispatcher.instance.implicitView!);

  setUpAll(() {
    final LocalFileComparator oldComparator =
        goldenFileComparator as LocalFileComparator;
    final _TolerantComparator newComparator =
        _TolerantComparator(Uri.parse('${oldComparator.basedir}test'));
    expect(oldComparator.basedir, newComparator.basedir);
    goldenFileComparator = newComparator;
  });

  testWidgets(
      'SvgPicture does not use a color filtering widget when no color specified',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      SvgPicture.string(
        svgStr,
        width: 100.0,
        height: 100.0,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ColorFiltered), findsNothing);
  });

  testWidgets('SvgPicture can work with a FittedBox',
      (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(100, 100)),
        child: Row(
          key: key,
          textDirection: TextDirection.ltr,
          children: <Widget>[
            Flexible(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: SvgPicture.string(
                  svgStr,
                  width: 20.0,
                  height: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final Finder widgetFinder = find.byKey(key);
    expect(widgetFinder, findsOneWidget);
  });

  testWidgets('SvgPicture.string', (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MediaQuery(
        data: mediaQueryData,
        child: RepaintBoundary(
          key: key,
          child: SvgPicture.string(
            svgStr,
            width: 100.0,
            height: 100.0,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'flutter_logo.string.png');
  });

  testWidgets('SvgPicture natural size', (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MediaQuery(
        data: mediaQueryData,
        child: Center(
          key: key,
          child: SvgPicture.string(
            svgStr,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'flutter_logo.natural.png');
  });

  testWidgets('SvgPicture clipped', (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MediaQuery(
        data: mediaQueryData,
        child: Center(
          key: key,
          child: SvgPicture.string(
            stickFigureSvgStr,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'stick_figure.withclipping.png');
  });

  testWidgets('SvgPicture.string ltr', (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MediaQuery(
        data: mediaQueryData,
        child: RepaintBoundary(
          key: key,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: const Color(0xFF0D47A1),
                    height: 100.0,
                  ),
                ),
                SvgPicture.string(
                  svgStr,
                  matchTextDirection: true,
                  height: 100.0,
                  width: 100.0,
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFF42A5F5),
                    height: 100.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'flutter_logo.string.ltr.png');
  });

  testWidgets('SvgPicture.string rtl', (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MediaQuery(
        data: mediaQueryData,
        child: RepaintBoundary(
          key: key,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: const Color(0xFF0D47A1),
                    height: 100.0,
                  ),
                ),
                SvgPicture.string(
                  svgStr,
                  matchTextDirection: true,
                  height: 100.0,
                  width: 100.0,
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFF42A5F5),
                    height: 100.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'flutter_logo.string.rtl.png');
  });

  testWidgets('SvgPicture.memory', (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MediaQuery(
        data: mediaQueryData,
        child: RepaintBoundary(
          key: key,
          child: SvgPicture.memory(
            svgBytes,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _checkWidgetAndGolden(key, 'flutter_logo.memory.png');
  });

  testWidgets('SvgPicture.asset', (WidgetTester tester) async {
    final FakeAssetBundle fakeAsset = FakeAssetBundle();
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MediaQuery(
        data: mediaQueryData,
        child: RepaintBoundary(
          key: key,
          child: SvgPicture.asset(
            'test.svg',
            bundle: fakeAsset,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'flutter_logo.asset.png');
  });

  testWidgets('SvgPicture.asset DefaultAssetBundle',
      (WidgetTester tester) async {
    final FakeAssetBundle fakeAsset = FakeAssetBundle();
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: mediaQueryData,
          child: DefaultAssetBundle(
            bundle: fakeAsset,
            child: RepaintBoundary(
              key: key,
              child: SvgPicture.asset(
                'test.svg',
                semanticsLabel: 'Test SVG',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'flutter_logo.asset.png');
  });

  testWidgets('SvgPicture.network', (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MediaQuery(
        data: mediaQueryData,
        child: RepaintBoundary(
          key: key,
          child: SvgPicture.network(
            'test.svg',
            httpClient: FakeHttpClient(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'flutter_logo.network.png');
  });

  testWidgets('SvgPicture.network with headers', (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    final FakeHttpClient client = FakeHttpClient();
    await tester.pumpWidget(
      MediaQuery(
        data: mediaQueryData,
        child: RepaintBoundary(
          key: key,
          child: SvgPicture.network(
            'test.svg',
            headers: const <String, String>{'a': 'b'},
            httpClient: client,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(client.headers['a'], 'b');
  });

  testWidgets('SvgPicture can be created without a MediaQuery',
      (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: SvgPicture.string(
          svgStr,
          width: 100.0,
          height: 100.0,
        ),
      ),
    );

    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'flutter_logo.string.png');
  });

  testWidgets('SvgPicture.network HTTP exception', (WidgetTester tester) async {
    expect(() async {
      final http.Client client = FakeHttpClient(400);
      await tester.pumpWidget(
        MediaQuery(
          data: mediaQueryData,
          child: SvgPicture.network(
            'notFound.svg',
            httpClient: client,
          ),
        ),
      );
    }, isNotNull);
  });

  testWidgets('SvgPicture semantics', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          child: SvgPicture.string(
            svgStr,
            semanticsLabel: 'Flutter Logo',
            width: 100.0,
            height: 100.0,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Semantics), findsOneWidget);
    expect(find.bySemanticsLabel('Flutter Logo'), findsOneWidget);
  });

  testWidgets('SvgPicture semantics - no label', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          child: SvgPicture.string(
            svgStr,
            width: 100.0,
            height: 100.0,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Semantics), findsOneWidget);
  });

  testWidgets('SvgPicture semantics - exclude', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          child: SvgPicture.string(
            svgStr,
            excludeFromSemantics: true,
            width: 100.0,
            height: 100.0,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Semantics), findsNothing);
  });

  testWidgets('SvgPicture colorFilter - flutter logo',
      (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: SvgPicture.string(
          svgStr,
          width: 100.0,
          height: 100.0,
          colorFilter: const ColorFilter.mode(
            Color(0xFF990000),
            BlendMode.srcIn,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'flutter_logo.string.color_filter.png');
  });

  testWidgets('SvgPicture colorFilter with text', (WidgetTester tester) async {
    const String svgData = '''
<svg font-family="arial" font-size="14" height="160" width="88" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#000" stroke-linecap="round" stroke-width="2" stroke-opacity="1" fill-opacity="1" stroke-linejoin="miter">
    <g>
      <line x1="60" x2="88" y1="136" y2="136"/>
    </g>
    <g>
      <text stroke-width="1" x="9" y="28">2</text>
    </g>
    <g>
      <text stroke-width="1" x="73" y="156">1</text>
    </g>
  </g>
</svg>''';
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: SvgPicture.string(
          svgData,
          width: 100.0,
          height: 100.0,
          colorFilter: const ColorFilter.mode(
            Color(0xFF990000),
            BlendMode.srcIn,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'text_color_filter.png');
  });

  testWidgets('Can take AlignmentDirectional', (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SvgPicture.string(
        svgStr,
        alignment: AlignmentDirectional.bottomEnd,
      ),
    ));
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  group('SvgPicture respects em units', () {
    testWidgets('circle (cx, cy, r)', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      const String svgStr = '''
<svg width="800px" height="600px" xmlns="http://www.w3.org/2000/svg">
  <circle cx="0.5em" cy="0.5em" r="0.5em" fill="orange" />
</svg>
''';

      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: SvgPicture.string(
            svgStr,
            theme: const SvgTheme(fontSize: 600),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await _checkWidgetAndGolden(key, 'circle.em_ex.png');
    });

    testWidgets('rect (x, y, width, height, rx, ry)',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      const String svgStr = '''
<svg width="800px" height="600px" xmlns="http://www.w3.org/2000/svg">
  <rect x="2em" y="1.5em" width="4em" height="3em" rx="0.5em" ry="0.5em" fill="orange" />
</svg>
''';

      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: SvgPicture.string(
            svgStr,
            theme: const SvgTheme(fontSize: 100),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await _checkWidgetAndGolden(key, 'rect.em_ex.png');
    });

    testWidgets('ellipse (cx, cy, rx, ry)', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      const String svgStr = '''
<svg width="800px" height="600px" xmlns="http://www.w3.org/2000/svg">
  <ellipse cx="7em" cy="4em" rx="1em" ry="2em" fill="orange" />
</svg>
''';

      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: SvgPicture.string(
            svgStr,
            theme: const SvgTheme(fontSize: 100),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await _checkWidgetAndGolden(key, 'ellipse.em_ex.png');
    });

    testWidgets('line (x1, y1, x2, y2)', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      const String svgStr = '''
<svg width="800px" height="600px" xmlns="http://www.w3.org/2000/svg">
  <line x1="0em" y1="6em" x2="4em" y2="0em" stroke="orange" />
  <line x1="4em" y1="0em" x2="8em" y2="6em" stroke="orange" />
</svg>
''';

      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: SvgPicture.string(
            svgStr,
            theme: const SvgTheme(fontSize: 100),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await _checkWidgetAndGolden(key, 'line.em_ex.png');
    });
  });

  group('SvgPicture respects ex units', () {
    testWidgets('circle (cx, cy, r)', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      const String svgStr = '''
<svg width="800px" height="600px" xmlns="http://www.w3.org/2000/svg">
  <circle cx="0.5ex" cy="0.5ex" r="0.5ex" fill="orange" />
</svg>
''';

      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: SvgPicture.string(
            svgStr,
            theme: const SvgTheme(
              fontSize: 1500,
              xHeight: 600,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await _checkWidgetAndGolden(key, 'circle.em_ex2.png');
    });

    testWidgets('rect (x, y, width, height, rx, ry)',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      const String svgStr = '''
<svg width="800px" height="600px" xmlns="http://www.w3.org/2000/svg">
  <rect x="2ex" y="1.5ex" width="4ex" height="3ex" rx="0.5ex" ry="0.5ex" fill="orange" />
</svg>
''';

      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: SvgPicture.string(
            svgStr,
            theme: const SvgTheme(
              fontSize: 300,
              xHeight: 100,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await _checkWidgetAndGolden(key, 'rect.em_ex2.png');
    });

    testWidgets('ellipse (cx, cy, rx, ry)', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      const String svgStr = '''
<svg width="800px" height="600px" xmlns="http://www.w3.org/2000/svg">
  <ellipse cx="7ex" cy="4ex" rx="1ex" ry="2ex" fill="orange" />
</svg>
''';

      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: SvgPicture.string(
            svgStr,
            theme: const SvgTheme(
              fontSize: 300,
              xHeight: 100,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await _checkWidgetAndGolden(key, 'ellipse.em_ex2.png');
    });

    testWidgets('line (x1, y1, x2, y2)', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      const String svgStr = '''
<svg width="800px" height="600px" xmlns="http://www.w3.org/2000/svg">
  <line x1="0ex" y1="6ex" x2="4ex" y2="0ex" stroke="orange" />
  <line x1="4ex" y1="0ex" x2="8ex" y2="6ex" stroke="orange" />
</svg>
''';

      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: SvgPicture.string(
            svgStr,
            theme: const SvgTheme(
              fontSize: 300,
              xHeight: 100,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await _checkWidgetAndGolden(key, 'line.em_ex2.png');
    });
  });

  testWidgets('SvgPicture - two of the same', (WidgetTester tester) async {
    // Regression test to make sure the same SVG can render twice in the same
    // view. If layers are incorrectly reused, this will fail.
    await tester.pumpWidget(RepaintBoundary(
        child: Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: <Widget>[
          SvgPicture.string(simpleSvg),
          SvgPicture.string(simpleSvg),
        ],
      ),
    )));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('golden_widget/two_of_same.png'),
    );
  });

  // This tests https://github.com/dnfield/flutter_svg/issues/990
  // Where embedded images were being incorrectly cached.
  testWidgets('SvgPicture - with cached images', (WidgetTester tester) async {
    // Simple red and blue 10x10 squares.
    // Borrowed from https://gist.github.com/ondrek/7413434?permalink_comment_id=4674255#gistcomment-4674255
    final Map<String, String> images = <String, String>{
      'red':
          'iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAFUlEQVR42mP8z8BQz0AEYBxVSF+FABJADveWkH6oAAAAAElFTkSuQmCC',
      'blue':
          'iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAFUlEQVR42mNkYPhfz0AEYBxVSF+FAP5FDvcfRYWgAAAAAElFTkSuQmCC',
    };

    // We keep pumping widgets into the same tester, to ensure the same cache
    // is used on each iteration.
    for (final String key in images.keys) {
      final String image = images[key]!;
      final String svgStr = '''
<svg
  xmlns="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink" width="100" height="100">
  <image width="100" height="100" href="data:image/png;base64,$image" />
</svg>''';

      // First try with SvgPicture.string
      await tester.pumpWidget(RepaintBoundary(
        child: SvgPicture.string(svgStr),
      ));
      await tester.runAsync(() => vg.waitForPendingDecodes());
      await tester.pumpAndSettle();

      Finder widgetFinder = find.byType(SvgPicture);
      expect(widgetFinder, findsOneWidget);
      await expectLater(
          widgetFinder, matchesGoldenFile('golden_widget/image_$key.png'));

      // Then with SvgPicture.memory
      await tester.pumpWidget(RepaintBoundary(
        // ignore: unnecessary_cast
        child: SvgPicture.memory(utf8.encode(svgStr) as Uint8List),
      ));
      await tester.runAsync(() => vg.waitForPendingDecodes());
      await tester.pumpAndSettle();

      widgetFinder = find.byType(SvgPicture);
      expect(widgetFinder, findsOneWidget);
      await expectLater(
          widgetFinder, matchesGoldenFile('golden_widget/image_$key.png'));
    }
  });
}

class FakeAssetBundle extends Fake implements AssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return svgStr;
  }

  @override
  Future<ByteData> load(String key) async {
    return Uint8List.fromList(utf8.encode(svgStr)).buffer.asByteData();
  }
}

class FakeHttpClient extends Fake implements http.Client {
  FakeHttpClient([this.statusCode = 200]);

  final int statusCode;

  final Map<String, String> headers = <String, String>{};

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    if (headers != null) {
      this.headers.addAll(headers);
    }
    return http.Response(svgStr, statusCode);
  }
}

const String simpleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" viewBox="0 0 20 20">
  <rect x="5" y="5" width="10" height="10"/>
</svg>
''';

const String svgStr = '''
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" viewBox="0 0 166 202">
  <defs>
      <linearGradient id="triangleGradient">
          <stop offset="20%" stop-color="#000000" stop-opacity=".55" />
          <stop offset="85%" stop-color="#616161" stop-opacity=".01" />
      </linearGradient>
      <linearGradient id="rectangleGradient" x1="0%" x2="0%" y1="0%" y2="100%">
          <stop offset="20%" stop-color="#000000" stop-opacity=".15" />
          <stop offset="85%" stop-color="#616161" stop-opacity=".01" />
      </linearGradient>
  </defs>
  <path fill="#42A5F5" fill-opacity=".8" d="M37.7 128.9 9.8 101 100.4 10.4 156.2 10.4"/>
  <path fill="#42A5F5" fill-opacity=".8" d="M156.2 94 100.4 94 79.5 114.9 107.4 142.8"/>
  <path fill="#0D47A1" d="M79.5 170.7 100.4 191.6 156.2 191.6 156.2 191.6 107.4 142.8"/>
  <g transform="matrix(0.7071, -0.7071, 0.7071, 0.7071, -77.667, 98.057)">
      <rect width="39.4" height="39.4" x="59.8" y="123.1" fill="#42A5F5" />
      <rect width="39.4" height="5.5" x="59.8" y="162.5" fill="url(#rectangleGradient)" />
  </g>
  <path d="M79.5 170.7 120.9 156.4 107.4 142.8" fill="url(#triangleGradient)" />
</svg>
''';

const String stickFigureSvgStr = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg width="27px" height="90px" viewBox="5 10 18 70" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <!-- Generator: Sketch 53 (72520) - https://sketchapp.com -->
    <title>svg/stick_figure</title>
    <desc>Created with Sketch.</desc>
    <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="iPhone-8" transform="translate(-53.000000, -359.000000)" stroke="#979797">
            <g id="stick_figure" transform="translate(53.000000, 359.000000)">
                <ellipse id="Oval" fill="#D8D8D8" cx="13.5" cy="12" rx="12" ry="11.5"></ellipse>
                <path d="M13.5,24 L13.5,71.5" id="Line" stroke-linecap="square"></path>
                <path d="M13.5,71.5 L1,89.5" id="Line-2" stroke-linecap="square"></path>
                <path d="M13.5,37.5 L1,55.5" id="Line-2-Copy-2" stroke-linecap="square"></path>
                <path d="M26.5,71.5 L14,89.5" id="Line-2" stroke-linecap="square" transform="translate(20.000000, 80.500000) scale(-1, 1) translate(-20.000000, -80.500000) "></path>
                <path d="M26.5,37.5 L14,55.5" id="Line-2-Copy" stroke-linecap="square" transform="translate(20.000000, 46.500000) scale(-1, 1) translate(-20.000000, -46.500000) "></path>
            </g>
        </g>
    </g>
</svg>
''';

final Uint8List svgBytes = Uint8List.fromList(utf8.encode(svgStr));

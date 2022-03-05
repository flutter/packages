import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show window;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_test/flutter_test.dart';

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(Uri testFile) : super(testFile);

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
        print(
            'Warning - golden differed less than .06% (${result.diffPercent}%), '
            'ignoring failure but producing output');
        print(error);
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
  late FakeHttpClientResponse fakeResponse;
  late FakeHttpClientRequest fakeRequest;
  late FakeHttpClient fakeHttpClient;

  setUpAll(() {
    final LocalFileComparator oldComparator =
        goldenFileComparator as LocalFileComparator;
    final _TolerantComparator newComparator = _TolerantComparator(
        Uri.parse(oldComparator.basedir.toString() + 'test'));
    expect(oldComparator.basedir, newComparator.basedir);
    goldenFileComparator = newComparator;
  });

  setUp(() {
    PictureProvider.cache.clear();
    svg.cacheColorFilterOverride = null;
    fakeResponse = FakeHttpClientResponse();
    fakeRequest = FakeHttpClientRequest(fakeResponse);
    fakeHttpClient = FakeHttpClient(fakeRequest);
  });

  testWidgets(
      'SvgPicture does not use a color filtering widget when no color specified',
      (WidgetTester tester) async {
    expect(PictureProvider.cache.count, 0);
    await tester.pumpWidget(
      SvgPicture.string(
        svgStr,
        width: 100.0,
        height: 100.0,
      ),
    );
    await tester.pumpAndSettle();
    expect(PictureProvider.cache.count, 1);
    expect(find.byType(ColorFiltered), findsNothing);
  });

  testWidgets('SvgPicture does not invalidate the cache when color changes',
      (WidgetTester tester) async {
    expect(PictureProvider.cache.count, 0);
    await tester.pumpWidget(
      SvgPicture.string(
        svgStr,
        width: 100.0,
        height: 100.0,
        color: const Color(0xFF990000),
      ),
    );

    expect(PictureProvider.cache.count, 1);

    await tester.pumpWidget(
      SvgPicture.string(
        svgStr,
        width: 100.0,
        height: 100.0,
        color: const Color(0xFF990099),
      ),
    );

    expect(PictureProvider.cache.count, 1);
  });

  testWidgets(
      'SvgPicture does invalidate the cache when color changes and color filter is cached',
      (WidgetTester tester) async {
    expect(PictureProvider.cache.count, 0);
    await tester.pumpWidget(
      SvgPicture.string(
        svgStr,
        width: 100.0,
        height: 100.0,
        color: const Color(0xFF990000),
        cacheColorFilter: true,
      ),
    );

    expect(PictureProvider.cache.count, 1);

    await tester.pumpWidget(
      SvgPicture.string(
        svgStr,
        width: 100.0,
        height: 100.0,
        color: const Color(0xFF990099),
        cacheColorFilter: true,
      ),
    );

    expect(PictureProvider.cache.count, 2);
  });

  testWidgets(
      'SvgPicture does invalidate the cache when color changes and color filter is cached (override)',
      (WidgetTester tester) async {
    svg.cacheColorFilterOverride = true;
    expect(PictureProvider.cache.count, 0);
    await tester.pumpWidget(
      SvgPicture.string(
        svgStr,
        width: 100.0,
        height: 100.0,
        color: const Color(0xFF990000),
      ),
    );

    expect(PictureProvider.cache.count, 1);

    await tester.pumpWidget(
      SvgPicture.string(
        svgStr,
        width: 100.0,
        height: 100.0,
        color: const Color(0xFF990099),
      ),
    );

    expect(PictureProvider.cache.count, 2);
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
        data: MediaQueryData.fromWindow(window),
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
        data: MediaQueryData.fromWindow(window),
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
        data: MediaQueryData.fromWindow(window),
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
        data: MediaQueryData.fromWindow(window),
        child: RepaintBoundary(
          key: key,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
        data: MediaQueryData.fromWindow(window),
        child: RepaintBoundary(
          key: key,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
        data: MediaQueryData.fromWindow(window),
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
        data: MediaQueryData.fromWindow(window),
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
          data: MediaQueryData.fromWindow(window),
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
    await HttpOverrides.runZoned(() async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData.fromWindow(window),
          child: RepaintBoundary(
            key: key,
            child: SvgPicture.network(
              'test.svg',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _checkWidgetAndGolden(key, 'flutter_logo.network.png');
    }, createHttpClient: (SecurityContext? c) => fakeHttpClient);
  });

  testWidgets('SvgPicture.network with headers', (WidgetTester tester) async {
    await HttpOverrides.runZoned(() async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData.fromWindow(window),
          child: RepaintBoundary(
            key: key,
            child: SvgPicture.network('test.svg',
                headers: const <String, String>{'a': 'b'}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(fakeRequest.headers['a']!.single, 'b');
    }, createHttpClient: (SecurityContext? c) => fakeHttpClient);
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
    await HttpOverrides.runZoned(() async {
      expect(() async {
        fakeResponse.statusCode = 400;
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData.fromWindow(window),
            child: SvgPicture.network(
              'notFound.svg',
            ),
          ),
        );
      }, isNotNull);
    }, createHttpClient: (SecurityContext? c) => fakeHttpClient);
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
  }, semanticsEnabled: true);

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
  }, semanticsEnabled: true);

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
  }, semanticsEnabled: true);

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
          color: const Color(0xFF990000),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'flutter_logo.string.color_filter.png');
  });

  testWidgets('SvgPicture colorFilter - flutter logo - BlendMode.color',
      (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: SvgPicture.string(
          svgStr,
          width: 100.0,
          height: 100.0,
          color: const Color(0xFF990000),
          colorBlendMode: BlendMode.color,
        ),
      ),
    );

    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(
        key, 'flutter_logo.string.color_filter.blendmode_color.png');
  });

  testWidgets('SvgPicture colorFilter with text', (WidgetTester tester) async {
    const String svgData =
        '''<svg font-family="arial" font-size="14" height="160" width="88" xmlns="http://www.w3.org/2000/svg">
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
          color: const Color(0xFF990000),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'text_color_filter.png');
  });

  testWidgets('Nested SVG elements report a FlutterError',
      (WidgetTester tester) async {
    await svg.fromSvgString(
        '<svg viewBox="0 0 166 202"><svg viewBox="0 0 166 202"></svg></svg>',
        'test');
    final UnsupportedError error = tester.takeException() as UnsupportedError;
    expect(error.message, 'Unsupported nested <svg> element.');
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

  testWidgets('SvgPicture.string respects clipBehavior',
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SvgPicture.string(svgStr),
    ));
    await tester.pumpAndSettle();

    // Check that the render object has received the default clip behavior.
    final RenderFittedBox renderObject =
        tester.allRenderObjects.whereType<RenderFittedBox>().first;
    expect(renderObject.clipBehavior, equals(Clip.hardEdge));

    // Pump a new widget to check that the render object can update its clip
    // behavior.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SvgPicture.string(svgStr, clipBehavior: Clip.antiAlias),
      ),
    );
    await tester.pumpAndSettle();
    expect(renderObject.clipBehavior, equals(Clip.antiAlias));
  });

  testWidgets('SvgPicture.asset respects clipBehavior',
      (WidgetTester tester) async {
    final FakeAssetBundle fakeAsset = FakeAssetBundle();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SvgPicture.asset(
        'test.svg',
        bundle: fakeAsset,
      ),
    ));
    await tester.pumpAndSettle();

    // Check that the render object has received the default clip behavior.
    final RenderFittedBox renderObject =
        tester.allRenderObjects.whereType<RenderFittedBox>().first;
    expect(renderObject.clipBehavior, equals(Clip.hardEdge));

    // Pump a new widget to check that the render object can update its clip
    // behavior.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SvgPicture.asset(
          'test.svg',
          bundle: fakeAsset,
          clipBehavior: Clip.antiAlias,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(renderObject.clipBehavior, equals(Clip.antiAlias));
  });

  testWidgets('SvgPicture.memory respects clipBehavior',
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SvgPicture.memory(svgBytes),
    ));
    await tester.pumpAndSettle();

    // Check that the render object has received the default clip behavior.
    final RenderFittedBox renderObject =
        tester.allRenderObjects.whereType<RenderFittedBox>().first;
    expect(renderObject.clipBehavior, equals(Clip.hardEdge));

    // Pump a new widget to check that the render object can update its clip
    // behavior.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SvgPicture.memory(svgBytes, clipBehavior: Clip.antiAlias),
      ),
    );
    await tester.pumpAndSettle();
    expect(renderObject.clipBehavior, equals(Clip.antiAlias));
  });

  testWidgets('SvgPicture.network respects clipBehavior',
      (WidgetTester tester) async {
    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SvgPicture.network('test.svg'),
        ),
      );
      await tester.pumpAndSettle();

      // Check that the render object has received the default clip behavior.
      final RenderFittedBox renderObject =
          tester.allRenderObjects.whereType<RenderFittedBox>().first;
      expect(renderObject.clipBehavior, equals(Clip.hardEdge));

      // Pump a new widget to check that the render object can update its clip
      // behavior.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SvgPicture.network('test.svg', clipBehavior: Clip.antiAlias),
        ),
      );
      await tester.pumpAndSettle();
      expect(renderObject.clipBehavior, equals(Clip.antiAlias));
    }, createHttpClient: (SecurityContext? c) => fakeHttpClient);
  });

  testWidgets('SvgPicture respects clipBehavior', (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SvgPicture.string(svgStr),
    ));
    await tester.pumpAndSettle();

    // Check that the render object has received the default clip behavior.
    final RenderFittedBox renderObject =
        tester.allRenderObjects.whereType<RenderFittedBox>().first;
    expect(renderObject.clipBehavior, equals(Clip.hardEdge));

    // Pump a new widget to check that the render object can update its clip
    // behavior.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SvgPicture.string(svgStr, clipBehavior: Clip.antiAlias),
      ),
    );
    await tester.pumpAndSettle();
    expect(renderObject.clipBehavior, equals(Clip.antiAlias));
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
      await _checkWidgetAndGolden(key, 'circle.em_ex.png');
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
      await _checkWidgetAndGolden(key, 'rect.em_ex.png');
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
      await _checkWidgetAndGolden(key, 'ellipse.em_ex.png');
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
      await _checkWidgetAndGolden(key, 'line.em_ex.png');
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

  testWidgets(
      'Update widget without a cache does not result in an disposed picture',
      (WidgetTester tester) async {
    final int oldCacheSize = PictureProvider.cache.maximumSize;
    PictureProvider.cache.maximumSize = 0;
    final GlobalKey key = GlobalKey();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SvgPicture(
            FakePictureProvider(
              SvgPicture.svgStringDecoderBuilder,
              simpleSvg,
            ),
            key: key),
      ),
    );

    expect(find.byKey(key), findsOneWidget);

    // Update the widget with a new incompatible key.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SvgPicture(
            FakePictureProvider(
              SvgPicture.svgStringDecoderBuilder,
              stickFigureSvgStr,
            ),
            key: key),
      ),
    );

    expect(find.byKey(key), findsOneWidget);
    await tester.pumpAndSettle();
    PictureProvider.cache.maximumSize = oldCacheSize;
  });

  testWidgets('state maintains a handle', (WidgetTester tester) async {
    final int oldCacheSize = PictureProvider.cache.maximumSize;
    PictureProvider.cache.maximumSize = 1;
    final GlobalKey key = GlobalKey();
    final FakePictureProvider provider = FakePictureProvider(
      SvgPicture.svgStringDecoderBuilder,
      simpleSvg,
    );

    final PictureStream stream = provider.resolve(
      createLocalPictureConfiguration(key.currentContext),
    );
    final Completer<PictureInfo> completer = Completer<PictureInfo>();
    void listener(PictureInfo? info, bool syncCall) {
      completer.complete(info!);
    }

    stream.addListener(listener);

    final PictureInfo info = await completer.future;
    expect(info.debugHandleCount, 1);
    stream.removeListener(listener);
    // Still in cache.
    expect(info.debugHandleCount, 1);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SvgPicture(provider, key: key),
      ),
    );
    expect(find.byKey(key), findsOneWidget);
    expect(info.debugHandleCount, 3);
    PictureProvider.cache.clear();
    expect(info.debugHandleCount, 3);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(info.debugHandleCount, 0);

    PictureProvider.cache.maximumSize = oldCacheSize;
  });
}

class FakePictureProvider extends StringPicture {
  FakePictureProvider(
    PictureInfoDecoderBuilder<String> decoderBuilder,
    String string,
  ) : super(decoderBuilder, string);

  int resolveCount = 0;

  @override
  PictureStream resolve(
    PictureConfiguration picture, {
    PictureErrorListener? onError,
  }) {
    resolveCount += 1;
    return super.resolve(picture, onError: onError);
  }

  @override
  // ignore: hash_and_equals, avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    // Picture providers should be compared based on key. Make sure tests don't
    // cheat this check by using an identical provider.
    return false;
  }
}

class FakeAssetBundle extends Fake implements AssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return svgStr;
  }
}

class FakeHttpClient extends Fake implements HttpClient {
  FakeHttpClient(this.request);

  FakeHttpClientRequest request;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => request;
}

class FakeHttpHeaders extends Fake implements HttpHeaders {
  final Map<String, String?> values = <String, String?>{};

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    values[name] = value.toString();
  }

  @override
  List<String>? operator [](String key) {
    return <String>[values[key]!];
  }
}

class FakeHttpClientRequest extends Fake implements HttpClientRequest {
  FakeHttpClientRequest(this.response);

  FakeHttpClientResponse response;

  @override
  final HttpHeaders headers = FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => response;
}

class FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int statusCode = 200;

  @override
  int contentLength = svgStr.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<Uint8List>.fromIterable(<Uint8List>[svgBytes]).listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
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

final Uint8List svgBytes = utf8.encode(svgStr) as Uint8List;

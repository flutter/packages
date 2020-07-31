import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show window;

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mockito/mockito.dart';

Future<void> _checkWidgetAndGolden(Key key, String filename) async {
  final Finder widgetFinder = find.byKey(key);
  expect(widgetFinder, findsOneWidget);
  await expectLater(widgetFinder, matchesGoldenFile('golden_widget/$filename'));
}

void main() {
  const String svgStr =
      '''<svg xmlns="http://www.w3.org/2000/svg" version="1.1" viewBox="0 0 166 202">
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
</svg>''';

  const String stickFigureSvgStr = '''<?xml version="1.0" encoding="UTF-8"?>
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
</svg>''';

  final Uint8List svgBytes = utf8.encode(svgStr) as Uint8List;

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

  testWidgets('SvgPicture.string rtl', (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData.fromWindow(window),
        child: RepaintBoundary(
          key: key,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SvgPicture.string(
              svgStr,
              matchTextDirection: true,
              width: 100.0,
              height: 100.0,
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
    final MockAssetBundle mockAsset = MockAssetBundle();
    when(mockAsset.loadString('test.svg'))
        .thenAnswer((_) => Future<String>.value(svgStr));

    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData.fromWindow(window),
        child: RepaintBoundary(
          key: key,
          child: SvgPicture.asset(
            'test.svg',
            bundle: mockAsset,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'flutter_logo.asset.png');
  });

  testWidgets('SvgPicture.asset DefaultAssetBundle',
      (WidgetTester tester) async {
    final MockAssetBundle mockAsset = MockAssetBundle();
    when(mockAsset.loadString('test.svg'))
        .thenAnswer((_) => Future<String>.value(svgStr));

    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData.fromWindow(window),
          child: DefaultAssetBundle(
            bundle: mockAsset,
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

  final MockHttpClient mockHttpClient = MockHttpClient();
  final MockHttpClientRequest mockRequest = MockHttpClientRequest();
  final MockHttpClientResponse mockResponse = MockHttpClientResponse();

  when(mockHttpClient.getUrl(any))
      .thenAnswer((_) => Future<MockHttpClientRequest>.value(mockRequest));

  when(mockRequest.close())
      .thenAnswer((_) => Future<MockHttpClientResponse>.value(mockResponse));

  when(mockResponse.transform<Uint8List>(any))
      .thenAnswer((_) => Stream<Uint8List>.fromIterable(<Uint8List>[svgBytes]));
  when(mockResponse.listen(any,
          onDone: anyNamed('onDone'),
          onError: anyNamed('onError'),
          cancelOnError: anyNamed('cancelOnError')))
      .thenAnswer((Invocation invocation) {
    final void Function(Uint8List) onData =
        invocation.positionalArguments[0] as void Function(Uint8List);
    final void Function(Object) onError =
        invocation.namedArguments[#onError] as void Function(Object);
    final VoidCallback onDone =
        invocation.namedArguments[#onDone] as VoidCallback;
    final bool cancelOnError =
        invocation.namedArguments[#cancelOnError] as bool;

    return Stream<Uint8List>.fromIterable(<Uint8List>[svgBytes]).listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  });

  testWidgets('SvgPicture.network', (WidgetTester tester) async {
    await HttpOverrides.runZoned(() async {
      when(mockResponse.statusCode).thenReturn(200);
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
    }, createHttpClient: (SecurityContext c) => mockHttpClient);
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
        when(mockResponse.statusCode).thenReturn(400);
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData.fromWindow(window),
            child: SvgPicture.network(
              'notFound.svg',
            ),
          ),
        );
      }, isNotNull);
    }, createHttpClient: (SecurityContext c) => mockHttpClient);
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
  }, skip: !isLinux);

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
}

class MockAssetBundle extends Mock implements AssetBundle {}

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

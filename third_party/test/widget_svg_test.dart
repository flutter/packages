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
  final Uint8List svg = utf8.encode(svgStr);

  testWidgets('SvgPicture can work with a FittedBox',
      (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData.fromWindow(window),
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
            svg,
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

  final MockHttpClient mockHttpClient = MockHttpClient();
  final MockHttpClientRequest mockRequest = MockHttpClientRequest();
  final MockHttpClientResponse mockResponse = MockHttpClientResponse();

  when(mockHttpClient.getUrl(any))
      .thenAnswer((_) => Future<MockHttpClientRequest>.value(mockRequest));

  when(mockRequest.close())
      .thenAnswer((_) => Future<MockHttpClientResponse>.value(mockResponse));

  when(mockResponse.transform<Uint8List>(any))
      .thenAnswer((_) => Stream<Uint8List>.fromIterable(<Uint8List>[svg]));
  when(mockResponse.listen(any,
          onDone: anyNamed('onDone'),
          onError: anyNamed('onError'),
          cancelOnError: anyNamed('cancelOnError')))
      .thenAnswer((Invocation invocation) {
    final void Function(Uint8List) onData = invocation.positionalArguments[0];
    final void Function(Object) onError = invocation.namedArguments[#onError];
    final void Function() onDone = invocation.namedArguments[#onDone];
    final bool cancelOnError = invocation.namedArguments[#cancelOnError];

    return Stream<Uint8List>.fromIterable(<Uint8List>[svg]).listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  });

  testWidgets('SvgPicture.network', (WidgetTester tester) async {
    HttpOverrides.runZoned(() async {
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
    HttpOverrides.runZoned(() async {
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
}

class MockAssetBundle extends Mock implements AssetBundle {}

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

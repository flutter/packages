import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mockito/mockito.dart';

Future<Null> _checkWidgetAndGolden(Key key, String filename) async {
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
    final GlobalKey key = new GlobalKey();
    await tester.pumpWidget(
      new Row(
        key: key,
        textDirection: TextDirection.ltr,
        children: <Widget>[
          new Flexible(
            child: new FittedBox(
              fit: BoxFit.fitWidth,
              child: new SvgPicture.string(
                svgStr,
                width: 20.0,
                height: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    final Finder widgetFinder = find.byKey(key);
    expect(widgetFinder, findsOneWidget);
  });

  testWidgets('SvgPicture.string', (WidgetTester tester) async {
    final GlobalKey key = new GlobalKey();
    await tester.pumpWidget(new RepaintBoundary(
        key: key,
        child: new SvgPicture.string(
          svgStr,
          // key: key,
          width: 100.0,
          height: 100.0,
        )));

    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'flutter_logo.string.png');
  });

  testWidgets('SvgPicture.string rtl', (WidgetTester tester) async {
    final GlobalKey key = new GlobalKey();
    await tester.pumpWidget(
      new RepaintBoundary(
        key: key,
        child: new Directionality(
          textDirection: TextDirection.rtl,
          child: new SvgPicture.string(
            svgStr,
            matchTextDirection: true,
            width: 100.0,
            height: 100.0,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'flutter_logo.string.rtl.png');
  });

  testWidgets('SvgPicture.memory', (WidgetTester tester) async {
    final GlobalKey key = new GlobalKey();
    await tester.pumpWidget(
      new RepaintBoundary(
        key: key,
        child: new SvgPicture.memory(
          svg,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _checkWidgetAndGolden(key, 'flutter_logo.memory.png');
  });

  testWidgets('SvgPicture.asset', (WidgetTester tester) async {
    final MockAssetBundle mockAsset = new MockAssetBundle();
    when(mockAsset.load('test.svg')).thenAnswer(
        (_) => new Future<ByteData>.value(new ByteData.view(svg.buffer)));

    final GlobalKey key = new GlobalKey();
    await tester.pumpWidget(
      new RepaintBoundary(
        key: key,
        child: new SvgPicture.asset(
          'test.svg',
          bundle: mockAsset,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _checkWidgetAndGolden(key, 'flutter_logo.asset.png');
  });

  final MockHttpClient mockHttpClient = new MockHttpClient();
  final MockHttpClientRequest mockRequest = new MockHttpClientRequest();
  final MockHttpClientResponse mockResponse = new MockHttpClientResponse();

  when(mockHttpClient.getUrl(typed(any)))
      .thenAnswer((_) => new Future<MockHttpClientRequest>.value(mockRequest));

  when(mockRequest.close()).thenAnswer(
      (_) => new Future<MockHttpClientResponse>.value(mockResponse));

  when(mockResponse.transform<Uint8List>(typed(any)))
      .thenAnswer((_) => new Stream<Uint8List>.fromIterable(<Uint8List>[svg]));
  when(mockResponse.listen(typed(any),
          onDone: typed(any, named: 'onDone'),
          onError: typed(any, named: 'onError'),
          cancelOnError: typed(any, named: 'cancelOnError')))
      .thenAnswer((Invocation invocation) {
    final void Function(Uint8List) onData = invocation.positionalArguments[0];
    final void Function(Object) onError = invocation.namedArguments[#onError];
    final void Function() onDone = invocation.namedArguments[#onDone];
    final bool cancelOnError = invocation.namedArguments[#cancelOnError];

    return new Stream<Uint8List>.fromIterable(<Uint8List>[svg]).listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  });

  testWidgets('SvgPicture.network', (WidgetTester tester) async {
    HttpOverrides.runZoned(() async {
      when(mockResponse.statusCode).thenReturn(200);
      final GlobalKey key = new GlobalKey();
      await tester.pumpWidget(
        new RepaintBoundary(
          key: key,
          child: new SvgPicture.network(
            'test.svg',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _checkWidgetAndGolden(key, 'flutter_logo.network.png');
    }, createHttpClient: (SecurityContext c) => mockHttpClient);
  });

  // // TODO: Why isn't this working when I just use SvgPicture.network?
  // testWidgets('SvgPicture.network HTTP exception', (WidgetTester tester) async {
  //   HttpOverrides.runZoned(() async {
  //     when(mockResponse.statusCode).thenReturn(400);
  //     expect(() async {
  //       Future<Null> t = await tester
  //           .pumpWidget(new SvgPicture.network('test.svg', 100.0, 100.0));
  //     }, throwsA(const isInstanceOf<HttpException>()));
  //   }, createHttpClient: (SecurityContext c) => mockHttpClient);
  // });
}

class MockAssetBundle extends Mock implements AssetBundle {}

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

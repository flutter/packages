import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mockito/mockito.dart';

void main() {
  const String svg = '''<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg viewBox="0 0 1000 300"
     xmlns="http://www.w3.org/2000/svg" version="1.1">
  <desc>Example text01 - 'Hello, out there' in blue</desc>

  <text x="250" y="150" 
        font-family="Verdana" font-size="55" stroke="red" fill="blue" >
    Hello, out there
  </text>

  <!-- Show outline of canvas using 'rect' element -->
  <rect x="1" y="1" width="998" height="298"
        fill="none" stroke="blue" stroke-width="2" />
</svg>''';

  testWidgets('SvgImage.fromString', (WidgetTester tester) async {
    final GlobalKey key = new GlobalKey();
    await tester.pumpWidget(new SvgImage.fromString(
      svg,
      const Size(100.0, 100.0),
      key: key,
    ));
    expect(find.byKey(key), findsOneWidget);
  });

  testWidgets('SvgImage.asset', (WidgetTester tester) async {
    final MockAssetBundle mockAsset = new MockAssetBundle();
    when(mockAsset.loadString('test.svg'))
        .thenAnswer((_) => new Future<String>.value(svg));

    final GlobalKey key = new GlobalKey();
    await tester.pumpWidget(new SvgImage.asset(
      'test.svg',
      const Size(100.0, 100.0),
      key: key,
      bundle: mockAsset,
    ));
    expect(find.byKey(key), findsOneWidget);
  });

  final MockHttpClient mockHttpClient = new MockHttpClient();
  final MockHttpClientRequest mockRequest = new MockHttpClientRequest();
  final MockHttpClientResponse mockResponse = new MockHttpClientResponse();

  when(mockHttpClient.getUrl(typed(any)))
      .thenAnswer((_) => new Future<MockHttpClientRequest>.value(mockRequest));

  when(mockRequest.close()).thenAnswer(
      (_) => new Future<MockHttpClientResponse>.value(mockResponse));

  when(mockResponse.transform<String>(typed(any)))
      .thenAnswer((_) => new Stream<String>.fromIterable(<String>[svg]));
  when(mockResponse.listen(typed(any),
          onDone: typed(any, named: 'onDone'),
          onError: typed(any, named: 'onError'),
          cancelOnError: typed(any, named: 'cancelOnError')))
      .thenAnswer((Invocation invocation) {
    final void Function(String) onData = invocation.positionalArguments[0];
    final void Function(Object) onError = invocation.namedArguments[#onError];
    final void Function() onDone = invocation.namedArguments[#onDone];
    final bool cancelOnError = invocation.namedArguments[#cancelOnError];

    return new Stream<String>.fromIterable(<String>[svg]).listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  });

  testWidgets('SvgImage.network', (WidgetTester tester) async {
    HttpOverrides.runZoned(() async {
      when(mockResponse.statusCode).thenReturn(200);
      final GlobalKey key = new GlobalKey();
      await tester.pumpWidget(new SvgImage.network(
        'test.svg',
        const Size(100.0, 100.0),
        key: key,
      ));
      expect(find.byKey(key), findsOneWidget);
    }, createHttpClient: (SecurityContext c) => mockHttpClient);
  });

  test('loadNetworkAsset HTTP exception', () {
    HttpOverrides.runZoned(() {
      when(mockResponse.statusCode).thenReturn(400);
      expect(() => loadNetworkAsset('test.svg', const Size(100.0, 100.0)),
          throwsA(const isInstanceOf<HttpException>()));
    }, createHttpClient: (SecurityContext c) => mockHttpClient);
  });
}

class MockAssetBundle extends Mock implements AssetBundle {}

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

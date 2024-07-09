// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:web/web.dart' as web;
import 'package:webview_flutter_platform_interface/src/webview_flutter_platform_interface_legacy.dart';
import 'package:webview_flutter_web/src/http_request_factory.dart';
import 'package:webview_flutter_web/src/webview_flutter_web_legacy.dart';

import 'webview_flutter_web_test.mocks.dart';

@GenerateMocks(<Type>[
  BuildContext,
  CreationParams,
  WebViewPlatformCallbacksHandler,
  HttpRequestFactory,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebWebViewPlatform', () {
    test('build returns a HtmlElementView', () {
      // Setup
      final WebWebViewPlatform platform = WebWebViewPlatform();
      // Run
      final Widget widget = platform.build(
        context: MockBuildContext(),
        creationParams: CreationParams(),
        webViewPlatformCallbacksHandler: MockWebViewPlatformCallbacksHandler(),
        javascriptChannelRegistry: null,
      );
      // Verify
      expect(widget, isA<HtmlElementView>());
    });
  });

  group('WebWebViewPlatformController', () {
    test('loadUrl sets url on iframe src attribute', () {
      // Setup
      final web.HTMLIFrameElement fakeIFrame = web.HTMLIFrameElement();
      final WebWebViewPlatformController controller =
          WebWebViewPlatformController(fakeIFrame);
      // Run
      controller.loadUrl('http://example.com/', null);
      // Verify
      expect(fakeIFrame.src, 'http://example.com/');
    });

    group('loadHtmlString', () {
      test('loadHtmlString loads html into iframe', () {
        // Setup
        final web.HTMLIFrameElement fakeIFrame = web.HTMLIFrameElement();
        final WebWebViewPlatformController controller =
            WebWebViewPlatformController(fakeIFrame);
        // Run
        controller.loadHtmlString('test html');
        // Verify
        expect(fakeIFrame.src,
            'data:text/html;charset=utf-8,${Uri.encodeFull('test html')}');
      });

      test('loadHtmlString escapes "#" correctly', () {
        // Setup
        final web.HTMLIFrameElement fakeIFrame = web.HTMLIFrameElement();
        final WebWebViewPlatformController controller =
            WebWebViewPlatformController(fakeIFrame);
        // Run
        controller.loadHtmlString('#');
        // Verify
        expect(fakeIFrame.src, contains('%23'));
      });
    });

    group('loadRequest', () {
      test('loadRequest throws ArgumentError on missing scheme', () {
        // Setup
        final web.HTMLIFrameElement fakeIFrame = web.HTMLIFrameElement();
        final WebWebViewPlatformController controller =
            WebWebViewPlatformController(fakeIFrame);

        // Run & Verify
        expect(
            () async => controller.loadRequest(
                  WebViewRequest(
                    uri: Uri.parse('flutter.dev'),
                    method: WebViewRequestMethod.get,
                  ),
                ),
            throwsA(const TypeMatcher<ArgumentError>()));
      });

      test('loadRequest makes request and loads response into iframe',
          () async {
        // Setup
        final web.HTMLIFrameElement fakeIFrame = web.HTMLIFrameElement();
        final WebWebViewPlatformController controller =
            WebWebViewPlatformController(fakeIFrame);

        final web.Response fakeResponse = web.Response(
            'test data'.toJS,
            <String, Object>{
              'headers': <String, Object>{
                'content-type': 'text/plain',
              },
            }.jsify()! as web.ResponseInit);

        final MockHttpRequestFactory mockHttpRequestFactory =
            MockHttpRequestFactory();
        when(mockHttpRequestFactory.request(
          any,
          method: anyNamed('method'),
          requestHeaders: anyNamed('requestHeaders'),
          sendData: anyNamed('sendData'),
        )).thenAnswer((_) => Future<web.Response>.value(fakeResponse));

        controller.httpRequestFactory = mockHttpRequestFactory;

        // Run
        await controller.loadRequest(
          WebViewRequest(
              uri: Uri.parse('https://flutter.dev'),
              method: WebViewRequestMethod.post,
              body: Uint8List.fromList('test body'.codeUnits),
              headers: <String, String>{'Foo': 'Bar'}),
        );
        // Verify
        verify(mockHttpRequestFactory.request(
          'https://flutter.dev',
          method: 'post',
          requestHeaders: <String, String>{'Foo': 'Bar'},
          sendData: Uint8List.fromList('test body'.codeUnits),
        ));

        expect(fakeIFrame.src,
            'data:;charset=utf-8,${Uri.encodeFull('test data')}');
      });

      test('loadRequest escapes "#" correctly', () async {
        // Setup
        final web.HTMLIFrameElement fakeIFrame = web.HTMLIFrameElement();
        final WebWebViewPlatformController controller =
            WebWebViewPlatformController(fakeIFrame);

        final web.Response fakeResponse = web.Response(
            '#'.toJS,
            <String, Object>{
              'headers': <String, Object>{
                'content-type': 'text/html',
              },
            }.jsify()! as web.ResponseInit);

        final MockHttpRequestFactory mockHttpRequestFactory =
            MockHttpRequestFactory();
        when(mockHttpRequestFactory.request(
          any,
          method: anyNamed('method'),
          requestHeaders: anyNamed('requestHeaders'),
          sendData: anyNamed('sendData'),
        )).thenAnswer((_) => Future<web.Response>.value(fakeResponse));

        controller.httpRequestFactory = mockHttpRequestFactory;

        // Run
        await controller.loadRequest(
          WebViewRequest(
              uri: Uri.parse('https://flutter.dev'),
              method: WebViewRequestMethod.post,
              body: Uint8List.fromList('test body'.codeUnits),
              headers: <String, String>{'Foo': 'Bar'}),
        );

        expect(fakeIFrame.src, contains('%23'));
      });
    });
  });
}

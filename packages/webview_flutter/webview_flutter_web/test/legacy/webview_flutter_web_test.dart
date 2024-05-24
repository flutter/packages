// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:web/web.dart' as html;
import 'package:webview_flutter_platform_interface/src/webview_flutter_platform_interface_legacy.dart';
import 'package:webview_flutter_web/src/http_request_factory.dart';
import 'package:webview_flutter_web/src/webview_flutter_web_legacy.dart';

import 'webview_flutter_web_test.mocks.dart';

@GenerateMocks(<Type>[
  BuildContext,
  CreationParams,
  WebViewPlatformCallbacksHandler,
  HttpRequestFactory,
  http.StreamedResponse,
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
      final html.HTMLIFrameElement mockElement = html.HTMLIFrameElement();
      final WebWebViewPlatformController controller =
          WebWebViewPlatformController(
        mockElement,
      );
      // Run
      controller.loadUrl('test url', null);
      // Verify
      verify(mockElement.src = 'test url');
    });

    group('loadHtmlString', () {
      test('loadHtmlString loads html into iframe', () {
        // Setup
        final html.HTMLIFrameElement mockElement = html.HTMLIFrameElement();
        final WebWebViewPlatformController controller =
            WebWebViewPlatformController(
          mockElement,
        );
        // Run
        controller.loadHtmlString('test html');
        // Verify
        verify(mockElement.src =
            'data:text/html;charset=utf-8,${Uri.encodeFull('test html')}');
      });

      test('loadHtmlString escapes "#" correctly', () {
        // Setup
        final html.HTMLIFrameElement mockElement = html.HTMLIFrameElement();
        final WebWebViewPlatformController controller =
            WebWebViewPlatformController(
          mockElement,
        );
        // Run
        controller.loadHtmlString('#');
        // Verify
        verify(mockElement.src = argThat(contains('%23')) ?? '');
      });
    });

    group('loadRequest', () {
      test('loadRequest throws ArgumentError on missing scheme', () {
        // Setup
        final html.HTMLIFrameElement mockElement = html.HTMLIFrameElement();
        final WebWebViewPlatformController controller =
            WebWebViewPlatformController(
          mockElement,
        );
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
        final html.HTMLIFrameElement mockElement = html.HTMLIFrameElement();
        final WebWebViewPlatformController controller =
            WebWebViewPlatformController(
          mockElement,
        );
        final MockStreamedResponse mockHttpRequest = MockStreamedResponse();
        when(mockHttpRequest.headers['content-type']).thenReturn('text/plain');

        final http.Response res =
            await http.Response.fromStream(mockHttpRequest);
        when(res.body).thenReturn('test data');
        final MockHttpRequestFactory mockHttpRequestFactory =
            MockHttpRequestFactory();
        when(mockHttpRequestFactory.request(
          any,
          method: anyNamed('method'),
          requestHeaders: anyNamed('requestHeaders'),
          sendData: anyNamed('sendData'),
        )).thenAnswer(
            (_) => Future<http.StreamedResponse>.value(mockHttpRequest));
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
        verify(mockElement.src =
            'data:;charset=utf-8,${Uri.encodeFull('test data')}');
      });

      test('loadRequest escapes "#" correctly', () async {
        // Setup
        final html.HTMLIFrameElement mockElement = html.HTMLIFrameElement();
        final WebWebViewPlatformController controller =
            WebWebViewPlatformController(
          mockElement,
        );
        final MockStreamedResponse mockHttpRequest = MockStreamedResponse();
        when(mockHttpRequest.headers['content-type']).thenReturn('text/html');

        final http.Response res =
            await http.Response.fromStream(mockHttpRequest);
        when(res.body).thenReturn('#');
        final MockHttpRequestFactory mockHttpRequestFactory =
            MockHttpRequestFactory();
        when(mockHttpRequestFactory.request(
          any,
          method: anyNamed('method'),
          requestHeaders: anyNamed('requestHeaders'),
          sendData: anyNamed('sendData'),
        )).thenAnswer(
            (_) => Future<http.StreamedResponse>.value(mockHttpRequest));
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
        verify(mockElement.src = argThat(contains('%23')) ?? '');
      });
    });
  });
}

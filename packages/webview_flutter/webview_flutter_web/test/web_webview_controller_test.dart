// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

import 'web_webview_controller_test.mocks.dart';

@GenerateMocks(<Type>[], customMocks: <MockSpec<Object>>[
  MockSpec<http.Response>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<HttpRequestFactory>(onMissingStub: OnMissingStub.returnDefault),
])
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('WebWebViewController', () {
    group('WebWebViewControllerCreationParams', () {
      test('sets iFrame fields', () {
        final WebWebViewControllerCreationParams params =
            WebWebViewControllerCreationParams();

        expect(params.iFrame.id, contains('webView'));
        expect(params.iFrame.style.width, '100%');
        expect(params.iFrame.style.height, '100%');
        expect(params.iFrame.style.border, 'none');
      });
    });

    group('loadHtmlString', () {
      test('loadHtmlString loads html into iframe', () async {
        final WebWebViewController controller =
            WebWebViewController(WebWebViewControllerCreationParams());

        await controller.loadHtmlString('test html');
        expect(
          (controller.params as WebWebViewControllerCreationParams).iFrame.src,
          'data:text/html;charset=utf-8,${Uri.encodeFull('test html')}',
        );
      });

      test('loadHtmlString escapes "#" correctly', () async {
        final WebWebViewController controller =
            WebWebViewController(WebWebViewControllerCreationParams());

        await controller.loadHtmlString('#');
        expect(
          (controller.params as WebWebViewControllerCreationParams).iFrame.src,
          contains('%23'),
        );
      });
    });

    group('loadRequest', () {
      test('throws ArgumentError on missing scheme', () async {
        final WebWebViewController controller =
            WebWebViewController(WebWebViewControllerCreationParams());

        await expectLater(
            () async => controller.loadRequest(
                  LoadRequestParams(uri: Uri.parse('flutter.dev')),
                ),
            throwsA(const TypeMatcher<ArgumentError>()));
      });

      test('skips XHR for simple GETs (no headers, no data)', () async {
        final MockHttpRequestFactory mockHttpRequestFactory =
            MockHttpRequestFactory();
        final WebWebViewController controller =
            WebWebViewController(WebWebViewControllerCreationParams(
          httpRequestFactory: mockHttpRequestFactory,
        ));

        when(mockHttpRequestFactory.request(
          any,
          method: anyNamed('method'),
          requestHeaders: anyNamed('requestHeaders'),
          sendData: anyNamed('sendData'),
        )).thenThrow(
            StateError('The `request` method should not have been called.'));

        await controller.loadRequest(LoadRequestParams(
          uri: Uri.parse('https://flutter.dev'),
        ));

        expect(
          (controller.params as WebWebViewControllerCreationParams).iFrame.src,
          'https://flutter.dev/',
        );
      });

      test('makes request and loads response into iframe', () async {
        final MockHttpRequestFactory mockHttpRequestFactory =
            MockHttpRequestFactory();
        final WebWebViewController controller =
            WebWebViewController(WebWebViewControllerCreationParams(
          httpRequestFactory: mockHttpRequestFactory,
        ));

        final MockResponse mockHttpRequest = MockResponse();
        when(mockHttpRequest.headers['content-type']).thenReturn('text/plain');

        when(mockHttpRequest.body).thenReturn('test data');

        when(mockHttpRequestFactory.request(
          any,
          method: anyNamed('method'),
          requestHeaders: anyNamed('requestHeaders'),
          sendData: anyNamed('sendData'),
        )).thenAnswer((_) => Future<http.Response>.value(mockHttpRequest));

        await controller.loadRequest(LoadRequestParams(
          uri: Uri.parse('https://flutter.dev'),
          method: LoadRequestMethod.post,
          body: Uint8List.fromList('test body'.codeUnits),
          headers: const <String, String>{'Foo': 'Bar'},
        ));

        verify(mockHttpRequestFactory.request(
          'https://flutter.dev',
          method: 'post',
          requestHeaders: <String, String>{'Foo': 'Bar'},
          sendData: Uint8List.fromList('test body'.codeUnits),
        ));

        expect(
          (controller.params as WebWebViewControllerCreationParams).iFrame.src,
          'data:;charset=utf-8,${Uri.encodeFull('test data')}',
        );
      });

      test('parses content-type response header correctly', () async {
        final MockHttpRequestFactory mockHttpRequestFactory =
            MockHttpRequestFactory();
        final WebWebViewController controller =
            WebWebViewController(WebWebViewControllerCreationParams(
          httpRequestFactory: mockHttpRequestFactory,
        ));

        final Encoding iso = Encoding.getByName('latin1')!;
        final MockResponse mockHttpRequest = MockResponse();

        when(mockHttpRequest.body)
            .thenReturn(String.fromCharCodes(iso.encode('España')));
        when(mockHttpRequest.headers['content-type'])
            .thenReturn('Text/HTmL; charset=latin1');

        when(mockHttpRequestFactory.request(
          any,
          method: anyNamed('method'),
          requestHeaders: anyNamed('requestHeaders'),
          sendData: anyNamed('sendData'),
        )).thenAnswer((_) => Future<http.Response>.value(mockHttpRequest));

        await controller.loadRequest(LoadRequestParams(
          uri: Uri.parse('https://flutter.dev'),
          method: LoadRequestMethod.post,
        ));

        expect(
          (controller.params as WebWebViewControllerCreationParams).iFrame.src,
          'data:text/html;charset=iso-8859-1,Espa%F1a',
        );
      });

      test('escapes "#" correctly', () async {
        final MockHttpRequestFactory mockHttpRequestFactory =
            MockHttpRequestFactory();
        final WebWebViewController controller =
            WebWebViewController(WebWebViewControllerCreationParams(
          httpRequestFactory: mockHttpRequestFactory,
        ));

        final MockResponse mockHttpRequest = MockResponse();
        when(mockHttpRequest.headers['content-type']).thenReturn('text/html');

        when(mockHttpRequest.body).thenReturn('#');
        when(mockHttpRequestFactory.request(
          any,
          method: anyNamed('method'),
          requestHeaders: anyNamed('requestHeaders'),
          sendData: anyNamed('sendData'),
        )).thenAnswer((_) => Future<http.Response>.value(mockHttpRequest));

        await controller.loadRequest(LoadRequestParams(
          uri: Uri.parse('https://flutter.dev'),
          method: LoadRequestMethod.post,
          body: Uint8List.fromList('test body'.codeUnits),
          headers: const <String, String>{'Foo': 'Bar'},
        ));

        expect(
          (controller.params as WebWebViewControllerCreationParams).iFrame.src,
          contains('%23'),
        );
      });
    });
  });
}

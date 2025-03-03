// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit.g.dart';
import 'package:webview_flutter_wkwebview/src/webkit_proxy.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'webkit_webview_cookie_manager_test.mocks.dart';

@GenerateMocks(<Type>[WKWebsiteDataStore, WKHTTPCookieStore])
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('WebKitWebViewCookieManager', () {
    test('clearCookies', () {
      final MockWKWebsiteDataStore mockWKWebsiteDataStore =
          MockWKWebsiteDataStore();

      final WebKitWebViewCookieManager manager = WebKitWebViewCookieManager(
        WebKitWebViewCookieManagerCreationParams(
          webKitProxy: WebKitProxy(
            defaultDataStoreWKWebsiteDataStore: () => mockWKWebsiteDataStore,
          ),
        ),
      );

      when(
        mockWKWebsiteDataStore.removeDataOfTypes(
          <WebsiteDataType>[WebsiteDataType.cookies],
          0.0,
        ),
      ).thenAnswer((_) => Future<bool>.value(true));
      expect(manager.clearCookies(), completion(true));

      when(
        mockWKWebsiteDataStore.removeDataOfTypes(
          <WebsiteDataType>[WebsiteDataType.cookies],
          0.0,
        ),
      ).thenAnswer((_) => Future<bool>.value(false));
      expect(manager.clearCookies(), completion(false));
    });

    test('setCookie', () async {
      final MockWKWebsiteDataStore mockWKWebsiteDataStore =
          MockWKWebsiteDataStore();

      final MockWKHTTPCookieStore mockCookieStore = MockWKHTTPCookieStore();
      when(mockWKWebsiteDataStore.httpCookieStore).thenReturn(mockCookieStore);

      Map<HttpCookiePropertyKey, Object?>? cookieProperties;
      final HTTPCookie cookie = HTTPCookie.pigeon_detached(
        pigeon_instanceManager: TestInstanceManager(),
      );
      final WebKitWebViewCookieManager manager = WebKitWebViewCookieManager(
        WebKitWebViewCookieManagerCreationParams(
          webKitProxy: WebKitProxy(
            defaultDataStoreWKWebsiteDataStore: () => mockWKWebsiteDataStore,
            newHTTPCookie: ({
              required Map<HttpCookiePropertyKey, Object> properties,
            }) {
              cookieProperties = properties;
              return cookie;
            },
          ),
        ),
      );

      await manager.setCookie(
        const WebViewCookie(name: 'a', value: 'b', domain: 'c', path: 'd'),
      );

      verify(mockCookieStore.setCookie(cookie));
      expect(
        cookieProperties,
        <HttpCookiePropertyKey, Object>{
          HttpCookiePropertyKey.name: 'a',
          HttpCookiePropertyKey.value: 'b',
          HttpCookiePropertyKey.domain: 'c',
          HttpCookiePropertyKey.path: 'd',
        },
      );
    });

    test('setCookie throws argument error with invalid path', () async {
      final MockWKWebsiteDataStore mockWKWebsiteDataStore =
          MockWKWebsiteDataStore();

      final MockWKHTTPCookieStore mockCookieStore = MockWKHTTPCookieStore();
      when(mockWKWebsiteDataStore.httpCookieStore).thenReturn(mockCookieStore);

      final WebKitWebViewCookieManager manager = WebKitWebViewCookieManager(
        WebKitWebViewCookieManagerCreationParams(
          webKitProxy: WebKitProxy(
            defaultDataStoreWKWebsiteDataStore: () => mockWKWebsiteDataStore,
          ),
        ),
      );

      expect(
        () => manager.setCookie(
          WebViewCookie(
            name: 'a',
            value: 'b',
            domain: 'c',
            path: String.fromCharCode(0x1F),
          ),
        ),
        throwsArgumentError,
      );
    });
  });
}

// Test InstanceManager that sets `onWeakReferenceRemoved` as a noop.
class TestInstanceManager extends PigeonInstanceManager {
  TestInstanceManager() : super(onWeakReferenceRemoved: (_) {});
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit.g.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'webkit_webview_cookie_manager_test.mocks.dart';

@GenerateMocks(<Type>[WKWebsiteDataStore, WKHTTPCookieStore])
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PigeonOverrides.pigeon_reset();
  });

  group('WebKitWebViewCookieManager', () {
    test('clearCookies', () {
      final mockWKWebsiteDataStore = MockWKWebsiteDataStore();

      PigeonOverrides.wKWebsiteDataStore_defaultDataStore =
          mockWKWebsiteDataStore;
      final manager = WebKitWebViewCookieManager(
        WebKitWebViewCookieManagerCreationParams(),
      );

      when(
        mockWKWebsiteDataStore.removeDataOfTypes(<WebsiteDataType>[
          WebsiteDataType.cookies,
        ], 0.0),
      ).thenAnswer((_) => Future<bool>.value(true));
      expect(manager.clearCookies(), completion(true));

      when(
        mockWKWebsiteDataStore.removeDataOfTypes(<WebsiteDataType>[
          WebsiteDataType.cookies,
        ], 0.0),
      ).thenAnswer((_) => Future<bool>.value(false));
      expect(manager.clearCookies(), completion(false));
    });

    test('setCookie', () async {
      final mockWKWebsiteDataStore = MockWKWebsiteDataStore();

      final mockCookieStore = MockWKHTTPCookieStore();
      when(mockWKWebsiteDataStore.httpCookieStore).thenReturn(mockCookieStore);

      Map<HttpCookiePropertyKey, Object?>? cookieProperties;
      final cookie = HTTPCookie.pigeon_detached();

      PigeonOverrides.wKWebsiteDataStore_defaultDataStore =
          mockWKWebsiteDataStore;
      PigeonOverrides.hTTPCookie_new =
          ({
            required Map<HttpCookiePropertyKey, Object> properties,
            dynamic observeValue,
          }) {
            cookieProperties = properties;
            return cookie;
          };
      final manager = WebKitWebViewCookieManager(
        WebKitWebViewCookieManagerCreationParams(),
      );

      await manager.setCookie(
        const WebViewCookie(name: 'a', value: 'b', domain: 'c', path: 'd'),
      );

      verify(mockCookieStore.setCookie(cookie));
      expect(cookieProperties, <HttpCookiePropertyKey, Object>{
        HttpCookiePropertyKey.name: 'a',
        HttpCookiePropertyKey.value: 'b',
        HttpCookiePropertyKey.domain: 'c',
        HttpCookiePropertyKey.path: 'd',
      });
    });

    test('setCookie throws argument error with invalid path', () async {
      final mockWKWebsiteDataStore = MockWKWebsiteDataStore();

      final mockCookieStore = MockWKHTTPCookieStore();
      when(mockWKWebsiteDataStore.httpCookieStore).thenReturn(mockCookieStore);

      PigeonOverrides.wKWebsiteDataStore_defaultDataStore =
          mockWKWebsiteDataStore;
      final manager = WebKitWebViewCookieManager(
        WebKitWebViewCookieManagerCreationParams(),
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

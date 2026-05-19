// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/src/webview_flutter_platform_interface_legacy.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit.g.dart';
import 'package:webview_flutter_wkwebview/src/legacy/wkwebview_cookie_manager.dart';

import 'web_kit_cookie_manager_test.mocks.dart';

@GenerateMocks(<Type>[WKHTTPCookieStore, WKWebsiteDataStore])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PigeonOverrides.pigeon_reset();
  });

  group('WebKitWebViewWidget', () {
    late MockWKWebsiteDataStore mockWebsiteDataStore;
    late MockWKHTTPCookieStore mockWKHttpCookieStore;

    late WKWebViewCookieManager cookieManager;
    late HTTPCookie cookie;
    late Map<HttpCookiePropertyKey, Object?> cookieProperties;

    setUp(() {
      mockWebsiteDataStore = MockWKWebsiteDataStore();
      mockWKHttpCookieStore = MockWKHTTPCookieStore();
      when(
        mockWebsiteDataStore.httpCookieStore,
      ).thenReturn(mockWKHttpCookieStore);

      PigeonOverrides.hTTPCookie_new =
          ({
            required Map<HttpCookiePropertyKey, Object> properties,
            void Function(
              NSObject instance,
              String? keyPath,
              NSObject? object,
              Map<KeyValueChangeKey, Object?>? change,
            )?
            observeValue,
          }) {
            cookieProperties = properties;
            return cookie = HTTPCookie.pigeon_detached();
          };
      cookieManager = WKWebViewCookieManager(
        websiteDataStore: mockWebsiteDataStore,
      );
    });

    test('clearCookies', () async {
      when(
        mockWebsiteDataStore.removeDataOfTypes(<WebsiteDataType>[
          WebsiteDataType.cookies,
        ], any),
      ).thenAnswer((_) => Future<bool>.value(true));
      expect(cookieManager.clearCookies(), completion(true));

      when(
        mockWebsiteDataStore.removeDataOfTypes(<WebsiteDataType>[
          WebsiteDataType.cookies,
        ], any),
      ).thenAnswer((_) => Future<bool>.value(false));
      expect(cookieManager.clearCookies(), completion(false));
    });

    test('setCookie', () async {
      await cookieManager.setCookie(
        const WebViewCookie(name: 'a', value: 'b', domain: 'c', path: 'd'),
      );

      verify(mockWKHttpCookieStore.setCookie(cookie));
      expect(cookieProperties, <HttpCookiePropertyKey, Object>{
        HttpCookiePropertyKey.name: 'a',
        HttpCookiePropertyKey.value: 'b',
        HttpCookiePropertyKey.domain: 'c',
        HttpCookiePropertyKey.path: 'd',
      });
    });

    test('setCookie throws argument error with invalid path', () async {
      expect(
        () => cookieManager.setCookie(
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

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'webview_cookie_manager_test.mocks.dart';

@GenerateMocks(<Type>[PlatformWebViewCookieManager])
void main() {
  group('WebViewCookieManager', () {
    test('clearCookies', () async {
      final mockPlatformWebViewCookieManager =
          MockPlatformWebViewCookieManager();
      when(
        mockPlatformWebViewCookieManager.clearCookies(),
      ).thenAnswer((_) => Future<bool>.value(false));

      final cookieManager = WebViewCookieManager.fromPlatform(
        mockPlatformWebViewCookieManager,
      );

      await expectLater(cookieManager.clearCookies(), completion(false));
    });

    test('setCookie', () async {
      final mockPlatformWebViewCookieManager =
          MockPlatformWebViewCookieManager();

      final cookieManager = WebViewCookieManager.fromPlatform(
        mockPlatformWebViewCookieManager,
      );

      const cookie = WebViewCookie(
        name: 'name',
        value: 'value',
        domain: 'domain',
      );

      await cookieManager.setCookie(cookie);

      final capturedCookie =
          verify(
                mockPlatformWebViewCookieManager.setCookie(captureAny),
              ).captured.single
              as WebViewCookie;
      expect(capturedCookie, cookie);
    });
  });
}

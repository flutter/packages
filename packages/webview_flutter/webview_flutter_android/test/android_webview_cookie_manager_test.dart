// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_android/src/android_webkit.g.dart'
    as android_webview;
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'android_webview_cookie_manager_test.mocks.dart';

@GenerateMocks(<Type>[android_webview.CookieManager, AndroidWebViewController])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('clearCookies should call android_webview.clearCookies', () async {
    final android_webview.CookieManager mockCookieManager = MockCookieManager();

    when(
      mockCookieManager.removeAllCookies(),
    ).thenAnswer((_) => Future<bool>.value(true));

    final params =
        AndroidWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
          const PlatformWebViewCookieManagerCreationParams(),
        );

    final bool hasClearedCookies = await AndroidWebViewCookieManager(
      params,
      cookieManager: mockCookieManager,
    ).clearCookies();

    expect(hasClearedCookies, true);
    verify(mockCookieManager.removeAllCookies());
  });

  test('setCookie should throw ArgumentError for cookie with invalid path', () {
    final params =
        AndroidWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
          const PlatformWebViewCookieManagerCreationParams(),
        );

    final androidCookieManager = AndroidWebViewCookieManager(
      params,
      cookieManager: MockCookieManager(),
    );

    expect(
      () => androidCookieManager.setCookie(
        const WebViewCookie(
          name: 'foo',
          value: 'bar',
          domain: 'flutter.dev',
          path: 'invalid;path',
        ),
      ),
      throwsA(const TypeMatcher<ArgumentError>()),
    );
  });

  test(
    'setCookie should call android_webview.setCookie with properly formatted cookie value',
    () {
      final android_webview.CookieManager mockCookieManager =
          MockCookieManager();
      final params =
          AndroidWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
            const PlatformWebViewCookieManagerCreationParams(),
          );

      AndroidWebViewCookieManager(
        params,
        cookieManager: mockCookieManager,
      ).setCookie(
        const WebViewCookie(name: 'foo&', value: 'bar@', domain: 'flutter.dev'),
      );

      verify(
        mockCookieManager.setCookie('flutter.dev', 'foo%26=bar%40; path=/'),
      );
    },
  );

  test('setAcceptThirdPartyCookies', () async {
    final mockController = MockAndroidWebViewController();

    final webView = android_webview.WebView.pigeon_detached();

    final int webViewIdentifier = android_webview.PigeonInstanceManager.instance
        .addDartCreatedInstance(webView);

    when(mockController.webViewIdentifier).thenReturn(webViewIdentifier);

    final params =
        AndroidWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
          const PlatformWebViewCookieManagerCreationParams(),
        );

    final mockCookieManager = MockCookieManager();

    await AndroidWebViewCookieManager(
      params,
      cookieManager: mockCookieManager,
    ).setAcceptThirdPartyCookies(mockController, false);

    verify(mockCookieManager.setAcceptThirdPartyCookies(webView, false));
  });

  test('getCookies should return list of WebViewCookie for a domain', () async {
    final mockCookieManager = MockCookieManager();

    // Mock the return value of getCookies
    when(
      mockCookieManager.getCookies('https://flutter.dev'),
    ).thenAnswer((_) => Future<String>.value('foo=bar; hello=world'));

    final params =
        AndroidWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
          const PlatformWebViewCookieManagerCreationParams(),
        );

    final cookieManager = AndroidWebViewCookieManager(
      params,
      cookieManager: mockCookieManager,
    );

    final List<WebViewCookie> cookies = await cookieManager.getCookies(
      Uri.parse('https://flutter.dev'),
    );

    expect(cookies.length, 2);

    expect(cookies[0].name, 'foo');
    expect(cookies[0].value, 'bar');
    expect(cookies[0].domain, 'https://flutter.dev');

    expect(cookies[1].name, 'hello');
    expect(cookies[1].value, 'world');
    expect(cookies[1].domain, 'https://flutter.dev');

    verify(mockCookieManager.getCookies('https://flutter.dev')).called(1);
  });

  test('getCookies should return empty list if no cookies exist', () async {
    final mockCookieManager = MockCookieManager();

    when(
      mockCookieManager.getCookies('https://flutter.dev'),
    ).thenAnswer((_) => Future<String>.value(''));

    final params =
        AndroidWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
          const PlatformWebViewCookieManagerCreationParams(),
        );

    final cookieManager = AndroidWebViewCookieManager(
      params,
      cookieManager: mockCookieManager,
    );

    final List<WebViewCookie> cookies = await cookieManager.getCookies(
      Uri.parse('https://flutter.dev'),
    );

    expect(cookies, isEmpty);
    verify(mockCookieManager.getCookies('https://flutter.dev')).called(1);
  });

  test('getCookies should throw UnsupportedError if domain is null', () async {
    final mockCookieManager = MockCookieManager();

    final params =
        AndroidWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
          const PlatformWebViewCookieManagerCreationParams(),
        );

    final cookieManager = AndroidWebViewCookieManager(
      params,
      cookieManager: mockCookieManager,
    );

    expect(
      () => cookieManager.getCookies(null),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('getCookies should handle single cookie correctly', () async {
    final mockCookieManager = MockCookieManager();

    when(
      mockCookieManager.getCookies('https://flutter.dev'),
    ).thenAnswer((_) => Future<String>.value('sessionId=abc123'));

    final params =
        AndroidWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
          const PlatformWebViewCookieManagerCreationParams(),
        );

    final cookieManager = AndroidWebViewCookieManager(
      params,
      cookieManager: mockCookieManager,
    );

    final List<WebViewCookie> cookies = await cookieManager.getCookies(
      Uri.parse('https://flutter.dev'),
    );

    expect(cookies.length, 1);
    expect(cookies[0].name, 'sessionId');
    expect(cookies[0].value, 'abc123');
    expect(cookies[0].domain, 'https://flutter.dev');

    verify(mockCookieManager.getCookies('https://flutter.dev')).called(1);
  });
}

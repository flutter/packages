// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'webview_platform_test.mocks.dart';

void main() {
  setUp(() {
    WebViewPlatform.instance = MockWebViewPlatformWithMixin();
  });

  test('Cannot be implemented with `implements`', () {
    when(
      (WebViewPlatform.instance! as MockWebViewPlatform)
          .createPlatformCookieManager(any),
    ).thenReturn(ImplementsPlatformWebViewCookieManager());

    expect(() {
      PlatformWebViewCookieManager(
        const PlatformWebViewCookieManagerCreationParams(),
      );
      // In versions of `package:plugin_platform_interface` prior to fixing
      // https://github.com/flutter/flutter/issues/109339, an attempt to
      // implement a platform interface using `implements` would sometimes throw
      // a `NoSuchMethodError` and other times throw an `AssertionError`.  After
      // the issue is fixed, an `AssertionError` will always be thrown.  For the
      // purpose of this test, we don't really care what exception is thrown, so
      // just allow any exception.
    }, throwsA(anything));
  });

  test('Can be extended', () {
    const params = PlatformWebViewCookieManagerCreationParams();
    when(
      (WebViewPlatform.instance! as MockWebViewPlatform)
          .createPlatformCookieManager(any),
    ).thenReturn(ExtendsPlatformWebViewCookieManager(params));

    expect(PlatformWebViewCookieManager(params), isNotNull);
  });

  test('Can be mocked with `implements`', () {
    when(
      (WebViewPlatform.instance! as MockWebViewPlatform)
          .createPlatformCookieManager(any),
    ).thenReturn(MockWebViewCookieManagerDelegate());

    expect(
      PlatformWebViewCookieManager(
        const PlatformWebViewCookieManagerCreationParams(),
      ),
      isNotNull,
    );
  });

  test(
    'Default implementation of clearCookies should throw unimplemented error',
    () {
      final PlatformWebViewCookieManager cookieManager =
          ExtendsPlatformWebViewCookieManager(
            const PlatformWebViewCookieManagerCreationParams(),
          );

      expect(() => cookieManager.clearCookies(), throwsUnimplementedError);
    },
  );

  test(
    'Default implementation of setCookie should throw unimplemented error',
    () {
      final PlatformWebViewCookieManager cookieManager =
          ExtendsPlatformWebViewCookieManager(
            const PlatformWebViewCookieManagerCreationParams(),
          );

      expect(
        () => cookieManager.setCookie(
          const WebViewCookie(name: 'foo', value: 'bar', domain: 'flutter.dev'),
        ),
        throwsUnimplementedError,
      );
    },
  );

  test(
    'Default implementation of getCookies should throw unimplemented error',
    () {
      final PlatformWebViewCookieManager cookieManager =
          ExtendsPlatformWebViewCookieManager(
            const PlatformWebViewCookieManagerCreationParams(),
          );

      expect(
        () => cookieManager.getCookies(Uri.parse('https://flutter.dev')),
        throwsUnimplementedError,
      );
    },
  );
}

class MockWebViewPlatformWithMixin extends MockWebViewPlatform
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin {}

class ImplementsPlatformWebViewCookieManager
    implements PlatformWebViewCookieManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWebViewCookieManagerDelegate extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements PlatformWebViewCookieManager {}

class ExtendsPlatformWebViewCookieManager extends PlatformWebViewCookieManager {
  ExtendsPlatformWebViewCookieManager(super.params) : super.implementation();
}

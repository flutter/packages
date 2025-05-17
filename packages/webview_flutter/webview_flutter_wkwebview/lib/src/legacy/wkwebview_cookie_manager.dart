// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
// ignore: implementation_imports
import 'package:webview_flutter_platform_interface/src/webview_flutter_platform_interface_legacy.dart';

import '../common/web_kit.g.dart';
import '../webkit_proxy.dart';

/// Handles all cookie operations for the WebView platform.
class WKWebViewCookieManager extends WebViewCookieManagerPlatform {
  /// Constructs a [WKWebViewCookieManager].
  WKWebViewCookieManager({
    WKWebsiteDataStore? websiteDataStore,
    @visibleForTesting WebKitProxy webKitProxy = const WebKitProxy(),
  })  : _webKitProxy = webKitProxy,
        websiteDataStore = websiteDataStore ??
            webKitProxy.defaultDataStoreWKWebsiteDataStore();

  /// Manages stored data for [WKWebView]s.
  final WKWebsiteDataStore websiteDataStore;

  final WebKitProxy _webKitProxy;

  @override
  Future<bool> clearCookies() async {
    return websiteDataStore.removeDataOfTypes(
      <WebsiteDataType>[WebsiteDataType.cookies],
      0,
    );
  }

  @override
  Future<void> setCookie(WebViewCookie cookie) {
    if (!_isValidPath(cookie.path)) {
      throw ArgumentError(
          'The path property for the provided cookie was not given a legal value.');
    }

    return websiteDataStore.httpCookieStore.setCookie(
      _webKitProxy.newHTTPCookie(
        properties: <HttpCookiePropertyKey, Object>{
          HttpCookiePropertyKey.name: cookie.name,
          HttpCookiePropertyKey.value: cookie.value,
          HttpCookiePropertyKey.domain: cookie.domain,
          HttpCookiePropertyKey.path: cookie.path,
        },
      ),
    );
  }

  bool _isValidPath(String path) {
    // Permitted ranges based on RFC6265bis: https://datatracker.ietf.org/doc/html/draft-ietf-httpbis-rfc6265bis-02#section-4.1.1
    return !path.codeUnits.any(
      (int char) {
        return (char < 0x20 || char > 0x3A) && (char < 0x3C || char > 0x7E);
      },
    );
  }
}

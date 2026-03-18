// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: implementation_imports
import 'package:webview_flutter_platform_interface/src/webview_flutter_platform_interface_legacy.dart';

import '../common/web_kit.g.dart';

/// Handles all cookie operations for the WebView platform.
class WKWebViewCookieManager extends WebViewCookieManagerPlatform {
  /// Constructs a [WKWebViewCookieManager].
  WKWebViewCookieManager({WKWebsiteDataStore? websiteDataStore})
    : websiteDataStore =
          websiteDataStore ?? WKWebsiteDataStore.defaultDataStore;

  /// Manages stored data for [WKWebView]s.
  final WKWebsiteDataStore websiteDataStore;

  @override
  Future<bool> clearCookies() async {
    return websiteDataStore.removeDataOfTypes(<WebsiteDataType>[
      WebsiteDataType.cookies,
    ], 0);
  }

  @override
  Future<void> setCookie(WebViewCookie cookie) {
    if (!_isValidPath(cookie.path)) {
      throw ArgumentError(
        'The path property for the provided cookie was not given a legal value.',
      );
    }

    return websiteDataStore.httpCookieStore.setCookie(
      HTTPCookie(
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
    return !path.codeUnits.any((int char) {
      return (char < 0x20 || char > 0x3A) && (char < 0x3C || char > 0x7E);
    });
  }
}

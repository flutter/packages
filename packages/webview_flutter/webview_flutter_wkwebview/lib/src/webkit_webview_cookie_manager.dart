// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'common/web_kit.g.dart';

/// Object specifying creation parameters for a [WebKitWebViewCookieManager].
class WebKitWebViewCookieManagerCreationParams
    extends PlatformWebViewCookieManagerCreationParams {
  /// Constructs a [WebKitWebViewCookieManagerCreationParams].
  WebKitWebViewCookieManagerCreationParams();

  /// Constructs a [WebKitWebViewCookieManagerCreationParams] using a
  /// [PlatformWebViewCookieManagerCreationParams].
  WebKitWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewCookieManagerCreationParams params,
  );

  /// Manages stored data for [WKWebView]s.
  late final WKWebsiteDataStore _websiteDataStore =
      WKWebsiteDataStore.defaultDataStore;
}

/// An implementation of [PlatformWebViewCookieManager] with the WebKit api.
class WebKitWebViewCookieManager extends PlatformWebViewCookieManager {
  /// Constructs a [WebKitWebViewCookieManager].
  WebKitWebViewCookieManager(PlatformWebViewCookieManagerCreationParams params)
    : super.implementation(
        params is WebKitWebViewCookieManagerCreationParams
            ? params
            : WebKitWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
                params,
              ),
      );

  WebKitWebViewCookieManagerCreationParams get _webkitParams =>
      params as WebKitWebViewCookieManagerCreationParams;

  @override
  Future<bool> clearCookies() {
    return _webkitParams._websiteDataStore.removeDataOfTypes(<WebsiteDataType>[
      WebsiteDataType.cookies,
    ], 0.0);
  }

  @override
  Future<void> setCookie(WebViewCookie cookie) {
    if (!_isValidPath(cookie.path)) {
      throw ArgumentError(
        'The path property for the provided cookie was not given a legal value.',
      );
    }

    return _webkitParams._websiteDataStore.httpCookieStore.setCookie(
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

  @override
  Future<List<WebViewCookie>> getCookies(String? domain) async {
    final List<HTTPCookie> httpCookies = await _webkitParams
        ._websiteDataStore
        .httpCookieStore
        .getCookies(domain);

    final Iterable<Future<WebViewCookie?>> webviewCookies = httpCookies.map((
      cookie,
    ) async {
      final Map<HttpCookiePropertyKey, Object>? props = await cookie
          .getProperties();

      if (props == null) {
        return null;
      }

      return WebViewCookie(
        name: props[HttpCookiePropertyKey.name].toString(),
        value: props[HttpCookiePropertyKey.value].toString(),
        domain: props[HttpCookiePropertyKey.domain].toString(),
        path: props[HttpCookiePropertyKey.path].toString(),
      );
    });

    return (await Future.wait(webviewCookies)).nonNulls.toList();
  }
}

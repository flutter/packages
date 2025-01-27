// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;
// ignore: implementation_imports
import 'package:webview_flutter_platform_interface/src/webview_flutter_platform_interface_legacy.dart';

import 'http_request_factory.dart';

/// Builds an iframe based WebView.
///
/// This is used as the default implementation for [WebView.platform] on web.
class WebWebViewPlatform implements WebViewPlatform {
  @override
  Widget build({
    required BuildContext context,
    required CreationParams creationParams,
    required WebViewPlatformCallbacksHandler webViewPlatformCallbacksHandler,
    required JavascriptChannelRegistry? javascriptChannelRegistry,
    WebViewPlatformCreatedCallback? onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  }) {
    return HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (Object iFrame) {
        iFrame as web.HTMLIFrameElement;
        iFrame.style.border = 'none';
        final String? initialUrl = creationParams.initialUrl;
        if (initialUrl != null) {
          iFrame.src = initialUrl;
        }
        if (onWebViewPlatformCreated != null) {
          onWebViewPlatformCreated(
            WebWebViewPlatformController(iFrame),
          );
        }
      },
    );
  }

  @override
  Future<bool> clearCookies() async => false;

  /// Gets called when the plugin is registered.
  static void registerWith(Registrar registrar) {}
}

/// Implementation of [WebViewPlatformController] for web.
class WebWebViewPlatformController implements WebViewPlatformController {
  /// Constructs a [WebWebViewPlatformController].
  WebWebViewPlatformController(this._element);

  final web.HTMLIFrameElement _element;
  HttpRequestFactory _httpRequestFactory = const HttpRequestFactory();

  /// Setter for setting the HttpRequestFactory, for testing purposes.
  @visibleForTesting
  // ignore: avoid_setters_without_getters
  set httpRequestFactory(HttpRequestFactory factory) {
    _httpRequestFactory = factory;
  }

  @override
  Future<void> addJavascriptChannels(Set<String> javascriptChannelNames) {
    throw UnimplementedError();
  }

  @override
  Future<bool> canGoBack() {
    throw UnimplementedError();
  }

  @override
  Future<bool> canGoForward() {
    throw UnimplementedError();
  }

  @override
  Future<void> clearCache() {
    throw UnimplementedError();
  }

  @override
  Future<String?> currentUrl() {
    throw UnimplementedError();
  }

  @override
  Future<String> evaluateJavascript(String javascript) {
    throw UnimplementedError();
  }

  @override
  Future<int> getScrollX() {
    throw UnimplementedError();
  }

  @override
  Future<int> getScrollY() {
    throw UnimplementedError();
  }

  @override
  Future<String?> getTitle() {
    throw UnimplementedError();
  }

  @override
  Future<void> goBack() {
    throw UnimplementedError();
  }

  @override
  Future<void> goForward() {
    throw UnimplementedError();
  }

  @override
  Future<void> loadUrl(String url, Map<String, String>? headers) async {
    _element.src = url;
  }

  @override
  Future<void> reload() {
    throw UnimplementedError();
  }

  @override
  Future<void> removeJavascriptChannels(Set<String> javascriptChannelNames) {
    throw UnimplementedError();
  }

  @override
  Future<void> runJavascript(String javascript) {
    throw UnimplementedError();
  }

  @override
  Future<String> runJavascriptReturningResult(String javascript) {
    throw UnimplementedError();
  }

  @override
  Future<void> scrollBy(int x, int y) {
    throw UnimplementedError();
  }

  @override
  Future<void> scrollTo(int x, int y) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateSettings(WebSettings setting) {
    throw UnimplementedError();
  }

  @override
  Future<void> loadFile(String absoluteFilePath) {
    throw UnimplementedError();
  }

  @override
  Future<void> loadHtmlString(
    String html, {
    String? baseUrl,
  }) async {
    _element.src = Uri.dataFromString(
      html,
      mimeType: 'text/html',
      encoding: utf8,
    ).toString();
  }

  @override
  Future<void> loadRequest(WebViewRequest request) async {
    if (!request.uri.hasScheme) {
      throw ArgumentError('WebViewRequest#uri is required to have a scheme.');
    }
    final web.Response response = await _httpRequestFactory.request(
        request.uri.toString(),
        method: request.method.serialize(),
        requestHeaders: request.headers,
        sendData: request.body) as web.Response;

    final String contentType =
        response.headers.get('content-type') ?? 'text/html';

    _element.src = Uri.dataFromString(
      (await response.text().toDart).toDart,
      mimeType: contentType,
      encoding: utf8,
    ).toString();
  }

  @override
  Future<void> loadFlutterAsset(String key) {
    throw UnimplementedError();
  }
}

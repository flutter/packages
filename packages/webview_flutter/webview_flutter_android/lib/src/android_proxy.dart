// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'android_webkit.g.dart';

/// Handles constructing objects and calling static methods for the Android
/// WebView native library.
///
/// This class provides dependency injection for the implementations of the
/// platform interface classes. Improving the ease of unit testing and/or
/// overriding the underlying Android WebView classes.
///
/// By default each function calls the default constructor of the WebView class
/// it intends to return.
class AndroidWebViewProxy {
  /// Constructs an [AndroidWebViewProxy].
  const AndroidWebViewProxy({
    this.newWebView = WebView.new,
    this.newJavaScriptChannel = JavaScriptChannel.new,
    this.newWebViewClient = WebViewClient.new,
    this.newDownloadListener = DownloadListener.new,
    this.newWebChromeClient = WebChromeClient.new,
    this.setWebContentsDebuggingEnabledWebView =
        WebView.setWebContentsDebuggingEnabled,
    this.instanceCookieManager = _instanceCookieManager,
    this.instanceFlutterAssetManager = _instanceFlutterAssetManager,
    this.instanceWebStorage = _instanceWebStorage,
  });

  /// Constructs [WebView].
  final WebView Function({
    void Function(
      WebView,
      int left,
      int top,
      int oldLeft,
      int oldTop,
    )? onScrollChanged,
  }) newWebView;

  /// Constructs [JavaScriptChannel].
  final JavaScriptChannel Function({
    required String channelName,
    required void Function(JavaScriptChannel, String) postMessage,
  }) newJavaScriptChannel;

  /// Constructs [WebViewClient].
  final WebViewClient Function({
    void Function(WebViewClient, WebView, String)? onPageStarted,
    void Function(WebViewClient, WebView, String)? onPageFinished,
    void Function(
      WebViewClient,
      WebView,
      WebResourceRequest,
      WebResourceResponse,
    )? onReceivedHttpError,
    void Function(
      WebViewClient,
      WebView,
      WebResourceRequest,
      WebResourceError,
    )? onReceivedRequestError,
    void Function(
      WebViewClient,
      WebView,
      WebResourceRequest,
      WebResourceErrorCompat,
    )? onReceivedRequestErrorCompat,
    void Function(WebViewClient, WebView, int, String, String)? onReceivedError,
    void Function(WebViewClient, WebView, WebResourceRequest)? requestLoading,
    void Function(WebViewClient, WebView, String)? urlLoading,
    void Function(WebViewClient, WebView, String, bool)? doUpdateVisitedHistory,
    void Function(WebViewClient, WebView, HttpAuthHandler, String, String)?
        onReceivedHttpAuthRequest,
  }) newWebViewClient;

  /// Constructs [DownloadListener].
  final DownloadListener Function({
    required void Function(
            DownloadListener, String, String, String, String, int)
        onDownloadStart,
  }) newDownloadListener;

  /// Constructs [WebChromeClient].
  final WebChromeClient Function({
    void Function(WebChromeClient, WebView, int)? onProgressChanged,
    Future<List<String>> Function(
      WebChromeClient,
      WebView,
      FileChooserParams,
    )? onShowFileChooser,
    void Function(WebChromeClient, PermissionRequest)? onPermissionRequest,
    void Function(WebChromeClient, View, CustomViewCallback)? onShowCustomView,
    void Function(WebChromeClient)? onHideCustomView,
    void Function(
      WebChromeClient,
      String,
      GeolocationPermissionsCallback,
    )? onGeolocationPermissionsShowPrompt,
    void Function(WebChromeClient)? onGeolocationPermissionsHidePrompt,
    void Function(WebChromeClient, ConsoleMessage)? onConsoleMessage,
    Future<void> Function(WebChromeClient, WebView, String, String)? onJsAlert,
    Future<bool> Function(
      WebChromeClient,
      WebView,
      String,
      String,
    )? onJsConfirm,
    Future<String?> Function(
      WebChromeClient,
      WebView,
      String,
      String,
      String,
    )? onJsPrompt,
  }) newWebChromeClient;

  /// Calls to [WebView.setWebContentsDebuggingEnabled].
  final Future<void> Function(bool) setWebContentsDebuggingEnabledWebView;

  /// Calls to [CookieManager.instance].
  final CookieManager Function() instanceCookieManager;

  /// Calls to [FlutterAssetManager.instance].
  final FlutterAssetManager Function() instanceFlutterAssetManager;

  /// Calls to [WebStorage.instance].
  final WebStorage Function() instanceWebStorage;

  static CookieManager _instanceCookieManager() => CookieManager.instance;

  static FlutterAssetManager _instanceFlutterAssetManager() =>
      FlutterAssetManager.instance;

  static WebStorage _instanceWebStorage() => WebStorage.instance;
}

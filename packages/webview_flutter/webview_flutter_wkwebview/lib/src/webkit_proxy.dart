// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'common/instance_manager.dart';
import 'foundation/foundation.dart';
import 'ui_kit/ui_kit.dart';
import 'web_kit/web_kit.dart';

// This convenience method was added because Dart doesn't support constant
// function literals: https://github.com/dart-lang/language/issues/1048.
WKWebsiteDataStore _defaultWebsiteDataStore() =>
    WKWebsiteDataStore.defaultDataStore;

// This convenience method was added because Dart doesn't support constant
// function literals: https://github.com/dart-lang/language/issues/1048.
WKWebView _platformWebViewConstructor(
  WKWebViewConfiguration configuration, {
  void Function(
    String keyPath,
    NSObject object,
    Map<NSKeyValueChangeKey, Object?> change,
  )? observeValue,
  InstanceManager? instanceManager,
}) {
  return Platform.isIOS
      ? WKWebViewIOS(configuration,
          observeValue: observeValue, instanceManager: instanceManager)
      : WKWebViewMacOS(configuration,
          observeValue: observeValue, instanceManager: instanceManager);
}

/// Handles constructing objects and calling static methods for the WebKit
/// native library.
///
/// This class provides dependency injection for the implementations of the
/// platform interface classes. Improving the ease of unit testing and/or
/// overriding the underlying WebKit classes.
///
/// By default each function calls the default constructor of the WebKit class
/// it intends to return.
class WebKitProxy {
  /// Constructs a [WebKitProxy].
  const WebKitProxy({
    this.createWebView = _platformWebViewConstructor,
    this.createWebViewConfiguration = WKWebViewConfiguration.new,
    this.createScriptMessageHandler = WKScriptMessageHandler.new,
    this.defaultWebsiteDataStore = _defaultWebsiteDataStore,
    this.createNavigationDelegate = WKNavigationDelegate.new,
    this.createUIDelegate = WKUIDelegate.new,
    this.createUIScrollViewDelegate = UIScrollViewDelegate.new,
  });

  /// Constructs a [WKWebView].
  final WKWebView Function(
    WKWebViewConfiguration configuration, {
    void Function(
      String keyPath,
      NSObject object,
      Map<NSKeyValueChangeKey, Object?> change,
    )? observeValue,
    InstanceManager? instanceManager,
  }) createWebView;

  /// Constructs a [WKWebViewConfiguration].
  final WKWebViewConfiguration Function({
    InstanceManager? instanceManager,
  }) createWebViewConfiguration;

  /// Constructs a [WKScriptMessageHandler].
  final WKScriptMessageHandler Function({
    required void Function(
      WKUserContentController userContentController,
      WKScriptMessage message,
    ) didReceiveScriptMessage,
  }) createScriptMessageHandler;

  /// The default [WKWebsiteDataStore].
  final WKWebsiteDataStore Function() defaultWebsiteDataStore;

  /// Constructs a [WKNavigationDelegate].
  final WKNavigationDelegate Function({
    void Function(WKWebView webView, String? url)? didFinishNavigation,
    void Function(WKWebView webView, String? url)?
        didStartProvisionalNavigation,
    Future<WKNavigationActionPolicy> Function(
      WKWebView webView,
      WKNavigationAction navigationAction,
    )? decidePolicyForNavigationAction,
    Future<WKNavigationResponsePolicy> Function(
      WKWebView webView,
      WKNavigationResponse navigationResponse,
    )? decidePolicyForNavigationResponse,
    void Function(WKWebView webView, NSError error)? didFailNavigation,
    void Function(WKWebView webView, NSError error)?
        didFailProvisionalNavigation,
    void Function(WKWebView webView)? webViewWebContentProcessDidTerminate,
    void Function(
      WKWebView webView,
      NSUrlAuthenticationChallenge challenge,
      void Function(
        NSUrlSessionAuthChallengeDisposition disposition,
        NSUrlCredential? credential,
      ) completionHandler,
    )? didReceiveAuthenticationChallenge,
  }) createNavigationDelegate;

  /// Constructs a [WKUIDelegate].
  final WKUIDelegate Function({
    void Function(
      WKWebView webView,
      WKWebViewConfiguration configuration,
      WKNavigationAction navigationAction,
    )? onCreateWebView,
    Future<WKPermissionDecision> Function(
      WKUIDelegate instance,
      WKWebView webView,
      WKSecurityOrigin origin,
      WKFrameInfo frame,
      WKMediaCaptureType type,
    )? requestMediaCapturePermission,
    Future<void> Function(
      String message,
      WKFrameInfo frame,
    )? runJavaScriptAlertDialog,
    Future<bool> Function(
      String message,
      WKFrameInfo frame,
    )? runJavaScriptConfirmDialog,
    Future<String> Function(
      String prompt,
      String defaultText,
      WKFrameInfo frame,
    )? runJavaScriptTextInputDialog,
    InstanceManager? instanceManager,
  }) createUIDelegate;

  /// Constructs a [UIScrollViewDelegate].
  final UIScrollViewDelegate Function({
    void Function(
      UIScrollView scrollView,
      double x,
      double y,
    )? scrollViewDidScroll,
  }) createUIScrollViewDelegate;
}

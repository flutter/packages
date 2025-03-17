// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'web_kit.g.dart';

/// Platform agnostic native WebView.
///
/// iOS and macOS reference different `WebView` implementations, so this handles
/// delegating calls to the implementation of the current platform.
class PlatformWebView {
  /// Creates a [PlatformWebView].
  PlatformWebView({
    required WKWebViewConfiguration initialConfiguration,
    void Function(
      NSObject instance,
      String? keyPath,
      NSObject? object,
      Map<KeyValueChangeKey, Object?>? change,
    )? observeValue,
  }) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        nativeWebView = UIViewWKWebView(
          initialConfiguration: initialConfiguration,
          observeValue: observeValue,
        );
      case TargetPlatform.macOS:
        nativeWebView = NSViewWKWebView(
          initialConfiguration: initialConfiguration,
          observeValue: observeValue,
        );
      case _:
        throw UnimplementedError('$defaultTargetPlatform is not supported.');
    }
  }

  /// Creates a [PlatformWebView] with the native WebView instance.
  PlatformWebView.fromNativeWebView(WKWebView webView)
      : nativeWebView = webView;

  /// The underlying native WebView instance.
  late final WKWebView nativeWebView;

  /// Registers the observer object to receive KVO notifications for the key
  /// path relative to the object receiving this message.
  Future<void> addObserver(
    NSObject observer,
    String keyPath,
    List<KeyValueObservingOptions> options,
  ) {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.addObserver(observer, keyPath, options);
      case NSViewWKWebView():
        return webView.addObserver(observer, keyPath, options);
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// A Boolean value that indicates whether there is a valid back item in the
  /// back-forward list.
  Future<bool> canGoBack() {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.canGoBack();
      case NSViewWKWebView():
        return webView.canGoBack();
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// A Boolean value that indicates whether there is a valid forward item in
  /// the back-forward list.
  Future<bool> canGoForward() {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.canGoForward();
      case NSViewWKWebView():
        return webView.canGoForward();
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// The object that contains the configuration details for the web view.
  WKWebViewConfiguration get configuration {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.configuration;
      case NSViewWKWebView():
        return webView.configuration;
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// Evaluates the specified JavaScript string.
  Future<Object?> evaluateJavaScript(String javaScriptString) {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.evaluateJavaScript(javaScriptString);
      case NSViewWKWebView():
        return webView.evaluateJavaScript(javaScriptString);
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// The custom user agent string.
  Future<String?> getCustomUserAgent() {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.getCustomUserAgent();
      case NSViewWKWebView():
        return webView.getCustomUserAgent();
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// An estimate of what fraction of the current navigation has been loaded.
  Future<double> getEstimatedProgress() {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.getEstimatedProgress();
      case NSViewWKWebView():
        return webView.getEstimatedProgress();
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// The page title.
  Future<String?> getTitle() {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.getTitle();
      case NSViewWKWebView():
        return webView.getTitle();
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// The URL being requested.
  Future<String?> getUrl() {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.getUrl();
      case NSViewWKWebView():
        return webView.getUrl();
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// Navigates to the back item in the back-forward list.
  Future<void> goBack() {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.goBack();
      case NSViewWKWebView():
        return webView.goBack();
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// Navigates to the forward item in the back-forward list.
  Future<void> goForward() {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.goForward();
      case NSViewWKWebView():
        return webView.goForward();
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// Loads the web content that the specified URL request object references and
  /// navigates to that content.
  Future<void> load(URLRequest request) {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.load(request);
      case NSViewWKWebView():
        return webView.load(request);
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// Loads the web content from the specified file and navigates to it.
  Future<void> loadFileUrl(String url, String readAccessUrl) {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.loadFileUrl(url, readAccessUrl);
      case NSViewWKWebView():
        return webView.loadFileUrl(url, readAccessUrl);
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// Convenience method to load a Flutter asset.
  Future<void> loadFlutterAsset(String key) {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.loadFlutterAsset(key);
      case NSViewWKWebView():
        return webView.loadFlutterAsset(key);
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// Loads the contents of the specified HTML string and navigates to it.
  Future<void> loadHtmlString(String string, String? baseUrl) {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.loadHtmlString(string, baseUrl);
      case NSViewWKWebView():
        return webView.loadHtmlString(string, baseUrl);
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// Informs the observing object when the value at the specified key path
  /// relative to the observed object has changed.
  void Function(NSObject pigeonInstance, String? keyPath, NSObject? object,
      Map<KeyValueChangeKey, Object>? change)? get observeValue {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.observeValue;
      case NSViewWKWebView():
        return webView.observeValue;
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// Reloads the current webpage.
  Future<void> reload() {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.reload();
      case NSViewWKWebView():
        return webView.reload();
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// Stops the observer object from receiving change notifications for the
  /// property specified by the key path relative to the object receiving this
  /// message.
  Future<void> removeObserver(NSObject object, String keyPath) {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.removeObserver(object, keyPath);
      case NSViewWKWebView():
        return webView.removeObserver(object, keyPath);
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// The scroll view associated with the web view.
  UIScrollView get scrollView {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.scrollView;
      case NSViewWKWebView():
        throw UnimplementedError('scrollView is not implemented on macOS');
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// A Boolean value that indicates whether horizontal swipe gestures trigger
  /// backward and forward page navigation.
  Future<void> setAllowsBackForwardNavigationGestures(bool allow) {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.setAllowsBackForwardNavigationGestures(allow);
      case NSViewWKWebView():
        return webView.setAllowsBackForwardNavigationGestures(allow);
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// The view’s background color.
  Future<void> setBackgroundColor(int? value) {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.setBackgroundColor(value);
      case NSViewWKWebView():
        // TODO(stuartmorgan): Implement background color support.
        throw UnimplementedError('backgroundColor is not implemented on macOS');
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// The custom user agent string.
  Future<void> setCustomUserAgent(String? userAgent) {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.setCustomUserAgent(userAgent);
      case NSViewWKWebView():
        return webView.setCustomUserAgent(userAgent);
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// A Boolean value that indicates whether you can inspect the view with
  /// Safari Web Inspector.
  Future<void> setInspectable(bool inspectable) {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.setInspectable(inspectable);
      case NSViewWKWebView():
        return webView.setInspectable(inspectable);
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// The object you use to manage navigation behavior for the web view.
  Future<void> setNavigationDelegate(WKNavigationDelegate delegate) {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.setNavigationDelegate(delegate);
      case NSViewWKWebView():
        return webView.setNavigationDelegate(delegate);
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// A Boolean value that determines whether the view is opaque.
  Future<void> setOpaque(bool opaque) {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.setOpaque(opaque);
      case NSViewWKWebView():
        throw UnimplementedError('opaque is not implemented on macOS');
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }

  /// The object you use to integrate custom user interface elements, such as
  /// contextual menus or panels, into web view interactions.
  Future<void> setUIDelegate(WKUIDelegate delegate) {
    final WKWebView webView = nativeWebView;
    switch (webView) {
      case UIViewWKWebView():
        return webView.setUIDelegate(delegate);
      case NSViewWKWebView():
        return webView.setUIDelegate(delegate);
    }

    throw UnimplementedError('${webView.runtimeType} is not supported.');
  }
}

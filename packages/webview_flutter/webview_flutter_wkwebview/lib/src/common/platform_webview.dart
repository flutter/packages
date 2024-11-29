// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'web_kit2.g.dart';

class PlatformWebView {
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
        throw UnimplementedError('$defaultTargetPlatform is not supported');
    }
  }

  PlatformWebView.fromNativeWebView(WKWebView webView)
      : nativeWebView = webView;

  late final WKWebView nativeWebView;

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

  void Function(NSObject pigeon_instance, String? keyPath, NSObject? object,
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

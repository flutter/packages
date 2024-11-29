// // Copyright 2013 The Flutter Authors. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.
//
// import 'dart:io';
//
// import 'common/instance_manager.dart';
// import 'foundation/foundation.dart';
// import 'ui_kit/ui_kit.dart';
// import 'web_kit/web_kit.dart';
//
// // This convenience method was added because Dart doesn't support constant
// // function literals: https://github.com/dart-lang/language/issues/1048.
// WKWebsiteDataStore _defaultWebsiteDataStore() =>
//     WKWebsiteDataStore.defaultDataStore;
//
// // This convenience method was added because Dart doesn't support constant
// // function literals: https://github.com/dart-lang/language/issues/1048.
// WKWebView _platformWebViewConstructor(
//   WKWebViewConfiguration configuration, {
//   void Function(
//     String keyPath,
//     NSObject object,
//     Map<NSKeyValueChangeKey, Object?> change,
//   )? observeValue,
//   InstanceManager? instanceManager,
// }) {
//   return Platform.isIOS
//       ? WKWebViewIOS(configuration,
//           observeValue: observeValue, instanceManager: instanceManager)
//       : WKWebViewMacOS(configuration,
//           observeValue: observeValue, instanceManager: instanceManager);
// }
//
// /// Handles constructing objects and calling static methods for the WebKit
// /// native library.
// ///
// /// This class provides dependency injection for the implementations of the
// /// platform interface classes. Improving the ease of unit testing and/or
// /// overriding the underlying WebKit classes.
// ///
// /// By default each function calls the default constructor of the WebKit class
// /// it intends to return.
// class WebKitProxy {
//   /// Constructs a [WebKitProxy].
//   const WebKitProxy({
//     this.createWebView = _platformWebViewConstructor,
//     this.createWebViewConfiguration = WKWebViewConfiguration.new,
//     this.createScriptMessageHandler = WKScriptMessageHandler.new,
//     this.defaultWebsiteDataStore = _defaultWebsiteDataStore,
//     this.createNavigationDelegate = WKNavigationDelegate.new,
//     this.createUIDelegate = WKUIDelegate.new,
//     this.createUIScrollViewDelegate = UIScrollViewDelegate.new,
//   });
//
//   /// Constructs a [WKWebView].
//   final WKWebView Function(
//     WKWebViewConfiguration configuration, {
//     void Function(
//       String keyPath,
//       NSObject object,
//       Map<NSKeyValueChangeKey, Object?> change,
//     )? observeValue,
//     InstanceManager? instanceManager,
//   }) createWebView;
//
//   /// Constructs a [WKWebViewConfiguration].
//   final WKWebViewConfiguration Function({
//     InstanceManager? instanceManager,
//   }) createWebViewConfiguration;
//
//   /// Constructs a [WKScriptMessageHandler].
//   final WKScriptMessageHandler Function({
//     required void Function(
//       WKUserContentController userContentController,
//       WKScriptMessage message,
//     ) didReceiveScriptMessage,
//   }) createScriptMessageHandler;
//
//   /// The default [WKWebsiteDataStore].
//   final WKWebsiteDataStore Function() defaultWebsiteDataStore;
//
//   /// Constructs a [WKNavigationDelegate].
//   final WKNavigationDelegate Function({
//     void Function(WKWebView webView, String? url)? didFinishNavigation,
//     void Function(WKWebView webView, String? url)?
//         didStartProvisionalNavigation,
//     Future<WKNavigationActionPolicy> Function(
//       WKWebView webView,
//       WKNavigationAction navigationAction,
//     )? decidePolicyForNavigationAction,
//     Future<WKNavigationResponsePolicy> Function(
//       WKWebView webView,
//       WKNavigationResponse navigationResponse,
//     )? decidePolicyForNavigationResponse,
//     void Function(WKWebView webView, NSError error)? didFailNavigation,
//     void Function(WKWebView webView, NSError error)?
//         didFailProvisionalNavigation,
//     void Function(WKWebView webView)? webViewWebContentProcessDidTerminate,
//     void Function(
//       WKWebView webView,
//       NSUrlAuthenticationChallenge challenge,
//       void Function(
//         NSUrlSessionAuthChallengeDisposition disposition,
//         NSUrlCredential? credential,
//       ) completionHandler,
//     )? didReceiveAuthenticationChallenge,
//   }) createNavigationDelegate;
//
//   /// Constructs a [WKUIDelegate].
//   final WKUIDelegate Function({
//     void Function(
//       WKWebView webView,
//       WKWebViewConfiguration configuration,
//       WKNavigationAction navigationAction,
//     )? onCreateWebView,
//     Future<WKPermissionDecision> Function(
//       WKUIDelegate instance,
//       WKWebView webView,
//       WKSecurityOrigin origin,
//       WKFrameInfo frame,
//       WKMediaCaptureType type,
//     )? requestMediaCapturePermission,
//     Future<void> Function(
//       String message,
//       WKFrameInfo frame,
//     )? runJavaScriptAlertDialog,
//     Future<bool> Function(
//       String message,
//       WKFrameInfo frame,
//     )? runJavaScriptConfirmDialog,
//     Future<String> Function(
//       String prompt,
//       String defaultText,
//       WKFrameInfo frame,
//     )? runJavaScriptTextInputDialog,
//     InstanceManager? instanceManager,
//   }) createUIDelegate;
//
//   /// Constructs a [UIScrollViewDelegate].
//   final UIScrollViewDelegate Function({
//     void Function(
//       UIScrollView scrollView,
//       double x,
//       double y,
//     )? scrollViewDidScroll,
//   }) createUIScrollViewDelegate;
// }

import 'common/platform_webview.dart';
import 'common/web_kit2.g.dart';

/// Handles constructing objects and calling static methods for the Darwin
/// WebKit native library.
///
/// This class provides dependency injection for the implementations of the
/// platform interface classes. Improving the ease of unit testing and/or
/// overriding the underlying Darwin classes.
///
/// By default each function calls the default constructor of the class it
/// intends to return.
class WebKitProxy {
  /// Constructs an [WebKitProxy].
  const WebKitProxy({
    this.newURLRequest = URLRequest.new,
    this.newWKUserScript = WKUserScript.new,
    this.newHTTPCookie = HTTPCookie.new,
    this.newAuthenticationChallengeResponse =
        AuthenticationChallengeResponse.new,
    this.newWKWebViewConfiguration = WKWebViewConfiguration.new,
    this.newWKScriptMessageHandler = WKScriptMessageHandler.new,
    this.newWKNavigationDelegate = WKNavigationDelegate.new,
    this.newNSObject = NSObject.new,
    this.newPlatformWebView = PlatformWebView.new,
    this.newWKUIDelegate = WKUIDelegate.new,
    this.newUIScrollViewDelegate = UIScrollViewDelegate.new,
    this.withUserURLCredential = URLCredential.withUser,
    this.defaultDataStoreWKWebsiteDataStore =
        _defaultDataStoreWKWebsiteDataStore,
  });

  /// Constructs [URLRequest].
  final URLRequest Function({required String url}) newURLRequest;

  /// Constructs [WKUserScript].
  final WKUserScript Function({
    required String source,
    required UserScriptInjectionTime injectionTime,
    required bool isMainFrameOnly,
  }) newWKUserScript;

  /// Constructs [HTTPCookie].
  final HTTPCookie Function(
      {required Map<HttpCookiePropertyKey, Object> properties}) newHTTPCookie;

  /// Constructs [AuthenticationChallengeResponse].
  final AuthenticationChallengeResponse Function({
    required UrlSessionAuthChallengeDisposition disposition,
    URLCredential? credential,
  }) newAuthenticationChallengeResponse;

  /// Constructs [WKWebViewConfiguration].
  final WKWebViewConfiguration Function() newWKWebViewConfiguration;

  /// Constructs [WKScriptMessageHandler].
  final WKScriptMessageHandler Function({
    required void Function(
      WKScriptMessageHandler,
      WKUserContentController,
      WKScriptMessage,
    ) didReceiveScriptMessage,
  }) newWKScriptMessageHandler;

  /// Constructs [WKNavigationDelegate].
  final WKNavigationDelegate Function({
    void Function(
      WKNavigationDelegate,
      WKWebView,
      String?,
    )? didFinishNavigation,
    void Function(
      WKNavigationDelegate,
      WKWebView,
      String?,
    )? didStartProvisionalNavigation,
    Future<NavigationActionPolicy> Function(
      WKNavigationDelegate,
      WKWebView,
      WKNavigationAction,
    )? decidePolicyForNavigationAction,
    Future<NavigationResponsePolicy> Function(
      WKNavigationDelegate,
      WKWebView,
      WKNavigationResponse,
    )? decidePolicyForNavigationResponse,
    void Function(
      WKNavigationDelegate,
      WKWebView,
      NSError,
    )? didFailNavigation,
    void Function(
      WKNavigationDelegate,
      WKWebView,
      NSError,
    )? didFailProvisionalNavigation,
    void Function(
      WKNavigationDelegate,
      WKWebView,
    )? webViewWebContentProcessDidTerminate,
    Future<AuthenticationChallengeResponse> Function(
      WKNavigationDelegate,
      WKWebView,
      URLAuthenticationChallenge,
    )? didReceiveAuthenticationChallenge,
  }) newWKNavigationDelegate;

  /// Constructs [NSObject].
  final NSObject Function(
      {void Function(
        NSObject,
        String?,
        NSObject?,
        Map<KeyValueChangeKey, Object>?,
      )? observeValue}) newNSObject;

  /// Constructs [PlatformWebView].
  final PlatformWebView Function({
    required WKWebViewConfiguration initialConfiguration,
    void Function(
      NSObject,
      String?,
      NSObject?,
      Map<KeyValueChangeKey, Object>?,
    )? observeValue,
  }) newPlatformWebView;

  /// Constructs [WKUIDelegate].
  final WKUIDelegate Function({
    void Function(
      WKUIDelegate,
      WKWebView,
      WKWebViewConfiguration,
      WKNavigationAction,
    )? onCreateWebView,
    Future<PermissionDecision> Function(
      WKUIDelegate,
      WKWebView,
      WKSecurityOrigin,
      WKFrameInfo,
      MediaCaptureType,
    )? requestMediaCapturePermission,
    Future<void> Function(
      WKUIDelegate,
      String,
      WKFrameInfo,
    )? runJavaScriptAlertPanel,
    Future<bool> Function(
      WKUIDelegate,
      String,
      WKFrameInfo,
    )? runJavaScriptConfirmPanel,
    Future<String?> Function(
      WKUIDelegate,
      String,
      String?,
      WKFrameInfo,
    )? runJavaScriptTextInputPanel,
  }) newWKUIDelegate;

  /// Constructs [UIScrollViewDelegate].
  final UIScrollViewDelegate Function({
    void Function(
      UIScrollViewDelegate,
      UIScrollView,
      double,
      double,
    )? scrollViewDidScroll,
  }) newUIScrollViewDelegate;

  /// Constructs [URLCredential].
  final URLCredential Function({
    required String user,
    required String password,
    required UrlCredentialPersistence persistence,
  }) withUserURLCredential;

  /// Calls to [WKWebsiteDataStore.defaultDataStore].
  final WKWebsiteDataStore Function() defaultDataStoreWKWebsiteDataStore;

  static WKWebsiteDataStore _defaultDataStoreWKWebsiteDataStore() =>
      WKWebsiteDataStore.defaultDataStore;
}

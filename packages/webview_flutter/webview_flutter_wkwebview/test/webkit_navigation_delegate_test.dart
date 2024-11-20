// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit2.g.dart';
import 'package:webview_flutter_wkwebview/src/common/webkit_constants.dart';
import 'package:webview_flutter_wkwebview/src/webkit_proxy.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

@GenerateMocks(<Type>[URLAuthenticationChallenge, URLRequest])
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('WebKitNavigationDelegate', () {
    test('WebKitNavigationDelegate uses params field in constructor', () async {
      await runZonedGuarded(
        () async => WebKitNavigationDelegate(
          const PlatformNavigationDelegateCreationParams(),
        ),
        (Object error, __) {
          expect(error, isNot(isA<TypeError>()));
        },
      );
    });

    test('setOnPageFinished', () {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
            newWKUIDelegate: CapturingUIDelegate.new,
          ),
        ),
      );

      late final String callbackUrl;
      webKitDelegate.setOnPageFinished((String url) => callbackUrl = url);

      CapturingNavigationDelegate.lastCreatedDelegate.didFinishNavigation!(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        'https://www.google.com',
      );

      expect(callbackUrl, 'https://www.google.com');
    });

    test('setOnPageStarted', () {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
            newWKUIDelegate: CapturingUIDelegate.new,
          ),
        ),
      );

      late final String callbackUrl;
      webKitDelegate.setOnPageStarted((String url) => callbackUrl = url);

      CapturingNavigationDelegate
          .lastCreatedDelegate.didStartProvisionalNavigation!(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        'https://www.google.com',
      );

      expect(callbackUrl, 'https://www.google.com');
    });

    test('setOnHttpError from decidePolicyForNavigationResponse', () {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
            newWKUIDelegate: CapturingUIDelegate.new,
          ),
        ),
      );

      late final HttpResponseError callbackError;
      void onHttpError(HttpResponseError error) {
        callbackError = error;
      }

      webKitDelegate.setOnHttpError(onHttpError);

      CapturingNavigationDelegate
          .lastCreatedDelegate.decidePolicyForNavigationResponse!(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        WKNavigationResponse.pigeon_detached(
          response: HTTPURLResponse.pigeon_detached(
            statusCode: 401,
            pigeon_instanceManager: TestInstanceManager(),
          ),
          forMainFrame: true,
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(callbackError.response?.statusCode, 401);
    });

    test('setOnHttpError is not called for error codes < 400', () {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
            newWKUIDelegate: CapturingUIDelegate.new,
          ),
        ),
      );

      HttpResponseError? callbackError;
      void onHttpError(HttpResponseError error) {
        callbackError = error;
      }

      webKitDelegate.setOnHttpError(onHttpError);

      CapturingNavigationDelegate
          .lastCreatedDelegate.decidePolicyForNavigationResponse!(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        WKNavigationResponse.pigeon_detached(
          response: HTTPURLResponse.pigeon_detached(
            statusCode: 399,
            pigeon_instanceManager: TestInstanceManager(),
          ),
          forMainFrame: true,
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(callbackError, isNull);
    });

    test('onWebResourceError from didFailNavigation', () {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
            newWKUIDelegate: CapturingUIDelegate.new,
          ),
        ),
      );

      late final WebKitWebResourceError callbackError;
      void onWebResourceError(WebResourceError error) {
        callbackError = error as WebKitWebResourceError;
      }

      webKitDelegate.setOnWebResourceError(onWebResourceError);

      CapturingNavigationDelegate.lastCreatedDelegate.didFailNavigation!(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        NSError.pigeon_detached(
          code: WKErrorCode.webViewInvalidated,
          domain: 'domain',
          userInfo: const <String, Object?>{
            NSErrorUserInfoKey.NSURLErrorFailingURLStringError:
                'www.flutter.dev',
            NSErrorUserInfoKey.NSLocalizedDescription: 'my desc',
          },
          localizedDescription: 'description',
        ),
      );

      expect(callbackError.description, 'my desc');
      expect(callbackError.errorCode, WKErrorCode.webViewInvalidated);
      expect(callbackError.url, 'www.flutter.dev');
      expect(callbackError.domain, 'domain');
      expect(callbackError.errorType, WebResourceErrorType.webViewInvalidated);
      expect(callbackError.isForMainFrame, true);
    });

    test('onWebResourceError from didFailProvisionalNavigation', () {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
            newWKUIDelegate: CapturingUIDelegate.new,
          ),
        ),
      );

      late final WebKitWebResourceError callbackError;
      void onWebResourceError(WebResourceError error) {
        callbackError = error as WebKitWebResourceError;
      }

      webKitDelegate.setOnWebResourceError(onWebResourceError);

      CapturingNavigationDelegate
          .lastCreatedDelegate.didFailProvisionalNavigation!(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        NSError.pigeon_detached(
          code: WKErrorCode.webViewInvalidated,
          domain: 'domain',
          userInfo: const <String, Object?>{
            NSErrorUserInfoKey.NSURLErrorFailingURLStringError:
                'www.flutter.dev',
            NSErrorUserInfoKey.NSLocalizedDescription: 'my desc',
          },
          localizedDescription: 'my desc',
        ),
      );

      expect(callbackError.description, 'my desc');
      expect(callbackError.url, 'www.flutter.dev');
      expect(callbackError.errorCode, WKErrorCode.webViewInvalidated);
      expect(callbackError.domain, 'domain');
      expect(callbackError.errorType, WebResourceErrorType.webViewInvalidated);
      expect(callbackError.isForMainFrame, true);
    });

    test('onWebResourceError from webViewWebContentProcessDidTerminate', () {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
            newWKUIDelegate: CapturingUIDelegate.new,
          ),
        ),
      );

      late final WebKitWebResourceError callbackError;
      void onWebResourceError(WebResourceError error) {
        callbackError = error as WebKitWebResourceError;
      }

      webKitDelegate.setOnWebResourceError(onWebResourceError);

      CapturingNavigationDelegate
          .lastCreatedDelegate.webViewWebContentProcessDidTerminate!(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(callbackError.description, '');
      expect(callbackError.errorCode, WKErrorCode.webContentProcessTerminated);
      expect(callbackError.domain, 'WKErrorDomain');
      expect(
        callbackError.errorType,
        WebResourceErrorType.webContentProcessTerminated,
      );
      expect(callbackError.isForMainFrame, true);
    });

    test('onNavigationRequest from decidePolicyForNavigationAction', () {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
            newWKUIDelegate: CapturingUIDelegate.new,
          ),
        ),
      );

      late final NavigationRequest callbackRequest;
      FutureOr<NavigationDecision> onNavigationRequest(
          NavigationRequest request) {
        callbackRequest = request;
        return NavigationDecision.navigate;
      }

      webKitDelegate.setOnNavigationRequest(onNavigationRequest);

      expect(
        CapturingNavigationDelegate
            .lastCreatedDelegate.decidePolicyForNavigationAction!(
          WKNavigationDelegate.pigeon_detached(
            pigeon_instanceManager: TestInstanceManager(),
          ),
          WKWebView.pigeon_detached(
            pigeon_instanceManager: TestInstanceManager(),
          ),
          WKNavigationAction.pigeon_detached(
            request: URLRequest.pigeon_detached(
              pigeon_instanceManager: TestInstanceManager(),
            ),
            targetFrame: WKFrameInfo.pigeon_detached(
              isMainFrame: false,
              request: URLRequest.pigeon_detached(
                pigeon_instanceManager: TestInstanceManager(),
              ),
            ),
            navigationType: NavigationType.linkActivated,
            pigeon_instanceManager: TestInstanceManager(),
          ),
        ),
        completion(NavigationActionPolicy.allow),
      );

      expect(callbackRequest.url, 'https://www.google.com');
      expect(callbackRequest.isMainFrame, isFalse);
    });

    test('onHttpBasicAuthRequest emits host and realm', () async {
      final WebKitNavigationDelegate iosNavigationDelegate =
          WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
          ),
        ),
      );

      String? callbackHost;
      String? callbackRealm;

      await iosNavigationDelegate.setOnHttpAuthRequest(
        (HttpAuthRequest request) {
          callbackHost = request.host;
          callbackRealm = request.realm;
        },
      );

      const String expectedHost = 'expectedHost';
      const String expectedRealm = 'expectedRealm';

      await CapturingNavigationDelegate
          .lastCreatedDelegate.didReceiveAuthenticationChallenge!(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        URLAuthenticationChallenge.pigeon_detached(
          // protectionSpace: URLProtectionSpace.pigeon_detached(
          //   host: expectedHost,
          //   realm: expectedRealm,
          //   authenticationMethod: NSUrlAuthenticationMethod.httpBasic,
          // ),
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(callbackHost, expectedHost);
      expect(callbackRealm, expectedRealm);
    });

    test('onHttpNtlmAuthRequest emits host and realm', () async {
      final WebKitNavigationDelegate iosNavigationDelegate =
          WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
          ),
        ),
      );

      String? callbackHost;
      String? callbackRealm;

      await iosNavigationDelegate.setOnHttpAuthRequest(
        (HttpAuthRequest request) {
          callbackHost = request.host;
          callbackRealm = request.realm;
        },
      );

      const String expectedHost = 'expectedHost';
      const String expectedRealm = 'expectedRealm';

      await CapturingNavigationDelegate
          .lastCreatedDelegate.didReceiveAuthenticationChallenge!(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        URLAuthenticationChallenge.pigeon_detached(
          // protectionSpace: URLProtectionSpace.pigeon_detached(
          //   host: expectedHost,
          //   realm: expectedRealm,
          //   authenticationMethod: NSUrlAuthenticationMethod.httpNtlm,
          // ),
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(callbackHost, expectedHost);
      expect(callbackRealm, expectedRealm);
    });
  });
}

// Records the last created instance of itself.
class CapturingNavigationDelegate extends WKNavigationDelegate {
  CapturingNavigationDelegate({
    super.didFinishNavigation,
    super.didStartProvisionalNavigation,
    super.decidePolicyForNavigationResponse,
    super.didFailNavigation,
    super.didFailProvisionalNavigation,
    super.decidePolicyForNavigationAction,
    super.webViewWebContentProcessDidTerminate,
    super.didReceiveAuthenticationChallenge,
  }) : super(pigeon_instanceManager: TestInstanceManager()) {
    lastCreatedDelegate = this;
  }
  static CapturingNavigationDelegate lastCreatedDelegate =
      CapturingNavigationDelegate();
}

// Records the last created instance of itself.
class CapturingUIDelegate extends WKUIDelegate {
  CapturingUIDelegate({
    super.onCreateWebView,
    super.requestMediaCapturePermission,
    super.runJavaScriptAlertPanel,
    super.runJavaScriptConfirmPanel,
    super.runJavaScriptTextInputPanel,
    PigeonInstanceManager? pigeon_instanceManager,
  }) : super(
          pigeon_instanceManager:
              pigeon_instanceManager ?? TestInstanceManager(),
        ) {
    lastCreatedDelegate = this;
  }
  static CapturingUIDelegate lastCreatedDelegate = CapturingUIDelegate();
}

// Test InstanceManager that sets `onWeakReferenceRemoved` as a noop.
class TestInstanceManager extends PigeonInstanceManager {
  TestInstanceManager() : super(onWeakReferenceRemoved: (_) {});
}

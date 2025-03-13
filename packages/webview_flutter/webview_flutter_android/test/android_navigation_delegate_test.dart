// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_android/src/android_proxy.dart';
import 'package:webview_flutter_android/src/android_webkit.g.dart'
    as android_webview;
import 'package:webview_flutter_android/src/android_webkit_constants.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'android_navigation_delegate_test.mocks.dart';

@GenerateMocks(<Type>[
  android_webview.HttpAuthHandler,
  android_webview.DownloadListener,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AndroidNavigationDelegate', () {
    test('onPageFinished', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      late final String callbackUrl;
      androidNavigationDelegate
          .setOnPageFinished((String url) => callbackUrl = url);

      CapturingWebViewClient.lastCreatedDelegate.onPageFinished!(
        CapturingWebViewClient(),
        TestWebView(),
        'https://www.google.com',
      );

      expect(callbackUrl, 'https://www.google.com');
    });

    test('onPageStarted', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      late final String callbackUrl;
      androidNavigationDelegate
          .setOnPageStarted((String url) => callbackUrl = url);

      CapturingWebViewClient.lastCreatedDelegate.onPageStarted!(
        CapturingWebViewClient(),
        TestWebView(),
        'https://www.google.com',
      );

      expect(callbackUrl, 'https://www.google.com');
    });

    test('onHttpError from onReceivedHttpError', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      late final HttpResponseError callbackError;
      androidNavigationDelegate.setOnHttpError(
          (HttpResponseError httpError) => callbackError = httpError);

      CapturingWebViewClient.lastCreatedDelegate.onReceivedHttpError!(
          CapturingWebViewClient(),
          TestWebView(),
          android_webview.WebResourceRequest.pigeon_detached(
            url: 'https://www.google.com',
            isForMainFrame: false,
            isRedirect: true,
            hasGesture: true,
            method: 'GET',
            requestHeaders: const <String, String>{'X-Mock': 'mocking'},
            pigeon_instanceManager: TestInstanceManager(),
          ),
          android_webview.WebResourceResponse.pigeon_detached(
            statusCode: 401,
            pigeon_instanceManager: TestInstanceManager(),
          ));

      expect(callbackError.response?.statusCode, 401);
    });

    test('onWebResourceError from onReceivedRequestError', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      late final WebResourceError callbackError;
      androidNavigationDelegate.setOnWebResourceError(
          (WebResourceError error) => callbackError = error);

      CapturingWebViewClient.lastCreatedDelegate.onReceivedRequestError!(
        CapturingWebViewClient(),
        TestWebView(),
        android_webview.WebResourceRequest.pigeon_detached(
          url: 'https://www.google.com',
          isForMainFrame: false,
          isRedirect: true,
          hasGesture: true,
          method: 'GET',
          requestHeaders: const <String, String>{'X-Mock': 'mocking'},
          pigeon_instanceManager: TestInstanceManager(),
        ),
        android_webview.WebResourceError.pigeon_detached(
          errorCode: WebViewClientConstants.errorFileNotFound,
          description: 'Page not found.',
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(callbackError.errorCode, WebViewClientConstants.errorFileNotFound);
      expect(callbackError.description, 'Page not found.');
      expect(callbackError.errorType, WebResourceErrorType.fileNotFound);
      expect(callbackError.isForMainFrame, false);
    });

    test('onWebResourceError from onRequestError', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      late final WebResourceError callbackError;
      androidNavigationDelegate.setOnWebResourceError(
          (WebResourceError error) => callbackError = error);

      CapturingWebViewClient.lastCreatedDelegate.onReceivedError!(
        CapturingWebViewClient(),
        TestWebView(),
        WebViewClientConstants.errorFileNotFound,
        'Page not found.',
        'https://www.google.com',
      );

      expect(callbackError.errorCode, WebViewClientConstants.errorFileNotFound);
      expect(callbackError.description, 'Page not found.');
      expect(callbackError.errorType, WebResourceErrorType.fileNotFound);
      expect(callbackError.isForMainFrame, true);
    });

    test(
        'onNavigationRequest from requestLoading should not be called when loadUrlCallback is not specified',
        () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      NavigationRequest? callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.prevent;
      });

      CapturingWebViewClient.lastCreatedDelegate.requestLoading!(
        CapturingWebViewClient(),
        TestWebView(),
        android_webview.WebResourceRequest.pigeon_detached(
          url: 'https://www.google.com',
          isForMainFrame: true,
          isRedirect: true,
          hasGesture: true,
          method: 'GET',
          requestHeaders: const <String, String>{'X-Mock': 'mocking'},
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(callbackNavigationRequest, isNull);
    });

    test(
        'onNavigationRequest from requestLoading should be called when request is for main frame',
        () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      NavigationRequest? callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.prevent;
      });

      androidNavigationDelegate.setOnLoadRequest((_) async {});

      CapturingWebViewClient.lastCreatedDelegate.requestLoading!(
        CapturingWebViewClient(),
        TestWebView(),
        android_webview.WebResourceRequest.pigeon_detached(
          url: 'https://www.google.com',
          isForMainFrame: true,
          isRedirect: true,
          hasGesture: true,
          method: 'GET',
          requestHeaders: const <String, String>{'X-Mock': 'mocking'},
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(callbackNavigationRequest, isNotNull);
    });

    test(
        'onNavigationRequest from requestLoading should not be called when request is not for main frame',
        () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      NavigationRequest? callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.prevent;
      });

      androidNavigationDelegate.setOnLoadRequest((_) async {});

      CapturingWebViewClient.lastCreatedDelegate.requestLoading!(
        CapturingWebViewClient(),
        TestWebView(),
        android_webview.WebResourceRequest.pigeon_detached(
          url: 'https://www.google.com',
          isForMainFrame: false,
          isRedirect: true,
          hasGesture: true,
          method: 'GET',
          requestHeaders: const <String, String>{'X-Mock': 'mocking'},
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(callbackNavigationRequest, isNull);
    });

    test(
        'onLoadRequest from requestLoading should not be called when navigationRequestCallback is not specified',
        () {
      final Completer<void> completer = Completer<void>();
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((_) {
        completer.complete();
        return completer.future;
      });

      CapturingWebViewClient.lastCreatedDelegate.requestLoading!(
        CapturingWebViewClient(),
        TestWebView(),
        android_webview.WebResourceRequest.pigeon_detached(
          url: 'https://www.google.com',
          isForMainFrame: true,
          isRedirect: true,
          hasGesture: true,
          method: 'GET',
          requestHeaders: const <String, String>{'X-Mock': 'mocking'},
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(completer.isCompleted, false);
    });

    test(
        'onLoadRequest from requestLoading should not be called when onNavigationRequestCallback returns NavigationDecision.prevent',
        () {
      final Completer<void> completer = Completer<void>();
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((_) {
        completer.complete();
        return completer.future;
      });

      late final NavigationRequest callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.prevent;
      });

      CapturingWebViewClient.lastCreatedDelegate.requestLoading!(
        CapturingWebViewClient(),
        TestWebView(),
        android_webview.WebResourceRequest.pigeon_detached(
          url: 'https://www.google.com',
          isForMainFrame: true,
          isRedirect: true,
          hasGesture: true,
          method: 'GET',
          requestHeaders: const <String, String>{'X-Mock': 'mocking'},
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(callbackNavigationRequest.isMainFrame, true);
      expect(callbackNavigationRequest.url, 'https://www.google.com');
      expect(completer.isCompleted, false);
    });

    test(
        'onLoadRequest from requestLoading should complete when onNavigationRequestCallback returns NavigationDecision.navigate',
        () {
      final Completer<void> completer = Completer<void>();
      late final LoadRequestParams loadRequestParams;
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((LoadRequestParams params) {
        loadRequestParams = params;
        completer.complete();
        return completer.future;
      });

      late final NavigationRequest callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.navigate;
      });

      CapturingWebViewClient.lastCreatedDelegate.requestLoading!(
        CapturingWebViewClient(),
        TestWebView(),
        android_webview.WebResourceRequest.pigeon_detached(
          url: 'https://www.google.com',
          isForMainFrame: true,
          isRedirect: true,
          hasGesture: true,
          method: 'GET',
          requestHeaders: const <String, String>{'X-Mock': 'mocking'},
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(loadRequestParams.uri.toString(), 'https://www.google.com');
      expect(loadRequestParams.headers, <String, String>{'X-Mock': 'mocking'});
      expect(callbackNavigationRequest.isMainFrame, true);
      expect(callbackNavigationRequest.url, 'https://www.google.com');
      expect(completer.isCompleted, true);
    });

    test(
        'onNavigationRequest from urlLoading should not be called when loadUrlCallback is not specified',
        () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      NavigationRequest? callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.prevent;
      });

      CapturingWebViewClient.lastCreatedDelegate.urlLoading!(
        CapturingWebViewClient(),
        TestWebView(),
        'https://www.google.com',
      );

      expect(callbackNavigationRequest, isNull);
    });

    test(
        'onLoadRequest from urlLoading should not be called when navigationRequestCallback is not specified',
        () {
      final Completer<void> completer = Completer<void>();
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((_) {
        completer.complete();
        return completer.future;
      });

      CapturingWebViewClient.lastCreatedDelegate.urlLoading!(
        CapturingWebViewClient(),
        TestWebView(),
        'https://www.google.com',
      );

      expect(completer.isCompleted, false);
    });

    test(
        'onLoadRequest from urlLoading should not be called when onNavigationRequestCallback returns NavigationDecision.prevent',
        () {
      final Completer<void> completer = Completer<void>();
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((_) {
        completer.complete();
        return completer.future;
      });

      late final NavigationRequest callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.prevent;
      });

      CapturingWebViewClient.lastCreatedDelegate.urlLoading!(
        CapturingWebViewClient(),
        TestWebView(),
        'https://www.google.com',
      );

      expect(callbackNavigationRequest.isMainFrame, true);
      expect(callbackNavigationRequest.url, 'https://www.google.com');
      expect(completer.isCompleted, false);
    });

    test(
        'onLoadRequest from urlLoading should complete when onNavigationRequestCallback returns NavigationDecision.navigate',
        () {
      final Completer<void> completer = Completer<void>();
      late final LoadRequestParams loadRequestParams;
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((LoadRequestParams params) {
        loadRequestParams = params;
        completer.complete();
        return completer.future;
      });

      late final NavigationRequest callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.navigate;
      });

      CapturingWebViewClient.lastCreatedDelegate.urlLoading!(
        CapturingWebViewClient(),
        TestWebView(),
        'https://www.google.com',
      );

      expect(loadRequestParams.uri.toString(), 'https://www.google.com');
      expect(loadRequestParams.headers, <String, String>{});
      expect(callbackNavigationRequest.isMainFrame, true);
      expect(callbackNavigationRequest.url, 'https://www.google.com');
      expect(completer.isCompleted, true);
    });

    test('setOnNavigationRequest should override URL loading', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnNavigationRequest(
        (NavigationRequest request) => NavigationDecision.navigate,
      );

      expect(
          CapturingWebViewClient.lastCreatedDelegate
              .synchronousReturnValueForShouldOverrideUrlLoading,
          isTrue);
    });

    test(
        'onLoadRequest from onDownloadStart should not be called when navigationRequestCallback is not specified',
        () {
      final Completer<void> completer = Completer<void>();
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((_) {
        completer.complete();
        return completer.future;
      });

      CapturingDownloadListener.lastCreatedListener.onDownloadStart(
        MockDownloadListener(),
        '',
        '',
        '',
        '',
        0,
      );

      expect(completer.isCompleted, false);
    });

    test(
        'onLoadRequest from onDownloadStart should not be called when onNavigationRequestCallback returns NavigationDecision.prevent',
        () {
      final Completer<void> completer = Completer<void>();
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((_) {
        completer.complete();
        return completer.future;
      });

      late final NavigationRequest callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.prevent;
      });

      CapturingDownloadListener.lastCreatedListener.onDownloadStart(
        MockDownloadListener(),
        'https://www.google.com',
        '',
        '',
        '',
        0,
      );

      expect(callbackNavigationRequest.isMainFrame, true);
      expect(callbackNavigationRequest.url, 'https://www.google.com');
      expect(completer.isCompleted, false);
    });

    test(
        'onLoadRequest from onDownloadStart should complete when onNavigationRequestCallback returns NavigationDecision.navigate',
        () {
      final Completer<void> completer = Completer<void>();
      late final LoadRequestParams loadRequestParams;
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      androidNavigationDelegate.setOnLoadRequest((LoadRequestParams params) {
        loadRequestParams = params;
        completer.complete();
        return completer.future;
      });

      late final NavigationRequest callbackNavigationRequest;
      androidNavigationDelegate
          .setOnNavigationRequest((NavigationRequest navigationRequest) {
        callbackNavigationRequest = navigationRequest;
        return NavigationDecision.navigate;
      });

      CapturingDownloadListener.lastCreatedListener.onDownloadStart(
        MockDownloadListener(),
        'https://www.google.com',
        '',
        '',
        '',
        0,
      );

      expect(loadRequestParams.uri.toString(), 'https://www.google.com');
      expect(loadRequestParams.headers, <String, String>{});
      expect(callbackNavigationRequest.isMainFrame, true);
      expect(callbackNavigationRequest.url, 'https://www.google.com');
      expect(completer.isCompleted, true);
    });

    test('onUrlChange', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      late final AndroidUrlChange urlChange;
      androidNavigationDelegate.setOnUrlChange(
        (UrlChange change) {
          urlChange = change as AndroidUrlChange;
        },
      );

      CapturingWebViewClient.lastCreatedDelegate.doUpdateVisitedHistory!(
        CapturingWebViewClient(),
        TestWebView(),
        'https://www.google.com',
        false,
      );

      expect(urlChange.url, 'https://www.google.com');
      expect(urlChange.isReload, isFalse);
    });

    test('onReceivedHttpAuthRequest emits host and realm', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(_buildCreationParams());

      String? callbackHost;
      String? callbackRealm;
      androidNavigationDelegate.setOnHttpAuthRequest((HttpAuthRequest request) {
        callbackHost = request.host;
        callbackRealm = request.realm;
      });

      const String expectedHost = 'expectedHost';
      const String expectedRealm = 'expectedRealm';

      CapturingWebViewClient.lastCreatedDelegate.onReceivedHttpAuthRequest!(
        CapturingWebViewClient(),
        TestWebView(),
        android_webview.HttpAuthHandler.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        expectedHost,
        expectedRealm,
      );

      expect(callbackHost, expectedHost);
      expect(callbackRealm, expectedRealm);
    });

    test('onReceivedHttpAuthRequest calls cancel by default', () {
      AndroidNavigationDelegate(_buildCreationParams());

      final MockHttpAuthHandler mockAuthHandler = MockHttpAuthHandler();

      CapturingWebViewClient.lastCreatedDelegate.onReceivedHttpAuthRequest!(
        CapturingWebViewClient(),
        TestWebView(),
        mockAuthHandler,
        'host',
        'realm',
      );

      verify(mockAuthHandler.cancel());
    });
  });
}

AndroidNavigationDelegateCreationParams _buildCreationParams() {
  return AndroidNavigationDelegateCreationParams
      .fromPlatformNavigationDelegateCreationParams(
    const PlatformNavigationDelegateCreationParams(),
    androidWebViewProxy: const AndroidWebViewProxy(
      newWebChromeClient: CapturingWebChromeClient.new,
      newWebViewClient: CapturingWebViewClient.new,
      newDownloadListener: CapturingDownloadListener.new,
    ),
  );
}

// Records the last created instance of itself.
// ignore: must_be_immutable
class CapturingWebViewClient extends android_webview.WebViewClient {
  CapturingWebViewClient({
    super.onPageFinished,
    super.onPageStarted,
    super.onReceivedHttpError,
    super.onReceivedError,
    super.onReceivedHttpAuthRequest,
    super.onReceivedRequestErrorCompat,
    super.doUpdateVisitedHistory,
    super.onReceivedRequestError,
    super.requestLoading,
    super.urlLoading,
  }) : super.pigeon_detached(
            pigeon_instanceManager: android_webview.PigeonInstanceManager(
                onWeakReferenceRemoved: (_) {})) {
    lastCreatedDelegate = this;
  }

  static CapturingWebViewClient lastCreatedDelegate = CapturingWebViewClient();

  bool synchronousReturnValueForShouldOverrideUrlLoading = false;

  @override
  Future<void> setSynchronousReturnValueForShouldOverrideUrlLoading(
      bool value) async {
    synchronousReturnValueForShouldOverrideUrlLoading = value;
  }
}

// Records the last created instance of itself.
class CapturingWebChromeClient extends android_webview.WebChromeClient {
  CapturingWebChromeClient({
    super.onProgressChanged,
    super.onShowFileChooser,
    super.onGeolocationPermissionsShowPrompt,
    super.onGeolocationPermissionsHidePrompt,
    super.onShowCustomView,
    super.onHideCustomView,
    super.onPermissionRequest,
    super.onConsoleMessage,
    super.onJsAlert,
    super.onJsConfirm,
    super.onJsPrompt,
  }) : super.pigeon_detached(
            pigeon_instanceManager: android_webview.PigeonInstanceManager(
                onWeakReferenceRemoved: (_) {})) {
    lastCreatedDelegate = this;
  }

  static CapturingWebChromeClient lastCreatedDelegate =
      CapturingWebChromeClient();
}

// Records the last created instance of itself.
class CapturingDownloadListener extends android_webview.DownloadListener {
  CapturingDownloadListener({
    required super.onDownloadStart,
  }) : super.pigeon_detached(
            pigeon_instanceManager: android_webview.PigeonInstanceManager(
                onWeakReferenceRemoved: (_) {})) {
    lastCreatedListener = this;
  }

  static CapturingDownloadListener lastCreatedListener =
      CapturingDownloadListener(
    onDownloadStart: (_, __, ___, ____, _____, ______) {},
  );
}

class TestWebView extends android_webview.WebView {
  TestWebView()
      : super.pigeon_detached(
          pigeon_instanceManager: android_webview.PigeonInstanceManager(
            onWeakReferenceRemoved: (_) {},
          ),
        );
}

class TestInstanceManager extends android_webview.PigeonInstanceManager {
  TestInstanceManager() : super(onWeakReferenceRemoved: (_) {});
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_android/src/android_webkit.g.dart'
    as android_webview;
import 'package:webview_flutter_android/src/android_webkit_constants.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'android_navigation_delegate_test.mocks.dart';

@GenerateMocks(<Type>[
  android_webview.HttpAuthHandler,
  android_webview.DownloadListener,
  android_webview.SslCertificate,
  android_webview.SslError,
  android_webview.SslErrorHandler,
  android_webview.X509Certificate,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AndroidNavigationDelegate', () {
    test('onPageFinished', () {
      final androidNavigationDelegate = AndroidNavigationDelegate(
        _buildCreationParams(),
      );

      late final String callbackUrl;
      androidNavigationDelegate.setOnPageFinished(
        (String url) => callbackUrl = url,
      );

      CapturingWebViewClient.lastCreatedDelegate.onPageFinished!(
        CapturingWebViewClient(),
        TestWebView(),
        'https://www.google.com',
      );

      expect(callbackUrl, 'https://www.google.com');
    });

    test('onPageStarted', () {
      final androidNavigationDelegate = AndroidNavigationDelegate(
        _buildCreationParams(),
      );

      late final String callbackUrl;
      androidNavigationDelegate.setOnPageStarted(
        (String url) => callbackUrl = url,
      );

      CapturingWebViewClient.lastCreatedDelegate.onPageStarted!(
        CapturingWebViewClient(),
        TestWebView(),
        'https://www.google.com',
      );

      expect(callbackUrl, 'https://www.google.com');
    });

    test('onHttpError from onReceivedHttpError', () {
      final androidNavigationDelegate = AndroidNavigationDelegate(
        _buildCreationParams(),
      );

      late final HttpResponseError callbackError;
      androidNavigationDelegate.setOnHttpError(
        (HttpResponseError httpError) => callbackError = httpError,
      );

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
        ),
        android_webview.WebResourceResponse.pigeon_detached(statusCode: 401),
      );

      expect(callbackError.response?.statusCode, 401);
    });

    test('onWebResourceError from onReceivedRequestError', () {
      final androidNavigationDelegate = AndroidNavigationDelegate(
        _buildCreationParams(),
      );

      late final WebResourceError callbackError;
      androidNavigationDelegate.setOnWebResourceError(
        (WebResourceError error) => callbackError = error,
      );

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
        ),
        android_webview.WebResourceError.pigeon_detached(
          errorCode: WebViewClientConstants.errorFileNotFound,
          description: 'Page not found.',
        ),
      );

      expect(callbackError.errorCode, WebViewClientConstants.errorFileNotFound);
      expect(callbackError.description, 'Page not found.');
      expect(callbackError.errorType, WebResourceErrorType.fileNotFound);
      expect(callbackError.isForMainFrame, false);
    });

    test(
      'onNavigationRequest from requestLoading should not be called when loadUrlCallback is not specified',
      () {
        final androidNavigationDelegate = AndroidNavigationDelegate(
          _buildCreationParams(),
        );

        NavigationRequest? callbackNavigationRequest;
        androidNavigationDelegate.setOnNavigationRequest((
          NavigationRequest navigationRequest,
        ) {
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
          ),
        );

        expect(callbackNavigationRequest, isNull);
      },
    );

    test(
      'onNavigationRequest from requestLoading should be called when request is for main frame',
      () {
        final androidNavigationDelegate = AndroidNavigationDelegate(
          _buildCreationParams(),
        );

        NavigationRequest? callbackNavigationRequest;
        androidNavigationDelegate.setOnNavigationRequest((
          NavigationRequest navigationRequest,
        ) {
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
          ),
        );

        expect(callbackNavigationRequest, isNotNull);
      },
    );

    test(
      'onNavigationRequest from requestLoading should not be called when request is not for main frame',
      () {
        final androidNavigationDelegate = AndroidNavigationDelegate(
          _buildCreationParams(),
        );

        NavigationRequest? callbackNavigationRequest;
        androidNavigationDelegate.setOnNavigationRequest((
          NavigationRequest navigationRequest,
        ) {
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
          ),
        );

        expect(callbackNavigationRequest, isNull);
      },
    );

    test(
      'onLoadRequest from requestLoading should not be called when navigationRequestCallback is not specified',
      () {
        final completer = Completer<void>();
        final androidNavigationDelegate = AndroidNavigationDelegate(
          _buildCreationParams(),
        );

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
          ),
        );

        expect(completer.isCompleted, false);
      },
    );

    test(
      'onLoadRequest from requestLoading should not be called when onNavigationRequestCallback returns NavigationDecision.prevent',
      () {
        final completer = Completer<void>();
        final androidNavigationDelegate = AndroidNavigationDelegate(
          _buildCreationParams(),
        );

        androidNavigationDelegate.setOnLoadRequest((_) {
          completer.complete();
          return completer.future;
        });

        late final NavigationRequest callbackNavigationRequest;
        androidNavigationDelegate.setOnNavigationRequest((
          NavigationRequest navigationRequest,
        ) {
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
          ),
        );

        expect(callbackNavigationRequest.isMainFrame, true);
        expect(callbackNavigationRequest.url, 'https://www.google.com');
        expect(completer.isCompleted, false);
      },
    );

    test(
      'onLoadRequest from requestLoading should complete when onNavigationRequestCallback returns NavigationDecision.navigate',
      () {
        final completer = Completer<void>();
        late final LoadRequestParams loadRequestParams;
        final androidNavigationDelegate = AndroidNavigationDelegate(
          _buildCreationParams(),
        );

        androidNavigationDelegate.setOnLoadRequest((LoadRequestParams params) {
          loadRequestParams = params;
          completer.complete();
          return completer.future;
        });

        late final NavigationRequest callbackNavigationRequest;
        androidNavigationDelegate.setOnNavigationRequest((
          NavigationRequest navigationRequest,
        ) {
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
          ),
        );

        expect(loadRequestParams.uri.toString(), 'https://www.google.com');
        expect(loadRequestParams.headers, <String, String>{
          'X-Mock': 'mocking',
        });
        expect(callbackNavigationRequest.isMainFrame, true);
        expect(callbackNavigationRequest.url, 'https://www.google.com');
        expect(completer.isCompleted, true);
      },
    );

    test(
      'onNavigationRequest from urlLoading should not be called when loadUrlCallback is not specified',
      () {
        final androidNavigationDelegate = AndroidNavigationDelegate(
          _buildCreationParams(),
        );

        NavigationRequest? callbackNavigationRequest;
        androidNavigationDelegate.setOnNavigationRequest((
          NavigationRequest navigationRequest,
        ) {
          callbackNavigationRequest = navigationRequest;
          return NavigationDecision.prevent;
        });

        CapturingWebViewClient.lastCreatedDelegate.urlLoading!(
          CapturingWebViewClient(),
          TestWebView(),
          'https://www.google.com',
        );

        expect(callbackNavigationRequest, isNull);
      },
    );

    test(
      'onLoadRequest from urlLoading should not be called when navigationRequestCallback is not specified',
      () {
        final completer = Completer<void>();
        final androidNavigationDelegate = AndroidNavigationDelegate(
          _buildCreationParams(),
        );

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
      },
    );

    test(
      'onLoadRequest from urlLoading should not be called when onNavigationRequestCallback returns NavigationDecision.prevent',
      () {
        final completer = Completer<void>();
        final androidNavigationDelegate = AndroidNavigationDelegate(
          _buildCreationParams(),
        );

        androidNavigationDelegate.setOnLoadRequest((_) {
          completer.complete();
          return completer.future;
        });

        late final NavigationRequest callbackNavigationRequest;
        androidNavigationDelegate.setOnNavigationRequest((
          NavigationRequest navigationRequest,
        ) {
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
      },
    );

    test(
      'onLoadRequest from urlLoading should complete when onNavigationRequestCallback returns NavigationDecision.navigate',
      () {
        final completer = Completer<void>();
        late final LoadRequestParams loadRequestParams;
        final androidNavigationDelegate = AndroidNavigationDelegate(
          _buildCreationParams(),
        );

        androidNavigationDelegate.setOnLoadRequest((LoadRequestParams params) {
          loadRequestParams = params;
          completer.complete();
          return completer.future;
        });

        late final NavigationRequest callbackNavigationRequest;
        androidNavigationDelegate.setOnNavigationRequest((
          NavigationRequest navigationRequest,
        ) {
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
      },
    );

    test('setOnNavigationRequest should override URL loading', () {
      final androidNavigationDelegate = AndroidNavigationDelegate(
        _buildCreationParams(),
      );

      androidNavigationDelegate.setOnNavigationRequest(
        (NavigationRequest request) => NavigationDecision.navigate,
      );

      expect(
        CapturingWebViewClient
            .lastCreatedDelegate
            .synchronousReturnValueForShouldOverrideUrlLoading,
        isTrue,
      );
    });

    test(
      'onLoadRequest from onDownloadStart should not be called when navigationRequestCallback is not specified',
      () {
        final completer = Completer<void>();
        final androidNavigationDelegate = AndroidNavigationDelegate(
          _buildCreationParams(),
        );

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
      },
    );

    test(
      'onLoadRequest from onDownloadStart should not be called when onNavigationRequestCallback returns NavigationDecision.prevent',
      () {
        final completer = Completer<void>();
        final androidNavigationDelegate = AndroidNavigationDelegate(
          _buildCreationParams(),
        );

        androidNavigationDelegate.setOnLoadRequest((_) {
          completer.complete();
          return completer.future;
        });

        late final NavigationRequest callbackNavigationRequest;
        androidNavigationDelegate.setOnNavigationRequest((
          NavigationRequest navigationRequest,
        ) {
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
      },
    );

    test(
      'onLoadRequest from onDownloadStart should complete when onNavigationRequestCallback returns NavigationDecision.navigate',
      () {
        final completer = Completer<void>();
        late final LoadRequestParams loadRequestParams;
        final androidNavigationDelegate = AndroidNavigationDelegate(
          _buildCreationParams(),
        );

        androidNavigationDelegate.setOnLoadRequest((LoadRequestParams params) {
          loadRequestParams = params;
          completer.complete();
          return completer.future;
        });

        late final NavigationRequest callbackNavigationRequest;
        androidNavigationDelegate.setOnNavigationRequest((
          NavigationRequest navigationRequest,
        ) {
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
      },
    );

    test('onUrlChange', () {
      final androidNavigationDelegate = AndroidNavigationDelegate(
        _buildCreationParams(),
      );

      late final AndroidUrlChange urlChange;
      androidNavigationDelegate.setOnUrlChange((UrlChange change) {
        urlChange = change as AndroidUrlChange;
      });

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
      final androidNavigationDelegate = AndroidNavigationDelegate(
        _buildCreationParams(),
      );

      String? callbackHost;
      String? callbackRealm;
      androidNavigationDelegate.setOnHttpAuthRequest((HttpAuthRequest request) {
        callbackHost = request.host;
        callbackRealm = request.realm;
      });

      const expectedHost = 'expectedHost';
      const expectedRealm = 'expectedRealm';

      CapturingWebViewClient.lastCreatedDelegate.onReceivedHttpAuthRequest!(
        CapturingWebViewClient(),
        TestWebView(),
        android_webview.HttpAuthHandler.pigeon_detached(),
        expectedHost,
        expectedRealm,
      );

      expect(callbackHost, expectedHost);
      expect(callbackRealm, expectedRealm);
    });

    test('onReceivedHttpAuthRequest calls cancel by default', () {
      AndroidNavigationDelegate(_buildCreationParams());

      final mockAuthHandler = MockHttpAuthHandler();

      CapturingWebViewClient.lastCreatedDelegate.onReceivedHttpAuthRequest!(
        CapturingWebViewClient(),
        TestWebView(),
        mockAuthHandler,
        'host',
        'realm',
      );

      verify(mockAuthHandler.cancel());
    });

    test('setOnSSlAuthError', () async {
      final androidNavigationDelegate = AndroidNavigationDelegate(
        _buildCreationParams(),
      );

      final errorCompleter = Completer<PlatformSslAuthError>();
      await androidNavigationDelegate.setOnSSlAuthError((
        PlatformSslAuthError error,
      ) {
        errorCompleter.complete(error);
      });

      final certificateData = Uint8List(0);
      const url = 'https://google.com';

      final mockSslError = MockSslError();
      when(mockSslError.url).thenReturn(url);
      when(
        mockSslError.getPrimaryError(),
      ).thenAnswer((_) async => android_webview.SslErrorType.dateInvalid);
      final mockSslCertificate = MockSslCertificate();
      final mockX509Certificate = MockX509Certificate();
      when(
        mockX509Certificate.getEncoded(),
      ).thenAnswer((_) async => certificateData);
      when(
        mockSslCertificate.getX509Certificate(),
      ).thenAnswer((_) async => mockX509Certificate);
      when(mockSslError.certificate).thenReturn(mockSslCertificate);

      final mockSslErrorHandler = MockSslErrorHandler();

      CapturingWebViewClient.lastCreatedDelegate.onReceivedSslError!(
        CapturingWebViewClient(),
        TestWebView(),
        mockSslErrorHandler,
        mockSslError,
      );

      final error = await errorCompleter.future as AndroidSslAuthError;
      expect(error.certificate?.data, certificateData);
      expect(error.description, 'The date of the certificate is invalid.');
      expect(error.url, url);

      await error.proceed();
      verify(mockSslErrorHandler.proceed());

      clearInteractions(mockSslErrorHandler);

      await error.cancel();
      verify(mockSslErrorHandler.cancel());
    });

    test('setOnSSlAuthError calls cancel by default', () async {
      AndroidNavigationDelegate(_buildCreationParams());

      final mockSslErrorHandler = MockSslErrorHandler();

      CapturingWebViewClient.lastCreatedDelegate.onReceivedSslError!(
        CapturingWebViewClient(),
        TestWebView(),
        mockSslErrorHandler,
        MockSslError(),
      );

      verify(mockSslErrorHandler.cancel());
    });
  });
}

AndroidNavigationDelegateCreationParams _buildCreationParams() {
  android_webview.PigeonOverrides.webViewClient_new =
      CapturingWebViewClient.new;
  android_webview.PigeonOverrides.webChromeClient_new =
      CapturingWebChromeClient.new;
  android_webview.PigeonOverrides.downloadListener_new =
      CapturingDownloadListener.new;
  return AndroidNavigationDelegateCreationParams.fromPlatformNavigationDelegateCreationParams(
    const PlatformNavigationDelegateCreationParams(),
  );
}

// Records the last created instance of itself.
// ignore: must_be_immutable
class CapturingWebViewClient extends android_webview.WebViewClient {
  CapturingWebViewClient({
    super.onPageFinished,
    super.onPageStarted,
    super.onReceivedHttpError,
    super.onReceivedHttpAuthRequest,
    super.onReceivedRequestErrorCompat,
    super.doUpdateVisitedHistory,
    super.onReceivedRequestError,
    super.requestLoading,
    super.urlLoading,
    super.onFormResubmission,
    super.onLoadResource,
    super.onPageCommitVisible,
    super.onReceivedClientCertRequest,
    super.onReceivedLoginRequest,
    super.onReceivedSslError,
    super.onScaleChanged,
  }) : super.pigeon_detached() {
    lastCreatedDelegate = this;
  }

  static CapturingWebViewClient lastCreatedDelegate = CapturingWebViewClient();

  bool synchronousReturnValueForShouldOverrideUrlLoading = false;

  @override
  Future<void> setSynchronousReturnValueForShouldOverrideUrlLoading(
    bool value,
  ) async {
    synchronousReturnValueForShouldOverrideUrlLoading = value;
  }
}

// Records the last created instance of itself.
class CapturingWebChromeClient extends android_webview.WebChromeClient {
  CapturingWebChromeClient({
    super.onProgressChanged,
    required super.onShowFileChooser,
    super.onGeolocationPermissionsShowPrompt,
    super.onGeolocationPermissionsHidePrompt,
    super.onShowCustomView,
    super.onHideCustomView,
    super.onPermissionRequest,
    super.onConsoleMessage,
    super.onJsAlert,
    required super.onJsConfirm,
    super.onJsPrompt,
  }) : super.pigeon_detached() {
    lastCreatedDelegate = this;
  }

  static CapturingWebChromeClient lastCreatedDelegate =
      CapturingWebChromeClient(
        onJsConfirm: (_, __, ___, ____) async => false,
        onShowFileChooser: (_, __, ___) async => <String>[],
      );
}

// Records the last created instance of itself.
class CapturingDownloadListener extends android_webview.DownloadListener {
  CapturingDownloadListener({required super.onDownloadStart})
    : super.pigeon_detached() {
    lastCreatedListener = this;
  }

  static CapturingDownloadListener lastCreatedListener =
      CapturingDownloadListener(
        onDownloadStart: (_, __, ___, ____, _____, ______) {},
      );
}

class TestWebView extends android_webview.WebView {
  TestWebView() : super.pigeon_detached();
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_android/src/android_proxy.dart';
import 'package:webview_flutter_android/src/android_webview.dart'
    as android_webview;
import 'package:webview_flutter_android/src/android_webview_api_impls.dart';
import 'package:webview_flutter_android/src/instance_manager.dart';
import 'package:webview_flutter_android/src/platform_views_service_proxy.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'android_navigation_delegate_test.dart';
import 'android_webview_controller_test.mocks.dart';
import 'android_webview_test.mocks.dart'
    show
        MockTestCustomViewCallbackHostApi,
        MockTestGeolocationPermissionsCallbackHostApi;
import 'test_android_webview.g.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<AndroidNavigationDelegate>(),
  MockSpec<AndroidWebViewController>(),
  MockSpec<AndroidWebViewProxy>(),
  MockSpec<AndroidWebViewWidgetCreationParams>(),
  MockSpec<ExpensiveAndroidViewController>(),
  MockSpec<android_webview.FlutterAssetManager>(),
  MockSpec<android_webview.JavaScriptChannel>(),
  MockSpec<android_webview.PermissionRequest>(),
  MockSpec<PlatformViewsServiceProxy>(),
  MockSpec<SurfaceAndroidViewController>(),
  MockSpec<android_webview.WebChromeClient>(),
  MockSpec<android_webview.WebSettings>(),
  MockSpec<android_webview.WebView>(),
  MockSpec<android_webview.WebViewClient>(),
  MockSpec<android_webview.WebStorage>(),
  MockSpec<InstanceManager>(),
  MockSpec<TestInstanceManagerHostApi>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  AndroidWebViewController createControllerWithMocks({
    android_webview.FlutterAssetManager? mockFlutterAssetManager,
    android_webview.JavaScriptChannel? mockJavaScriptChannel,
    android_webview.WebChromeClient Function({
      void Function(android_webview.WebView webView, int progress)?
          onProgressChanged,
      Future<List<String>> Function(
        android_webview.WebView webView,
        android_webview.FileChooserParams params,
      )? onShowFileChooser,
      android_webview.GeolocationPermissionsShowPrompt?
          onGeolocationPermissionsShowPrompt,
      android_webview.GeolocationPermissionsHidePrompt?
          onGeolocationPermissionsHidePrompt,
      void Function(
        android_webview.WebChromeClient instance,
        android_webview.PermissionRequest request,
      )? onPermissionRequest,
      void Function(
              android_webview.WebChromeClient instance,
              android_webview.View view,
              android_webview.CustomViewCallback callback)?
          onShowCustomView,
      void Function(android_webview.WebChromeClient instance)? onHideCustomView,
      void Function(android_webview.WebChromeClient instance,
              android_webview.ConsoleMessage message)?
          onConsoleMessage,
      Future<void> Function(String url, String message)? onJsAlert,
      Future<bool> Function(String url, String message)? onJsConfirm,
      Future<String> Function(String url, String message, String defaultValue)?
          onJsPrompt,
    })? createWebChromeClient,
    android_webview.WebView? mockWebView,
    android_webview.WebViewClient? mockWebViewClient,
    android_webview.WebStorage? mockWebStorage,
    android_webview.WebSettings? mockSettings,
  }) {
    final android_webview.WebView nonNullMockWebView =
        mockWebView ?? MockWebView();

    final AndroidWebViewControllerCreationParams creationParams =
        AndroidWebViewControllerCreationParams(
            androidWebStorage: mockWebStorage ?? MockWebStorage(),
            androidWebViewProxy: AndroidWebViewProxy(
              createAndroidWebChromeClient: createWebChromeClient ??
                  ({
                    void Function(android_webview.WebView, int)?
                        onProgressChanged,
                    Future<List<String>> Function(
                      android_webview.WebView webView,
                      android_webview.FileChooserParams params,
                    )? onShowFileChooser,
                    void Function(
                      android_webview.WebChromeClient instance,
                      android_webview.PermissionRequest request,
                    )? onPermissionRequest,
                    Future<void> Function(
                      String origin,
                      android_webview.GeolocationPermissionsCallback callback,
                    )? onGeolocationPermissionsShowPrompt,
                    void Function(android_webview.WebChromeClient instance)?
                        onGeolocationPermissionsHidePrompt,
                    void Function(
                            android_webview.WebChromeClient instance,
                            android_webview.View view,
                            android_webview.CustomViewCallback callback)?
                        onShowCustomView,
                    void Function(android_webview.WebChromeClient instance)?
                        onHideCustomView,
                    void Function(android_webview.WebChromeClient instance,
                            android_webview.ConsoleMessage message)?
                        onConsoleMessage,
                    Future<void> Function(String url, String message)?
                        onJsAlert,
                    Future<bool> Function(String url, String message)?
                        onJsConfirm,
                    Future<String> Function(
                            String url, String message, String defaultValue)?
                        onJsPrompt,
                  }) =>
                      MockWebChromeClient(),
              createAndroidWebView: (
                      {dynamic Function(
                              int left, int top, int oldLeft, int oldTop)?
                          onScrollChanged}) =>
                  nonNullMockWebView,
              createAndroidWebViewClient: ({
                void Function(android_webview.WebView webView, String url)?
                    onPageFinished,
                void Function(android_webview.WebView webView, String url)?
                    onPageStarted,
                void Function(
                        android_webview.WebView webView,
                        android_webview.WebResourceRequest request,
                        android_webview.WebResourceResponse response)?
                    onReceivedHttpError,
                @Deprecated('Only called on Android version < 23.')
                void Function(
                  android_webview.WebView webView,
                  int errorCode,
                  String description,
                  String failingUrl,
                )? onReceivedError,
                void Function(
                  android_webview.WebView webView,
                  android_webview.HttpAuthHandler hander,
                  String host,
                  String realm,
                )? onReceivedHttpAuthRequest,
                void Function(
                  android_webview.WebView webView,
                  android_webview.WebResourceRequest request,
                  android_webview.WebResourceError error,
                )? onReceivedRequestError,
                void Function(
                  android_webview.WebView webView,
                  android_webview.WebResourceRequest request,
                )? requestLoading,
                void Function(android_webview.WebView webView, String url)?
                    urlLoading,
                void Function(
                  android_webview.WebView webView,
                  String url,
                  bool isReload,
                )? doUpdateVisitedHistory,
              }) =>
                  mockWebViewClient ?? MockWebViewClient(),
              createFlutterAssetManager: () =>
                  mockFlutterAssetManager ?? MockFlutterAssetManager(),
              createJavaScriptChannel: (
                String channelName, {
                required void Function(String) postMessage,
              }) =>
                  mockJavaScriptChannel ?? MockJavaScriptChannel(),
            ));

    when(nonNullMockWebView.settings)
        .thenReturn(mockSettings ?? MockWebSettings());

    return AndroidWebViewController(creationParams);
  }

  group('AndroidWebViewController', () {
    AndroidJavaScriptChannelParams
        createAndroidJavaScriptChannelParamsWithMocks({
      String? name,
      MockJavaScriptChannel? mockJavaScriptChannel,
    }) {
      return AndroidJavaScriptChannelParams(
          name: name ?? 'test',
          onMessageReceived: (JavaScriptMessage message) {},
          webViewProxy: AndroidWebViewProxy(
            createJavaScriptChannel: (
              String channelName, {
              required void Function(String) postMessage,
            }) =>
                mockJavaScriptChannel ?? MockJavaScriptChannel(),
          ));
    }

    test('loadFile without file prefix', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockWebSettings = MockWebSettings();
      createControllerWithMocks(
        mockWebView: mockWebView,
        mockSettings: mockWebSettings,
      );

      verify(mockWebSettings.setBuiltInZoomControls(true)).called(1);
      verify(mockWebSettings.setDisplayZoomControls(false)).called(1);
      verify(mockWebSettings.setDomStorageEnabled(true)).called(1);
      verify(mockWebSettings.setJavaScriptCanOpenWindowsAutomatically(true))
          .called(1);
      verify(mockWebSettings.setLoadWithOverviewMode(true)).called(1);
      verify(mockWebSettings.setSupportMultipleWindows(true)).called(1);
      verify(mockWebSettings.setUseWideViewPort(true)).called(1);
    });

    test('loadFile without file prefix', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockWebSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
        mockSettings: mockWebSettings,
      );

      await controller.loadFile('/path/to/file.html');

      verify(mockWebSettings.setAllowFileAccess(true)).called(1);
      verify(mockWebView.loadUrl(
        'file:///path/to/file.html',
        <String, String>{},
      )).called(1);
    });

    test('loadFile without file prefix and characters to be escaped', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockWebSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
        mockSettings: mockWebSettings,
      );

      await controller.loadFile('/path/to/?_<_>_.html');

      verify(mockWebSettings.setAllowFileAccess(true)).called(1);
      verify(mockWebView.loadUrl(
        'file:///path/to/%3F_%3C_%3E_.html',
        <String, String>{},
      )).called(1);
    });

    test('loadFile with file prefix', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockWebSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.settings).thenReturn(mockWebSettings);

      await controller.loadFile('file:///path/to/file.html');

      verify(mockWebSettings.setAllowFileAccess(true)).called(1);
      verify(mockWebView.loadUrl(
        'file:///path/to/file.html',
        <String, String>{},
      )).called(1);
    });

    test('loadFlutterAsset when asset does not exist', () async {
      final MockWebView mockWebView = MockWebView();
      final MockFlutterAssetManager mockAssetManager =
          MockFlutterAssetManager();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockFlutterAssetManager: mockAssetManager,
        mockWebView: mockWebView,
      );

      when(mockAssetManager.getAssetFilePathByName('mock_key'))
          .thenAnswer((_) => Future<String>.value(''));
      when(mockAssetManager.list(''))
          .thenAnswer((_) => Future<List<String>>.value(<String>[]));

      try {
        await controller.loadFlutterAsset('mock_key');
        fail('Expected an `ArgumentError`.');
      } on ArgumentError catch (e) {
        expect(e.message, 'Asset for key "mock_key" not found.');
        expect(e.name, 'key');
      } on Error {
        fail('Expect an `ArgumentError`.');
      }

      verify(mockAssetManager.getAssetFilePathByName('mock_key')).called(1);
      verify(mockAssetManager.list('')).called(1);
      verifyNever(mockWebView.loadUrl(any, any));
    });

    test('loadFlutterAsset when asset does exists', () async {
      final MockWebView mockWebView = MockWebView();
      final MockFlutterAssetManager mockAssetManager =
          MockFlutterAssetManager();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockFlutterAssetManager: mockAssetManager,
        mockWebView: mockWebView,
      );

      when(mockAssetManager.getAssetFilePathByName('mock_key'))
          .thenAnswer((_) => Future<String>.value('www/mock_file.html'));
      when(mockAssetManager.list('www')).thenAnswer(
          (_) => Future<List<String>>.value(<String>['mock_file.html']));

      await controller.loadFlutterAsset('mock_key');

      verify(mockAssetManager.getAssetFilePathByName('mock_key')).called(1);
      verify(mockAssetManager.list('www')).called(1);
      verify(mockWebView.loadUrl(
          'file:///android_asset/www/mock_file.html', <String, String>{}));
    });

    test(
        'loadFlutterAsset when asset name contains characters that should be escaped',
        () async {
      final MockWebView mockWebView = MockWebView();
      final MockFlutterAssetManager mockAssetManager =
          MockFlutterAssetManager();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockFlutterAssetManager: mockAssetManager,
        mockWebView: mockWebView,
      );

      when(mockAssetManager.getAssetFilePathByName('mock_key'))
          .thenAnswer((_) => Future<String>.value('www/?_<_>_.html'));
      when(mockAssetManager.list('www')).thenAnswer(
          (_) => Future<List<String>>.value(<String>['?_<_>_.html']));

      await controller.loadFlutterAsset('mock_key');

      verify(mockAssetManager.getAssetFilePathByName('mock_key')).called(1);
      verify(mockAssetManager.list('www')).called(1);
      verify(mockWebView.loadUrl(
          'file:///android_asset/www/%3F_%3C_%3E_.html', <String, String>{}));
    });

    test('loadHtmlString without baseUrl', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.loadHtmlString('<p>Hello Test!</p>');

      verify(mockWebView.loadDataWithBaseUrl(
        data: '<p>Hello Test!</p>',
        mimeType: 'text/html',
      )).called(1);
    });

    test('loadHtmlString with baseUrl', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.loadHtmlString('<p>Hello Test!</p>',
          baseUrl: 'https://flutter.dev');

      verify(mockWebView.loadDataWithBaseUrl(
        data: '<p>Hello Test!</p>',
        baseUrl: 'https://flutter.dev',
        mimeType: 'text/html',
      )).called(1);
    });

    test('loadRequest without URI scheme', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      final LoadRequestParams requestParams = LoadRequestParams(
        uri: Uri.parse('flutter.dev'),
      );

      try {
        await controller.loadRequest(requestParams);
        fail('Expect an `ArgumentError`.');
      } on ArgumentError catch (e) {
        expect(e.message, 'WebViewRequest#uri is required to have a scheme.');
      } on Error {
        fail('Expect a `ArgumentError`.');
      }

      verifyNever(mockWebView.loadUrl(any, any));
      verifyNever(mockWebView.postUrl(any, any));
    });

    test('loadRequest using the GET method', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      final LoadRequestParams requestParams = LoadRequestParams(
        uri: Uri.parse('https://flutter.dev'),
        headers: const <String, String>{'X-Test': 'Testing'},
      );

      await controller.loadRequest(requestParams);

      verify(mockWebView.loadUrl(
        'https://flutter.dev',
        <String, String>{'X-Test': 'Testing'},
      ));
      verifyNever(mockWebView.postUrl(any, any));
    });

    test('loadRequest using the POST method without body', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      final LoadRequestParams requestParams = LoadRequestParams(
        uri: Uri.parse('https://flutter.dev'),
        method: LoadRequestMethod.post,
        headers: const <String, String>{'X-Test': 'Testing'},
      );

      await controller.loadRequest(requestParams);

      verify(mockWebView.postUrl(
        'https://flutter.dev',
        Uint8List(0),
      ));
      verifyNever(mockWebView.loadUrl(any, any));
    });

    test('loadRequest using the POST method with body', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      final LoadRequestParams requestParams = LoadRequestParams(
        uri: Uri.parse('https://flutter.dev'),
        method: LoadRequestMethod.post,
        headers: const <String, String>{'X-Test': 'Testing'},
        body: Uint8List.fromList('{"message": "Hello World!"}'.codeUnits),
      );

      await controller.loadRequest(requestParams);

      verify(mockWebView.postUrl(
        'https://flutter.dev',
        Uint8List.fromList('{"message": "Hello World!"}'.codeUnits),
      ));
      verifyNever(mockWebView.loadUrl(any, any));
    });

    test('currentUrl', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.currentUrl();

      verify(mockWebView.getUrl()).called(1);
    });

    test('canGoBack', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.canGoBack();

      verify(mockWebView.canGoBack()).called(1);
    });

    test('canGoForward', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.canGoForward();

      verify(mockWebView.canGoForward()).called(1);
    });

    test('goBack', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.goBack();

      verify(mockWebView.goBack()).called(1);
    });

    test('goForward', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.goForward();

      verify(mockWebView.goForward()).called(1);
    });

    test('reload', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.reload();

      verify(mockWebView.reload()).called(1);
    });

    test('clearCache', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.clearCache();

      verify(mockWebView.clearCache(true)).called(1);
    });

    test('clearLocalStorage', () async {
      final MockWebStorage mockWebStorage = MockWebStorage();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebStorage: mockWebStorage,
      );

      await controller.clearLocalStorage();

      verify(mockWebStorage.deleteAllData()).called(1);
    });

    test('setPlatformNavigationDelegate', () async {
      final MockAndroidNavigationDelegate mockNavigationDelegate =
          MockAndroidNavigationDelegate();
      final MockWebView mockWebView = MockWebView();
      final MockWebChromeClient mockWebChromeClient = MockWebChromeClient();
      final MockWebViewClient mockWebViewClient = MockWebViewClient();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockNavigationDelegate.androidWebChromeClient)
          .thenReturn(mockWebChromeClient);
      when(mockNavigationDelegate.androidWebViewClient)
          .thenReturn(mockWebViewClient);

      await controller.setPlatformNavigationDelegate(mockNavigationDelegate);

      verify(mockWebView.setWebViewClient(mockWebViewClient));
      verifyNever(mockWebView.setWebChromeClient(mockWebChromeClient));
    });

    test('onProgress', () {
      final AndroidNavigationDelegate androidNavigationDelegate =
          AndroidNavigationDelegate(
        AndroidNavigationDelegateCreationParams
            .fromPlatformNavigationDelegateCreationParams(
          const PlatformNavigationDelegateCreationParams(),
          androidWebViewProxy: const AndroidWebViewProxy(
            createAndroidWebViewClient: android_webview.WebViewClient.detached,
            createAndroidWebChromeClient:
                android_webview.WebChromeClient.detached,
            createDownloadListener: android_webview.DownloadListener.detached,
          ),
        ),
      );

      late final int callbackProgress;
      androidNavigationDelegate
          .setOnProgress((int progress) => callbackProgress = progress);

      final AndroidWebViewController controller = createControllerWithMocks(
        createWebChromeClient: CapturingWebChromeClient.new,
      );
      controller.setPlatformNavigationDelegate(androidNavigationDelegate);

      CapturingWebChromeClient.lastCreatedDelegate.onProgressChanged!(
        android_webview.WebView.detached(),
        42,
      );

      expect(callbackProgress, 42);
    });

    test('onProgress does not cause LateInitializationError', () {
      // ignore: unused_local_variable
      final AndroidWebViewController controller = createControllerWithMocks(
        createWebChromeClient: CapturingWebChromeClient.new,
      );

      // Should not cause LateInitializationError
      CapturingWebChromeClient.lastCreatedDelegate.onProgressChanged!(
        android_webview.WebView.detached(),
        42,
      );
    });

    test('setOnShowFileSelector', () async {
      late final Future<List<String>> Function(
        android_webview.WebView webView,
        android_webview.FileChooserParams params,
      ) onShowFileChooserCallback;
      final MockWebChromeClient mockWebChromeClient = MockWebChromeClient();
      final AndroidWebViewController controller = createControllerWithMocks(
        createWebChromeClient: ({
          dynamic onProgressChanged,
          Future<List<String>> Function(
            android_webview.WebView webView,
            android_webview.FileChooserParams params,
          )? onShowFileChooser,
          dynamic onGeolocationPermissionsShowPrompt,
          dynamic onGeolocationPermissionsHidePrompt,
          dynamic onPermissionRequest,
          dynamic onShowCustomView,
          dynamic onHideCustomView,
          dynamic onConsoleMessage,
          dynamic onJsAlert,
          dynamic onJsConfirm,
          dynamic onJsPrompt,
        }) {
          onShowFileChooserCallback = onShowFileChooser!;
          return mockWebChromeClient;
        },
      );

      late final FileSelectorParams fileSelectorParams;
      await controller.setOnShowFileSelector(
        (FileSelectorParams params) async {
          fileSelectorParams = params;
          return <String>[];
        },
      );

      verify(
        mockWebChromeClient.setSynchronousReturnValueForOnShowFileChooser(true),
      );

      await onShowFileChooserCallback(
        android_webview.WebView.detached(),
        android_webview.FileChooserParams.detached(
          isCaptureEnabled: false,
          acceptTypes: const <String>['png'],
          filenameHint: 'filenameHint',
          mode: android_webview.FileChooserMode.open,
        ),
      );

      expect(fileSelectorParams.isCaptureEnabled, isFalse);
      expect(fileSelectorParams.acceptTypes, <String>['png']);
      expect(fileSelectorParams.filenameHint, 'filenameHint');
      expect(fileSelectorParams.mode, FileSelectorMode.open);
    });

    test('setGeolocationPermissionsPromptCallbacks', () async {
      final MockTestGeolocationPermissionsCallbackHostApi mockApi =
          MockTestGeolocationPermissionsCallbackHostApi();
      TestGeolocationPermissionsCallbackHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final android_webview.GeolocationPermissionsCallback testCallback =
          android_webview.GeolocationPermissionsCallback.detached(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(testCallback, instanceIdentifier);

      late final Future<void> Function(String origin,
              android_webview.GeolocationPermissionsCallback callback)
          onGeoPermissionHandle;
      late final void Function(android_webview.WebChromeClient instance)
          onGeoPermissionHidePromptHandle;

      final MockWebChromeClient mockWebChromeClient = MockWebChromeClient();
      final AndroidWebViewController controller = createControllerWithMocks(
        createWebChromeClient: ({
          dynamic onProgressChanged,
          dynamic onShowFileChooser,
          Future<void> Function(String origin,
                  android_webview.GeolocationPermissionsCallback callback)?
              onGeolocationPermissionsShowPrompt,
          void Function(android_webview.WebChromeClient instance)?
              onGeolocationPermissionsHidePrompt,
          dynamic onPermissionRequest,
          dynamic onShowCustomView,
          dynamic onHideCustomView,
          dynamic onConsoleMessage,
          dynamic onJsAlert,
          dynamic onJsConfirm,
          dynamic onJsPrompt,
        }) {
          onGeoPermissionHandle = onGeolocationPermissionsShowPrompt!;
          onGeoPermissionHidePromptHandle = onGeolocationPermissionsHidePrompt!;
          return mockWebChromeClient;
        },
      );

      String testValue = 'origin';
      const String allowOrigin = 'https://www.allow.com';
      bool isAllow = false;

      late final GeolocationPermissionsResponse response;
      await controller.setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (GeolocationPermissionsRequestParams request) async {
          isAllow = request.origin == allowOrigin;
          response =
              GeolocationPermissionsResponse(allow: isAllow, retain: isAllow);
          return response;
        },
        onHidePrompt: () {
          testValue = 'changed';
        },
      );

      await onGeoPermissionHandle(
        allowOrigin,
        testCallback,
      );

      expect(isAllow, true);

      onGeoPermissionHidePromptHandle(mockWebChromeClient);
      expect(testValue, 'changed');
    });

    test('setCustomViewCallbacks', () async {
      final MockTestCustomViewCallbackHostApi mockApi =
          MockTestCustomViewCallbackHostApi();
      TestCustomViewCallbackHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final android_webview.CustomViewCallback testCallback =
          android_webview.CustomViewCallback.detached(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(testCallback, instanceIdentifier);

      late final void Function(
          android_webview.WebChromeClient instance,
          android_webview.View view,
          android_webview.CustomViewCallback callback) onShowCustomViewHandle;
      late final void Function(android_webview.WebChromeClient instance)
          onHideCustomViewHandle;

      final MockWebChromeClient mockWebChromeClient = MockWebChromeClient();
      final AndroidWebViewController controller = createControllerWithMocks(
        createWebChromeClient: ({
          dynamic onProgressChanged,
          dynamic onShowFileChooser,
          dynamic onGeolocationPermissionsShowPrompt,
          dynamic onGeolocationPermissionsHidePrompt,
          dynamic onPermissionRequest,
          dynamic onJsAlert,
          dynamic onJsConfirm,
          dynamic onJsPrompt,
          void Function(
                  android_webview.WebChromeClient instance,
                  android_webview.View view,
                  android_webview.CustomViewCallback callback)?
              onShowCustomView,
          void Function(android_webview.WebChromeClient instance)?
              onHideCustomView,
          dynamic onConsoleMessage,
        }) {
          onShowCustomViewHandle = onShowCustomView!;
          onHideCustomViewHandle = onHideCustomView!;
          return mockWebChromeClient;
        },
      );

      final android_webview.View testView = android_webview.View.detached();
      bool showCustomViewCalled = false;
      bool hideCustomViewCalled = false;

      await controller.setCustomWidgetCallbacks(
        onShowCustomWidget:
            (Widget widget, OnHideCustomWidgetCallback callback) async {
          showCustomViewCalled = true;
        },
        onHideCustomWidget: () {
          hideCustomViewCalled = true;
        },
      );

      onShowCustomViewHandle(
        mockWebChromeClient,
        testView,
        android_webview.CustomViewCallback.detached(),
      );

      expect(showCustomViewCalled, true);

      onHideCustomViewHandle(mockWebChromeClient);
      expect(hideCustomViewCalled, true);
    });

    test('setOnPlatformPermissionRequest', () async {
      late final void Function(
        android_webview.WebChromeClient instance,
        android_webview.PermissionRequest request,
      ) onPermissionRequestCallback;

      final MockWebChromeClient mockWebChromeClient = MockWebChromeClient();
      final AndroidWebViewController controller = createControllerWithMocks(
        createWebChromeClient: ({
          dynamic onProgressChanged,
          dynamic onShowFileChooser,
          dynamic onGeolocationPermissionsShowPrompt,
          dynamic onGeolocationPermissionsHidePrompt,
          void Function(
            android_webview.WebChromeClient instance,
            android_webview.PermissionRequest request,
          )? onPermissionRequest,
          dynamic onShowCustomView,
          dynamic onHideCustomView,
          dynamic onConsoleMessage,
          dynamic onJsAlert,
          dynamic onJsConfirm,
          dynamic onJsPrompt,
        }) {
          onPermissionRequestCallback = onPermissionRequest!;
          return mockWebChromeClient;
        },
      );

      late final PlatformWebViewPermissionRequest permissionRequest;
      await controller.setOnPlatformPermissionRequest(
        (PlatformWebViewPermissionRequest request) async {
          permissionRequest = request;
          await request.grant();
        },
      );

      final List<String> permissionTypes = <String>[
        android_webview.PermissionRequest.audioCapture,
      ];

      final MockPermissionRequest mockPermissionRequest =
          MockPermissionRequest();
      when(mockPermissionRequest.resources).thenReturn(permissionTypes);

      onPermissionRequestCallback(
        android_webview.WebChromeClient.detached(),
        mockPermissionRequest,
      );

      expect(permissionRequest.types, <WebViewPermissionResourceType>[
        WebViewPermissionResourceType.microphone,
      ]);
      verify(mockPermissionRequest.grant(permissionTypes));
    });

    test(
        'setOnPlatformPermissionRequest callback not invoked when type is not recognized',
        () async {
      late final void Function(
        android_webview.WebChromeClient instance,
        android_webview.PermissionRequest request,
      ) onPermissionRequestCallback;

      final MockWebChromeClient mockWebChromeClient = MockWebChromeClient();
      final AndroidWebViewController controller = createControllerWithMocks(
        createWebChromeClient: ({
          dynamic onProgressChanged,
          dynamic onShowFileChooser,
          dynamic onGeolocationPermissionsShowPrompt,
          dynamic onGeolocationPermissionsHidePrompt,
          void Function(
            android_webview.WebChromeClient instance,
            android_webview.PermissionRequest request,
          )? onPermissionRequest,
          dynamic onShowCustomView,
          dynamic onHideCustomView,
          dynamic onConsoleMessage,
          dynamic onJsAlert,
          dynamic onJsConfirm,
          dynamic onJsPrompt,
        }) {
          onPermissionRequestCallback = onPermissionRequest!;
          return mockWebChromeClient;
        },
      );

      bool callbackCalled = false;
      await controller.setOnPlatformPermissionRequest(
        (PlatformWebViewPermissionRequest request) async {
          callbackCalled = true;
        },
      );

      final MockPermissionRequest mockPermissionRequest =
          MockPermissionRequest();
      when(mockPermissionRequest.resources).thenReturn(<String>['unknownType']);

      onPermissionRequestCallback(
        android_webview.WebChromeClient.detached(),
        mockPermissionRequest,
      );

      expect(callbackCalled, isFalse);
    });

    group('JavaScript Dialog', () {
      test('setOnJavaScriptAlertDialog', () async {
        late final Future<void> Function(String url, String message)
            onJsAlertCallback;

        final MockWebChromeClient mockWebChromeClient = MockWebChromeClient();

        final AndroidWebViewController controller = createControllerWithMocks(
          createWebChromeClient: ({
            dynamic onProgressChanged,
            dynamic onShowFileChooser,
            dynamic onGeolocationPermissionsShowPrompt,
            dynamic onGeolocationPermissionsHidePrompt,
            dynamic onPermissionRequest,
            dynamic onShowCustomView,
            dynamic onHideCustomView,
            Future<void> Function(String url, String message)? onJsAlert,
            dynamic onJsConfirm,
            dynamic onJsPrompt,
            dynamic onConsoleMessage,
          }) {
            onJsAlertCallback = onJsAlert!;
            return mockWebChromeClient;
          },
        );

        late final String message;
        await controller.setOnJavaScriptAlertDialog(
            (JavaScriptAlertDialogRequest request) async {
          message = request.message;
          return;
        });

        const String callbackMessage = 'Message';
        await onJsAlertCallback('', callbackMessage);
        expect(message, callbackMessage);
      });

      test('setOnJavaScriptConfirmDialog', () async {
        late final Future<bool> Function(String url, String message)
            onJsConfirmCallback;

        final MockWebChromeClient mockWebChromeClient = MockWebChromeClient();

        final AndroidWebViewController controller = createControllerWithMocks(
          createWebChromeClient: ({
            dynamic onProgressChanged,
            dynamic onShowFileChooser,
            dynamic onGeolocationPermissionsShowPrompt,
            dynamic onGeolocationPermissionsHidePrompt,
            dynamic onPermissionRequest,
            dynamic onShowCustomView,
            dynamic onHideCustomView,
            dynamic onJsAlert,
            Future<bool> Function(String url, String message)? onJsConfirm,
            dynamic onJsPrompt,
            dynamic onConsoleMessage,
          }) {
            onJsConfirmCallback = onJsConfirm!;
            return mockWebChromeClient;
          },
        );

        late final String message;
        const bool callbackReturnValue = true;
        await controller.setOnJavaScriptConfirmDialog(
            (JavaScriptConfirmDialogRequest request) async {
          message = request.message;
          return callbackReturnValue;
        });

        const String callbackMessage = 'Message';
        final bool returnValue = await onJsConfirmCallback('', callbackMessage);

        expect(message, callbackMessage);
        expect(returnValue, callbackReturnValue);
      });

      test('setOnJavaScriptTextInputDialog', () async {
        late final Future<String> Function(
            String url, String message, String defaultValue) onJsPromptCallback;
        final MockWebChromeClient mockWebChromeClient = MockWebChromeClient();

        final AndroidWebViewController controller = createControllerWithMocks(
          createWebChromeClient: ({
            dynamic onProgressChanged,
            dynamic onShowFileChooser,
            dynamic onGeolocationPermissionsShowPrompt,
            dynamic onGeolocationPermissionsHidePrompt,
            dynamic onPermissionRequest,
            dynamic onShowCustomView,
            dynamic onHideCustomView,
            dynamic onJsAlert,
            dynamic onJsConfirm,
            Future<String> Function(
                    String url, String message, String defaultText)?
                onJsPrompt,
            dynamic onConsoleMessage,
          }) {
            onJsPromptCallback = onJsPrompt!;
            return mockWebChromeClient;
          },
        );

        late final String message;
        late final String? defaultText;
        const String callbackReturnValue = 'Return Value';
        await controller.setOnJavaScriptTextInputDialog(
            (JavaScriptTextInputDialogRequest request) async {
          message = request.message;
          defaultText = request.defaultText;
          return callbackReturnValue;
        });

        const String callbackMessage = 'Message';
        const String callbackDefaultText = 'Default Text';

        final String returnValue =
            await onJsPromptCallback('', callbackMessage, callbackDefaultText);

        expect(message, callbackMessage);
        expect(defaultText, callbackDefaultText);
        expect(returnValue, callbackReturnValue);
      });
    });

    test('setOnConsoleLogCallback', () async {
      late final void Function(
        android_webview.WebChromeClient instance,
        android_webview.ConsoleMessage message,
      ) onConsoleMessageCallback;

      final MockWebChromeClient mockWebChromeClient = MockWebChromeClient();
      final AndroidWebViewController controller = createControllerWithMocks(
        createWebChromeClient: ({
          dynamic onProgressChanged,
          dynamic onShowFileChooser,
          dynamic onGeolocationPermissionsShowPrompt,
          dynamic onGeolocationPermissionsHidePrompt,
          dynamic onPermissionRequest,
          dynamic onShowCustomView,
          dynamic onHideCustomView,
          dynamic onJsAlert,
          dynamic onJsConfirm,
          dynamic onJsPrompt,
          void Function(
            android_webview.WebChromeClient,
            android_webview.ConsoleMessage,
          )? onConsoleMessage,
        }) {
          onConsoleMessageCallback = onConsoleMessage!;
          return mockWebChromeClient;
        },
      );

      final Map<String, JavaScriptLogLevel> logs =
          <String, JavaScriptLogLevel>{};
      await controller.setOnConsoleMessage(
        (JavaScriptConsoleMessage message) async {
          logs[message.message] = message.level;
        },
      );

      onConsoleMessageCallback(
        mockWebChromeClient,
        ConsoleMessage(
          lineNumber: 42,
          message: 'Debug message',
          level: ConsoleMessageLevel.debug,
          sourceId: 'source',
        ),
      );
      onConsoleMessageCallback(
        mockWebChromeClient,
        ConsoleMessage(
          lineNumber: 42,
          message: 'Error message',
          level: ConsoleMessageLevel.error,
          sourceId: 'source',
        ),
      );
      onConsoleMessageCallback(
        mockWebChromeClient,
        ConsoleMessage(
          lineNumber: 42,
          message: 'Log message',
          level: ConsoleMessageLevel.log,
          sourceId: 'source',
        ),
      );
      onConsoleMessageCallback(
        mockWebChromeClient,
        ConsoleMessage(
          lineNumber: 42,
          message: 'Tip message',
          level: ConsoleMessageLevel.tip,
          sourceId: 'source',
        ),
      );
      onConsoleMessageCallback(
        mockWebChromeClient,
        ConsoleMessage(
          lineNumber: 42,
          message: 'Warning message',
          level: ConsoleMessageLevel.warning,
          sourceId: 'source',
        ),
      );
      onConsoleMessageCallback(
        mockWebChromeClient,
        ConsoleMessage(
          lineNumber: 42,
          message: 'Unknown message',
          level: ConsoleMessageLevel.unknown,
          sourceId: 'source',
        ),
      );

      expect(logs.length, 6);
      expect(logs['Debug message'], JavaScriptLogLevel.debug);
      expect(logs['Error message'], JavaScriptLogLevel.error);
      expect(logs['Log message'], JavaScriptLogLevel.log);
      expect(logs['Tip message'], JavaScriptLogLevel.debug);
      expect(logs['Warning message'], JavaScriptLogLevel.warning);
      expect(logs['Unknown message'], JavaScriptLogLevel.log);
    });

    test('runJavaScript', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.runJavaScript('alert("This is a test.");');

      verify(mockWebView.evaluateJavascript('alert("This is a test.");'))
          .called(1);
    });

    test('runJavaScriptReturningResult with return value', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.evaluateJavascript('return "Hello" + " World!";'))
          .thenAnswer((_) => Future<String>.value('Hello World!'));

      final String message = await controller.runJavaScriptReturningResult(
          'return "Hello" + " World!";') as String;

      expect(message, 'Hello World!');
    });

    test('runJavaScriptReturningResult returning null', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.evaluateJavascript('alert("This is a test.");'))
          .thenAnswer((_) => Future<String?>.value());

      final String message = await controller
          .runJavaScriptReturningResult('alert("This is a test.");') as String;

      expect(message, '');
    });

    test('runJavaScriptReturningResult parses num', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.evaluateJavascript('alert("This is a test.");'))
          .thenAnswer((_) => Future<String?>.value('3.14'));

      final num message = await controller
          .runJavaScriptReturningResult('alert("This is a test.");') as num;

      expect(message, 3.14);
    });

    test('runJavaScriptReturningResult parses true', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.evaluateJavascript('alert("This is a test.");'))
          .thenAnswer((_) => Future<String?>.value('true'));

      final bool message = await controller
          .runJavaScriptReturningResult('alert("This is a test.");') as bool;

      expect(message, true);
    });

    test('runJavaScriptReturningResult parses false', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      when(mockWebView.evaluateJavascript('alert("This is a test.");'))
          .thenAnswer((_) => Future<String?>.value('false'));

      final bool message = await controller
          .runJavaScriptReturningResult('alert("This is a test.");') as bool;

      expect(message, false);
    });

    test('addJavaScriptChannel', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      final AndroidJavaScriptChannelParams paramsWithMock =
          createAndroidJavaScriptChannelParamsWithMocks(name: 'test');
      await controller.addJavaScriptChannel(paramsWithMock);
      verify(mockWebView.addJavaScriptChannel(
              argThat(isA<android_webview.JavaScriptChannel>())))
          .called(1);
    });

    test(
        'addJavaScriptChannel add channel with same name should remove existing channel',
        () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      final AndroidJavaScriptChannelParams paramsWithMock =
          createAndroidJavaScriptChannelParamsWithMocks(name: 'test');
      await controller.addJavaScriptChannel(paramsWithMock);
      verify(mockWebView.addJavaScriptChannel(
              argThat(isA<android_webview.JavaScriptChannel>())))
          .called(1);

      await controller.addJavaScriptChannel(paramsWithMock);
      verifyInOrder(<Object>[
        mockWebView.removeJavaScriptChannel(
            argThat(isA<android_webview.JavaScriptChannel>())),
        mockWebView.addJavaScriptChannel(
            argThat(isA<android_webview.JavaScriptChannel>())),
      ]);
    });

    test('removeJavaScriptChannel when channel is not registered', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.removeJavaScriptChannel('test');
      verifyNever(mockWebView.removeJavaScriptChannel(any));
    });

    test('removeJavaScriptChannel when channel exists', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      final AndroidJavaScriptChannelParams paramsWithMock =
          createAndroidJavaScriptChannelParamsWithMocks(name: 'test');

      // Make sure channel exists before removing it.
      await controller.addJavaScriptChannel(paramsWithMock);
      verify(mockWebView.addJavaScriptChannel(
              argThat(isA<android_webview.JavaScriptChannel>())))
          .called(1);

      await controller.removeJavaScriptChannel('test');
      verify(mockWebView.removeJavaScriptChannel(
              argThat(isA<android_webview.JavaScriptChannel>())))
          .called(1);
    });

    test('getTitle', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.getTitle();

      verify(mockWebView.getTitle()).called(1);
    });

    test('scrollTo', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.scrollTo(4, 2);

      verify(mockWebView.scrollTo(4, 2)).called(1);
    });

    test('scrollBy', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.scrollBy(4, 2);

      verify(mockWebView.scrollBy(4, 2)).called(1);
    });

    test('getScrollPosition', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );
      when(mockWebView.getScrollPosition())
          .thenAnswer((_) => Future<Offset>.value(const Offset(4, 2)));

      final Offset position = await controller.getScrollPosition();

      verify(mockWebView.getScrollPosition()).called(1);
      expect(position.dx, 4);
      expect(position.dy, 2);
    });

    test('enableDebugging', () async {
      final MockAndroidWebViewProxy mockProxy = MockAndroidWebViewProxy();

      await AndroidWebViewController.enableDebugging(
        true,
        webViewProxy: mockProxy,
      );
      verify(mockProxy.setWebContentsDebuggingEnabled(true)).called(1);
    });

    test('enableZoom', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
        mockSettings: mockSettings,
      );

      clearInteractions(mockWebView);

      await controller.enableZoom(true);

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setSupportZoom(true)).called(1);
    });

    test('setBackgroundColor', () async {
      final MockWebView mockWebView = MockWebView();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.setBackgroundColor(Colors.blue);

      verify(mockWebView.setBackgroundColor(Colors.blue)).called(1);
    });

    test('setJavaScriptMode', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
        mockSettings: mockSettings,
      );

      clearInteractions(mockWebView);

      await controller.setJavaScriptMode(JavaScriptMode.disabled);

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setJavaScriptEnabled(false)).called(1);
    });

    test('setUserAgent', () async {
      final MockWebView mockWebView = MockWebView();
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
        mockSettings: mockSettings,
      );

      clearInteractions(mockWebView);

      await controller.setUserAgent('Test Framework');

      verify(mockWebView.settings).called(1);
      verify(mockSettings.setUserAgentString('Test Framework')).called(1);
    });

    test('getUserAgent', () async {
      final MockWebSettings mockSettings = MockWebSettings();
      final AndroidWebViewController controller = createControllerWithMocks(
        mockSettings: mockSettings,
      );

      const String userAgent = 'str';

      when(mockSettings.getUserAgentString())
          .thenAnswer((_) => Future<String>.value(userAgent));

      expect(await controller.getUserAgent(), userAgent);
    });
  });

  test('setMediaPlaybackRequiresUserGesture', () async {
    final MockWebView mockWebView = MockWebView();
    final MockWebSettings mockSettings = MockWebSettings();
    final AndroidWebViewController controller = createControllerWithMocks(
      mockWebView: mockWebView,
      mockSettings: mockSettings,
    );

    await controller.setMediaPlaybackRequiresUserGesture(true);

    verify(mockSettings.setMediaPlaybackRequiresUserGesture(true)).called(1);
  });

  test('setTextZoom', () async {
    final MockWebView mockWebView = MockWebView();
    final MockWebSettings mockSettings = MockWebSettings();
    final AndroidWebViewController controller = createControllerWithMocks(
      mockWebView: mockWebView,
      mockSettings: mockSettings,
    );

    clearInteractions(mockWebView);

    await controller.setTextZoom(100);

    verify(mockWebView.settings).called(1);
    verify(mockSettings.setTextZoom(100)).called(1);
  });

  test('webViewIdentifier', () {
    final MockWebView mockWebView = MockWebView();
    final InstanceManager instanceManager = InstanceManager(
      onWeakReferenceRemoved: (_) {},
    );
    instanceManager.addHostCreatedInstance(mockWebView, 0);

    android_webview.WebView.api = WebViewHostApiImpl(
      instanceManager: instanceManager,
    );

    final AndroidWebViewController controller = createControllerWithMocks(
      mockWebView: mockWebView,
    );

    expect(
      controller.webViewIdentifier,
      0,
    );

    android_webview.WebView.api = WebViewHostApiImpl();
  });

  group('AndroidWebViewWidget', () {
    testWidgets('Builds Android view using supplied parameters',
        (WidgetTester tester) async {
      final AndroidWebViewController controller = createControllerWithMocks();

      final AndroidWebViewWidget webViewWidget = AndroidWebViewWidget(
        AndroidWebViewWidgetCreationParams(
          key: const Key('test_web_view'),
          controller: controller,
        ),
      );

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) => webViewWidget.build(context),
      ));

      expect(find.byType(PlatformViewLink), findsOneWidget);
      expect(find.byKey(const Key('test_web_view')), findsOneWidget);
    });

    testWidgets('displayWithHybridComposition is false',
        (WidgetTester tester) async {
      final AndroidWebViewController controller = createControllerWithMocks();

      final MockPlatformViewsServiceProxy mockPlatformViewsService =
          MockPlatformViewsServiceProxy();

      when(
        mockPlatformViewsService.initSurfaceAndroidView(
          id: anyNamed('id'),
          viewType: anyNamed('viewType'),
          layoutDirection: anyNamed('layoutDirection'),
          creationParams: anyNamed('creationParams'),
          creationParamsCodec: anyNamed('creationParamsCodec'),
          onFocus: anyNamed('onFocus'),
        ),
      ).thenReturn(MockSurfaceAndroidViewController());

      final AndroidWebViewWidget webViewWidget = AndroidWebViewWidget(
        AndroidWebViewWidgetCreationParams(
          key: const Key('test_web_view'),
          controller: controller,
          platformViewsServiceProxy: mockPlatformViewsService,
        ),
      );

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) => webViewWidget.build(context),
      ));
      await tester.pumpAndSettle();

      verify(
        mockPlatformViewsService.initSurfaceAndroidView(
          id: anyNamed('id'),
          viewType: anyNamed('viewType'),
          layoutDirection: anyNamed('layoutDirection'),
          creationParams: anyNamed('creationParams'),
          creationParamsCodec: anyNamed('creationParamsCodec'),
          onFocus: anyNamed('onFocus'),
        ),
      );
    });

    testWidgets('displayWithHybridComposition is true',
        (WidgetTester tester) async {
      final AndroidWebViewController controller = createControllerWithMocks();

      final MockPlatformViewsServiceProxy mockPlatformViewsService =
          MockPlatformViewsServiceProxy();

      when(
        mockPlatformViewsService.initExpensiveAndroidView(
          id: anyNamed('id'),
          viewType: anyNamed('viewType'),
          layoutDirection: anyNamed('layoutDirection'),
          creationParams: anyNamed('creationParams'),
          creationParamsCodec: anyNamed('creationParamsCodec'),
          onFocus: anyNamed('onFocus'),
        ),
      ).thenReturn(MockExpensiveAndroidViewController());

      final AndroidWebViewWidget webViewWidget = AndroidWebViewWidget(
        AndroidWebViewWidgetCreationParams(
          key: const Key('test_web_view'),
          controller: controller,
          platformViewsServiceProxy: mockPlatformViewsService,
          displayWithHybridComposition: true,
        ),
      );

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) => webViewWidget.build(context),
      ));
      await tester.pumpAndSettle();

      verify(
        mockPlatformViewsService.initExpensiveAndroidView(
          id: anyNamed('id'),
          viewType: anyNamed('viewType'),
          layoutDirection: anyNamed('layoutDirection'),
          creationParams: anyNamed('creationParams'),
          creationParamsCodec: anyNamed('creationParamsCodec'),
          onFocus: anyNamed('onFocus'),
        ),
      );
    });

    testWidgets('default handling of custom views',
        (WidgetTester tester) async {
      final MockWebChromeClient mockWebChromeClient = MockWebChromeClient();

      void Function(
              android_webview.WebChromeClient instance,
              android_webview.View view,
              android_webview.CustomViewCallback callback)?
          onShowCustomViewCallback;

      final AndroidWebViewController controller = createControllerWithMocks(
        createWebChromeClient: ({
          dynamic onProgressChanged,
          dynamic onShowFileChooser,
          dynamic onGeolocationPermissionsShowPrompt,
          dynamic onGeolocationPermissionsHidePrompt,
          dynamic onPermissionRequest,
          void Function(
                  android_webview.WebChromeClient instance,
                  android_webview.View view,
                  android_webview.CustomViewCallback callback)?
              onShowCustomView,
          dynamic onHideCustomView,
          dynamic onConsoleMessage,
          dynamic onJsAlert,
          dynamic onJsConfirm,
          dynamic onJsPrompt,
        }) {
          onShowCustomViewCallback = onShowCustomView;
          return mockWebChromeClient;
        },
      );

      final MockPlatformViewsServiceProxy mockPlatformViewsService =
          MockPlatformViewsServiceProxy();

      when(
        mockPlatformViewsService.initSurfaceAndroidView(
          id: anyNamed('id'),
          viewType: anyNamed('viewType'),
          layoutDirection: anyNamed('layoutDirection'),
          creationParams: anyNamed('creationParams'),
          creationParamsCodec: anyNamed('creationParamsCodec'),
          onFocus: anyNamed('onFocus'),
        ),
      ).thenReturn(MockSurfaceAndroidViewController());

      final AndroidWebViewWidget webViewWidget = AndroidWebViewWidget(
        AndroidWebViewWidgetCreationParams(
          key: const Key('test_web_view'),
          controller: controller,
          platformViewsServiceProxy: mockPlatformViewsService,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) => webViewWidget.build(context),
          ),
        ),
      );
      await tester.pumpAndSettle();

      onShowCustomViewCallback!(
        MockWebChromeClient(),
        android_webview.WebView.detached(),
        android_webview.CustomViewCallback.detached(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AndroidCustomViewWidget), findsOneWidget);
    });

    testWidgets('PlatformView is recreated when the controller changes',
        (WidgetTester tester) async {
      final MockPlatformViewsServiceProxy mockPlatformViewsService =
          MockPlatformViewsServiceProxy();

      when(
        mockPlatformViewsService.initSurfaceAndroidView(
          id: anyNamed('id'),
          viewType: anyNamed('viewType'),
          layoutDirection: anyNamed('layoutDirection'),
          creationParams: anyNamed('creationParams'),
          creationParamsCodec: anyNamed('creationParamsCodec'),
          onFocus: anyNamed('onFocus'),
        ),
      ).thenReturn(MockSurfaceAndroidViewController());

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) {
          return AndroidWebViewWidget(
            AndroidWebViewWidgetCreationParams(
              controller: createControllerWithMocks(),
              platformViewsServiceProxy: mockPlatformViewsService,
            ),
          ).build(context);
        },
      ));
      await tester.pumpAndSettle();

      verify(
        mockPlatformViewsService.initSurfaceAndroidView(
          id: anyNamed('id'),
          viewType: anyNamed('viewType'),
          layoutDirection: anyNamed('layoutDirection'),
          creationParams: anyNamed('creationParams'),
          creationParamsCodec: anyNamed('creationParamsCodec'),
          onFocus: anyNamed('onFocus'),
        ),
      );

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) {
          return AndroidWebViewWidget(
            AndroidWebViewWidgetCreationParams(
              controller: createControllerWithMocks(),
              platformViewsServiceProxy: mockPlatformViewsService,
            ),
          ).build(context);
        },
      ));
      await tester.pumpAndSettle();

      verify(
        mockPlatformViewsService.initSurfaceAndroidView(
          id: anyNamed('id'),
          viewType: anyNamed('viewType'),
          layoutDirection: anyNamed('layoutDirection'),
          creationParams: anyNamed('creationParams'),
          creationParamsCodec: anyNamed('creationParamsCodec'),
          onFocus: anyNamed('onFocus'),
        ),
      );
    });

    testWidgets(
        'PlatformView does not rebuild when creation params stay the same',
        (WidgetTester tester) async {
      final MockPlatformViewsServiceProxy mockPlatformViewsService =
          MockPlatformViewsServiceProxy();

      final AndroidWebViewController controller = createControllerWithMocks();

      when(
        mockPlatformViewsService.initSurfaceAndroidView(
          id: anyNamed('id'),
          viewType: anyNamed('viewType'),
          layoutDirection: anyNamed('layoutDirection'),
          creationParams: anyNamed('creationParams'),
          creationParamsCodec: anyNamed('creationParamsCodec'),
          onFocus: anyNamed('onFocus'),
        ),
      ).thenReturn(MockSurfaceAndroidViewController());

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) {
          return AndroidWebViewWidget(
            AndroidWebViewWidgetCreationParams(
              controller: controller,
              platformViewsServiceProxy: mockPlatformViewsService,
            ),
          ).build(context);
        },
      ));
      await tester.pumpAndSettle();

      verify(
        mockPlatformViewsService.initSurfaceAndroidView(
          id: anyNamed('id'),
          viewType: anyNamed('viewType'),
          layoutDirection: anyNamed('layoutDirection'),
          creationParams: anyNamed('creationParams'),
          creationParamsCodec: anyNamed('creationParamsCodec'),
          onFocus: anyNamed('onFocus'),
        ),
      );

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) {
          return AndroidWebViewWidget(
            AndroidWebViewWidgetCreationParams(
              controller: controller,
              platformViewsServiceProxy: mockPlatformViewsService,
            ),
          ).build(context);
        },
      ));
      await tester.pumpAndSettle();

      verifyNever(
        mockPlatformViewsService.initSurfaceAndroidView(
          id: anyNamed('id'),
          viewType: anyNamed('viewType'),
          layoutDirection: anyNamed('layoutDirection'),
          creationParams: anyNamed('creationParams'),
          creationParamsCodec: anyNamed('creationParamsCodec'),
          onFocus: anyNamed('onFocus'),
        ),
      );
    });
  });

  group('AndroidCustomViewWidget', () {
    testWidgets('Builds Android custom view using supplied parameters',
        (WidgetTester tester) async {
      final AndroidWebViewController controller = createControllerWithMocks();

      final AndroidCustomViewWidget customViewWidget =
          AndroidCustomViewWidget.private(
        key: const Key('test_custom_view'),
        customView: android_webview.View.detached(),
        controller: controller,
      );

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) => customViewWidget.build(context),
      ));

      expect(find.byType(PlatformViewLink), findsOneWidget);
      expect(find.byKey(const Key('test_custom_view')), findsOneWidget);
    });

    testWidgets('displayWithHybridComposition should be false',
        (WidgetTester tester) async {
      final AndroidWebViewController controller = createControllerWithMocks();

      final MockPlatformViewsServiceProxy mockPlatformViewsService =
          MockPlatformViewsServiceProxy();

      when(
        mockPlatformViewsService.initSurfaceAndroidView(
          id: anyNamed('id'),
          viewType: anyNamed('viewType'),
          layoutDirection: anyNamed('layoutDirection'),
          creationParams: anyNamed('creationParams'),
          creationParamsCodec: anyNamed('creationParamsCodec'),
          onFocus: anyNamed('onFocus'),
        ),
      ).thenReturn(MockSurfaceAndroidViewController());

      final AndroidCustomViewWidget customViewWidget =
          AndroidCustomViewWidget.private(
        controller: controller,
        customView: android_webview.View.detached(),
        platformViewsServiceProxy: mockPlatformViewsService,
      );

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) => customViewWidget.build(context),
      ));
      await tester.pumpAndSettle();

      verify(
        mockPlatformViewsService.initSurfaceAndroidView(
          id: anyNamed('id'),
          viewType: anyNamed('viewType'),
          layoutDirection: anyNamed('layoutDirection'),
          creationParams: anyNamed('creationParams'),
          creationParamsCodec: anyNamed('creationParamsCodec'),
          onFocus: anyNamed('onFocus'),
        ),
      );
    });
  });
}

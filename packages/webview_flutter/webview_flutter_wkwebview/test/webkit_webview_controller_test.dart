// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit2.g.dart';
import 'package:webview_flutter_wkwebview/src/common/webkit_constants.dart';
import 'package:webview_flutter_wkwebview/src/webkit_proxy.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'webkit_webview_controller_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<UIScrollView>(),
  MockSpec<UIScrollViewDelegate>(),
  MockSpec<URL>(),
  MockSpec<URLRequest>(),
  MockSpec<WKPreferences>(),
  MockSpec<WKScriptMessageHandler>(),
  MockSpec<WKUserContentController>(),
  MockSpec<WKUserScript>(),
  MockSpec<WKWebView>(),
  MockSpec<WKWebViewConfiguration>(),
  MockSpec<WKWebViewUIExtensions>(),
  MockSpec<WKWebsiteDataStore>(),
])
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('WebKitWebViewController', () {
    WebKitWebViewController createControllerWithMocks({
      MockUIScrollView? mockScrollView,
      UIScrollViewDelegate? scrollViewDelegate,
      MockWKPreferences? mockPreferences,
      WKUIDelegate? uiDelegate,
      MockWKUserContentController? mockUserContentController,
      MockWKWebsiteDataStore? mockWebsiteDataStore,
      MockWKWebView Function(
        WKWebViewConfiguration configuration, {
        void Function(
          NSObject,
          String keyPath,
          NSObject object,
          Map<KeyValueChangeKey, Object?> change,
        )? observeValue,
      })? createMockWebView,
      MockWKWebViewConfiguration? mockWebViewConfiguration,
      MockURLRequest Function({required String url})? createURLRequest,
      PigeonInstanceManager? instanceManager,
    }) {
      final MockWKWebViewConfiguration nonNullMockWebViewConfiguration =
          mockWebViewConfiguration ?? MockWKWebViewConfiguration();
      late final MockWKWebView nonNullMockWebView;

      final PlatformWebViewControllerCreationParams controllerCreationParams =
          WebKitWebViewControllerCreationParams(
        webKitProxy: WebKitProxy(
          newWKWebViewConfiguration: (
              {PigeonInstanceManager? instanceManager}) {
            return nonNullMockWebViewConfiguration;
          },
          newWKWebView: ({
            required WKWebViewConfiguration initialConfiguration,
            void Function(
              NSObject,
              String,
              NSObject,
              Map<KeyValueChangeKey, Object?>,
            )? observeValue,
          }) {
            nonNullMockWebView = createMockWebView == null
                ? MockWKWebView()
                : createMockWebView(
                    nonNullMockWebViewConfiguration,
                    observeValue: observeValue,
                  );
            return nonNullMockWebView;
          },
          newWKUIDelegate: ({
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
            Future<String> Function(
              WKUIDelegate,
              String,
              String,
              WKFrameInfo,
            )? runJavaScriptTextInputPanel,
          }) {
            return uiDelegate ??
                CapturingUIDelegate(
                    onCreateWebView: onCreateWebView,
                    requestMediaCapturePermission:
                        requestMediaCapturePermission,
                    runJavaScriptAlertPanel: runJavaScriptAlertPanel,
                    runJavaScriptConfirmPanel: runJavaScriptConfirmPanel,
                    runJavaScriptTextInputPanel: runJavaScriptTextInputPanel);
          },
          newWKScriptMessageHandler: WKScriptMessageHandler.pigeon_detached,
          newUIScrollViewDelegate: ({
            void Function(
              UIScrollViewDelegate,
              UIScrollViewDelegate,
              double,
              double,
            )? scrollViewDidScroll,
          }) {
            return scrollViewDelegate ??
                CapturingUIScrollViewDelegate(
                  scrollViewDidScroll: scrollViewDidScroll,
                );
          },
          newURLRequest:
              createURLRequest ?? ({required String url}) => MockURLRequest(),
          newWKUserScript: ({
            required String source,
            required UserScriptInjectionTime injectionTime,
            required bool isMainFrameOnly,
          }) {
            return WKUserScript.pigeon_detached(
              source: source,
              injectionTime: injectionTime,
              isMainFrameOnly: isMainFrameOnly,
              pigeon_instanceManager: TestInstanceManager(),
            );
          },
        ),
        instanceManager: instanceManager ?? TestInstanceManager(),
      );

      final WebKitWebViewController controller = WebKitWebViewController(
        controllerCreationParams,
      );

      final MockWKWebViewUIExtensions mockWebViewUIExtensions =
          MockWKWebViewUIExtensions();
      when(nonNullMockWebView.UIWebViewExtensions).thenReturn(
        mockWebViewUIExtensions,
      );
      when(mockWebViewUIExtensions.scrollView)
          .thenReturn(mockScrollView ?? MockUIScrollView());
      when(nonNullMockWebView.configuration)
          .thenReturn(nonNullMockWebViewConfiguration);

      when(nonNullMockWebViewConfiguration.getUserPreferences()).thenAnswer(
        (_) => Future<MockWKPreferences>.value(
          mockPreferences ?? MockWKPreferences(),
        ),
      );
      when(nonNullMockWebViewConfiguration.getUserContentController())
          .thenAnswer(
        (_) => Future<MockWKUserContentController>.value(
          mockUserContentController ?? MockWKUserContentController(),
        ),
      );
      when(nonNullMockWebViewConfiguration.getWebsiteDataStore()).thenAnswer(
        (_) => Future<MockWKWebsiteDataStore>.value(
          mockWebsiteDataStore ?? MockWKWebsiteDataStore(),
        ),
      );

      return controller;
    }

    group('WebKitWebViewControllerCreationParams', () {
      test('allowsInlineMediaPlayback', () {
        final MockWKWebViewConfiguration mockConfiguration =
            MockWKWebViewConfiguration();

        WebKitWebViewControllerCreationParams(
          webKitProxy: WebKitProxy(
            newWKWebViewConfiguration: () => mockConfiguration,
          ),
          instanceManager: TestInstanceManager(),
          allowsInlineMediaPlayback: true,
        );

        verify(
          mockConfiguration.setAllowsInlineMediaPlayback(true),
        );
      });

      test('limitsNavigationsToAppBoundDomains', () {
        final MockWKWebViewConfiguration mockConfiguration =
            MockWKWebViewConfiguration();

        WebKitWebViewControllerCreationParams(
          webKitProxy: WebKitProxy(
            newWKWebViewConfiguration: () {
              return mockConfiguration;
            },
          ),
          instanceManager: TestInstanceManager(),
          limitsNavigationsToAppBoundDomains: true,
        );

        verify(
          mockConfiguration.setLimitsNavigationsToAppBoundDomains(true),
        );
      });

      test(
          'limitsNavigationsToAppBoundDomains is not called if it uses default value (false)',
          () {
        final MockWKWebViewConfiguration mockConfiguration =
            MockWKWebViewConfiguration();

        WebKitWebViewControllerCreationParams(
          webKitProxy: WebKitProxy(
            newWKWebViewConfiguration: () {
              return mockConfiguration;
            },
          ),
          instanceManager: TestInstanceManager(),
        );

        verifyNever(
          mockConfiguration.setLimitsNavigationsToAppBoundDomains(any),
        );
      });

      test('mediaTypesRequiringUserAction', () {
        final MockWKWebViewConfiguration mockConfiguration =
            MockWKWebViewConfiguration();

        WebKitWebViewControllerCreationParams(
          webKitProxy: WebKitProxy(
            newWKWebViewConfiguration: () {
              return mockConfiguration;
            },
          ),
          instanceManager: TestInstanceManager(),
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{
            PlaybackMediaTypes.video,
          },
        );

        verify(
          mockConfiguration.setMediaTypesRequiringUserActionForPlayback(
            <AudiovisualMediaType>[AudiovisualMediaType.video],
          ),
        );
      });

      test('mediaTypesRequiringUserAction defaults to include audio and video',
          () {
        final MockWKWebViewConfiguration mockConfiguration =
            MockWKWebViewConfiguration();

        WebKitWebViewControllerCreationParams(
          webKitProxy: WebKitProxy(
            newWKWebViewConfiguration: () {
              return mockConfiguration;
            },
          ),
          instanceManager: TestInstanceManager(),
        );

        verify(
          mockConfiguration.setMediaTypesRequiringUserActionForPlayback(
            <AudiovisualMediaType>[
              AudiovisualMediaType.audio,
              AudiovisualMediaType.video,
            ],
          ),
        );
      });

      test('mediaTypesRequiringUserAction sets value to none if set is empty',
          () {
        final MockWKWebViewConfiguration mockConfiguration =
            MockWKWebViewConfiguration();

        WebKitWebViewControllerCreationParams(
          webKitProxy: WebKitProxy(
            newWKWebViewConfiguration: () {
              return mockConfiguration;
            },
          ),
          instanceManager: TestInstanceManager(),
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );

        verify(
          mockConfiguration.setMediaTypesRequiringUserActionForPlayback(
            <AudiovisualMediaType>[AudiovisualMediaType.none],
          ),
        );
      });
    });

    test('loadFile', () async {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.loadFile('/path/to/file.html');
      verify(mockWebView.loadFileUrl('/path/to/file.html', '/path/to'));
    });

    test('loadFlutterAsset', () async {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.loadFlutterAsset('test_assets/index.html');
      verify(mockWebView.loadFlutterAsset('test_assets/index.html'));
    });

    test('loadHtmlString', () async {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      const String htmlString = '<html lang=""><body>Test data.</body></html>';
      await controller.loadHtmlString(htmlString, baseUrl: 'baseUrl');

      verify(mockWebView.loadHtmlString(
        '<html lang=""><body>Test data.</body></html>',
        'baseUrl',
      ));
    });

    group('loadRequest', () {
      test('Throws ArgumentError for empty scheme', () async {
        final MockWKWebView mockWebView = MockWKWebView();
        when(mockWebView.UIWebViewExtensions).thenReturn(
          MockWKWebViewUIExtensions(),
        );

        final WebKitWebViewController controller = createControllerWithMocks(
          createMockWebView: (_, {dynamic observeValue}) => mockWebView,
        );

        expect(
          () async => controller.loadRequest(
            LoadRequestParams(uri: Uri.parse('www.google.com')),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('GET without headers', () async {
        final MockWKWebView mockWebView = MockWKWebView();
        final MockURLRequest mockRequest = MockURLRequest();

        final WebKitWebViewController controller = createControllerWithMocks(
            createMockWebView: (_, {dynamic observeValue}) => mockWebView,
            createURLRequest: ({required String url}) {
              expect(url, 'https://www.google.com');
              return mockRequest;
            });

        await controller.loadRequest(
          LoadRequestParams(uri: Uri.parse('https://www.google.com')),
        );

        final URLRequest request =
            verify(mockWebView.load(captureAny)).captured.single as URLRequest;
        verify(request.setAllHttpHeaderFields(<String, String>{}));
        verify(request.setHttpMethod('get'));
      });

      test('GET with headers', () async {
        final MockWKWebView mockWebView = MockWKWebView();

        final WebKitWebViewController controller = createControllerWithMocks(
          createMockWebView: (_, {dynamic observeValue}) => mockWebView,
        );

        await controller.loadRequest(
          LoadRequestParams(
            uri: Uri.parse('https://www.google.com'),
            headers: const <String, String>{'a': 'header'},
          ),
        );

        final URLRequest request =
            verify(mockWebView.load(captureAny)).captured.single as URLRequest;
        verify(request.setAllHttpHeaderFields(<String, String>{'a': 'header'}));
        verify(request.setHttpMethod('get'));
      });

      test('POST without body', () async {
        final MockWKWebView mockWebView = MockWKWebView();

        final WebKitWebViewController controller = createControllerWithMocks(
          createMockWebView: (_, {dynamic observeValue}) => mockWebView,
        );

        await controller.loadRequest(LoadRequestParams(
          uri: Uri.parse('https://www.google.com'),
          method: LoadRequestMethod.post,
        ));

        final URLRequest request =
            verify(mockWebView.load(captureAny)).captured.single as URLRequest;
        verify(request.setHttpMethod('post'));
      });

      test('POST with body', () async {
        final MockWKWebView mockWebView = MockWKWebView();

        final WebKitWebViewController controller = createControllerWithMocks(
          createMockWebView: (_, {dynamic observeValue}) => mockWebView,
        );

        await controller.loadRequest(LoadRequestParams(
          uri: Uri.parse('https://www.google.com'),
          method: LoadRequestMethod.post,
          body: Uint8List.fromList('Test Body'.codeUnits),
        ));

        final URLRequest request =
            verify(mockWebView.load(captureAny)).captured.single as URLRequest;
        verify(request.setHttpMethod('post'));
        verify(request.setHttpBody(Uint8List.fromList('Test Body'.codeUnits)));
      });
    });

    test('canGoBack', () {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      when(mockWebView.canGoBack()).thenAnswer(
        (_) => Future<bool>.value(false),
      );
      expect(controller.canGoBack(), completion(false));
    });

    test('canGoForward', () {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      when(mockWebView.canGoForward()).thenAnswer(
        (_) => Future<bool>.value(true),
      );
      expect(controller.canGoForward(), completion(true));
    });

    test('goBack', () async {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.goBack();
      verify(mockWebView.goBack());
    });

    test('goForward', () async {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.goForward();
      verify(mockWebView.goForward());
    });

    test('reload', () async {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.reload();
      verify(mockWebView.reload());
    });

    test('setAllowsBackForwardNavigationGestures', () async {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.setAllowsBackForwardNavigationGestures(true);
      verify(mockWebView.setAllowsBackForwardNavigationGestures(true));
    });

    test('runJavaScriptReturningResult', () {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      final Object result = Object();
      when(mockWebView.evaluateJavaScript('runJavaScript')).thenAnswer(
        (_) => Future<Object>.value(result),
      );
      expect(
        controller.runJavaScriptReturningResult('runJavaScript'),
        completion(result),
      );
    });

    test('runJavaScriptReturningResult throws error on null return value', () {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      when(mockWebView.evaluateJavaScript('runJavaScript')).thenAnswer(
        (_) => Future<String?>.value(),
      );
      expect(
        () => controller.runJavaScriptReturningResult('runJavaScript'),
        throwsArgumentError,
      );
    });

    test('runJavaScript', () {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      when(mockWebView.evaluateJavaScript('runJavaScript')).thenAnswer(
        (_) => Future<String>.value('returnString'),
      );
      expect(
        controller.runJavaScript('runJavaScript'),
        completes,
      );
    });

    test('runJavaScript ignores exception with unsupported javaScript type',
        () {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      when(mockWebView.evaluateJavaScript('runJavaScript'))
          .thenThrow(PlatformException(
        code: '',
        details: NSError.pigeon_detached(
          code: WKErrorCode.javaScriptResultTypeIsUnsupported,
          domain: '',
          userInfo: const <String, Object?>{},
          pigeon_instanceManager: TestInstanceManager(),
        ),
      ));
      expect(
        controller.runJavaScript('runJavaScript'),
        completes,
      );
    });

    test('getTitle', () async {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      when(mockWebView.getTitle())
          .thenAnswer((_) => Future<String>.value('Web Title'));
      expect(controller.getTitle(), completion('Web Title'));
    });

    test('currentUrl', () {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      when(mockWebView.getUrl())
          .thenAnswer((_) => Future<String>.value('myUrl.com'));
      expect(controller.currentUrl(), completion('myUrl.com'));
    });

    test('scrollTo', () async {
      final MockUIScrollView mockScrollView = MockUIScrollView();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockScrollView: mockScrollView,
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await controller.scrollTo(2, 4);
      verify(mockScrollView.setContentOffset(2.0, 4.0));

      debugDefaultTargetPlatformOverride = null;
    });

    test('scrollBy', () async {
      final MockUIScrollView mockScrollView = MockUIScrollView();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockScrollView: mockScrollView,
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await controller.scrollBy(2, 4);
      verify(mockScrollView.scrollBy(2.0, 4.0));

      debugDefaultTargetPlatformOverride = null;
    });

    test('getScrollPosition', () {
      final MockUIScrollView mockScrollView = MockUIScrollView();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockScrollView: mockScrollView,
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      when(mockScrollView.getContentOffset()).thenAnswer(
        (_) => Future<List<double>>.value(<double>[8.0, 16.0]),
      );
      expect(
        controller.getScrollPosition(),
        completion(const Offset(8.0, 16.0)),
      );

      debugDefaultTargetPlatformOverride = null;
    });

    test('disable zoom', () async {
      final MockWKUserContentController mockUserContentController =
          MockWKUserContentController();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockUserContentController: mockUserContentController,
      );

      await controller.enableZoom(false);

      final WKUserScript zoomScript =
          verify(mockUserContentController.addUserScript(captureAny))
              .captured
              .first as WKUserScript;
      expect(zoomScript.isMainFrameOnly, isTrue);
      expect(zoomScript.injectionTime, UserScriptInjectionTime.atDocumentEnd);
      expect(
        zoomScript.source,
        "var meta = document.createElement('meta');\n"
        "meta.name = 'viewport';\n"
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, "
        "user-scalable=no';\n"
        "var head = document.getElementsByTagName('head')[0];head.appendChild(meta);",
      );
    });

    test('setBackgroundColor', () async {
      final MockWKWebView mockWebView = MockWKWebView();
      //when(mockWebView)
      final MockUIScrollView mockScrollView = MockUIScrollView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
        mockScrollView: mockScrollView,
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await controller.setBackgroundColor(Colors.red);

      final MockWKWebViewUIExtensions extensions =
          mockWebView.UIWebViewExtensions as MockWKWebViewUIExtensions;

      // UIScrollView.setBackgroundColor must be called last.
      verifyInOrder(<Object>[
        extensions.setOpaque(false),
        extensions.setBackgroundColor(
          Colors.transparent.value,
        ),
        mockScrollView.setBackgroundColor(Colors.red.value),
      ]);

      debugDefaultTargetPlatformOverride = null;
    });

    test('userAgent', () async {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.setUserAgent('MyUserAgent');
      verify(mockWebView.setCustomUserAgent('MyUserAgent'));
    });

    test('enable JavaScript', () async {
      final MockWKPreferences mockPreferences = MockWKPreferences();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockPreferences: mockPreferences,
      );

      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);

      verify(mockPreferences.setJavaScriptEnabled(true));
    });

    test('disable JavaScript', () async {
      final MockWKPreferences mockPreferences = MockWKPreferences();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockPreferences: mockPreferences,
      );

      await controller.setJavaScriptMode(JavaScriptMode.disabled);

      verify(mockPreferences.setJavaScriptEnabled(false));
    });

    test('clearCache', () {
      final MockWKWebsiteDataStore mockWebsiteDataStore =
          MockWKWebsiteDataStore();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockWebsiteDataStore: mockWebsiteDataStore,
      );
      when(
        mockWebsiteDataStore.removeDataOfTypes(
          <WebsiteDataType>[
            WebsiteDataType.memoryCache,
            WebsiteDataType.diskCache,
            WebsiteDataType.offlineWebApplicationCache,
          ],
          0,
        ),
      ).thenAnswer((_) => Future<bool>.value(false));

      expect(controller.clearCache(), completes);
    });

    test('clearLocalStorage', () {
      final MockWKWebsiteDataStore mockWebsiteDataStore =
          MockWKWebsiteDataStore();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockWebsiteDataStore: mockWebsiteDataStore,
      );
      when(
        mockWebsiteDataStore.removeDataOfTypes(
          <WebsiteDataType>[WebsiteDataType.localStorage],
          0,
        ),
      ).thenAnswer((_) => Future<bool>.value(false));

      expect(controller.clearLocalStorage(), completes);
    });

    test('addJavaScriptChannel', () async {
      final WebKitProxy webKitProxy = WebKitProxy(
        newWKScriptMessageHandler: ({
          required void Function(
            WKScriptMessageHandler,
            WKUserContentController,
            WKScriptMessage,
          ) didReceiveScriptMessage,
        }) {
          return WKScriptMessageHandler.pigeon_detached(
            didReceiveScriptMessage: didReceiveScriptMessage,
            pigeon_instanceManager: TestInstanceManager(),
          );
        },
      );

      final WebKitJavaScriptChannelParams javaScriptChannelParams =
          WebKitJavaScriptChannelParams(
        name: 'name',
        onMessageReceived: (JavaScriptMessage message) {},
        webKitProxy: webKitProxy,
      );

      final MockWKUserContentController mockUserContentController =
          MockWKUserContentController();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockUserContentController: mockUserContentController,
      );

      await controller.addJavaScriptChannel(javaScriptChannelParams);
      verify(mockUserContentController.addScriptMessageHandler(
        argThat(isA<WKScriptMessageHandler>()),
        'name',
      ));

      final WKUserScript userScript =
          verify(mockUserContentController.addUserScript(captureAny))
              .captured
              .single as WKUserScript;
      expect(userScript.source, 'window.name = webkit.messageHandlers.name;');
      expect(
        userScript.injectionTime,
        UserScriptInjectionTime.atDocumentStart,
      );
    });

    test('addJavaScriptChannel requires channel with a unique name', () async {
      final WebKitProxy webKitProxy = WebKitProxy(
        newWKScriptMessageHandler: ({
          required void Function(
            WKScriptMessageHandler,
            WKUserContentController,
            WKScriptMessage,
          ) didReceiveScriptMessage,
        }) {
          return WKScriptMessageHandler.pigeon_detached(
            didReceiveScriptMessage: didReceiveScriptMessage,
            pigeon_instanceManager: TestInstanceManager(),
          );
        },
      );
      final MockWKUserContentController mockUserContentController =
          MockWKUserContentController();
      final WebKitWebViewController controller = createControllerWithMocks(
        mockUserContentController: mockUserContentController,
      );

      const String nonUniqueName = 'name';
      final WebKitJavaScriptChannelParams javaScriptChannelParams =
          WebKitJavaScriptChannelParams(
        name: nonUniqueName,
        onMessageReceived: (JavaScriptMessage message) {},
        webKitProxy: webKitProxy,
      );
      await controller.addJavaScriptChannel(javaScriptChannelParams);

      expect(
        () => controller.addJavaScriptChannel(
          JavaScriptChannelParams(
            name: nonUniqueName,
            onMessageReceived: (_) {},
          ),
        ),
        throwsArgumentError,
      );
    });

    test('removeJavaScriptChannel', () async {
      final WebKitProxy webKitProxy = WebKitProxy(
        newWKScriptMessageHandler: ({
          required void Function(
            WKScriptMessageHandler,
            WKUserContentController,
            WKScriptMessage,
          ) didReceiveScriptMessage,
        }) {
          return WKScriptMessageHandler.pigeon_detached(
            didReceiveScriptMessage: didReceiveScriptMessage,
            pigeon_instanceManager: TestInstanceManager(),
          );
        },
      );

      final WebKitJavaScriptChannelParams javaScriptChannelParams =
          WebKitJavaScriptChannelParams(
        name: 'name',
        onMessageReceived: (JavaScriptMessage message) {},
        webKitProxy: webKitProxy,
      );

      final MockWKUserContentController mockUserContentController =
          MockWKUserContentController();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockUserContentController: mockUserContentController,
      );

      await controller.addJavaScriptChannel(javaScriptChannelParams);
      reset(mockUserContentController);

      await controller.removeJavaScriptChannel('name');

      verify(mockUserContentController.removeAllUserScripts());
      verify(mockUserContentController.removeScriptMessageHandler('name'));

      verifyNoMoreInteractions(mockUserContentController);
    });

    test('removeJavaScriptChannel with zoom disabled', () async {
      final WebKitProxy webKitProxy = WebKitProxy(
        newWKScriptMessageHandler: ({
          required void Function(
            WKScriptMessageHandler,
            WKUserContentController,
            WKScriptMessage,
          ) didReceiveScriptMessage,
        }) {
          return WKScriptMessageHandler.pigeon_detached(
            didReceiveScriptMessage: didReceiveScriptMessage,
            pigeon_instanceManager: TestInstanceManager(),
          );
        },
      );

      final WebKitJavaScriptChannelParams javaScriptChannelParams =
          WebKitJavaScriptChannelParams(
        name: 'name',
        onMessageReceived: (JavaScriptMessage message) {},
        webKitProxy: webKitProxy,
      );

      final MockWKUserContentController mockUserContentController =
          MockWKUserContentController();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockUserContentController: mockUserContentController,
      );

      await controller.enableZoom(false);
      await controller.addJavaScriptChannel(javaScriptChannelParams);
      clearInteractions(mockUserContentController);
      await controller.removeJavaScriptChannel('name');

      final WKUserScript zoomScript =
          verify(mockUserContentController.addUserScript(captureAny))
              .captured
              .first as WKUserScript;
      expect(zoomScript.isMainFrameOnly, isTrue);
      expect(zoomScript.injectionTime, UserScriptInjectionTime.atDocumentEnd);
      expect(
        zoomScript.source,
        "var meta = document.createElement('meta');\n"
        "meta.name = 'viewport';\n"
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, "
        "user-scalable=no';\n"
        "var head = document.getElementsByTagName('head')[0];head.appendChild(meta);",
      );
    });

    test('getUserAgent', () {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      const String userAgent = 'str';

      when(mockWebView.getCustomUserAgent()).thenAnswer(
        (_) => Future<String?>.value(userAgent),
      );
      expect(controller.getUserAgent(), completion(userAgent));
    });

    test('setPlatformNavigationDelegate', () {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      final WebKitNavigationDelegate navigationDelegate =
          WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
            newWKUIDelegate: CapturingUIDelegate.new,
          ),
        ),
      );

      controller.setPlatformNavigationDelegate(navigationDelegate);

      verify(
        mockWebView.setNavigationDelegate(
          CapturingNavigationDelegate.lastCreatedDelegate,
        ),
      );
    });

    test('setPlatformNavigationDelegate onProgress', () async {
      final MockWKWebView mockWebView = MockWKWebView();

      late final void Function(
        NSObject,
        String keyPath,
        NSObject object,
        Map<KeyValueChangeKey, Object?> change,
      ) webViewObserveValue;

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (
          WKWebViewConfiguration configuration, {
          void Function(
            NSObject,
            String keyPath,
            NSObject object,
            Map<KeyValueChangeKey, Object?> change,
          )? observeValue,
        }) {
          webViewObserveValue = observeValue!;
          return mockWebView;
        },
      );

      verify(
        mockWebView.addObserver(
          mockWebView,
          keyPath: 'estimatedProgress',
          options: <NSKeyValueObservingOptions>{
            NSKeyValueObservingOptions.newValue,
          },
        ),
      );

      final WebKitNavigationDelegate navigationDelegate =
          WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            createNavigationDelegate: CapturingNavigationDelegate.new,
            createUIDelegate: WKUIDelegate.detached,
          ),
        ),
      );

      late final int callbackProgress;
      await navigationDelegate.setOnProgress(
        (int progress) => callbackProgress = progress,
      );

      await controller.setPlatformNavigationDelegate(navigationDelegate);

      webViewObserveValue(
        'estimatedProgress',
        mockWebView,
        <NSKeyValueChangeKey, Object?>{NSKeyValueChangeKey.newValue: 0.0},
      );

      expect(callbackProgress, 0);
    });
//
//     test('Requests to open a new window loads request in same window', () {
//       // Reset last created delegate.
//       CapturingUIDelegate.lastCreatedDelegate = CapturingUIDelegate();
//
//       // Create a new WebKitWebViewController that sets
//       // CapturingUIDelegate.lastCreatedDelegate.
//       createControllerWithMocks();
//
//       final MockWKWebView mockWebView = MockWKWebView();
//       const NSUrlRequest request = NSUrlRequest(url: 'https://www.google.com');
//
//       CapturingUIDelegate.lastCreatedDelegate.onCreateWebView!(
//         mockWebView,
//         WKWebViewConfiguration.detached(),
//         const WKNavigationAction(
//           request: request,
//           targetFrame: WKFrameInfo(
//               isMainFrame: false,
//               request: NSUrlRequest(url: 'https://google.com')),
//           navigationType: WKNavigationType.linkActivated,
//         ),
//       );
//
//       verify(mockWebView.loadRequest(request));
//     });
//
//     test(
//         'setPlatformNavigationDelegate onProgress can be changed by the WebKitNavigationDelegate',
//         () async {
//       final MockWKWebView mockWebView = MockWKWebView();
//
//       late final void Function(
//         String keyPath,
//         NSObject object,
//         Map<NSKeyValueChangeKey, Object?> change,
//       ) webViewObserveValue;
//
//       final WebKitWebViewController controller = createControllerWithMocks(
//         createMockWebView: (
//           _, {
//           void Function(
//             String keyPath,
//             NSObject object,
//             Map<NSKeyValueChangeKey, Object?> change,
//           )? observeValue,
//         }) {
//           webViewObserveValue = observeValue!;
//           return mockWebView;
//         },
//       );
//
//       final WebKitNavigationDelegate navigationDelegate =
//           WebKitNavigationDelegate(
//         const WebKitNavigationDelegateCreationParams(
//           webKitProxy: WebKitProxy(
//             createNavigationDelegate: CapturingNavigationDelegate.new,
//             createUIDelegate: WKUIDelegate.detached,
//           ),
//         ),
//       );
//
//       // First value of onProgress does nothing.
//       await navigationDelegate.setOnProgress((_) {});
//       await controller.setPlatformNavigationDelegate(navigationDelegate);
//
//       // Second value of onProgress sets `callbackProgress`.
//       late final int callbackProgress;
//       await navigationDelegate.setOnProgress(
//         (int progress) => callbackProgress = progress,
//       );
//
//       webViewObserveValue(
//         'estimatedProgress',
//         mockWebView,
//         <NSKeyValueChangeKey, Object?>{NSKeyValueChangeKey.newValue: 0.0},
//       );
//
//       expect(callbackProgress, 0);
//     });
//
//     test('setPlatformNavigationDelegate onUrlChange', () async {
//       final MockWKWebView mockWebView = MockWKWebView();
//
//       late final void Function(
//         String keyPath,
//         NSObject object,
//         Map<NSKeyValueChangeKey, Object?> change,
//       ) webViewObserveValue;
//
//       final WebKitWebViewController controller = createControllerWithMocks(
//         createMockWebView: (
//           _, {
//           void Function(
//             String keyPath,
//             NSObject object,
//             Map<NSKeyValueChangeKey, Object?> change,
//           )? observeValue,
//         }) {
//           webViewObserveValue = observeValue!;
//           return mockWebView;
//         },
//       );
//
//       verify(
//         mockWebView.addObserver(
//           mockWebView,
//           keyPath: 'URL',
//           options: <NSKeyValueObservingOptions>{
//             NSKeyValueObservingOptions.newValue,
//           },
//         ),
//       );
//
//       final WebKitNavigationDelegate navigationDelegate =
//           WebKitNavigationDelegate(
//         const WebKitNavigationDelegateCreationParams(
//           webKitProxy: WebKitProxy(
//             createNavigationDelegate: CapturingNavigationDelegate.new,
//             createUIDelegate: WKUIDelegate.detached,
//           ),
//         ),
//       );
//
//       final Completer<UrlChange> urlChangeCompleter = Completer<UrlChange>();
//       await navigationDelegate.setOnUrlChange(
//         (UrlChange change) => urlChangeCompleter.complete(change),
//       );
//
//       await controller.setPlatformNavigationDelegate(navigationDelegate);
//
//       final MockNSUrl mockNSUrl = MockNSUrl();
//       when(mockNSUrl.getAbsoluteString()).thenAnswer((_) {
//         return Future<String>.value('https://www.google.com');
//       });
//       webViewObserveValue(
//         'URL',
//         mockWebView,
//         <NSKeyValueChangeKey, Object?>{NSKeyValueChangeKey.newValue: mockNSUrl},
//       );
//
//       final UrlChange urlChange = await urlChangeCompleter.future;
//       expect(urlChange.url, 'https://www.google.com');
//     });
//
//     test('setPlatformNavigationDelegate onUrlChange to null NSUrl', () async {
//       final MockWKWebView mockWebView = MockWKWebView();
//
//       late final void Function(
//         String keyPath,
//         NSObject object,
//         Map<NSKeyValueChangeKey, Object?> change,
//       ) webViewObserveValue;
//
//       final WebKitWebViewController controller = createControllerWithMocks(
//         createMockWebView: (
//           _, {
//           void Function(
//             String keyPath,
//             NSObject object,
//             Map<NSKeyValueChangeKey, Object?> change,
//           )? observeValue,
//         }) {
//           webViewObserveValue = observeValue!;
//           return mockWebView;
//         },
//       );
//
//       final WebKitNavigationDelegate navigationDelegate =
//           WebKitNavigationDelegate(
//         const WebKitNavigationDelegateCreationParams(
//           webKitProxy: WebKitProxy(
//             createNavigationDelegate: CapturingNavigationDelegate.new,
//             createUIDelegate: WKUIDelegate.detached,
//           ),
//         ),
//       );
//
//       final Completer<UrlChange> urlChangeCompleter = Completer<UrlChange>();
//       await navigationDelegate.setOnUrlChange(
//         (UrlChange change) => urlChangeCompleter.complete(change),
//       );
//
//       await controller.setPlatformNavigationDelegate(navigationDelegate);
//
//       webViewObserveValue(
//         'URL',
//         mockWebView,
//         <NSKeyValueChangeKey, Object?>{NSKeyValueChangeKey.newValue: null},
//       );
//
//       final UrlChange urlChange = await urlChangeCompleter.future;
//       expect(urlChange.url, isNull);
//     });
//
//     test('webViewIdentifier', () {
//       final InstanceManager instanceManager = InstanceManager(
//         onWeakReferenceRemoved: (_) {},
//       );
//       final MockWKWebView mockWebView = MockWKWebView();
//       when(mockWebView.copy()).thenReturn(MockWKWebView());
//       instanceManager.addHostCreatedInstance(mockWebView, 0);
//
//       final WebKitWebViewController controller = createControllerWithMocks(
//         createMockWebView: (_, {dynamic observeValue}) => mockWebView,
//         instanceManager: instanceManager,
//       );
//
//       expect(
//         controller.webViewIdentifier,
//         instanceManager.getIdentifier(mockWebView),
//       );
//     });
//
//     test('setOnPermissionRequest', () async {
//       final WebKitWebViewController controller = createControllerWithMocks();
//
//       late final PlatformWebViewPermissionRequest permissionRequest;
//       await controller.setOnPlatformPermissionRequest(
//         (PlatformWebViewPermissionRequest request) async {
//           permissionRequest = request;
//           await request.grant();
//         },
//       );
//
//       final Future<WKPermissionDecision> Function(
//         WKUIDelegate instance,
//         WKWebView webView,
//         WKSecurityOrigin origin,
//         WKFrameInfo frame,
//         WKMediaCaptureType type,
//       ) onPermissionRequestCallback = CapturingUIDelegate
//           .lastCreatedDelegate.requestMediaCapturePermission!;
//
//       final WKPermissionDecision decision = await onPermissionRequestCallback(
//         CapturingUIDelegate.lastCreatedDelegate,
//         WKWebViewIOS.detached(),
//         const WKSecurityOrigin(host: '', port: 0, protocol: ''),
//         const WKFrameInfo(
//             isMainFrame: false,
//             request: NSUrlRequest(url: 'https://google.com')),
//         WKMediaCaptureType.microphone,
//       );
//
//       expect(permissionRequest.types, <WebViewPermissionResourceType>[
//         WebViewPermissionResourceType.microphone,
//       ]);
//       expect(decision, WKPermissionDecision.grant);
//     });
//
//     group('JavaScript Dialog', () {
//       test('setOnJavaScriptAlertDialog', () async {
//         final WebKitWebViewController controller = createControllerWithMocks();
//         late final String message;
//         await controller.setOnJavaScriptAlertDialog(
//             (JavaScriptAlertDialogRequest request) async {
//           message = request.message;
//           return;
//         });
//
//         const String callbackMessage = 'Message';
//         final Future<void> Function(String message, WKFrameInfo frame)
//             onJavaScriptAlertDialog =
//             CapturingUIDelegate.lastCreatedDelegate.runJavaScriptAlertDialog!;
//         await onJavaScriptAlertDialog(
//             callbackMessage,
//             const WKFrameInfo(
//                 isMainFrame: false,
//                 request: NSUrlRequest(url: 'https://google.com')));
//
//         expect(message, callbackMessage);
//       });
//
//       test('setOnJavaScriptConfirmDialog', () async {
//         final WebKitWebViewController controller = createControllerWithMocks();
//         late final String message;
//         const bool callbackReturnValue = true;
//         await controller.setOnJavaScriptConfirmDialog(
//             (JavaScriptConfirmDialogRequest request) async {
//           message = request.message;
//           return callbackReturnValue;
//         });
//
//         const String callbackMessage = 'Message';
//         final Future<bool> Function(String message, WKFrameInfo frame)
//             onJavaScriptConfirmDialog =
//             CapturingUIDelegate.lastCreatedDelegate.runJavaScriptConfirmDialog!;
//         final bool returnValue = await onJavaScriptConfirmDialog(
//             callbackMessage,
//             const WKFrameInfo(
//                 isMainFrame: false,
//                 request: NSUrlRequest(url: 'https://google.com')));
//
//         expect(message, callbackMessage);
//         expect(returnValue, callbackReturnValue);
//       });
//
//       test('setOnJavaScriptTextInputDialog', () async {
//         final WebKitWebViewController controller = createControllerWithMocks();
//         late final String message;
//         late final String? defaultText;
//         const String callbackReturnValue = 'Return Value';
//         await controller.setOnJavaScriptTextInputDialog(
//             (JavaScriptTextInputDialogRequest request) async {
//           message = request.message;
//           defaultText = request.defaultText;
//           return callbackReturnValue;
//         });
//
//         const String callbackMessage = 'Message';
//         const String callbackDefaultText = 'Default Text';
//         final Future<String> Function(
//                 String prompt, String defaultText, WKFrameInfo frame)
//             onJavaScriptTextInputDialog = CapturingUIDelegate
//                 .lastCreatedDelegate.runJavaScriptTextInputDialog!;
//         final String returnValue = await onJavaScriptTextInputDialog(
//             callbackMessage,
//             callbackDefaultText,
//             const WKFrameInfo(
//                 isMainFrame: false,
//                 request: NSUrlRequest(url: 'https://google.com')));
//
//         expect(message, callbackMessage);
//         expect(defaultText, callbackDefaultText);
//         expect(returnValue, callbackReturnValue);
//       });
//     });
//
//     test('inspectable', () async {
//       final MockWKWebView mockWebView = MockWKWebView();
//
//       final WebKitWebViewController controller = createControllerWithMocks(
//         createMockWebView: (_, {dynamic observeValue}) => mockWebView,
//       );
//
//       await controller.setInspectable(true);
//       verify(mockWebView.setInspectable(true));
//     });
//
//     group('Console logging', () {
//       test('setConsoleLogCallback should inject the correct JavaScript',
//           () async {
//         final MockWKUserContentController mockUserContentController =
//             MockWKUserContentController();
//         final WebKitWebViewController controller = createControllerWithMocks(
//           mockUserContentController: mockUserContentController,
//         );
//
//         await controller
//             .setOnConsoleMessage((JavaScriptConsoleMessage message) {});
//
//         final List<dynamic> capturedScripts =
//             verify(mockUserContentController.addUserScript(captureAny))
//                 .captured
//                 .toList();
//         final WKUserScript messageHandlerScript =
//             capturedScripts[0] as WKUserScript;
//         final WKUserScript overrideConsoleScript =
//             capturedScripts[1] as WKUserScript;
//
//         expect(messageHandlerScript.isMainFrameOnly, isFalse);
//         expect(messageHandlerScript.injectionTime,
//             WKUserScriptInjectionTime.atDocumentStart);
//         expect(messageHandlerScript.source,
//             'window.fltConsoleMessage = webkit.messageHandlers.fltConsoleMessage;');
//
//         expect(overrideConsoleScript.isMainFrameOnly, isTrue);
//         expect(overrideConsoleScript.injectionTime,
//             WKUserScriptInjectionTime.atDocumentStart);
//         expect(overrideConsoleScript.source, '''
// var _flutter_webview_plugin_overrides = _flutter_webview_plugin_overrides || {
//   removeCyclicObject: function() {
//     const traversalStack = [];
//     return function (k, v) {
//       if (typeof v !== "object" || v === null) { return v; }
//       const currentParentObj = this;
//       while (
//         traversalStack.length > 0 &&
//         traversalStack[traversalStack.length - 1] !== currentParentObj
//       ) {
//         traversalStack.pop();
//       }
//       if (traversalStack.includes(v)) { return; }
//       traversalStack.push(v);
//       return v;
//     };
//   },
//   log: function (type, args) {
//     var message =  Object.values(args)
//         .map(v => typeof(v) === "undefined" ? "undefined" : typeof(v) === "object" ? JSON.stringify(v, _flutter_webview_plugin_overrides.removeCyclicObject()) : v.toString())
//         .map(v => v.substring(0, 3000)) // Limit msg to 3000 chars
//         .join(", ");
//
//     var log = {
//       level: type,
//       message: message
//     };
//
//     window.webkit.messageHandlers.fltConsoleMessage.postMessage(JSON.stringify(log));
//   }
// };
//
// let originalLog = console.log;
// let originalInfo = console.info;
// let originalWarn = console.warn;
// let originalError = console.error;
// let originalDebug = console.debug;
//
// console.log = function() { _flutter_webview_plugin_overrides.log("log", arguments); originalLog.apply(null, arguments) };
// console.info = function() { _flutter_webview_plugin_overrides.log("info", arguments); originalInfo.apply(null, arguments) };
// console.warn = function() { _flutter_webview_plugin_overrides.log("warning", arguments); originalWarn.apply(null, arguments) };
// console.error = function() { _flutter_webview_plugin_overrides.log("error", arguments); originalError.apply(null, arguments) };
// console.debug = function() { _flutter_webview_plugin_overrides.log("debug", arguments); originalDebug.apply(null, arguments) };
//
// window.addEventListener("error", function(e) {
//   log("error", e.message + " at " + e.filename + ":" + e.lineno + ":" + e.colno);
// });
//       ''');
//       });
//
//       test('setConsoleLogCallback should parse levels correctly', () async {
//         final MockWKUserContentController mockUserContentController =
//             MockWKUserContentController();
//         final WebKitWebViewController controller = createControllerWithMocks(
//           mockUserContentController: mockUserContentController,
//         );
//
//         final Map<JavaScriptLogLevel, String> logs =
//             <JavaScriptLogLevel, String>{};
//         await controller.setOnConsoleMessage(
//             (JavaScriptConsoleMessage message) =>
//                 logs[message.level] = message.message);
//
//         final List<dynamic> capturedParameters = verify(
//                 mockUserContentController.addScriptMessageHandler(
//                     captureAny, any))
//             .captured
//             .toList();
//         final WKScriptMessageHandler scriptMessageHandler =
//             capturedParameters[0] as WKScriptMessageHandler;
//
//         scriptMessageHandler.didReceiveScriptMessage(
//             mockUserContentController,
//             const WKScriptMessage(
//                 name: 'test',
//                 body: '{"level": "debug", "message": "Debug message"}'));
//         scriptMessageHandler.didReceiveScriptMessage(
//             mockUserContentController,
//             const WKScriptMessage(
//                 name: 'test',
//                 body: '{"level": "error", "message": "Error message"}'));
//         scriptMessageHandler.didReceiveScriptMessage(
//             mockUserContentController,
//             const WKScriptMessage(
//                 name: 'test',
//                 body: '{"level": "info", "message": "Info message"}'));
//         scriptMessageHandler.didReceiveScriptMessage(
//             mockUserContentController,
//             const WKScriptMessage(
//                 name: 'test',
//                 body: '{"level": "log", "message": "Log message"}'));
//         scriptMessageHandler.didReceiveScriptMessage(
//             mockUserContentController,
//             const WKScriptMessage(
//                 name: 'test',
//                 body: '{"level": "warning", "message": "Warning message"}'));
//
//         expect(logs.length, 5);
//         expect(logs[JavaScriptLogLevel.debug], 'Debug message');
//         expect(logs[JavaScriptLogLevel.error], 'Error message');
//         expect(logs[JavaScriptLogLevel.info], 'Info message');
//         expect(logs[JavaScriptLogLevel.log], 'Log message');
//         expect(logs[JavaScriptLogLevel.warning], 'Warning message');
//       });
//     });
//
//     test('setOnScrollPositionChange', () async {
//       final WebKitWebViewController controller = createControllerWithMocks();
//
//       final Completer<ScrollPositionChange> changeCompleter =
//           Completer<ScrollPositionChange>();
//       await controller.setOnScrollPositionChange(
//         (ScrollPositionChange change) {
//           changeCompleter.complete(change);
//         },
//       );
//
//       final void Function(
//         UIScrollView scrollView,
//         double,
//         double,
//       ) onScrollViewDidScroll = CapturingUIScrollViewDelegate
//           .lastCreatedDelegate.scrollViewDidScroll!;
//
//       final MockUIScrollView mockUIScrollView = MockUIScrollView();
//       onScrollViewDidScroll(mockUIScrollView, 1.0, 2.0);
//
//       final ScrollPositionChange change = await changeCompleter.future;
//       expect(change.x, 1.0);
//       expect(change.y, 2.0);
//     });
  });

  // group('WebKitJavaScriptChannelParams', () {
  //   test('onMessageReceived', () async {
  //     late final WKScriptMessageHandler messageHandler;
  //
  //     final WebKitProxy webKitProxy = WebKitProxy(
  //       createScriptMessageHandler: ({
  //         required void Function(
  //           WKUserContentController userContentController,
  //           WKScriptMessage message,
  //         ) didReceiveScriptMessage,
  //       }) {
  //         messageHandler = WKScriptMessageHandler.detached(
  //           didReceiveScriptMessage: didReceiveScriptMessage,
  //         );
  //         return messageHandler;
  //       },
  //     );
  //
  //     late final String callbackMessage;
  //     WebKitJavaScriptChannelParams(
  //       name: 'name',
  //       onMessageReceived: (JavaScriptMessage message) {
  //         callbackMessage = message.message;
  //       },
  //       webKitProxy: webKitProxy,
  //     );
  //
  //     messageHandler.didReceiveScriptMessage(
  //       MockWKUserContentController(),
  //       const WKScriptMessage(name: 'name', body: 'myMessage'),
  //     );
  //
  //     expect(callbackMessage, 'myMessage');
  //   });
  // });
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
  }) : super.pigeon_detached(pigeon_instanceManager: TestInstanceManager()) {
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
  }) : super.pigeon_detached(pigeon_instanceManager: TestInstanceManager()) {
    lastCreatedDelegate = this;
  }
  static CapturingUIDelegate lastCreatedDelegate = CapturingUIDelegate();
}

class CapturingUIScrollViewDelegate extends UIScrollViewDelegate {
  CapturingUIScrollViewDelegate({
    super.scrollViewDidScroll,
  }) : super.pigeon_detached(pigeon_instanceManager: TestInstanceManager()) {
    lastCreatedDelegate = this;
  }

  static CapturingUIScrollViewDelegate lastCreatedDelegate =
      CapturingUIScrollViewDelegate();
}

// Test InstanceManager that sets `onWeakReferenceRemoved` as a noop.
class TestInstanceManager extends PigeonInstanceManager {
  TestInstanceManager() : super(onWeakReferenceRemoved: (_) {});
}

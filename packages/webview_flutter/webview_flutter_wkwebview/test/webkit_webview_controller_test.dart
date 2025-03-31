// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/common/platform_webview.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit.g.dart';
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
  MockSpec<WKWebpagePreferences>(),
  MockSpec<UIViewWKWebView>(),
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
      MockUIViewWKWebView Function(
        WKWebViewConfiguration configuration, {
        void Function(
          NSObject,
          String? keyPath,
          NSObject? object,
          Map<KeyValueChangeKey, Object?>? change,
        )? observeValue,
      })? createMockWebView,
      MockWKWebViewConfiguration? mockWebViewConfiguration,
      MockURLRequest Function({required String url})? createURLRequest,
      PigeonInstanceManager? instanceManager,
      MockWKWebpagePreferences? mockWebpagePreferences,
    }) {
      final MockWKWebViewConfiguration nonNullMockWebViewConfiguration =
          mockWebViewConfiguration ?? MockWKWebViewConfiguration();
      late final MockUIViewWKWebView nonNullMockWebView;

      final PlatformWebViewControllerCreationParams controllerCreationParams =
          WebKitWebViewControllerCreationParams(
        webKitProxy: WebKitProxy(
          newWKWebViewConfiguration: (
              {PigeonInstanceManager? instanceManager}) {
            return nonNullMockWebViewConfiguration;
          },
          newPlatformWebView: ({
            required WKWebViewConfiguration initialConfiguration,
            void Function(
              NSObject,
              String?,
              NSObject?,
              Map<KeyValueChangeKey, Object?>?,
            )? observeValue,
          }) {
            nonNullMockWebView = createMockWebView == null
                ? MockUIViewWKWebView()
                : createMockWebView(
                    nonNullMockWebViewConfiguration,
                    observeValue: observeValue,
                  );
            return PlatformWebView.fromNativeWebView(nonNullMockWebView);
          },
          newWKUIDelegate: ({
            void Function(
              WKUIDelegate,
              WKWebView,
              WKWebViewConfiguration,
              WKNavigationAction,
            )? onCreateWebView,
            required Future<PermissionDecision> Function(
              WKUIDelegate,
              WKWebView,
              WKSecurityOrigin,
              WKFrameInfo,
              MediaCaptureType,
            ) requestMediaCapturePermission,
            Future<void> Function(
              WKUIDelegate,
              WKWebView,
              String,
              WKFrameInfo,
            )? runJavaScriptAlertPanel,
            required Future<bool> Function(
              WKUIDelegate,
              WKWebView,
              String,
              WKFrameInfo,
            ) runJavaScriptConfirmPanel,
            Future<String?> Function(
              WKUIDelegate,
              WKWebView,
              String,
              String?,
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
          newUIScrollViewDelegate: ({
            void Function(
              UIScrollViewDelegate,
              UIScrollView,
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
            required bool isForMainFrameOnly,
          }) {
            return WKUserScript.pigeon_detached(
              source: source,
              injectionTime: injectionTime,
              isForMainFrameOnly: isForMainFrameOnly,
              pigeon_instanceManager: TestInstanceManager(),
            );
          },
        ),
        instanceManager: instanceManager ?? TestInstanceManager(),
      );

      final WebKitWebViewController controller = WebKitWebViewController(
        controllerCreationParams,
      );

      when(nonNullMockWebView.scrollView)
          .thenReturn(mockScrollView ?? MockUIScrollView());
      when(nonNullMockWebView.configuration)
          .thenReturn(nonNullMockWebViewConfiguration);

      when(nonNullMockWebViewConfiguration.getPreferences()).thenAnswer(
        (_) => Future<MockWKPreferences>.value(
          mockPreferences ?? MockWKPreferences(),
        ),
      );
      when(nonNullMockWebViewConfiguration.getDefaultWebpagePreferences())
          .thenAnswer(
        (_) async => mockWebpagePreferences ?? MockWKWebpagePreferences(),
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
            AudiovisualMediaType.video,
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
            AudiovisualMediaType.all,
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
            AudiovisualMediaType.none,
          ),
        );
      });
    });

    test('loadFile', () async {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.loadFile('/path/to/file.html');
      verify(mockWebView.loadFileUrl('/path/to/file.html', '/path/to'));
    });

    test('loadFlutterAsset', () async {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.loadFlutterAsset('test_assets/index.html');
      verify(mockWebView.loadFlutterAsset('test_assets/index.html'));
    });

    test('loadHtmlString', () async {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

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
        final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

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
        final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();
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
        final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

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
        final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

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
        final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

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
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      when(mockWebView.canGoBack()).thenAnswer(
        (_) => Future<bool>.value(false),
      );
      expect(controller.canGoBack(), completion(false));
    });

    test('canGoForward', () {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      when(mockWebView.canGoForward()).thenAnswer(
        (_) => Future<bool>.value(true),
      );
      expect(controller.canGoForward(), completion(true));
    });

    test('goBack', () async {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.goBack();
      verify(mockWebView.goBack());
    });

    test('goForward', () async {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.goForward();
      verify(mockWebView.goForward());
    });

    test('reload', () async {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.reload();
      verify(mockWebView.reload());
    });

    test('setAllowsBackForwardNavigationGestures', () async {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.setAllowsBackForwardNavigationGestures(true);
      verify(mockWebView.setAllowsBackForwardNavigationGestures(true));
    });

    test('runJavaScriptReturningResult', () {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

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
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

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
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

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
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

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
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      when(mockWebView.getTitle())
          .thenAnswer((_) => Future<String>.value('Web Title'));
      expect(controller.getTitle(), completion('Web Title'));
    });

    test('currentUrl', () {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

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
      expect(zoomScript.isForMainFrameOnly, isTrue);
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
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();
      //when(mockWebView)
      final MockUIScrollView mockScrollView = MockUIScrollView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
        mockScrollView: mockScrollView,
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await controller.setBackgroundColor(Colors.red);

      // UIScrollView.setBackgroundColor must be called last.
      verifyInOrder(<Object>[
        mockWebView.setOpaque(false),
        mockWebView.setBackgroundColor(Colors.transparent.value),
        mockScrollView.setBackgroundColor(Colors.red.value),
      ]);

      debugDefaultTargetPlatformOverride = null;
    });

    test('userAgent', () async {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.setUserAgent('MyUserAgent');
      verify(mockWebView.setCustomUserAgent('MyUserAgent'));
    });

    test('enable JavaScript', () async {
      final MockWKWebpagePreferences mockWebpagePreferences =
          MockWKWebpagePreferences();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockWebpagePreferences: mockWebpagePreferences,
      );

      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);

      verify(mockWebpagePreferences.setAllowsContentJavaScript(true));
    });

    test('disable JavaScript', () async {
      final MockWKWebpagePreferences mockWebpagePreferences =
          MockWKWebpagePreferences();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockWebpagePreferences: mockWebpagePreferences,
      );

      await controller.setJavaScriptMode(JavaScriptMode.disabled);

      verify(mockWebpagePreferences.setAllowsContentJavaScript(false));
    });

    test(
        'enable JavaScript calls WKPreferences.setJavaScriptEnabled for lower versions',
        () async {
      final MockWKPreferences mockPreferences = MockWKPreferences();
      final MockWKWebpagePreferences mockWebpagePreferences =
          MockWKWebpagePreferences();
      when(mockWebpagePreferences.setAllowsContentJavaScript(any)).thenThrow(
        PlatformException(code: 'PigeonUnsupportedOperationError'),
      );

      final WebKitWebViewController controller = createControllerWithMocks(
        mockPreferences: mockPreferences,
        mockWebpagePreferences: mockWebpagePreferences,
      );

      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);

      verify(mockPreferences.setJavaScriptEnabled(true));
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

    test('removeJavaScriptChannel multiple times', () async {
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

      final WebKitJavaScriptChannelParams javaScriptChannelParams1 =
          WebKitJavaScriptChannelParams(
        name: 'name1',
        onMessageReceived: (JavaScriptMessage message) {},
        webKitProxy: webKitProxy,
      );

      final WebKitJavaScriptChannelParams javaScriptChannelParams2 =
          WebKitJavaScriptChannelParams(
        name: 'name2',
        onMessageReceived: (JavaScriptMessage message) {},
        webKitProxy: webKitProxy,
      );

      final MockWKUserContentController mockUserContentController =
          MockWKUserContentController();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockUserContentController: mockUserContentController,
      );

      await controller.addJavaScriptChannel(javaScriptChannelParams1);
      await controller.addJavaScriptChannel(javaScriptChannelParams2);
      reset(mockUserContentController);

      await controller.removeJavaScriptChannel('name1');

      verify(mockUserContentController.removeAllUserScripts());
      verify(mockUserContentController.removeScriptMessageHandler('name1'));
      verify(mockUserContentController.removeScriptMessageHandler('name2'));

      verify(mockUserContentController.addScriptMessageHandler(
        argThat(isA<WKScriptMessageHandler>()),
        'name2',
      ));

      final WKUserScript userScript =
          verify(mockUserContentController.addUserScript(captureAny))
              .captured
              .single as WKUserScript;
      expect(userScript.source, 'window.name2 = webkit.messageHandlers.name2;');
      expect(
        userScript.injectionTime,
        UserScriptInjectionTime.atDocumentStart,
      );

      await controller.removeJavaScriptChannel('name2');
      verify(mockUserContentController.removeAllUserScripts());
      verify(mockUserContentController.removeScriptMessageHandler('name2'));
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
      expect(zoomScript.isForMainFrameOnly, isTrue);
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
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

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
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

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
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      late final void Function(
        NSObject,
        String? keyPath,
        NSObject? object,
        Map<KeyValueChangeKey, Object>? change,
      ) webViewObserveValue;

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (
          WKWebViewConfiguration configuration, {
          void Function(
            NSObject,
            String? keyPath,
            NSObject? object,
            Map<KeyValueChangeKey, Object>? change,
          )? observeValue,
        }) {
          webViewObserveValue = observeValue!;
          return mockWebView;
        },
      );

      verify(
        mockWebView.addObserver(
          mockWebView,
          'estimatedProgress',
          <KeyValueObservingOptions>[KeyValueObservingOptions.newValue],
        ),
      );

      final WebKitNavigationDelegate navigationDelegate =
          WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
          ),
        ),
      );

      late final int callbackProgress;
      await navigationDelegate.setOnProgress(
        (int progress) => callbackProgress = progress,
      );

      await controller.setPlatformNavigationDelegate(navigationDelegate);

      webViewObserveValue(
        mockWebView,
        'estimatedProgress',
        mockWebView,
        <KeyValueChangeKey, Object>{KeyValueChangeKey.newValue: 0.0},
      );

      expect(callbackProgress, 0);
    });

    test('Requests to open a new window loads request in same window', () {
      // Reset last created delegate.
      CapturingUIDelegate.lastCreatedDelegate = CapturingUIDelegate(
        requestMediaCapturePermission: (_, __, ___, ____, _____) async {
          return PermissionDecision.deny;
        },
        runJavaScriptConfirmPanel: (_, __, ___, ____) async {
          return false;
        },
      );

      // Create a new WebKitWebViewController that sets
      // CapturingUIDelegate.lastCreatedDelegate.
      createControllerWithMocks();

      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();
      final MockURLRequest mockRequest = MockURLRequest();

      CapturingUIDelegate.lastCreatedDelegate.onCreateWebView!(
        CapturingUIDelegate.lastCreatedDelegate,
        mockWebView,
        MockWKWebViewConfiguration(),
        WKNavigationAction.pigeon_detached(
          request: mockRequest,
          targetFrame: WKFrameInfo.pigeon_detached(
            isMainFrame: false,
            request: MockURLRequest(),
            pigeon_instanceManager: TestInstanceManager(),
          ),
          navigationType: NavigationType.linkActivated,
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      verify(mockWebView.load(mockRequest));
    });

    test(
        'setPlatformNavigationDelegate onProgress can be changed by the WebKitNavigationDelegate',
        () async {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      late final void Function(
        NSObject,
        String? keyPath,
        NSObject? object,
        Map<KeyValueChangeKey, Object>? change,
      ) webViewObserveValue;

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (
          WKWebViewConfiguration configuration, {
          void Function(
            NSObject,
            String? keyPath,
            NSObject? object,
            Map<KeyValueChangeKey, Object>? change,
          )? observeValue,
        }) {
          webViewObserveValue = observeValue!;
          return mockWebView;
        },
      );

      final WebKitNavigationDelegate navigationDelegate =
          WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
          ),
        ),
      );

      // First value of onProgress does nothing.
      await navigationDelegate.setOnProgress((_) {});
      await controller.setPlatformNavigationDelegate(navigationDelegate);

      // Second value of onProgress sets `callbackProgress`.
      late final int callbackProgress;
      await navigationDelegate.setOnProgress(
        (int progress) => callbackProgress = progress,
      );

      webViewObserveValue(
        mockWebView,
        'estimatedProgress',
        mockWebView,
        <KeyValueChangeKey, Object>{KeyValueChangeKey.newValue: 0.0},
      );

      expect(callbackProgress, 0);
    });

    test('setPlatformNavigationDelegate onUrlChange', () async {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      late final void Function(
        NSObject,
        String? keyPath,
        NSObject? object,
        Map<KeyValueChangeKey, Object>? change,
      ) webViewObserveValue;

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (
          WKWebViewConfiguration configuration, {
          void Function(
            NSObject,
            String? keyPath,
            NSObject? object,
            Map<KeyValueChangeKey, Object>? change,
          )? observeValue,
        }) {
          webViewObserveValue = observeValue!;
          return mockWebView;
        },
      );

      verify(
        mockWebView.addObserver(
          mockWebView,
          'URL',
          <KeyValueObservingOptions>[
            KeyValueObservingOptions.newValue,
          ],
        ),
      );

      final WebKitNavigationDelegate navigationDelegate =
          WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
          ),
        ),
      );

      final Completer<UrlChange> urlChangeCompleter = Completer<UrlChange>();
      await navigationDelegate.setOnUrlChange(
        (UrlChange change) => urlChangeCompleter.complete(change),
      );

      await controller.setPlatformNavigationDelegate(navigationDelegate);

      final MockURL mockUrl = MockURL();
      when(mockUrl.getAbsoluteString()).thenAnswer((_) {
        return Future<String>.value('https://www.google.com');
      });
      webViewObserveValue(
        mockWebView,
        'URL',
        mockWebView,
        <KeyValueChangeKey, Object>{KeyValueChangeKey.newValue: mockUrl},
      );

      final UrlChange urlChange = await urlChangeCompleter.future;
      expect(urlChange.url, 'https://www.google.com');
    });

    test('setPlatformNavigationDelegate onUrlChange to null NSUrl', () async {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      late final void Function(
        NSObject,
        String? keyPath,
        NSObject? object,
        Map<KeyValueChangeKey, Object?>? change,
      ) webViewObserveValue;

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (
          WKWebViewConfiguration configuration, {
          void Function(
            NSObject,
            String? keyPath,
            NSObject? object,
            Map<KeyValueChangeKey, Object?>? change,
          )? observeValue,
        }) {
          webViewObserveValue = observeValue!;
          return mockWebView;
        },
      );

      final WebKitNavigationDelegate navigationDelegate =
          WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
          ),
        ),
      );

      final Completer<UrlChange> urlChangeCompleter = Completer<UrlChange>();
      await navigationDelegate.setOnUrlChange(
        (UrlChange change) => urlChangeCompleter.complete(change),
      );

      await controller.setPlatformNavigationDelegate(navigationDelegate);

      webViewObserveValue(
        mockWebView,
        'URL',
        mockWebView,
        <KeyValueChangeKey, Object?>{KeyValueChangeKey.newValue: null},
      );

      final UrlChange urlChange = await urlChangeCompleter.future;
      expect(urlChange.url, null);
    });

    test('webViewIdentifier', () {
      final PigeonInstanceManager instanceManager = TestInstanceManager();

      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();
      when(mockWebView.pigeon_copy()).thenReturn(MockUIViewWKWebView());
      instanceManager.addHostCreatedInstance(mockWebView, 0);

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
        instanceManager: instanceManager,
      );

      expect(
        controller.webViewIdentifier,
        instanceManager.getIdentifier(mockWebView),
      );
    });

    test('setOnPermissionRequest', () async {
      final WebKitWebViewController controller = createControllerWithMocks();

      late final PlatformWebViewPermissionRequest permissionRequest;
      await controller.setOnPlatformPermissionRequest(
        (PlatformWebViewPermissionRequest request) async {
          permissionRequest = request;
          await request.grant();
        },
      );

      final Future<PermissionDecision> Function(
        WKUIDelegate instance,
        WKWebView webView,
        WKSecurityOrigin origin,
        WKFrameInfo frame,
        MediaCaptureType type,
      ) onPermissionRequestCallback =
          CapturingUIDelegate.lastCreatedDelegate.requestMediaCapturePermission;

      final PermissionDecision decision = await onPermissionRequestCallback(
        CapturingUIDelegate.lastCreatedDelegate,
        MockWKWebView(),
        WKSecurityOrigin.pigeon_detached(
          host: '',
          port: 0,
          securityProtocol: '',
          pigeon_instanceManager: TestInstanceManager(),
        ),
        WKFrameInfo.pigeon_detached(
          isMainFrame: false,
          request: MockURLRequest(),
          pigeon_instanceManager: TestInstanceManager(),
        ),
        MediaCaptureType.microphone,
      );

      expect(permissionRequest.types, <WebViewPermissionResourceType>[
        WebViewPermissionResourceType.microphone,
      ]);
      expect(decision, PermissionDecision.grant);
    });

    group('JavaScript Dialog', () {
      test('setOnJavaScriptAlertPanel', () async {
        final WebKitWebViewController controller = createControllerWithMocks();
        late final String message;
        await controller.setOnJavaScriptAlertDialog(
            (JavaScriptAlertDialogRequest request) async {
          message = request.message;
          return;
        });

        const String callbackMessage = 'Message';
        final Future<void> Function(
          WKUIDelegate,
          WKWebView,
          String message,
          WKFrameInfo frame,
        ) onJavaScriptAlertPanel =
            CapturingUIDelegate.lastCreatedDelegate.runJavaScriptAlertPanel!;

        final MockURLRequest mockRequest = MockURLRequest();
        when(mockRequest.getUrl()).thenAnswer(
          (_) => Future<String>.value('https://google.com'),
        );

        await onJavaScriptAlertPanel(
          CapturingUIDelegate.lastCreatedDelegate,
          MockWKWebView(),
          callbackMessage,
          WKFrameInfo.pigeon_detached(
            isMainFrame: false,
            request: mockRequest,
            pigeon_instanceManager: TestInstanceManager(),
          ),
        );

        expect(message, callbackMessage);
      });

      test('setOnJavaScriptConfirmPanel', () async {
        final WebKitWebViewController controller = createControllerWithMocks();
        late final String message;
        const bool callbackReturnValue = true;
        await controller.setOnJavaScriptConfirmDialog(
            (JavaScriptConfirmDialogRequest request) async {
          message = request.message;
          return callbackReturnValue;
        });

        const String callbackMessage = 'Message';
        final Future<bool> Function(
          WKUIDelegate,
          WKWebView,
          String message,
          WKFrameInfo frame,
        ) onJavaScriptConfirmPanel =
            CapturingUIDelegate.lastCreatedDelegate.runJavaScriptConfirmPanel;

        final MockURLRequest mockRequest = MockURLRequest();
        when(mockRequest.getUrl()).thenAnswer(
          (_) => Future<String>.value('https://google.com'),
        );

        final bool returnValue = await onJavaScriptConfirmPanel(
          CapturingUIDelegate.lastCreatedDelegate,
          MockWKWebView(),
          callbackMessage,
          WKFrameInfo.pigeon_detached(
            isMainFrame: false,
            request: mockRequest,
            pigeon_instanceManager: TestInstanceManager(),
          ),
        );

        expect(message, callbackMessage);
        expect(returnValue, callbackReturnValue);
      });

      test('setOnJavaScriptTextInputPanel', () async {
        final WebKitWebViewController controller = createControllerWithMocks();
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
        final Future<String?> Function(
          WKUIDelegate,
          WKWebView,
          String prompt,
          String? defaultText,
          WKFrameInfo frame,
        ) onJavaScriptTextInputPanel = CapturingUIDelegate
            .lastCreatedDelegate.runJavaScriptTextInputPanel!;

        final MockURLRequest mockRequest = MockURLRequest();
        when(mockRequest.getUrl()).thenAnswer(
          (_) => Future<String>.value('https://google.com'),
        );

        final String? returnValue = await onJavaScriptTextInputPanel(
          CapturingUIDelegate.lastCreatedDelegate,
          MockWKWebView(),
          callbackMessage,
          callbackDefaultText,
          WKFrameInfo.pigeon_detached(
            isMainFrame: false,
            request: mockRequest,
            pigeon_instanceManager: TestInstanceManager(),
          ),
        );

        expect(message, callbackMessage);
        expect(defaultText, callbackDefaultText);
        expect(returnValue, callbackReturnValue);
      });
    });

    test('inspectable', () async {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (_, {dynamic observeValue}) => mockWebView,
      );

      await controller.setInspectable(true);
      verify(mockWebView.setInspectable(true));
    });

    group('Console logging', () {
      test('setConsoleLogCallback should inject the correct JavaScript',
          () async {
        final MockWKUserContentController mockUserContentController =
            MockWKUserContentController();
        final WebKitWebViewController controller = createControllerWithMocks(
          mockUserContentController: mockUserContentController,
        );

        await controller
            .setOnConsoleMessage((JavaScriptConsoleMessage message) {});

        final List<dynamic> capturedScripts =
            verify(mockUserContentController.addUserScript(captureAny))
                .captured
                .toList();
        final WKUserScript messageHandlerScript =
            capturedScripts[0] as WKUserScript;
        final WKUserScript overrideConsoleScript =
            capturedScripts[1] as WKUserScript;

        expect(messageHandlerScript.isForMainFrameOnly, isFalse);
        expect(messageHandlerScript.injectionTime,
            UserScriptInjectionTime.atDocumentStart);
        expect(messageHandlerScript.source,
            'window.fltConsoleMessage = webkit.messageHandlers.fltConsoleMessage;');

        expect(overrideConsoleScript.isForMainFrameOnly, isTrue);
        expect(overrideConsoleScript.injectionTime,
            UserScriptInjectionTime.atDocumentStart);
        expect(overrideConsoleScript.source, '''
var _flutter_webview_plugin_overrides = _flutter_webview_plugin_overrides || {
  removeCyclicObject: function() {
    const traversalStack = [];
    return function (k, v) {
      if (typeof v !== "object" || v === null) { return v; }
      const currentParentObj = this;
      while (
        traversalStack.length > 0 &&
        traversalStack[traversalStack.length - 1] !== currentParentObj
      ) {
        traversalStack.pop();
      }
      if (traversalStack.includes(v)) { return; }
      traversalStack.push(v);
      return v;
    };
  },
  log: function (type, args) {
    var message =  Object.values(args)
        .map(v => typeof(v) === "undefined" ? "undefined" : typeof(v) === "object" ? JSON.stringify(v, _flutter_webview_plugin_overrides.removeCyclicObject()) : v.toString())
        .map(v => v.substring(0, 3000)) // Limit msg to 3000 chars
        .join(", ");

    var log = {
      level: type,
      message: message
    };

    window.webkit.messageHandlers.fltConsoleMessage.postMessage(JSON.stringify(log));
  }
};

let originalLog = console.log;
let originalInfo = console.info;
let originalWarn = console.warn;
let originalError = console.error;
let originalDebug = console.debug;

console.log = function() { _flutter_webview_plugin_overrides.log("log", arguments); originalLog.apply(null, arguments) };
console.info = function() { _flutter_webview_plugin_overrides.log("info", arguments); originalInfo.apply(null, arguments) };
console.warn = function() { _flutter_webview_plugin_overrides.log("warning", arguments); originalWarn.apply(null, arguments) };
console.error = function() { _flutter_webview_plugin_overrides.log("error", arguments); originalError.apply(null, arguments) };
console.debug = function() { _flutter_webview_plugin_overrides.log("debug", arguments); originalDebug.apply(null, arguments) };

window.addEventListener("error", function(e) {
  log("error", e.message + " at " + e.filename + ":" + e.lineno + ":" + e.colno);
});
      ''');
      });

      test('setConsoleLogCallback should parse levels correctly', () async {
        final MockWKUserContentController mockUserContentController =
            MockWKUserContentController();
        final WebKitWebViewController controller = createControllerWithMocks(
          mockUserContentController: mockUserContentController,
        );

        final Map<JavaScriptLogLevel, String> logs =
            <JavaScriptLogLevel, String>{};
        await controller.setOnConsoleMessage(
            (JavaScriptConsoleMessage message) =>
                logs[message.level] = message.message);

        final List<dynamic> capturedParameters = verify(
                mockUserContentController.addScriptMessageHandler(
                    captureAny, any))
            .captured
            .toList();
        final WKScriptMessageHandler scriptMessageHandler =
            capturedParameters[0] as WKScriptMessageHandler;

        scriptMessageHandler.didReceiveScriptMessage(
          scriptMessageHandler,
          mockUserContentController,
          WKScriptMessage.pigeon_detached(
            name: 'test',
            body: '{"level": "debug", "message": "Debug message"}',
            pigeon_instanceManager: TestInstanceManager(),
          ),
        );
        scriptMessageHandler.didReceiveScriptMessage(
          scriptMessageHandler,
          mockUserContentController,
          WKScriptMessage.pigeon_detached(
            name: 'test',
            body: '{"level": "error", "message": "Error message"}',
            pigeon_instanceManager: TestInstanceManager(),
          ),
        );
        scriptMessageHandler.didReceiveScriptMessage(
          scriptMessageHandler,
          mockUserContentController,
          WKScriptMessage.pigeon_detached(
            name: 'test',
            body: '{"level": "info", "message": "Info message"}',
            pigeon_instanceManager: TestInstanceManager(),
          ),
        );
        scriptMessageHandler.didReceiveScriptMessage(
          scriptMessageHandler,
          mockUserContentController,
          WKScriptMessage.pigeon_detached(
            name: 'test',
            body: '{"level": "log", "message": "Log message"}',
            pigeon_instanceManager: TestInstanceManager(),
          ),
        );
        scriptMessageHandler.didReceiveScriptMessage(
          scriptMessageHandler,
          mockUserContentController,
          WKScriptMessage.pigeon_detached(
            name: 'test',
            body: '{"level": "warning", "message": "Warning message"}',
            pigeon_instanceManager: TestInstanceManager(),
          ),
        );

        expect(logs.length, 5);
        expect(logs[JavaScriptLogLevel.debug], 'Debug message');
        expect(logs[JavaScriptLogLevel.error], 'Error message');
        expect(logs[JavaScriptLogLevel.info], 'Info message');
        expect(logs[JavaScriptLogLevel.log], 'Log message');
        expect(logs[JavaScriptLogLevel.warning], 'Warning message');
      });
    });

    test('setOnCanGoBackChange', () async {
      final MockUIViewWKWebView mockWebView = MockUIViewWKWebView();

      late final void Function(
        NSObject,
        String? keyPath,
        NSObject? object,
        Map<KeyValueChangeKey, Object>? change,
      ) webViewObserveValue;

      final WebKitWebViewController controller = createControllerWithMocks(
        createMockWebView: (
          WKWebViewConfiguration configuration, {
          void Function(
            NSObject,
            String? keyPath,
            NSObject? object,
            Map<KeyValueChangeKey, Object>? change,
          )? observeValue,
        }) {
          webViewObserveValue = observeValue!;
          return mockWebView;
        },
      );

      verify(
        mockWebView.addObserver(
          mockWebView,
          'canGoBack',
          <KeyValueObservingOptions>[KeyValueObservingOptions.newValue],
        ),
      );

      late final bool callbackCanGoBack;

      await controller.setOnCanGoBackChange(
        (bool canGoBack) => callbackCanGoBack = canGoBack,
      );

      webViewObserveValue(
        mockWebView,
        'canGoBack',
        mockWebView,
        <KeyValueChangeKey, Object>{KeyValueChangeKey.newValue: true},
      );

      expect(callbackCanGoBack, true);
    });

    test('setOnScrollPositionChange', () async {
      final WebKitWebViewController controller = createControllerWithMocks();

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final Completer<ScrollPositionChange> changeCompleter =
          Completer<ScrollPositionChange>();
      await controller.setOnScrollPositionChange(
        (ScrollPositionChange change) {
          changeCompleter.complete(change);
        },
      );

      final void Function(
        UIScrollViewDelegate,
        UIScrollView scrollView,
        double,
        double,
      ) onScrollViewDidScroll = CapturingUIScrollViewDelegate
          .lastCreatedDelegate.scrollViewDidScroll!;

      final MockUIScrollView mockUIScrollView = MockUIScrollView();
      onScrollViewDidScroll(
        CapturingUIScrollViewDelegate.lastCreatedDelegate,
        mockUIScrollView,
        1.0,
        2.0,
      );

      final ScrollPositionChange change = await changeCompleter.future;
      expect(change.x, 1.0);
      expect(change.y, 2.0);

      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('WebKitJavaScriptChannelParams', () {
    test('onMessageReceived', () async {
      late final WKScriptMessageHandler messageHandler;

      final WebKitProxy webKitProxy = WebKitProxy(
        newWKScriptMessageHandler: ({
          required void Function(
            WKScriptMessageHandler,
            WKUserContentController userContentController,
            WKScriptMessage message,
          ) didReceiveScriptMessage,
        }) {
          messageHandler = WKScriptMessageHandler.pigeon_detached(
            didReceiveScriptMessage: didReceiveScriptMessage,
            pigeon_instanceManager: TestInstanceManager(),
          );
          return messageHandler;
        },
      );

      late final String callbackMessage;
      WebKitJavaScriptChannelParams(
        name: 'name',
        onMessageReceived: (JavaScriptMessage message) {
          callbackMessage = message.message;
        },
        webKitProxy: webKitProxy,
      );

      messageHandler.didReceiveScriptMessage(
        messageHandler,
        MockWKUserContentController(),
        WKScriptMessage.pigeon_detached(
          name: 'name',
          body: 'myMessage',
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(callbackMessage, 'myMessage');
    });
  });
}

// Records the last created instance of itself.
class CapturingNavigationDelegate extends WKNavigationDelegate {
  CapturingNavigationDelegate({
    super.didFinishNavigation,
    super.didStartProvisionalNavigation,
    required super.decidePolicyForNavigationResponse,
    super.didFailNavigation,
    super.didFailProvisionalNavigation,
    required super.decidePolicyForNavigationAction,
    super.webViewWebContentProcessDidTerminate,
    required super.didReceiveAuthenticationChallenge,
  }) : super.pigeon_detached(pigeon_instanceManager: TestInstanceManager()) {
    lastCreatedDelegate = this;
  }
  static CapturingNavigationDelegate lastCreatedDelegate =
      CapturingNavigationDelegate(
    decidePolicyForNavigationAction: (_, __, ___) async {
      return NavigationActionPolicy.cancel;
    },
    decidePolicyForNavigationResponse: (_, __, ___) async {
      return NavigationResponsePolicy.cancel;
    },
    didReceiveAuthenticationChallenge: (_, __, ___) async {
      return <Object?>[
        UrlSessionAuthChallengeDisposition.performDefaultHandling,
        null,
      ];
    },
  );
}

// Records the last created instance of itself.
class CapturingUIDelegate extends WKUIDelegate {
  CapturingUIDelegate({
    super.onCreateWebView,
    required super.requestMediaCapturePermission,
    super.runJavaScriptAlertPanel,
    required super.runJavaScriptConfirmPanel,
    super.runJavaScriptTextInputPanel,
  }) : super.pigeon_detached(pigeon_instanceManager: TestInstanceManager()) {
    lastCreatedDelegate = this;
  }
  static CapturingUIDelegate lastCreatedDelegate = CapturingUIDelegate(
    requestMediaCapturePermission: (_, __, ___, ____, _____) async {
      return PermissionDecision.deny;
    },
    runJavaScriptConfirmPanel: (_, __, ___, ____) async {
      return false;
    },
  );
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

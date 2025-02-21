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
import 'package:webview_flutter_platform_interface/src/webview_flutter_platform_interface_legacy.dart';
import 'package:webview_flutter_wkwebview/src/common/platform_webview.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit.g.dart';
import 'package:webview_flutter_wkwebview/src/common/webkit_constants.dart';
import 'package:webview_flutter_wkwebview/src/legacy/web_kit_webview_widget.dart';

import 'web_kit_webview_widget_test.mocks.dart';

@GenerateMocks(<Type>[
  UIScrollView,
  URLRequest,
  WKNavigationDelegate,
  WKPreferences,
  WKScriptMessageHandler,
  WKWebView,
  UIViewWKWebView,
  WKWebViewConfiguration,
  WKWebsiteDataStore,
  WKUIDelegate,
  WKUserContentController,
  JavascriptChannelRegistry,
  WebViewPlatformCallbacksHandler,
  WebViewWidgetProxy,
  WKWebpagePreferences,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebKitWebViewWidget', () {
    _WebViewMocks configureMocks() {
      final _WebViewMocks mocks = _WebViewMocks(
          webView: MockUIViewWKWebView(),
          webViewWidgetProxy: MockWebViewWidgetProxy(),
          userContentController: MockWKUserContentController(),
          preferences: MockWKPreferences(),
          webViewConfiguration: MockWKWebViewConfiguration(),
          uiDelegate: MockWKUIDelegate(),
          scrollView: MockUIScrollView(),
          websiteDataStore: MockWKWebsiteDataStore(),
          navigationDelegate: MockWKNavigationDelegate(),
          callbacksHandler: MockWebViewPlatformCallbacksHandler(),
          javascriptChannelRegistry: MockJavascriptChannelRegistry(),
          webpagePreferences: MockWKWebpagePreferences());

      when(
        mocks.webViewWidgetProxy.createWebView(
          any,
          observeValue: anyNamed('observeValue'),
        ),
      ).thenReturn(PlatformWebView.fromNativeWebView(mocks.webView));
      when(
        mocks.webViewWidgetProxy.createUIDelgate(
          onCreateWebView: captureAnyNamed('onCreateWebView'),
        ),
      ).thenReturn(mocks.uiDelegate);
      when(mocks.webViewWidgetProxy.createNavigationDelegate(
        didFinishNavigation: anyNamed('didFinishNavigation'),
        didStartProvisionalNavigation:
            anyNamed('didStartProvisionalNavigation'),
        decidePolicyForNavigationAction:
            anyNamed('decidePolicyForNavigationAction'),
        didFailNavigation: anyNamed('didFailNavigation'),
        didFailProvisionalNavigation: anyNamed('didFailProvisionalNavigation'),
        webViewWebContentProcessDidTerminate:
            anyNamed('webViewWebContentProcessDidTerminate'),
        decidePolicyForNavigationResponse:
            anyNamed('decidePolicyForNavigationResponse'),
        didReceiveAuthenticationChallenge:
            anyNamed('didReceiveAuthenticationChallenge'),
      )).thenReturn(mocks.navigationDelegate);
      when(mocks.webView.configuration).thenReturn(mocks.webViewConfiguration);
      when(mocks.webViewConfiguration.getUserContentController()).thenAnswer(
        (_) => Future<WKUserContentController>.value(
          mocks.userContentController,
        ),
      );
      when(mocks.webViewConfiguration.getPreferences())
          .thenAnswer((_) => Future<WKPreferences>.value(mocks.preferences));
      when(mocks.webViewConfiguration.getDefaultWebpagePreferences())
          .thenAnswer((_) =>
              Future<WKWebpagePreferences>.value(mocks.webpagePreferences));

      when(mocks.webView.scrollView).thenReturn(mocks.scrollView);

      when(mocks.webViewConfiguration.getWebsiteDataStore()).thenAnswer(
        (_) => Future<WKWebsiteDataStore>.value(mocks.websiteDataStore),
      );
      return mocks;
    }

    // Builds a WebViewCupertinoWidget with default parameters and returns its
    // controller.
    Future<WebKitWebViewPlatformController> buildWidget(
      WidgetTester tester,
      _WebViewMocks mocks, {
      CreationParams? creationParams,
      bool hasNavigationDelegate = false,
      bool hasProgressTracking = false,
    }) async {
      final Completer<WebKitWebViewPlatformController> testController =
          Completer<WebKitWebViewPlatformController>();
      await tester.pumpWidget(WebKitWebViewWidget(
        creationParams: creationParams ??
            CreationParams(
                webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: hasNavigationDelegate,
              hasProgressTracking: hasProgressTracking,
            )),
        callbacksHandler: mocks.callbacksHandler,
        javascriptChannelRegistry: mocks.javascriptChannelRegistry,
        webViewProxy: mocks.webViewWidgetProxy,
        configuration: mocks.webViewConfiguration,
        onBuildWidget: (WebKitWebViewPlatformController controller) {
          testController.complete(controller);
          return Container();
        },
      ));
      await tester.pumpAndSettle();
      return testController.future;
    }

    testWidgets('build WebKitWebViewWidget', (WidgetTester tester) async {
      final _WebViewMocks mocks = configureMocks();
      await buildWidget(tester, mocks);
    });

    testWidgets('Requests to open a new window loads request in same window',
        (WidgetTester tester) async {
      final _WebViewMocks mocks = configureMocks();
      await buildWidget(tester, mocks);

      final void Function(
        WKUIDelegate,
        WKWebView,
        WKWebViewConfiguration,
        WKNavigationAction,
      ) onCreateWebView = verify(mocks.webViewWidgetProxy.createUIDelgate(
              onCreateWebView: captureAnyNamed('onCreateWebView')))
          .captured
          .single as void Function(
        WKUIDelegate,
        WKWebView,
        WKWebViewConfiguration,
        WKNavigationAction,
      );

      final URLRequest request = URLRequest.pigeon_detached(
        pigeon_instanceManager: TestInstanceManager(),
      );
      onCreateWebView(
        MockWKUIDelegate(),
        mocks.webView,
        mocks.webViewConfiguration,
        WKNavigationAction.pigeon_detached(
          request: request,
          targetFrame: WKFrameInfo.pigeon_detached(
            isMainFrame: false,
            request: request,
            pigeon_instanceManager: TestInstanceManager(),
          ),
          navigationType: NavigationType.linkActivated,
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      verify(mocks.webView.load(request));
    });

    group('CreationParams', () {
      testWidgets('initialUrl', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        when(
          mocks.webViewWidgetProxy.createRequest(url: 'https://www.google.com'),
        ).thenReturn(MockURLRequest());

        await buildWidget(
          tester,
          mocks,
          creationParams: CreationParams(
            initialUrl: 'https://www.google.com',
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        verify(mocks.webView.load(captureAny)).captured.single as URLRequest;
      });

      testWidgets('backgroundColor', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();

        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        await buildWidget(
          tester,
          mocks,
          creationParams: CreationParams(
            backgroundColor: Colors.red,
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        verify(mocks.webView.setOpaque(false));
        verify(mocks.webView.setBackgroundColor(Colors.transparent.value));
        verify(mocks.scrollView.setBackgroundColor(Colors.red.value));

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('userAgent', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        await buildWidget(
          tester,
          mocks,
          creationParams: CreationParams(
            userAgent: 'MyUserAgent',
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        verify(mocks.webView.setCustomUserAgent('MyUserAgent'));
      });

      testWidgets('autoMediaPlaybackPolicy true', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        await buildWidget(
          tester,
          mocks,
          creationParams: CreationParams(
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        verify(mocks.webViewConfiguration
            .setMediaTypesRequiringUserActionForPlayback(
          AudiovisualMediaType.all,
        ));
      });

      testWidgets('autoMediaPlaybackPolicy false', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        await buildWidget(
          tester,
          mocks,
          creationParams: CreationParams(
            autoMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        verify(mocks.webViewConfiguration
            .setMediaTypesRequiringUserActionForPlayback(
          AudiovisualMediaType.none,
        ));
      });

      testWidgets('javascriptChannelNames', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        when(
          mocks.webViewWidgetProxy.createScriptMessageHandler(
            didReceiveScriptMessage: anyNamed('didReceiveScriptMessage'),
          ),
        ).thenReturn(
          MockWKScriptMessageHandler(),
        );

        await buildWidget(
          tester,
          mocks,
          creationParams: CreationParams(
            javascriptChannelNames: <String>{'a', 'b'},
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        final List<dynamic> javaScriptChannels = verify(
          mocks.userContentController.addScriptMessageHandler(
            captureAny,
            captureAny,
          ),
        ).captured;
        expect(
          javaScriptChannels[0],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[1], 'a');
        expect(
          javaScriptChannels[2],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[3], 'b');
      });

      group('WebSettings', () {
        testWidgets('javascriptMode', (WidgetTester tester) async {
          final _WebViewMocks mocks = configureMocks();
          await buildWidget(
            tester,
            mocks,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.absent(),
                javascriptMode: JavascriptMode.unrestricted,
                hasNavigationDelegate: false,
              ),
            ),
          );

          verify(mocks.webpagePreferences.setAllowsContentJavaScript(true));
        });

        testWidgets('userAgent', (WidgetTester tester) async {
          final _WebViewMocks mocks = configureMocks();
          await buildWidget(
            tester,
            mocks,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.of('myUserAgent'),
                hasNavigationDelegate: false,
              ),
            ),
          );

          verify(mocks.webView.setCustomUserAgent('myUserAgent'));
        });

        testWidgets(
          'enabling zoom re-adds JavaScript channels',
          (WidgetTester tester) async {
            final _WebViewMocks mocks = configureMocks();
            when(
              mocks.webViewWidgetProxy.createScriptMessageHandler(
                didReceiveScriptMessage: anyNamed('didReceiveScriptMessage'),
              ),
            ).thenReturn(
              MockWKScriptMessageHandler(),
            );

            final WebKitWebViewPlatformController testController =
                await buildWidget(
              tester,
              mocks,
              creationParams: CreationParams(
                webSettings: WebSettings(
                  userAgent: const WebSetting<String?>.absent(),
                  zoomEnabled: false,
                  hasNavigationDelegate: false,
                ),
                javascriptChannelNames: <String>{'myChannel'},
              ),
            );

            clearInteractions(mocks.userContentController);

            await testController.updateSettings(WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              zoomEnabled: true,
            ));

            final List<dynamic> javaScriptChannels = verifyInOrder(<Object>[
              mocks.userContentController.removeAllUserScripts(),
              mocks.userContentController
                  .removeScriptMessageHandler('myChannel'),
              mocks.userContentController.addScriptMessageHandler(
                captureAny,
                captureAny,
              ),
            ]).captured[2];

            expect(
              javaScriptChannels[0],
              isA<WKScriptMessageHandler>(),
            );
            expect(javaScriptChannels[1], 'myChannel');
          },
        );

        testWidgets(
          'enabling zoom removes script',
          (WidgetTester tester) async {
            final _WebViewMocks mocks = configureMocks();
            final WebKitWebViewPlatformController testController =
                await buildWidget(
              tester,
              mocks,
              creationParams: CreationParams(
                webSettings: WebSettings(
                  userAgent: const WebSetting<String?>.absent(),
                  zoomEnabled: false,
                  hasNavigationDelegate: false,
                ),
              ),
            );

            clearInteractions(mocks.userContentController);

            await testController.updateSettings(WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              zoomEnabled: true,
            ));

            verify(mocks.userContentController.removeAllUserScripts());
            verifyNever(mocks.userContentController.addScriptMessageHandler(
              any,
              any,
            ));
          },
        );

        testWidgets('zoomEnabled is false', (WidgetTester tester) async {
          final _WebViewMocks mocks = configureMocks();
          await buildWidget(
            tester,
            mocks,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.absent(),
                zoomEnabled: false,
                hasNavigationDelegate: false,
              ),
            ),
          );

          final WKUserScript zoomScript =
              verify(mocks.userContentController.addUserScript(captureAny))
                  .captured
                  .first as WKUserScript;
          expect(zoomScript.isForMainFrameOnly, isTrue);
          expect(
              zoomScript.injectionTime, UserScriptInjectionTime.atDocumentEnd);
          expect(
            zoomScript.source,
            "var meta = document.createElement('meta');\n"
            "meta.name = 'viewport';\n"
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, "
            "user-scalable=no';\n"
            "var head = document.getElementsByTagName('head')[0];head.appendChild(meta);",
          );
        });

        testWidgets('allowsInlineMediaPlayback', (WidgetTester tester) async {
          final _WebViewMocks mocks = configureMocks();
          await buildWidget(
            tester,
            mocks,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.absent(),
                allowsInlineMediaPlayback: true,
              ),
            ),
          );

          verify(mocks.webViewConfiguration.setAllowsInlineMediaPlayback(true));
        });
      });
    });

    group('WebKitWebViewPlatformController', () {
      testWidgets('loadFile', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        await testController.loadFile('/path/to/file.html');
        verify(mocks.webView.loadFileUrl('/path/to/file.html', '/path/to'));
      });
      //
      testWidgets('loadFlutterAsset', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        await testController.loadFlutterAsset('test_assets/index.html');
        verify(mocks.webView.loadFlutterAsset('test_assets/index.html'));
      });

      testWidgets('loadHtmlString', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        const String htmlString =
            '<html lang=""><body>Test data.</body></html>';
        await testController.loadHtmlString(htmlString, baseUrl: 'baseUrl');

        verify(mocks.webView.loadHtmlString(
          '<html lang=""><body>Test data.</body></html>',
          'baseUrl',
        ));
      });

      testWidgets('loadUrl', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(
          mocks.webViewWidgetProxy.createRequest(url: 'https://www.google.com'),
        ).thenReturn(MockURLRequest());

        await testController.loadUrl(
          'https://www.google.com',
          <String, String>{'a': 'header'},
        );

        final URLRequest request = verify(mocks.webView.load(captureAny))
            .captured
            .single as URLRequest;
        verify(request.setAllHttpHeaderFields(<String, String>{'a': 'header'}));
      });

      group('loadRequest', () {
        testWidgets('Throws ArgumentError for empty scheme',
            (WidgetTester tester) async {
          final _WebViewMocks mocks = configureMocks();
          final WebKitWebViewPlatformController testController =
              await buildWidget(tester, mocks);

          expect(
              () async => testController.loadRequest(
                    WebViewRequest(
                      uri: Uri.parse('www.google.com'),
                      method: WebViewRequestMethod.get,
                    ),
                  ),
              throwsA(const TypeMatcher<ArgumentError>()));
        });

        testWidgets('GET without headers', (WidgetTester tester) async {
          final _WebViewMocks mocks = configureMocks();
          final WebKitWebViewPlatformController testController =
              await buildWidget(tester, mocks);

          when(
            mocks.webViewWidgetProxy
                .createRequest(url: 'https://www.google.com'),
          ).thenReturn(MockURLRequest());

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.get,
          ));

          final URLRequest request = verify(mocks.webView.load(captureAny))
              .captured
              .single as URLRequest;
          verify(request.setAllHttpHeaderFields(<String, String>{}));
          verify(request.setHttpMethod('get'));
        });

        testWidgets('GET with headers', (WidgetTester tester) async {
          final _WebViewMocks mocks = configureMocks();
          final WebKitWebViewPlatformController testController =
              await buildWidget(tester, mocks);

          when(
            mocks.webViewWidgetProxy
                .createRequest(url: 'https://www.google.com'),
          ).thenReturn(MockURLRequest());

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.get,
            headers: <String, String>{'a': 'header'},
          ));

          final URLRequest request = verify(mocks.webView.load(captureAny))
              .captured
              .single as URLRequest;
          verify(
            request.setAllHttpHeaderFields(<String, String>{'a': 'header'}),
          );
          verify(request.setHttpMethod('get'));
        });

        testWidgets('POST without body', (WidgetTester tester) async {
          final _WebViewMocks mocks = configureMocks();
          final WebKitWebViewPlatformController testController =
              await buildWidget(tester, mocks);

          when(
            mocks.webViewWidgetProxy
                .createRequest(url: 'https://www.google.com'),
          ).thenReturn(MockURLRequest());

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.post,
          ));

          final URLRequest request = verify(mocks.webView.load(captureAny))
              .captured
              .single as URLRequest;
          verify(request.setHttpMethod('post'));
        });

        testWidgets('POST with body', (WidgetTester tester) async {
          final _WebViewMocks mocks = configureMocks();
          final WebKitWebViewPlatformController testController =
              await buildWidget(tester, mocks);

          when(
            mocks.webViewWidgetProxy
                .createRequest(url: 'https://www.google.com'),
          ).thenReturn(MockURLRequest());

          await testController.loadRequest(WebViewRequest(
              uri: Uri.parse('https://www.google.com'),
              method: WebViewRequestMethod.post,
              body: Uint8List.fromList('Test Body'.codeUnits)));

          final URLRequest request = verify(mocks.webView.load(captureAny))
              .captured
              .single as URLRequest;
          verify(request.setHttpMethod('post'));
          verify(
            request.setHttpBody(Uint8List.fromList('Test Body'.codeUnits)),
          );
        });
      });

      testWidgets('canGoBack', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.canGoBack()).thenAnswer(
          (_) => Future<bool>.value(false),
        );
        expect(testController.canGoBack(), completion(false));
      });

      testWidgets('canGoForward', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.canGoForward()).thenAnswer(
          (_) => Future<bool>.value(true),
        );
        expect(testController.canGoForward(), completion(true));
      });

      testWidgets('goBack', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        await testController.goBack();
        verify(mocks.webView.goBack());
      });

      testWidgets('goForward', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        await testController.goForward();
        verify(mocks.webView.goForward());
      });

      testWidgets('reload', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        await testController.reload();
        verify(mocks.webView.reload());
      });

      testWidgets('evaluateJavascript', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          testController.evaluateJavascript('runJavaScript'),
          completion('returnString'),
        );
      });

      testWidgets('evaluateJavascript with null return value',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<Object?>.value(),
        );
        // The legacy implementation of webview_flutter_wkwebview would convert
        // objects to strings before returning them to Dart. This verifies null
        // is represented the way it is in Objective-C.
        expect(
          testController.evaluateJavascript('runJavaScript'),
          completion('(null)'),
        );
      });

      testWidgets('evaluateJavascript with bool return value',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<Object?>.value(true),
        );
        // The legacy implementation of webview_flutter_wkwebview would convert
        // objects to strings before returning them to Dart. This verifies bool
        // is represented the way it is in Objective-C.
        // `NSNumber.description` converts bool values to a 1 or 0.
        expect(
          testController.evaluateJavascript('runJavaScript'),
          completion('1'),
        );
      });

      testWidgets('evaluateJavascript with double return value',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<Object?>.value(1.0),
        );
        // The legacy implementation of webview_flutter_wkwebview would convert
        // objects to strings before returning them to Dart. This verifies
        // double is represented the way it is in Objective-C. If a double
        // doesn't contain any decimal values, it gets truncated to an int.
        // This should be happening because NSNumber converts float values
        // with no decimals to an int when using `NSNumber.description`.
        expect(
          testController.evaluateJavascript('runJavaScript'),
          completion('1'),
        );
      });

      testWidgets('evaluateJavascript with list return value',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<Object?>.value(<Object?>[1, 'string', null]),
        );
        // The legacy implementation of webview_flutter_wkwebview would convert
        // objects to strings before returning them to Dart. This verifies list
        // is represented the way it is in Objective-C.
        expect(
          testController.evaluateJavascript('runJavaScript'),
          completion('(1,string,"<null>")'),
        );
      });

      testWidgets('evaluateJavascript with map return value',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<Object?>.value(<Object?, Object?>{
            1: 'string',
            null: null,
          }),
        );
        // The legacy implementation of webview_flutter_wkwebview would convert
        // objects to strings before returning them to Dart. This verifies map
        // is represented the way it is in Objective-C.
        expect(
          testController.evaluateJavascript('runJavaScript'),
          completion('{1 = string;"<null>" = "<null>"}'),
        );
      });

      testWidgets('evaluateJavascript throws exception',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.evaluateJavaScript('runJavaScript'))
            .thenThrow(Error());
        expect(
          testController.evaluateJavascript('runJavaScript'),
          throwsA(isA<Error>()),
        );
      });

      testWidgets('runJavascriptReturningResult', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          testController.runJavascriptReturningResult('runJavaScript'),
          completion('returnString'),
        );
      });

      testWidgets(
          'runJavascriptReturningResult throws error on null return value',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<String?>.value(),
        );
        expect(
          () => testController.runJavascriptReturningResult('runJavaScript'),
          throwsArgumentError,
        );
      });

      testWidgets('runJavascriptReturningResult with bool return value',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<Object?>.value(false),
        );
        // The legacy implementation of webview_flutter_wkwebview would convert
        // objects to strings before returning them to Dart. This verifies bool
        // is represented the way it is in Objective-C.
        // `NSNumber.description` converts bool values to a 1 or 0.
        expect(
          testController.runJavascriptReturningResult('runJavaScript'),
          completion('0'),
        );
      });

      testWidgets('runJavascript', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          testController.runJavascript('runJavaScript'),
          completes,
        );
      });

      testWidgets(
          'runJavascript ignores exception with unsupported javascript type',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.evaluateJavaScript('runJavaScript'))
            .thenThrow(PlatformException(
          code: '',
          details: NSError.pigeon_detached(
            code: WKErrorCode.javaScriptResultTypeIsUnsupported,
            domain: '',
            userInfo: const <String, Object?>{},
          ),
        ));
        expect(
          testController.runJavascript('runJavaScript'),
          completes,
        );
      });

      testWidgets('getTitle', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.getTitle())
            .thenAnswer((_) => Future<String>.value('Web Title'));
        expect(testController.getTitle(), completion('Web Title'));
      });

      testWidgets('currentUrl', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.webView.getUrl())
            .thenAnswer((_) => Future<String>.value('myUrl.com'));
        expect(testController.currentUrl(), completion('myUrl.com'));
      });

      testWidgets('scrollTo', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        await testController.scrollTo(2, 4);
        verify(mocks.scrollView.setContentOffset(2.0, 4.0));

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('scrollBy', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        await testController.scrollBy(2, 4);
        verify(mocks.scrollView.scrollBy(2.0, 4.0));

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('getScrollX', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        when(mocks.scrollView.getContentOffset()).thenAnswer(
            (_) => Future<List<double>>.value(const <double>[8.0, 16.0]));
        expect(testController.getScrollX(), completion(8.0));

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('getScrollY', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        when(mocks.scrollView.getContentOffset()).thenAnswer(
            (_) => Future<List<double>>.value(const <double>[8.0, 16.0]));
        expect(testController.getScrollY(), completion(16.0));

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('clearCache', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);
        when(
          mocks.websiteDataStore.removeDataOfTypes(
            <WebsiteDataType>[
              WebsiteDataType.memoryCache,
              WebsiteDataType.diskCache,
              WebsiteDataType.offlineWebApplicationCache,
              WebsiteDataType.localStorage,
            ],
            0,
          ),
        ).thenAnswer((_) => Future<bool>.value(false));

        expect(testController.clearCache(), completes);
      });

      testWidgets('addJavascriptChannels', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        when(
          mocks.webViewWidgetProxy.createScriptMessageHandler(
            didReceiveScriptMessage: anyNamed('didReceiveScriptMessage'),
          ),
        ).thenReturn(
          MockWKScriptMessageHandler(),
        );

        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        await testController.addJavascriptChannels(<String>{'c', 'd'});
        final List<dynamic> javaScriptChannels = verify(
          mocks.userContentController
              .addScriptMessageHandler(captureAny, captureAny),
        ).captured;
        expect(
          javaScriptChannels[0],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[1], 'c');
        expect(
          javaScriptChannels[2],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[3], 'd');

        final List<WKUserScript> userScripts =
            verify(mocks.userContentController.addUserScript(captureAny))
                .captured
                .cast<WKUserScript>();
        expect(userScripts[0].source, 'window.c = webkit.messageHandlers.c;');
        expect(
          userScripts[0].injectionTime,
          UserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isForMainFrameOnly, false);
        expect(userScripts[1].source, 'window.d = webkit.messageHandlers.d;');
        expect(
          userScripts[1].injectionTime,
          UserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isForMainFrameOnly, false);
      });

      testWidgets('removeJavascriptChannels', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        when(
          mocks.webViewWidgetProxy.createScriptMessageHandler(
            didReceiveScriptMessage: anyNamed('didReceiveScriptMessage'),
          ),
        ).thenReturn(
          MockWKScriptMessageHandler(),
        );

        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        await testController.addJavascriptChannels(<String>{'c', 'd'});
        reset(mocks.userContentController);

        await testController.removeJavascriptChannels(<String>{'c'});

        verify(mocks.userContentController.removeAllUserScripts());
        verify(mocks.userContentController.removeScriptMessageHandler('c'));
        verify(mocks.userContentController.removeScriptMessageHandler('d'));

        final List<dynamic> javaScriptChannels = verify(
          mocks.userContentController.addScriptMessageHandler(
            captureAny,
            captureAny,
          ),
        ).captured;
        expect(
          javaScriptChannels[0],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[1], 'd');

        final List<WKUserScript> userScripts =
            verify(mocks.userContentController.addUserScript(captureAny))
                .captured
                .cast<WKUserScript>();
        expect(userScripts[0].source, 'window.d = webkit.messageHandlers.d;');
        expect(
          userScripts[0].injectionTime,
          UserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isForMainFrameOnly, false);
      });

      testWidgets('removeJavascriptChannels with zoom disabled',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        when(
          mocks.webViewWidgetProxy.createScriptMessageHandler(
            didReceiveScriptMessage: anyNamed('didReceiveScriptMessage'),
          ),
        ).thenReturn(
          MockWKScriptMessageHandler(),
        );

        final WebKitWebViewPlatformController testController =
            await buildWidget(
          tester,
          mocks,
          creationParams: CreationParams(
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              zoomEnabled: false,
              hasNavigationDelegate: false,
            ),
          ),
        );

        await testController.addJavascriptChannels(<String>{'c'});
        clearInteractions(mocks.userContentController);
        await testController.removeJavascriptChannels(<String>{'c'});

        final WKUserScript zoomScript =
            verify(mocks.userContentController.addUserScript(captureAny))
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
    });

    group('WebViewPlatformCallbacksHandler', () {
      testWidgets('onPageStarted', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        await buildWidget(tester, mocks);

        final void Function(WKNavigationDelegate, WKWebView, String)
            didStartProvisionalNavigation =
            verify(mocks.webViewWidgetProxy.createNavigationDelegate(
          didFinishNavigation: anyNamed('didFinishNavigation'),
          didStartProvisionalNavigation:
              captureAnyNamed('didStartProvisionalNavigation'),
          decidePolicyForNavigationAction:
              anyNamed('decidePolicyForNavigationAction'),
          didFailNavigation: anyNamed('didFailNavigation'),
          didFailProvisionalNavigation:
              anyNamed('didFailProvisionalNavigation'),
          webViewWebContentProcessDidTerminate:
              anyNamed('webViewWebContentProcessDidTerminate'),
          decidePolicyForNavigationResponse:
              anyNamed('decidePolicyForNavigationResponse'),
          didReceiveAuthenticationChallenge:
              anyNamed('didReceiveAuthenticationChallenge'),
        )).captured.single as void Function(
                WKNavigationDelegate, WKWebView, String);
        didStartProvisionalNavigation(
          mocks.navigationDelegate,
          mocks.webView,
          'https://google.com',
        );

        verify(mocks.callbacksHandler.onPageStarted('https://google.com'));
      });

      testWidgets('onPageFinished', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        await buildWidget(tester, mocks);

        final void Function(WKNavigationDelegate, WKWebView, String)
            didFinishNavigation =
            verify(mocks.webViewWidgetProxy.createNavigationDelegate(
          didFinishNavigation: captureAnyNamed('didFinishNavigation'),
          didStartProvisionalNavigation:
              anyNamed('didStartProvisionalNavigation'),
          decidePolicyForNavigationAction:
              anyNamed('decidePolicyForNavigationAction'),
          didFailNavigation: anyNamed('didFailNavigation'),
          didFailProvisionalNavigation:
              anyNamed('didFailProvisionalNavigation'),
          webViewWebContentProcessDidTerminate:
              anyNamed('webViewWebContentProcessDidTerminate'),
          decidePolicyForNavigationResponse:
              anyNamed('decidePolicyForNavigationResponse'),
          didReceiveAuthenticationChallenge:
              anyNamed('didReceiveAuthenticationChallenge'),
        )).captured.single as void Function(
                WKNavigationDelegate, WKWebView, String);
        didFinishNavigation(
          mocks.navigationDelegate,
          mocks.webView,
          'https://google.com',
        );

        verify(mocks.callbacksHandler.onPageFinished('https://google.com'));
      });

      testWidgets('onWebResourceError from didFailNavigation',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        await buildWidget(tester, mocks);

        final void Function(WKNavigationDelegate, WKWebView, NSError)
            didFailNavigation =
            verify(mocks.webViewWidgetProxy.createNavigationDelegate(
          didFinishNavigation: anyNamed('didFinishNavigation'),
          didStartProvisionalNavigation:
              anyNamed('didStartProvisionalNavigation'),
          decidePolicyForNavigationAction:
              anyNamed('decidePolicyForNavigationAction'),
          didFailNavigation: captureAnyNamed('didFailNavigation'),
          didFailProvisionalNavigation:
              anyNamed('didFailProvisionalNavigation'),
          webViewWebContentProcessDidTerminate:
              anyNamed('webViewWebContentProcessDidTerminate'),
          decidePolicyForNavigationResponse:
              anyNamed('decidePolicyForNavigationResponse'),
          didReceiveAuthenticationChallenge:
              anyNamed('didReceiveAuthenticationChallenge'),
        )).captured.single as void Function(
                WKNavigationDelegate, WKWebView, NSError);

        didFailNavigation(
          mocks.navigationDelegate,
          mocks.webView,
          NSError.pigeon_detached(
            code: WKErrorCode.webViewInvalidated,
            domain: 'domain',
            userInfo: const <String, Object?>{
              NSErrorUserInfoKey.NSLocalizedDescription: 'my desc',
            },
            pigeon_instanceManager: TestInstanceManager(),
          ),
        );

        final WebResourceError error =
            verify(mocks.callbacksHandler.onWebResourceError(captureAny))
                .captured
                .single as WebResourceError;
        expect(error.description, 'my desc');
        expect(error.errorCode, WKErrorCode.webViewInvalidated);
        expect(error.domain, 'domain');
        expect(error.errorType, WebResourceErrorType.webViewInvalidated);
      });

      testWidgets('onWebResourceError from didFailProvisionalNavigation',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        await buildWidget(tester, mocks);

        final void Function(WKNavigationDelegate, WKWebView, NSError)
            didFailProvisionalNavigation =
            verify(mocks.webViewWidgetProxy.createNavigationDelegate(
          didFinishNavigation: anyNamed('didFinishNavigation'),
          didStartProvisionalNavigation:
              anyNamed('didStartProvisionalNavigation'),
          decidePolicyForNavigationAction:
              anyNamed('decidePolicyForNavigationAction'),
          didFailNavigation: anyNamed('didFailNavigation'),
          didFailProvisionalNavigation:
              captureAnyNamed('didFailProvisionalNavigation'),
          webViewWebContentProcessDidTerminate:
              anyNamed('webViewWebContentProcessDidTerminate'),
          decidePolicyForNavigationResponse:
              anyNamed('decidePolicyForNavigationResponse'),
          didReceiveAuthenticationChallenge:
              anyNamed('didReceiveAuthenticationChallenge'),
        )).captured.single as void Function(
                WKNavigationDelegate, WKWebView, NSError);

        didFailProvisionalNavigation(
          mocks.navigationDelegate,
          mocks.webView,
          NSError.pigeon_detached(
            code: WKErrorCode.webContentProcessTerminated,
            domain: 'domain',
            userInfo: const <String, Object?>{
              NSErrorUserInfoKey.NSLocalizedDescription: 'my desc',
            },
            pigeon_instanceManager: TestInstanceManager(),
          ),
        );

        final WebResourceError error =
            verify(mocks.callbacksHandler.onWebResourceError(captureAny))
                .captured
                .single as WebResourceError;
        expect(error.description, 'my desc');
        expect(error.errorCode, WKErrorCode.webContentProcessTerminated);
        expect(error.domain, 'domain');
        expect(
          error.errorType,
          WebResourceErrorType.webContentProcessTerminated,
        );
      });

      testWidgets(
          'onWebResourceError from webViewWebContentProcessDidTerminate',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        await buildWidget(tester, mocks);

        final void Function(WKNavigationDelegate, WKWebView)
            webViewWebContentProcessDidTerminate =
            verify(mocks.webViewWidgetProxy.createNavigationDelegate(
          didFinishNavigation: anyNamed('didFinishNavigation'),
          didStartProvisionalNavigation:
              anyNamed('didStartProvisionalNavigation'),
          decidePolicyForNavigationAction:
              anyNamed('decidePolicyForNavigationAction'),
          didFailNavigation: anyNamed('didFailNavigation'),
          didFailProvisionalNavigation:
              anyNamed('didFailProvisionalNavigation'),
          webViewWebContentProcessDidTerminate:
              captureAnyNamed('webViewWebContentProcessDidTerminate'),
          decidePolicyForNavigationResponse:
              anyNamed('decidePolicyForNavigationResponse'),
          didReceiveAuthenticationChallenge:
              anyNamed('didReceiveAuthenticationChallenge'),
        )).captured.single as void Function(WKNavigationDelegate, WKWebView);
        webViewWebContentProcessDidTerminate(
          mocks.navigationDelegate,
          mocks.webView,
        );

        final WebResourceError error =
            verify(mocks.callbacksHandler.onWebResourceError(captureAny))
                .captured
                .single as WebResourceError;
        expect(error.description, '');
        expect(error.errorCode, WKErrorCode.webContentProcessTerminated);
        expect(error.domain, 'WKErrorDomain');
        expect(
          error.errorType,
          WebResourceErrorType.webContentProcessTerminated,
        );
      });

      testWidgets('onNavigationRequest from decidePolicyForNavigationAction',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        await buildWidget(tester, mocks, hasNavigationDelegate: true);

        final Future<NavigationActionPolicy> Function(
                WKNavigationDelegate, WKWebView, WKNavigationAction)
            decidePolicyForNavigationAction =
            verify(mocks.webViewWidgetProxy.createNavigationDelegate(
          didFinishNavigation: anyNamed('didFinishNavigation'),
          didStartProvisionalNavigation:
              anyNamed('didStartProvisionalNavigation'),
          decidePolicyForNavigationAction:
              captureAnyNamed('decidePolicyForNavigationAction'),
          didFailNavigation: anyNamed('didFailNavigation'),
          didFailProvisionalNavigation:
              anyNamed('didFailProvisionalNavigation'),
          webViewWebContentProcessDidTerminate:
              anyNamed('webViewWebContentProcessDidTerminate'),
          decidePolicyForNavigationResponse:
              anyNamed('decidePolicyForNavigationResponse'),
          didReceiveAuthenticationChallenge:
              anyNamed('didReceiveAuthenticationChallenge'),
        )).captured.single as Future<NavigationActionPolicy> Function(
                WKNavigationDelegate, WKWebView, WKNavigationAction);

        when(mocks.callbacksHandler.onNavigationRequest(
          isForMainFrame: argThat(isFalse, named: 'isForMainFrame'),
          url: 'https://google.com',
        )).thenReturn(true);

        final MockURLRequest mockRequest = MockURLRequest();
        when(mockRequest.getUrl()).thenAnswer(
          (_) => Future<String>.value('https://google.com'),
        );

        expect(
          await decidePolicyForNavigationAction(
            mocks.navigationDelegate,
            mocks.webView,
            WKNavigationAction.pigeon_detached(
              request: mockRequest,
              targetFrame: WKFrameInfo.pigeon_detached(
                isMainFrame: false,
                request: mockRequest,
                pigeon_instanceManager: TestInstanceManager(),
              ),
              navigationType: NavigationType.linkActivated,
              pigeon_instanceManager: TestInstanceManager(),
            ),
          ),
          NavigationActionPolicy.allow,
        );

        verify(mocks.callbacksHandler.onNavigationRequest(
          url: 'https://google.com',
          isForMainFrame: false,
        ));
      });

      testWidgets('onProgress', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        await buildWidget(tester, mocks, hasProgressTracking: true);

        verify(mocks.webView.addObserver(
          mocks.webView,
          'estimatedProgress',
          <KeyValueObservingOptions>[KeyValueObservingOptions.newValue],
        ));

        final void Function(String, NSObject, Map<KeyValueChangeKey, Object?>)
            observeValue = verify(mocks.webViewWidgetProxy.createWebView(any,
                        observeValue: captureAnyNamed('observeValue')))
                    .captured
                    .single
                as void Function(
                    String, NSObject, Map<KeyValueChangeKey, Object?>);

        observeValue(
          'estimatedProgress',
          mocks.webView,
          <KeyValueChangeKey, Object?>{KeyValueChangeKey.newValue: 0.32},
        );

        verify(mocks.callbacksHandler.onProgress(32));
      });

      testWidgets('progress observer is not removed without being set first',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        await buildWidget(tester, mocks);

        verifyNever(mocks.webView.removeObserver(
          mocks.webView,
          'estimatedProgress',
        ));
      });
    });

    group('JavascriptChannelRegistry', () {
      testWidgets('onJavascriptChannelMessage', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        when(
          mocks.webViewWidgetProxy.createScriptMessageHandler(
            didReceiveScriptMessage: anyNamed('didReceiveScriptMessage'),
          ),
        ).thenReturn(
          MockWKScriptMessageHandler(),
        );

        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);
        await testController.addJavascriptChannels(<String>{'hello'});

        final void Function(WKScriptMessageHandler, WKUserContentController,
            WKScriptMessage) didReceiveScriptMessage = verify(
                    mocks.webViewWidgetProxy.createScriptMessageHandler(
                        didReceiveScriptMessage:
                            captureAnyNamed('didReceiveScriptMessage')))
                .captured
                .single
            as void Function(WKScriptMessageHandler, WKUserContentController,
                WKScriptMessage);

        didReceiveScriptMessage(
          MockWKScriptMessageHandler(),
          mocks.userContentController,
          WKScriptMessage.pigeon_detached(
            name: 'hello',
            body: 'A message.',
            pigeon_instanceManager: TestInstanceManager(),
          ),
        );
        verify(mocks.javascriptChannelRegistry.onJavascriptChannelMessage(
          'hello',
          'A message.',
        ));
      });
    });
  });
}

/// A collection of mocks used in constructing a WebViewWidget.
class _WebViewMocks {
  _WebViewMocks({
    required this.webView,
    required this.webViewWidgetProxy,
    required this.userContentController,
    required this.preferences,
    required this.webViewConfiguration,
    required this.uiDelegate,
    required this.scrollView,
    required this.websiteDataStore,
    required this.navigationDelegate,
    required this.callbacksHandler,
    required this.javascriptChannelRegistry,
    required this.webpagePreferences,
  });

  final MockUIViewWKWebView webView;
  final MockWebViewWidgetProxy webViewWidgetProxy;
  final MockWKUserContentController userContentController;
  final MockWKPreferences preferences;
  final MockWKWebViewConfiguration webViewConfiguration;
  final MockWKUIDelegate uiDelegate;
  final MockUIScrollView scrollView;
  final MockWKWebsiteDataStore websiteDataStore;
  final MockWKNavigationDelegate navigationDelegate;
  final MockWebViewPlatformCallbacksHandler callbacksHandler;
  final MockJavascriptChannelRegistry javascriptChannelRegistry;
  final MockWKWebpagePreferences webpagePreferences;
}

// Test InstanceManager that sets `onWeakReferenceRemoved` as a noop.
class TestInstanceManager extends PigeonInstanceManager {
  TestInstanceManager() : super(onWeakReferenceRemoved: (_) {});
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/src/webview_flutter_platform_interface_legacy.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart';
import 'package:webview_flutter_wkwebview/src/legacy/web_kit_webview_widget.dart';
import 'package:webview_flutter_wkwebview/src/ui_kit/ui_kit.dart';
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart';

import 'web_kit_webview_widget_test.mocks.dart';

@GenerateMocks(<Type>[
  UIScrollView,
  WKNavigationDelegate,
  WKPreferences,
  WKScriptMessageHandler,
  WKWebView,
  WKWebViewConfiguration,
  WKWebsiteDataStore,
  WKUIDelegate,
  WKUserContentController,
  JavascriptChannelRegistry,
  WebViewPlatformCallbacksHandler,
  WebViewWidgetProxy,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebKitWebViewWidget', () {
    _WebViewMocks configureMocks() {
      final _WebViewMocks mocks = _WebViewMocks(
          webView: MockWKWebView(),
          webViewWidgetProxy: MockWebViewWidgetProxy(),
          userContentController: MockWKUserContentController(),
          preferences: MockWKPreferences(),
          webViewConfiguration: MockWKWebViewConfiguration(),
          uiDelegate: MockWKUIDelegate(),
          scrollView: MockUIScrollView(),
          websiteDataStore: MockWKWebsiteDataStore(),
          navigationDelegate: MockWKNavigationDelegate(),
          callbacksHandler: MockWebViewPlatformCallbacksHandler(),
          javascriptChannelRegistry: MockJavascriptChannelRegistry());

      when(
        mocks.webViewWidgetProxy.createWebView(
          any,
          observeValue: anyNamed('observeValue'),
        ),
      ).thenReturn(mocks.webView);
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
      )).thenReturn(mocks.navigationDelegate);
      when(mocks.webView.configuration).thenReturn(mocks.webViewConfiguration);
      when(mocks.webViewConfiguration.userContentController).thenReturn(
        mocks.userContentController,
      );
      when(mocks.webViewConfiguration.preferences)
          .thenReturn(mocks.preferences);

      when(mocks.webView.scrollView).thenReturn(mocks.scrollView);

      when(mocks.webViewConfiguration.websiteDataStore).thenReturn(
        mocks.websiteDataStore,
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

      final void Function(WKWebView, WKWebViewConfiguration, WKNavigationAction)
          onCreateWebView = verify(mocks.webViewWidgetProxy.createUIDelgate(
                      onCreateWebView: captureAnyNamed('onCreateWebView')))
                  .captured
                  .single
              as void Function(
                  WKWebView, WKWebViewConfiguration, WKNavigationAction);

      const NSUrlRequest request = NSUrlRequest(url: 'https://google.com');
      onCreateWebView(
        mocks.webView,
        mocks.webViewConfiguration,
        const WKNavigationAction(
          request: request,
          targetFrame: WKFrameInfo(isMainFrame: false, request: request),
          navigationType: WKNavigationType.linkActivated,
        ),
      );

      verify(mocks.webView.loadRequest(request));
    });

    group('CreationParams', () {
      testWidgets('initialUrl', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
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
        final NSUrlRequest request =
            verify(mocks.webView.loadRequest(captureAny)).captured.single
                as NSUrlRequest;
        expect(request.url, 'https://www.google.com');
      });

      testWidgets('backgroundColor', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
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
        verify(mocks.webView.setBackgroundColor(Colors.transparent));
        verify(mocks.scrollView.setBackgroundColor(Colors.red));
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
            .setMediaTypesRequiringUserActionForPlayback(<WKAudiovisualMediaType>{
          WKAudiovisualMediaType.all,
        }));
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
            .setMediaTypesRequiringUserActionForPlayback(<WKAudiovisualMediaType>{
          WKAudiovisualMediaType.none,
        }));
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

          verify(mocks.preferences.setJavaScriptEnabled(true));
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
          expect(zoomScript.isMainFrameOnly, isTrue);
          expect(zoomScript.injectionTime,
              WKUserScriptInjectionTime.atDocumentEnd);
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
        verify(mocks.webView.loadFileUrl(
          '/path/to/file.html',
          readAccessUrl: '/path/to',
        ));
      });

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

        const String htmlString = '<html><body>Test data.</body></html>';
        await testController.loadHtmlString(htmlString, baseUrl: 'baseUrl');

        verify(mocks.webView.loadHtmlString(
          '<html><body>Test data.</body></html>',
          baseUrl: 'baseUrl',
        ));
      });

      testWidgets('loadUrl', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        await testController.loadUrl(
          'https://www.google.com',
          <String, String>{'a': 'header'},
        );

        final NSUrlRequest request =
            verify(mocks.webView.loadRequest(captureAny)).captured.single
                as NSUrlRequest;
        expect(request.url, 'https://www.google.com');
        expect(request.allHttpHeaderFields, <String, String>{'a': 'header'});
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

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.get,
          ));

          final NSUrlRequest request =
              verify(mocks.webView.loadRequest(captureAny)).captured.single
                  as NSUrlRequest;
          expect(request.url, 'https://www.google.com');
          expect(request.allHttpHeaderFields, <String, String>{});
          expect(request.httpMethod, 'get');
        });

        testWidgets('GET with headers', (WidgetTester tester) async {
          final _WebViewMocks mocks = configureMocks();
          final WebKitWebViewPlatformController testController =
              await buildWidget(tester, mocks);

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.get,
            headers: <String, String>{'a': 'header'},
          ));

          final NSUrlRequest request =
              verify(mocks.webView.loadRequest(captureAny)).captured.single
                  as NSUrlRequest;
          expect(request.url, 'https://www.google.com');
          expect(request.allHttpHeaderFields, <String, String>{'a': 'header'});
          expect(request.httpMethod, 'get');
        });

        testWidgets('POST without body', (WidgetTester tester) async {
          final _WebViewMocks mocks = configureMocks();
          final WebKitWebViewPlatformController testController =
              await buildWidget(tester, mocks);

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.post,
          ));

          final NSUrlRequest request =
              verify(mocks.webView.loadRequest(captureAny)).captured.single
                  as NSUrlRequest;
          expect(request.url, 'https://www.google.com');
          expect(request.httpMethod, 'post');
        });

        testWidgets('POST with body', (WidgetTester tester) async {
          final _WebViewMocks mocks = configureMocks();
          final WebKitWebViewPlatformController testController =
              await buildWidget(tester, mocks);

          await testController.loadRequest(WebViewRequest(
              uri: Uri.parse('https://www.google.com'),
              method: WebViewRequestMethod.post,
              body: Uint8List.fromList('Test Body'.codeUnits)));

          final NSUrlRequest request =
              verify(mocks.webView.loadRequest(captureAny)).captured.single
                  as NSUrlRequest;
          expect(request.url, 'https://www.google.com');
          expect(request.httpMethod, 'post');
          expect(
            request.httpBody,
            Uint8List.fromList('Test Body'.codeUnits),
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
          details: const NSError(
            code: WKErrorCode.javaScriptResultTypeIsUnsupported,
            domain: '',
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

        await testController.scrollTo(2, 4);
        verify(
            mocks.scrollView.setContentOffset(const Point<double>(2.0, 4.0)));
      });

      testWidgets('scrollBy', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        await testController.scrollBy(2, 4);
        verify(mocks.scrollView.scrollBy(const Point<double>(2.0, 4.0)));
      });

      testWidgets('getScrollX', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.scrollView.getContentOffset()).thenAnswer(
            (_) => Future<Point<double>>.value(const Point<double>(8.0, 16.0)));
        expect(testController.getScrollX(), completion(8.0));
      });

      testWidgets('getScrollY', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);

        when(mocks.scrollView.getContentOffset()).thenAnswer(
            (_) => Future<Point<double>>.value(const Point<double>(8.0, 16.0)));
        expect(testController.getScrollY(), completion(16.0));
      });

      testWidgets('clearCache', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        final WebKitWebViewPlatformController testController =
            await buildWidget(tester, mocks);
        when(
          mocks.websiteDataStore.removeDataOfTypes(
            <WKWebsiteDataType>{
              WKWebsiteDataType.memoryCache,
              WKWebsiteDataType.diskCache,
              WKWebsiteDataType.offlineWebApplicationCache,
              WKWebsiteDataType.localStorage,
            },
            DateTime.fromMillisecondsSinceEpoch(0),
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
          WKUserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isMainFrameOnly, false);
        expect(userScripts[1].source, 'window.d = webkit.messageHandlers.d;');
        expect(
          userScripts[1].injectionTime,
          WKUserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isMainFrameOnly, false);
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
          WKUserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isMainFrameOnly, false);
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
        expect(zoomScript.isMainFrameOnly, isTrue);
        expect(
            zoomScript.injectionTime, WKUserScriptInjectionTime.atDocumentEnd);
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

        final void Function(WKWebView, String) didStartProvisionalNavigation =
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
        )).captured.single as void Function(WKWebView, String);
        didStartProvisionalNavigation(mocks.webView, 'https://google.com');

        verify(mocks.callbacksHandler.onPageStarted('https://google.com'));
      });

      testWidgets('onPageFinished', (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        await buildWidget(tester, mocks);

        final void Function(WKWebView, String) didFinishNavigation =
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
        )).captured.single as void Function(WKWebView, String);
        didFinishNavigation(mocks.webView, 'https://google.com');

        verify(mocks.callbacksHandler.onPageFinished('https://google.com'));
      });

      testWidgets('onWebResourceError from didFailNavigation',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        await buildWidget(tester, mocks);

        final void Function(WKWebView, NSError) didFailNavigation =
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
        )).captured.single as void Function(WKWebView, NSError);

        didFailNavigation(
          mocks.webView,
          const NSError(
            code: WKErrorCode.webViewInvalidated,
            domain: 'domain',
            userInfo: <String, Object?>{
              NSErrorUserInfoKey.NSLocalizedDescription: 'my desc',
            },
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

        final void Function(WKWebView, NSError) didFailProvisionalNavigation =
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
        )).captured.single as void Function(WKWebView, NSError);

        didFailProvisionalNavigation(
          mocks.webView,
          const NSError(
            code: WKErrorCode.webContentProcessTerminated,
            domain: 'domain',
            userInfo: <String, Object?>{
              NSErrorUserInfoKey.NSLocalizedDescription: 'my desc',
            },
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

        final void Function(WKWebView) webViewWebContentProcessDidTerminate =
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
        )).captured.single as void Function(WKWebView);
        webViewWebContentProcessDidTerminate(mocks.webView);

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

        final Future<WKNavigationActionPolicy> Function(
                WKWebView, WKNavigationAction) decidePolicyForNavigationAction =
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
        )).captured.single as Future<WKNavigationActionPolicy> Function(
                WKWebView, WKNavigationAction);

        when(mocks.callbacksHandler.onNavigationRequest(
          isForMainFrame: argThat(isFalse, named: 'isForMainFrame'),
          url: 'https://google.com',
        )).thenReturn(true);

        expect(
          decidePolicyForNavigationAction(
            mocks.webView,
            const WKNavigationAction(
              request: NSUrlRequest(url: 'https://google.com'),
              targetFrame: WKFrameInfo(
                  isMainFrame: false,
                  request: NSUrlRequest(url: 'https://google.com')),
              navigationType: WKNavigationType.linkActivated,
            ),
          ),
          completion(WKNavigationActionPolicy.allow),
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
          keyPath: 'estimatedProgress',
          options: <NSKeyValueObservingOptions>{
            NSKeyValueObservingOptions.newValue,
          },
        ));

        final void Function(String, NSObject, Map<NSKeyValueChangeKey, Object?>)
            observeValue = verify(mocks.webViewWidgetProxy.createWebView(any,
                        observeValue: captureAnyNamed('observeValue')))
                    .captured
                    .single
                as void Function(
                    String, NSObject, Map<NSKeyValueChangeKey, Object?>);

        observeValue(
          'estimatedProgress',
          mocks.webView,
          <NSKeyValueChangeKey, Object?>{NSKeyValueChangeKey.newValue: 0.32},
        );

        verify(mocks.callbacksHandler.onProgress(32));
      });

      testWidgets('progress observer is not removed without being set first',
          (WidgetTester tester) async {
        final _WebViewMocks mocks = configureMocks();
        await buildWidget(tester, mocks);

        verifyNever(mocks.webView.removeObserver(
          mocks.webView,
          keyPath: 'estimatedProgress',
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

        final void Function(WKUserContentController, WKScriptMessage)
            didReceiveScriptMessage = verify(mocks.webViewWidgetProxy
                        .createScriptMessageHandler(
                            didReceiveScriptMessage:
                                captureAnyNamed('didReceiveScriptMessage')))
                    .captured
                    .single
                as void Function(WKUserContentController, WKScriptMessage);

        didReceiveScriptMessage(
          mocks.userContentController,
          const WKScriptMessage(name: 'hello', body: 'A message.'),
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
  });

  final MockWKWebView webView;
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
}

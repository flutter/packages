// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_wkwebview/src/common/instance_manager.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart';
import 'package:webview_flutter_wkwebview/src/ui_kit/ui_kit.dart';
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart';
import 'package:webview_flutter_wkwebview/src/webkit_proxy.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'webkit_webview_controller_test.mocks.dart'
    show MockUIScrollViewDelegate;
import 'webkit_webview_widget_test.mocks.dart';

@GenerateMocks(<Type>[WKUIDelegate, WKWebViewConfiguration])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebKitWebViewWidget', () {
    testWidgets('build', (WidgetTester tester) async {
      final InstanceManager testInstanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final WebKitWebViewController controller =
          createTestWebViewController(testInstanceManager);

      final WebKitWebViewWidget widget = WebKitWebViewWidget(
        WebKitWebViewWidgetCreationParams(
          key: const Key('keyValue'),
          controller: controller,
          instanceManager: testInstanceManager,
        ),
      );

      await tester.pumpWidget(
        Builder(builder: (BuildContext context) => widget.build(context)),
      );

      expect(find.byType(Platform.isMacOS ? AppKitView : UiKitView),
          findsOneWidget);
      expect(find.byKey(const Key('keyValue')), findsOneWidget);
    });

    testWidgets('Key of the PlatformView changes when the controller changes',
        (WidgetTester tester) async {
      final InstanceManager testInstanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      // Pump WebViewWidget with first controller.
      final WebKitWebViewController controller1 =
          createTestWebViewController(testInstanceManager);
      final WebKitWebViewWidget webViewWidget = WebKitWebViewWidget(
        WebKitWebViewWidgetCreationParams(
          controller: controller1,
          instanceManager: testInstanceManager,
        ),
      );

      await tester.pumpWidget(
        Builder(
          builder: (BuildContext context) => webViewWidget.build(context),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          ValueKey<WebKitWebViewWidgetCreationParams>(
            webViewWidget.params as WebKitWebViewWidgetCreationParams,
          ),
        ),
        findsOneWidget,
      );

      // Pump WebViewWidget with second controller.
      final WebKitWebViewController controller2 =
          createTestWebViewController(testInstanceManager);
      final WebKitWebViewWidget webViewWidget2 = WebKitWebViewWidget(
        WebKitWebViewWidgetCreationParams(
          controller: controller2,
          instanceManager: testInstanceManager,
        ),
      );

      await tester.pumpWidget(
        Builder(
          builder: (BuildContext context) => webViewWidget2.build(context),
        ),
      );
      await tester.pumpAndSettle();

      expect(webViewWidget.params != webViewWidget2.params, isTrue);
      expect(
        find.byKey(
          ValueKey<WebKitWebViewWidgetCreationParams>(
            webViewWidget.params as WebKitWebViewWidgetCreationParams,
          ),
        ),
        findsNothing,
      );
      expect(
        find.byKey(
          ValueKey<WebKitWebViewWidgetCreationParams>(
            webViewWidget2.params as WebKitWebViewWidgetCreationParams,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'Key of the PlatformView is the same when the creation params are equal',
        (WidgetTester tester) async {
      final InstanceManager testInstanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final WebKitWebViewController controller =
          createTestWebViewController(testInstanceManager);

      final WebKitWebViewWidget webViewWidget = WebKitWebViewWidget(
        WebKitWebViewWidgetCreationParams(
          controller: controller,
          instanceManager: testInstanceManager,
        ),
      );

      await tester.pumpWidget(
        Builder(
          builder: (BuildContext context) => webViewWidget.build(context),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          ValueKey<WebKitWebViewWidgetCreationParams>(
            webViewWidget.params as WebKitWebViewWidgetCreationParams,
          ),
        ),
        findsOneWidget,
      );

      final WebKitWebViewWidget webViewWidget2 = WebKitWebViewWidget(
        WebKitWebViewWidgetCreationParams(
          controller: controller,
          instanceManager: testInstanceManager,
        ),
      );

      await tester.pumpWidget(
        Builder(
          builder: (BuildContext context) => webViewWidget2.build(context),
        ),
      );
      await tester.pumpAndSettle();

      // Can find the new widget with the key of the first widget.
      expect(
        find.byKey(
          ValueKey<WebKitWebViewWidgetCreationParams>(
            webViewWidget.params as WebKitWebViewWidgetCreationParams,
          ),
        ),
        findsOneWidget,
      );
    });
  });
}

WebKitWebViewController createTestWebViewController(
  InstanceManager testInstanceManager,
) {
  return WebKitWebViewController(
    WebKitWebViewControllerCreationParams(
      webKitProxy: WebKitProxy(createWebView: (
        WKWebViewConfiguration configuration, {
        void Function(
          String keyPath,
          NSObject object,
          Map<NSKeyValueChangeKey, Object?> change,
        )? observeValue,
        InstanceManager? instanceManager,
      }) {
        final WKWebView webView = WKWebViewIOS.detached(
          instanceManager: testInstanceManager,
        );
        testInstanceManager.addDartCreatedInstance(webView);
        return webView;
      }, createWebViewConfiguration: ({InstanceManager? instanceManager}) {
        return MockWKWebViewConfiguration();
      }, createUIDelegate: ({
        dynamic onCreateWebView,
        dynamic requestMediaCapturePermission,
        dynamic runJavaScriptAlertDialog,
        dynamic runJavaScriptConfirmDialog,
        dynamic runJavaScriptTextInputDialog,
        InstanceManager? instanceManager,
      }) {
        final MockWKUIDelegate mockWKUIDelegate = MockWKUIDelegate();
        when(mockWKUIDelegate.copy()).thenReturn(MockWKUIDelegate());

        testInstanceManager.addDartCreatedInstance(mockWKUIDelegate);
        return mockWKUIDelegate;
      }, createUIScrollViewDelegate: ({
        void Function(UIScrollView, double, double)? scrollViewDidScroll,
      }) {
        final MockUIScrollViewDelegate mockScrollViewDelegate =
            MockUIScrollViewDelegate();
        when(mockScrollViewDelegate.copy())
            .thenReturn(MockUIScrollViewDelegate());

        testInstanceManager.addDartCreatedInstance(mockScrollViewDelegate);
        return mockScrollViewDelegate;
      }),
    ),
  );
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit.g.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'webkit_webview_widget_test.mocks.dart';

@GenerateMocks(<Type>[
  WKUIDelegate,
  WKWebViewConfiguration,
  UIScrollViewDelegate,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PigeonOverrides.pigeon_reset();
  });

  group('WebKitWebViewWidget', () {
    testWidgets('build', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final WebKitWebViewController controller = createTestWebViewController();

      final widget = WebKitWebViewWidget(
        WebKitWebViewWidgetCreationParams(
          key: const Key('keyValue'),
          controller: controller,
        ),
      );

      await tester.pumpWidget(
        Builder(builder: (BuildContext context) => widget.build(context)),
      );

      expect(
        find.byType(
          defaultTargetPlatform == TargetPlatform.macOS
              ? AppKitView
              : UiKitView,
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('keyValue')), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Key of the PlatformView changes when the controller changes', (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      // Pump WebViewWidget with first controller.
      final WebKitWebViewController controller1 = createTestWebViewController();
      final webViewWidget = WebKitWebViewWidget(
        WebKitWebViewWidgetCreationParams(controller: controller1),
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
      final WebKitWebViewController controller2 = createTestWebViewController();
      final webViewWidget2 = WebKitWebViewWidget(
        WebKitWebViewWidgetCreationParams(controller: controller2),
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

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
      'Key of the PlatformView is the same when the creation params are equal',
      (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        final WebKitWebViewController controller =
            createTestWebViewController();

        final webViewWidget = WebKitWebViewWidget(
          WebKitWebViewWidgetCreationParams(controller: controller),
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

        final webViewWidget2 = WebKitWebViewWidget(
          WebKitWebViewWidgetCreationParams(controller: controller),
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

        debugDefaultTargetPlatformOverride = null;
      },
    );
  });
}

WebKitWebViewController createTestWebViewController() {
  PigeonOverrides.uIViewWKWebView_new =
      ({
        required WKWebViewConfiguration initialConfiguration,
        void Function(
          NSObject,
          String?,
          NSObject?,
          Map<KeyValueChangeKey, Object>?,
        )?
        observeValue,
      }) {
        final webView = UIViewWKWebView.pigeon_detached();
        PigeonInstanceManager.instance.addDartCreatedInstance(webView);
        return webView;
      };
  PigeonOverrides.wKWebViewConfiguration_new = ({dynamic observeValue}) {
    return MockWKWebViewConfiguration();
  };
  PigeonOverrides.wKUIDelegate_new =
      ({
        dynamic onCreateWebView,
        dynamic requestMediaCapturePermission,
        dynamic runJavaScriptAlertPanel,
        dynamic runJavaScriptConfirmPanel,
        dynamic runJavaScriptTextInputPanel,
        dynamic observeValue,
      }) {
        final mockWKUIDelegate = MockWKUIDelegate();
        when(mockWKUIDelegate.pigeon_copy()).thenReturn(MockWKUIDelegate());

        PigeonInstanceManager.instance.addDartCreatedInstance(mockWKUIDelegate);
        return mockWKUIDelegate;
      };
  PigeonOverrides.uIScrollViewDelegate_new =
      ({dynamic scrollViewDidScroll, dynamic observeValue}) {
        final mockScrollViewDelegate = MockUIScrollViewDelegate();
        when(
          mockScrollViewDelegate.pigeon_copy(),
        ).thenReturn(MockUIScrollViewDelegate());

        PigeonInstanceManager.instance.addDartCreatedInstance(
          mockScrollViewDelegate,
        );
        return mockScrollViewDelegate;
      };
  return WebKitWebViewController(WebKitWebViewControllerCreationParams());
}

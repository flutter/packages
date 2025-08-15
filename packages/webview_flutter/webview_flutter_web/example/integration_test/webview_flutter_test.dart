// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart' as web;
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

import 'wrapped_webview.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String fakeUrl = 'about:blank';

  testWidgets('loadRequest', (WidgetTester tester) async {
    final WebWebViewController controller = WebWebViewController(
      const PlatformWebViewControllerCreationParams(),
    );
    await controller.loadRequest(
      LoadRequestParams(uri: Uri.parse(fakeUrl)),
    );

    await tester.pumpWidget(
      wrappedWebView(controller),
    );
    // Pump 2 frames so the framework injects the platform view into the DOM.
    // The duration of the second pump is set so the browser has some idle time
    // to actually show the contents of the iFrame.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Assert an iFrame has been rendered to the DOM with the correct src attribute.
    final web.HTMLIFrameElement? element =
        web.document.querySelector('iframe') as web.HTMLIFrameElement?;
    expect(element, isNotNull);
    expect(element!.src, fakeUrl);
  });

  testWidgets('loadHtmlString', (WidgetTester tester) async {
    final WebWebViewController controller = WebWebViewController(
      const PlatformWebViewControllerCreationParams(),
    );
    await controller.loadHtmlString(
      'data:text/html;charset=utf-8,${Uri.encodeFull('test html')}',
    );

    await tester.pumpWidget(
      wrappedWebView(controller),
    );
    // Pump 2 frames so the framework injects the platform view into the DOM.
    // The duration of the second pump is set so the browser has some idle time
    // to actually show the contents of the iFrame.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Assert an iFrame has been rendered to the DOM with the correct src attribute.
    final web.HTMLIFrameElement? element =
        web.document.querySelector('iframe') as web.HTMLIFrameElement?;
    expect(element, isNotNull);
    expect(
      element!.src,
      'data:text/html;charset=utf-8,data:text/html;charset=utf-8,test%2520html',
    );
  });
}

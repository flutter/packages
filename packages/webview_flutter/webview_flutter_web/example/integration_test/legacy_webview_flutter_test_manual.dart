// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This test flakes badly in headless mode!

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart' as web;
import 'package:webview_flutter_web_example/legacy/web_view.dart';

import 'wrapped_webview.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String someUrl = 'about:blank';
  const String fakeUrl = 'https://www.flutter.dev/';

  testWidgets('initialUrl', (WidgetTester tester) async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    await tester.pumpWidget(
      wrappedLegacyWebView(fakeUrl, (WebViewController controller) {
        controllerCompleter.complete(controller);
      }),
    );
    await controllerCompleter.future;
    // Pump 2 frames so the framework injects the platform view into the DOM.
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    // Assert an iframe has been rendered to the DOM with the correct src attribute.
    final web.HTMLIFrameElement? element =
        web.document.querySelector('iframe') as web.HTMLIFrameElement?;
    expect(element, isNotNull);
    expect(element!.src, fakeUrl);
  });

  testWidgets('loadUrl', (WidgetTester tester) async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    await tester.pumpWidget(
      wrappedLegacyWebView(someUrl, (WebViewController controller) {
        controllerCompleter.complete(controller);
      }),
    );

    final WebViewController controller = await controllerCompleter.future;
    await controller.loadUrl(fakeUrl);
    // Pump 2 frames so the framework injects the platform view into the DOM.
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    // Assert an iframe has been rendered to the DOM with the correct src attribute.
    final web.HTMLIFrameElement? element =
        web.document.querySelector('iframe') as web.HTMLIFrameElement?;
    expect(element, isNotNull);
    expect(element!.src, fakeUrl);
  });
}

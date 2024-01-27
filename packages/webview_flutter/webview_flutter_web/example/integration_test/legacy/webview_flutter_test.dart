// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:webview_flutter_web_example/legacy/web_view.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String primaryPage = 'first.txt';
  const String secondaryPage = 'second.txt';
  final HttpServer server =
      await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  unawaited(server.forEach((HttpRequest request) {
    if (request.uri.path == '/$primaryPage') {
      request.response.writeln('Hello, world.');
    }
    if (request.uri.path == '/$secondaryPage') {
      request.response.writeln('Another page.');
    } else {
      fail('unexpected request: ${request.method} ${request.uri}');
    }
    request.response.close();
  }));
  final String prefixUrl = 'http://localhost:${server.port}';
  final String primaryUrl = '$prefixUrl/$primaryPage';
  final String secondaryUrl = '$prefixUrl/$secondaryPage';

  testWidgets('initialUrl', (WidgetTester tester) async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: GlobalKey(),
          initialUrl: primaryUrl,
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    await controllerCompleter.future;

    // Assert an iframe has been rendered to the DOM with the correct src attribute.
    final html.IFrameElement? element =
        html.document.querySelector('iframe') as html.IFrameElement?;
    expect(element, isNotNull);
    expect(element!.src, primaryUrl);
  });

  testWidgets('loadUrl', (WidgetTester tester) async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: GlobalKey(),
          initialUrl: primaryUrl,
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    await controller.loadUrl(secondaryUrl);

    // Assert an iframe has been rendered to the DOM with the correct src attribute.
    final html.IFrameElement? element =
        html.document.querySelector('iframe') as html.IFrameElement?;
    expect(element, isNotNull);
    expect(element!.src, secondaryUrl);
  });
}

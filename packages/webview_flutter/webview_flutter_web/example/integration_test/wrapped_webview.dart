// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:webview_flutter_web_example/legacy/web_view.dart';

/// Returns the webview widget for a given [controller], wrapped so it works
/// in our integration tests.
Widget wrappedWebView(WebWebViewController controller) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (BuildContext ctx) => PlatformWebViewWidget(
          PlatformWebViewWidgetCreationParams(controller: controller),
        ).build(ctx),
      ),
    ),
  );
}

/// Returns a (legacy) webview widget for an [url], that calls [onCreated] when
/// done, wrapped so it works in our integration tests.
Widget wrappedLegacyWebView(String url, WebViewCreatedCallback onCreated) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (BuildContext ctx) => WebView(
          key: GlobalKey(),
          initialUrl: url,
          onWebViewCreated: onCreated,
        ),
      ),
    ),
  );
}

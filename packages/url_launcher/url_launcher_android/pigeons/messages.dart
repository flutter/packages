// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  javaOptions: JavaOptions(package: 'io.flutter.plugins.urllauncher'),
  javaOut: 'android/src/main/java/io/flutter/plugins/urllauncher/Messages.java',
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Configuration options for an in-app WebView.
class WebViewOptions {
  const WebViewOptions({
    required this.enableJavaScript,
    required this.enableDomStorage,
    this.headers = const <String, String>{},
  });

  final bool enableJavaScript;
  final bool enableDomStorage;
  final Map<String, String> headers;
}

/// Configuration options for in-app browser views.
class BrowserOptions {
  BrowserOptions({required this.showTitle});

  /// Whether or not to show the webpage title.
  final bool showTitle;
}

@HostApi()
abstract class UrlLauncherApi {
  /// Returns true if the URL can definitely be launched.
  bool canLaunchUrl(String url);

  /// Opens the URL externally, returning true if successful.
  bool launchUrl(String url, Map<String, String> headers);

  /// Opens the URL in an in-app Custom Tab or WebView, returning true if it
  /// opens successfully.
  bool openUrlInApp(
    String url,
    bool allowCustomTab,
    WebViewOptions webViewOptions,
    BrowserOptions browserOptions,
  );

  bool supportsCustomTabs();

  /// Closes the view opened by [openUrlInSafariViewController].
  void closeWebView();
}

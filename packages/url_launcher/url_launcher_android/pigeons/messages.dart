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

/// Possible responses for launching a URL.
enum LaunchStatus {
  /// The URL was launched successfully.
  success,

  /// There is no current activity to launch from.
  noCurrentActivity,

  /// No activity was found to handle the launch intent.
  noHandlingActivity,
}

// TODO(stuartmorgan): Remove this when
// https://github.com/flutter/flutter/issues/87307 is implemented.
class LaunchStatusWrapper {
  LaunchStatusWrapper({required this.value});
  final LaunchStatus value;
}

/// Configuration options for an in-app WebView.
class WebViewOptions {
  const WebViewOptions(
      {required this.enableJavaScript,
      required this.enableDomStorage,
      this.headers = const <String, String>{}});
  final bool enableJavaScript;
  final bool enableDomStorage;
  // TODO(stuartmorgan): Declare these as non-nullable generics once
  // https://github.com/flutter/flutter/issues/97848 is fixed. In practice,
  // the values will never be null, and the native implementation assumes that.
  final Map<String?, String?> headers;
}

@HostApi()
abstract class UrlLauncherApi {
  /// Returns true if the URL can definitely be launched.
  bool canLaunchUrl(String url);

  /// Opens the URL externally, returning true if successful.
  LaunchStatusWrapper launchUrl(String url, Map<String, String> headers);

  /// Opens the URL in an in-app WebView, returning true when it has loaded
  /// successfully.
  LaunchStatusWrapper openUrlInWebView(String url, WebViewOptions options);

  /// Closes the view opened by [openUrlInSafariViewController].
  void closeWebView();
}

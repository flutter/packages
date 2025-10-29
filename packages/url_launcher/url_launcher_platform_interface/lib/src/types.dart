// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// The desired mode to launch a URL.
///
/// Support for these modes varies by platform. Platforms that do not support
/// the requested mode may substitute another mode.
enum PreferredLaunchMode {
  /// Leaves the decision of how to launch the URL to the platform
  /// implementation.
  platformDefault,

  /// Loads the URL in an in-app web view (e.g., Android WebView).
  inAppWebView,

  /// Loads the URL in an in-app browser view (e.g., Android Custom Tabs,
  /// SFSafariViewController).
  inAppBrowserView,

  /// Passes the URL to the OS to be handled by another application.
  externalApplication,

  /// Passes the URL to the OS to be handled by another non-browser application.
  externalNonBrowserApplication,
}

/// Additional configuration options for [PreferredLaunchMode.inAppWebView].
///
/// Not all options are supported on all platforms. This is a superset of
/// available options exposed across all implementations.
@immutable
class InAppWebViewConfiguration {
  /// Creates a new WebViewConfiguration with the given settings.
  const InAppWebViewConfiguration({
    this.enableJavaScript = true,
    this.enableDomStorage = true,
    this.headers = const <String, String>{},
  });

  /// Whether or not JavaScript is enabled for the web content.
  final bool enableJavaScript;

  /// Whether or not DOM storage is enabled for the web content.
  final bool enableDomStorage;

  /// Additional headers to pass in the load request.
  final Map<String, String> headers;
}

/// Additional configuration options for [PreferredLaunchMode.inAppBrowserView].
@immutable
class InAppBrowserConfiguration {
  /// Creates a new InAppBrowserConfiguration with given settings.
  const InAppBrowserConfiguration({this.showTitle = false});

  /// Whether or not to show the webpage title.
  ///
  /// May not be supported on all platforms.
  final bool showTitle;
}

/// Options for [launchUrl].
@immutable
class LaunchOptions {
  /// Creates a new parameter object with the given options.
  const LaunchOptions({
    this.mode = PreferredLaunchMode.platformDefault,
    this.webViewConfiguration = const InAppWebViewConfiguration(),
    this.browserConfiguration = const InAppBrowserConfiguration(),
    this.webOnlyWindowName,
  });

  /// The requested launch mode.
  final PreferredLaunchMode mode;

  /// Configuration for the web view in [PreferredLaunchMode.inAppWebView] mode.
  final InAppWebViewConfiguration webViewConfiguration;

  /// Configuration for the browser view in [PreferredLaunchMode.inAppBrowserView] mode.
  final InAppBrowserConfiguration browserConfiguration;

  /// A web-platform-specific option to set the link target.
  ///
  /// Default behaviour when unset should be to open the url in a new tab.
  final String? webOnlyWindowName;
}

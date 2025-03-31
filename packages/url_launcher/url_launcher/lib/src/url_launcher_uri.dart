// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

// PreferredLaunchMode is hidden to prevent accidentally using it in APIs at
// this layer. If it is ever needed in this file, it should be imported
// separately with a prefix.
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart'
    hide PreferredLaunchMode;

import '../url_launcher_string.dart';
import 'type_conversion.dart';

/// Passes [url] to the underlying platform for handling.
///
/// [mode] support varies significantly by platform. Clients can use
/// [supportsLaunchMode] to query for support, but platforms will fall back to
/// other modes if the requested mode is not supported, so checking is not
/// required. The default behavior of [LaunchMode.platformDefault] is up to each
/// platform, and its behavior for a given platform may change over time as new
/// modes are supported, so clients that want a specific mode should request it
/// rather than rely on any currently observed default behavior.
///
/// For web, [webOnlyWindowName] specifies a target for the launch. This
/// supports the standard special link target names. For example:
///  - "_blank" opens the new URL in a new tab.
///  - "_self" opens the new URL in the current tab.
/// Default behaviour when unset is to open the url in a new tab.
///
/// Web browsers prevent launching URLs in a new tab/window, unless
/// triggered by a user action (e.g. a button click). See
/// [package:url_launcher_web](https://pub.dev/packages/url_launcher_web#limitations-on-the-web-platform)
/// for more details.
///
/// Returns true if the URL was launched successfully, otherwise either returns
/// false or throws a [PlatformException] depending on the failure.
Future<bool> launchUrl(
  Uri url, {
  LaunchMode mode = LaunchMode.platformDefault,
  WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
  BrowserConfiguration browserConfiguration = const BrowserConfiguration(),
  String? webOnlyWindowName,
}) async {
  if ((mode == LaunchMode.inAppWebView ||
          mode == LaunchMode.inAppBrowserView) &&
      !(url.scheme == 'https' || url.scheme == 'http')) {
    throw ArgumentError.value(url, 'url',
        'To use an in-app web view, you must provide an http(s) URL.');
  }
  return UrlLauncherPlatform.instance.launchUrl(
    url.toString(),
    LaunchOptions(
      mode: convertLaunchMode(mode),
      webViewConfiguration: convertWebViewConfiguration(webViewConfiguration),
      browserConfiguration: convertBrowserConfiguration(browserConfiguration),
      webOnlyWindowName: webOnlyWindowName,
    ),
  );
}

/// Checks whether the specified URL can be handled by some app installed on the
/// device.
///
/// Returns true if it is possible to verify that there is a handler available.
/// A false return value can indicate either that there is no handler available,
/// or that the application does not have permission to check. For example:
/// - On recent versions of Android and iOS, this will always return false
///   unless the application has been configuration to allow
///   querying the system for launch support. See
///   [the README](https://pub.dev/packages/url_launcher#configuration) for
///   details.
/// - On web, this will always return false except for a few specific schemes
///   that are always assumed to be supported (such as http(s)), as web pages
///   are never allowed to query installed applications.
Future<bool> canLaunchUrl(Uri url) async {
  return UrlLauncherPlatform.instance.canLaunch(url.toString());
}

/// Closes the current in-app web view, if one was previously opened by
/// [launchUrl].
///
/// This works only if [supportsCloseForLaunchMode] returns true for the mode
/// that was used by [launchUrl].
Future<void> closeInAppWebView() async {
  return UrlLauncherPlatform.instance.closeWebView();
}

/// Returns true if [mode] is supported by the current platform implementation.
///
/// Calling [launchUrl] with an unsupported mode will fall back to a supported
/// mode, so calling this method is only necessary for cases where the caller
/// needs to know which mode will be used.
Future<bool> supportsLaunchMode(LaunchMode mode) {
  return UrlLauncherPlatform.instance.supportsMode(convertLaunchMode(mode));
}

/// Returns true if [closeInAppWebView] is supported for [mode] in the current
/// platform implementation.
///
/// If this returns false, [closeInAppWebView] will not work when launching
/// URLs with [mode].
Future<bool> supportsCloseForLaunchMode(LaunchMode mode) {
  return UrlLauncherPlatform.instance.supportsMode(convertLaunchMode(mode));
}

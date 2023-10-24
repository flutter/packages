// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'src/messages.g.dart';

/// An implementation of [UrlLauncherPlatform] for iOS.
class UrlLauncherIOS extends UrlLauncherPlatform {
  /// Creates a new plugin implementation instance.
  UrlLauncherIOS({
    @visibleForTesting UrlLauncherApi? api,
  }) : _hostApi = api ?? UrlLauncherApi();

  final UrlLauncherApi _hostApi;

  /// Registers this class as the default instance of [UrlLauncherPlatform].
  static void registerWith() {
    UrlLauncherPlatform.instance = UrlLauncherIOS();
  }

  @override
  final LinkDelegate? linkDelegate = null;

  @override
  Future<bool> canLaunch(String url) {
    return _hostApi.canLaunchUrl(url);
  }

  @override
  Future<void> closeWebView() {
    return _hostApi.closeSafariViewController();
  }

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    final PreferredLaunchMode mode;
    if (useSafariVC) {
      mode = PreferredLaunchMode.inAppBrowserView;
    } else if (universalLinksOnly) {
      mode = PreferredLaunchMode.externalNonBrowserApplication;
    } else {
      mode = PreferredLaunchMode.externalApplication;
    }
    return launchUrl(
        url,
        LaunchOptions(
            mode: mode,
            webViewConfiguration: InAppWebViewConfiguration(
                enableDomStorage: enableDomStorage,
                enableJavaScript: enableJavaScript,
                headers: headers)));
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    final bool inApp;
    switch (options.mode) {
      case PreferredLaunchMode.inAppWebView:
      case PreferredLaunchMode.inAppBrowserView:
        // The iOS implementation doesn't distinguish between these two modes;
        // both are treated as inAppBrowserView.
        inApp = true;
        break;
      case PreferredLaunchMode.externalApplication:
      case PreferredLaunchMode.externalNonBrowserApplication:
        inApp = false;
        break;
      case PreferredLaunchMode.platformDefault:
      // Intentionally treat any new values as platformDefault; support for any
      // new mode requires intentional opt-in, otherwise falling back is the
      // documented behavior.
      // ignore: no_default_cases
      default:
        // By default, open web URLs in the application.
        inApp = url.startsWith('http:') || url.startsWith('https:');
        break;
    }

    if (inApp) {
      return _hostApi.openUrlInSafariViewController(url);
    } else {
      return _hostApi.launchUrl(url,
          options.mode == PreferredLaunchMode.externalNonBrowserApplication);
    }
  }

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async {
    switch (mode) {
      case PreferredLaunchMode.platformDefault:
      case PreferredLaunchMode.inAppWebView:
      case PreferredLaunchMode.inAppBrowserView:
      case PreferredLaunchMode.externalApplication:
      case PreferredLaunchMode.externalNonBrowserApplication:
        return true;
      // Default is a desired behavior here since support for new modes is
      // always opt-in, and the enum lives in a different package, so silently
      // adding "false" for new values is the correct behavior.
      // ignore: no_default_cases
      default:
        return false;
    }
  }

  @override
  Future<bool> supportsCloseForMode(PreferredLaunchMode mode) async {
    return mode == PreferredLaunchMode.inAppWebView ||
        mode == PreferredLaunchMode.inAppBrowserView;
  }
}

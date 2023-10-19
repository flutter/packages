// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'src/messages.g.dart';

/// An implementation of [UrlLauncherPlatform] for Android.
class UrlLauncherAndroid extends UrlLauncherPlatform {
  /// Creates a new plugin implementation instance.
  UrlLauncherAndroid({
    @visibleForTesting UrlLauncherApi? api,
  }) : _hostApi = api ?? UrlLauncherApi();

  final UrlLauncherApi _hostApi;

  /// Registers this class as the default instance of [UrlLauncherPlatform].
  static void registerWith() {
    UrlLauncherPlatform.instance = UrlLauncherAndroid();
  }

  @override
  final LinkDelegate? linkDelegate = null;

  @override
  Future<bool> canLaunch(String url) async {
    final bool canLaunchSpecificUrl = await _hostApi.canLaunchUrl(url);
    if (!canLaunchSpecificUrl) {
      final String scheme = _getUrlScheme(url);
      // canLaunch can return false when a custom application is registered to
      // handle a web URL, but the caller doesn't have permission to see what
      // that handler is. If that happens, try a web URL (with the same scheme
      // variant, to be safe) that should not have a custom handler. If that
      // returns true, then there is a browser, which means that there is
      // at least one handler for the original URL.
      if (scheme == 'http' || scheme == 'https') {
        return _hostApi.canLaunchUrl('$scheme://flutter.dev');
      }
    }
    return canLaunchSpecificUrl;
  }

  @override
  Future<void> closeWebView() {
    return _hostApi.closeWebView();
  }

  // TODO(stuartmorgan): Implement launchUrl, and make this a passthrough
  // to launchUrl. See also https://github.com/flutter/flutter/issues/66721
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
    final bool succeeded;
    if (useWebView) {
      succeeded = await _hostApi.openUrlInWebView(
          url,
          WebViewOptions(
              enableJavaScript: enableJavaScript,
              enableDomStorage: enableDomStorage,
              headers: headers));
    } else {
      succeeded = await _hostApi.launchUrl(url, headers);
    }
    // TODO(stuartmorgan): Remove this special handling as part of a
    // breaking change to rework failure handling across all platform. The
    // current behavior is backwards compatible with the previous Java error.
    if (!succeeded) {
      throw PlatformException(
          code: 'ACTIVITY_NOT_FOUND',
          message: 'No Activity found to handle intent { $url }');
    }
    return succeeded;
  }

  // Returns the part of [url] up to the first ':', or an empty string if there
  // is no ':'. This deliberately does not use [Uri] to extract the scheme
  // so that it works on strings that aren't actually valid URLs, since Android
  // is very lenient about what it accepts for launching.
  String _getUrlScheme(String url) {
    final int schemeEnd = url.indexOf(':');
    if (schemeEnd == -1) {
      return '';
    }
    return url.substring(0, schemeEnd);
  }
}

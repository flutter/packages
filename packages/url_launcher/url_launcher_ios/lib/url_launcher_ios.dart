// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
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
  Future<bool> canLaunch(String url) async {
    final LaunchResultDetails result = await _hostApi.canLaunchUrl(url);
    return _mapLaunchResults(results: result);
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
    final LaunchResultDetails result =
        await _launchUrl(useSafariVC, url, universalLinksOnly);
    return _mapLaunchResults(results: result);
  }

  Future<LaunchResultDetails> _launchUrl(
      bool useSafariVC, String url, bool universalLinksOnly) {
    if (useSafariVC) {
      return _hostApi.openUrlInSafariViewController(url);
    } else {
      return _hostApi.launchUrl(url, universalLinksOnly);
    }
  }

  bool _mapLaunchResults({required final LaunchResultDetails results}) {
    switch (results.result) {
      case LaunchResult.success:
        return true;
      case LaunchResult.failure:
        return false;
      case LaunchResult.invalidUrl:
        throw PlatformException(
          code: 'invalidUrl',
          message: results.errorMessage,
          details: results.errorDetails,
        );
      case LaunchResult.failedToLoad:
        throw PlatformException(
          code: 'failedToLoad',
          message: results.errorMessage,
          details: results.errorDetails,
        );
    }
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'src/messages.g.dart';

/// An implementation of [UrlLauncherPlatform] for Linux.
class UrlLauncherLinux extends UrlLauncherPlatform {
  /// Creates a new URL launcher instance.
  UrlLauncherLinux({@visibleForTesting UrlLauncherApi? api})
      : _hostApi = api ?? UrlLauncherApi();

  /// Registers this class as the default instance of [UrlLauncherPlatform].
  static void registerWith() {
    UrlLauncherPlatform.instance = UrlLauncherLinux();
  }

  final UrlLauncherApi _hostApi;

  @override
  final LinkDelegate? linkDelegate = null;

  @override
  Future<bool> canLaunch(String url) async {
    return _hostApi.canLaunchUrl(url);
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
  }) {
    // None of the options are supported, so they don't need to be converted to
    // LaunchOptions.
    return launchUrl(url, const LaunchOptions());
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    final String? error = await _hostApi.launchUrl(url);
    if (error != null) {
      // TODO(stuartmorgan): Standardize errors across the entire plugin,
      // instead of using PlatformException. This preserves the pre-Pigeon
      // behavior of the C code returning this error response.
      throw PlatformException(
          code: 'Launch Error', message: 'Failed to launch URL: $error');
    }
    return true;
  }

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async {
    return mode == PreferredLaunchMode.platformDefault ||
        mode == PreferredLaunchMode.externalApplication;
  }

  @override
  Future<bool> supportsCloseForMode(PreferredLaunchMode mode) async {
    // No supported mode is closeable.
    return false;
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import '../platform_interface/platform_ima_settings.dart';
import 'interactive_media_ads.g.dart';

/// Implementation of [PlatformImaSettings] for iOS.
final class IOSImaSettings extends PlatformImaSettings {
  /// Constructs an [IosImaSettings].
  IOSImaSettings(super.params) : super.implementation();

  /// The native iOS ImaSdkSettings.
  ///
  /// Defines general SDK settings that are used when creating an `IMAAdsLoader`.
  @internal
  late final IMASettings nativeSetting = _initSettings();

  @override
  Future<void> setAutoPlayAdBreaks(bool autoPlayAdBreaks) {
    return nativeSetting.setAutoPlayAdBreaks(autoPlayAdBreaks);
  }

  @override
  Future<void> setDebugMode(bool enabled) {
    return nativeSetting.setEnableDebugMode(enabled);
  }

  @override
  Future<void> setFeatureFlags(Map<String, String>? featureFlags) {
    return nativeSetting.setFeatureFlags(featureFlags ?? <String, String>{});
  }

  @override
  Future<void> setMaxRedirects(int maxRedirects) {
    return nativeSetting.setMaxRedirects(maxRedirects);
  }

  @override
  Future<void> setPlayerType(String? playerType) {
    return nativeSetting.setPlayerType(playerType);
  }

  @override
  Future<void> setPlayerVersion(String? playerVersion) {
    return nativeSetting.setPlayerVersion(playerVersion);
  }

  @override
  Future<void> setPpid(String? ppid) {
    return nativeSetting.setPPID(ppid);
  }

  @override
  Future<void> setSessionID(String? sessionID) {
    return nativeSetting.setSessionID(sessionID ?? '');
  }

  IMASettings _initSettings() {
    final IMASettings settings = IMASettings();
    if (params.language case final String language) {
      settings.setLanguage(language);
    }
    return settings;
  }
}

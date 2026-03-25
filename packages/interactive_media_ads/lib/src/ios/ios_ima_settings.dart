// Copyright 2013 The Flutter Authors
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
  late final IMASettings nativeSettings = _createSettings();

  @override
  Future<void> setAutoPlayAdBreaks(bool autoPlayAdBreaks) {
    return nativeSettings.setAutoPlayAdBreaks(autoPlayAdBreaks);
  }

  @override
  Future<void> setDebugMode(bool enabled) {
    return nativeSettings.setEnableDebugMode(enabled);
  }

  @override
  Future<void> setFeatureFlags(Map<String, String>? featureFlags) {
    return nativeSettings.setFeatureFlags(featureFlags ?? <String, String>{});
  }

  @override
  Future<void> setMaxRedirects(int maxRedirects) {
    return nativeSettings.setMaxRedirects(maxRedirects);
  }

  @override
  Future<void> setPlayerType(String? playerType) {
    return nativeSettings.setPlayerType(playerType);
  }

  @override
  Future<void> setPlayerVersion(String? playerVersion) {
    return nativeSettings.setPlayerVersion(playerVersion);
  }

  @override
  Future<void> setPpid(String? ppid) {
    return nativeSettings.setPPID(ppid);
  }

  @override
  Future<void> setSessionID(String? sessionID) {
    return nativeSettings.setSessionID(sessionID);
  }

  /// Enable background audio playback for the SDK.
  ///
  /// The default value is false.
  Future<void> setEnableBackgroundPlayback(bool enabled) {
    return nativeSettings.setEnableBackgroundPlayback(enabled);
  }

  IMASettings _createSettings() {
    final settings = IMASettings();
    if (params.language case final String language) {
      settings.setLanguage(language);
    }
    return settings;
  }
}

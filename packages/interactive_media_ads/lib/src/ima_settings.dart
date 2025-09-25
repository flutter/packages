// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'ads_loader.dart';
import 'platform_interface/platform_interface.dart';

/// Defines general SDK settings that are used when creating an [AdsLoader].
///
/// ## Platform-Specific Features
/// This class contains an underlying implementation provided by the current
/// platform. Once a platform implementation is imported, the examples below
/// can be followed to use features provided by a platform's implementation.
///
/// {@macro interactive_media_ads.ImaSettings.fromPlatformCreationParams}
///
/// Below is an example of accessing the platform-specific implementation for
/// iOS and Android:
///
/// ```dart
/// final ImaSettings settings = ImaSettings();
///
/// switch (settings.platform) {
///   case final IOSImaSettings iosSettings:
///     // ...
///   case final AndroidImaSettings androidSettings:
///     // ...
/// }
/// ```
@immutable
class ImaSettings {
  /// Creates an [ImaSettings].
  ImaSettings({String? language})
    : this.fromPlatformCreationParams(
        PlatformImaSettingsCreationParams(language: language),
      );

  /// Constructs an [ImaSettings] from creation params for a specific platform.
  ///
  /// {@template interactive_media_ads.ImaSettings.fromPlatformCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// iOS and Android:
  ///
  /// ```dart
  /// PlatformImaSettingsCreationParams params =
  ///     const PlatformImaSettingsCreationParams();
  ///
  /// if (InteractiveMediaAdsPlatform.instance is IOSInteractiveMediaAdsPlatform) {
  ///   params = IOSImaSettingsCreationParams
  ///       .fromPlatformImaSettingsCreationParams(
  ///     params,
  ///   );
  /// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
  ///   params = AndroidImaSettingsCreationParams
  ///       .fromPlatformImaSettingsCreationParams(
  ///     params,
  ///   );
  /// }
  ///
  /// final ImaSettings settings = ImaSettings.fromPlatformCreationParams(
  ///   params,
  /// );
  /// ```
  /// {@endtemplate}
  ImaSettings.fromPlatformCreationParams(
    PlatformImaSettingsCreationParams params,
  ) : this.fromPlatform(PlatformImaSettings(params));

  /// Constructs an [ImaSettings] from a specific platform implementation.
  const ImaSettings.fromPlatform(this.platform);

  /// Implementation of [PlatformImaSettings] for the current platform.
  final PlatformImaSettings platform;

  /// Specifies whether to automatically play VMAP and ad rules ad breaks.
  ///
  /// The default value is true.
  Future<void> setAutoPlayAdBreaks(bool autoPlayAdBreaks) {
    return platform.setAutoPlayAdBreaks(autoPlayAdBreaks);
  }

  /// Enables and disables the debug mode, which is disabled by default.
  Future<void> setDebugMode(bool enabled) {
    return platform.setDebugMode(enabled);
  }

  /// Sets the feature flags and their states to control experimental features.
  ///
  /// This should be set as early as possible, before requesting ads. Settings
  /// will remain constant until the next ad request. Calling this method again
  /// will reset any feature flags for the next ad request.
  Future<void> setFeatureFlags(Map<String, String> featureFlags) {
    return platform.setFeatureFlags(featureFlags);
  }

  /// Specifies maximum number of redirects after which subsequent redirects
  /// will be denied, and the ad load aborted.
  ///
  /// In this case, the ad will raise an error with error code 302.
  ///
  /// The default value is 4.
  Future<void> setMaxRedirects(int maxRedirects) {
    return platform.setMaxRedirects(maxRedirects);
  }

  /// Sets the partner specified video player that is integrating with the SDK.
  ///
  /// This setting should be used to specify the name of the player being
  /// integrated with the SDK. Player type greater than 20 characters will be
  /// truncated. The player type specified should be short and unique. This is
  /// an optional setting used to improve SDK usability by tracking player
  /// types.
  Future<void> setPlayerType(String playerType) {
    return platform.setPlayerType(playerType);
  }

  /// Sets the partner specified player version that is integrating with the
  /// SDK.
  ///
  /// This setting should be usegd to specify the version of the partner player
  /// being integrated with the SDK. Player versions greater than 20 characters
  /// will be truncated. This is an optional setting used to improve SDK
  /// usability by tracking player version.
  Future<void> setPlayerVersion(String playerVersion) {
    return platform.setPlayerVersion(playerVersion);
  }

  /// Sets the Publisher Provided Identification (PPID) sent with ads request.
  Future<void> setPpid(String ppid) {
    return platform.setPpid(ppid);
  }

  /// Sets the session ID to identify a single user session.
  ///
  /// This must be a UUID. It is used exclusively for frequency capping across
  /// the user session.
  Future<void> setSessionID(String sessionID) {
    return platform.setSessionID(sessionID);
  }

  @override
  bool operator ==(Object other) =>
      other is ImaSettings && other.platform == platform;

  @override
  int get hashCode => platform.hashCode;
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'interactive_media_ads_platform.dart';

/// Object specifying creation parameters for creating a [PlatformImaSettings].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the
/// [PlatformImaSettingsCreationParams] to provide additional
/// platform specific parameters.
///
/// When extending [PlatformImaSettingsCreationParams] additional
/// parameters should always accept `null` or have a default value to prevent
/// breaking changes.
///
/// ```dart
/// class AndroidPlatformImaSettingsCreationParams
///     extends PlatformImaSettingsCreationParams {
///   AndroidPlatformImaSettingsCreationParams({
///     super.language,
///     this.androidSpecificValue,
///   });
///
///   factory AndroidPlatformImaSettingsCreationParams.fromPlatformImaSettingsCreationParams(
///     PlatformImaSettingsCreationParams params, {
///     String? androidSpecificValue,
///   }) {
///     return AndroidPlatformImaSettingsCreationParams._(
///       params,
///       androidSpecificValue: androidSpecificValue
///     );
///   }
///
///   final String? androidSpecificValue;
/// }
/// ```
@immutable
base class PlatformImaSettingsCreationParams {
  /// Used by the platform implementation to create a new [PlatformImaSettings].
  const PlatformImaSettingsCreationParams({this.language});

  /// Language specification used for localization.
  ///
  /// For Android, the supported codes can be found in the Localization guide
  /// and are closely related to the two-letter ISO 639-1 language codes.
  ///
  /// For iOS, `language` must be formatted as a canonicalized IETF BCP 47
  /// language identifier such as would be returned by
  /// `[NSLocale preferredLanguages]`.
  final String? language;
}

/// Defines general SDK settings that are used when creating a
/// `PlatformAdsLoader`.
abstract base class PlatformImaSettings {
  /// Creates a new [PlatformImaSettings].
  factory PlatformImaSettings(PlatformImaSettingsCreationParams params) {
    assert(InteractiveMediaAdsPlatform.instance != null);
    final PlatformImaSettings implementation = InteractiveMediaAdsPlatform
        .instance!
        .createPlatformImaSettings(params);
    return implementation;
  }

  /// Used by the platform implementation to create a new [PlatformImaSettings].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformImaSettings.implementation(this.params);

  /// The parameters used to initialize the [PlatformImaSettings].
  final PlatformImaSettingsCreationParams params;

  /// Sets the Publisher Provided Identification (PPID) sent with ads request.
  Future<void> setPpid(String ppid);

  /// Specifies maximum number of redirects after which subsequent redirects
  /// will be denied, and the ad load aborted.
  ///
  /// In this case, the ad will raise an error with error code 302.
  ///
  /// The default value is 4.
  Future<void> setMaxRedirects(int maxRedirects);

  /// Sets the feature flags and their states to control experimental features.
  ///
  /// This should be set as early as possible, before requesting ads. Settings
  /// will remain constant until the next ad request. Calling this method again
  /// will reset any feature flags for the next ad request.
  Future<void> setFeatureFlags(Map<String, String> featureFlags);

  /// Specifies whether to automatically play VMAP and ad rules ad breaks.
  ///
  /// The default value is true.
  Future<void> setAutoPlayAdBreaks(bool autoPlayAdBreaks);

  /// Sets the partner specified video player that is integrating with the SDK.
  ///
  /// This setting should be used to specify the name of the player being
  /// integrated with the SDK. Player type greater than 20 characters will be
  /// truncated. The player type specified should be short and unique. This is
  /// an optional setting used to improve SDK usability by tracking player
  /// types.
  Future<void> setPlayerType(String playerType);

  /// Sets the partner specified player version that is integrating with the
  /// SDK.
  ///
  /// This setting should be usegd to specify the version of the partner player
  /// being integrated with the SDK. Player versions greater than 20 characters
  /// will be truncated. This is an optional setting used to improve SDK
  /// usability by tracking player version.
  Future<void> setPlayerVersion(String playerVersion);

  /// Sets the session ID to identify a single user session.
  ///
  /// This must be a UUID. It is used exclusively for frequency capping across
  /// the user session.
  Future<void> setSessionID(String sessionID);

  /// Enables and disables the debug mode, which is disabled by default.
  Future<void> setDebugMode(bool enabled);
}

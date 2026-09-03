// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// Widevine DRM configuration for the Android implementation of video_player.
///
/// Pass an instance of this class as the `drmConfiguration` of a network data
/// source to play Widevine-protected content. The license exchange itself is
/// performed by Media3/ExoPlayer, using [licenseUri] and [licenseHeaders].
///
/// DRM is only supported for network sources; providing this configuration for
/// any other source type throws an [ArgumentError].
@immutable
class WidevineDrmConfiguration extends VideoDrmConfiguration {
  /// Creates a configuration for Widevine playback.
  const WidevineDrmConfiguration({
    required this.licenseUri,
    this.licenseHeaders = const <String, String>{},
  });

  /// The license acquisition URL of the Widevine license server.
  final Uri licenseUri;

  /// Headers to attach to each license request sent to [licenseUri].
  ///
  /// This is typically where provider-specific authorization tokens go.
  final Map<String, String> licenseHeaders;
}

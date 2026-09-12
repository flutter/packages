// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// FairPlay DRM configuration for the AVFoundation implementation of
/// video_player.
///
/// Pass an instance of this class as the `drmConfiguration` of a network data
/// source to play FairPlay-protected content. The plugin installs an
/// `AVAssetResourceLoaderDelegate` that fetches the application certificate
/// from [certificateUri], generates the SPC, and POSTs it to [licenseUri] with
/// [licenseHeaders] to obtain the CKC.
///
/// Only the standard FairPlay exchange is supported: the SPC is sent as an
/// `application/octet-stream` body, and the response body is used as the CKC
/// as-is. Providers that require custom request or response encoding are not
/// supported.
///
/// DRM is only supported for network sources; providing this configuration for
/// any other source type throws an [ArgumentError].
@immutable
class FairPlayDrmConfiguration extends VideoDrmConfiguration {
  /// Creates a configuration for FairPlay playback.
  const FairPlayDrmConfiguration({
    required this.certificateUri,
    required this.licenseUri,
    this.licenseHeaders = const <String, String>{},
    this.contentId,
  });

  /// The URL of the FairPlay application certificate.
  final Uri certificateUri;

  /// The license acquisition URL of the FairPlay license server.
  final Uri licenseUri;

  /// Headers to attach to each license request sent to [licenseUri].
  ///
  /// This is typically where provider-specific authorization tokens go.
  final Map<String, String> licenseHeaders;

  /// The content identifier to use when generating the SPC.
  ///
  /// If this is null, the full `skd://` key URI that AVFoundation asks the
  /// plugin to resolve is used, for example `skd://some-key-id`.
  ///
  /// License servers differ on what they expect as the content identifier.
  /// Providers that key licenses on just the identifier portion of that URI,
  /// rather than the whole URI, need it passed explicitly here — supplying the
  /// wrong identifier produces an SPC the license server will reject.
  final String? contentId;
}

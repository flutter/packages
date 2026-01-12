// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Simple data object containing podding metadata.
base class PlatformAdPodInfo {
  /// Constructs a [PlatformAdPodInfo].
  PlatformAdPodInfo({
    required this.adPosition,
    required this.maxDuration,
    required this.podIndex,
    required this.timeOffset,
    required this.totalAds,
    required this.isBumper,
  });

  /// The position of the ad within the pod.
  ///
  /// The value returned is one-based, for example, 1 of 2, 2 of 2, etc. If the
  /// ad is not part of a pod, this will return 1.
  final int adPosition;

  /// The maximum duration of the pod.
  ///
  /// For unknown duration, null.
  final Duration? maxDuration;

  /// Returns the index of the ad pod.
  ///
  /// Client side: For a preroll pod, returns 0. For midrolls, returns 1, 2,…,
  /// N. For a postroll pod, returns -1. Defaults to 0 if this ad is not part of
  /// a pod, or this pod is not part of a playlist.
  ///
  /// DAI VOD: Returns the index of the ad pod. For a preroll pod, returns 0.
  /// For midrolls, returns 1, 2,…,N. For a postroll pod, returns N+1…N+X.
  /// Defaults to 0 if this ad is not part of a pod, or this pod is not part of
  /// a playlist.
  ///
  /// DAI live stream: For a preroll pod, returns 0. For midrolls, returns the
  /// break ID. Returns -2 if pod index cannot be determined (internal error).
  final int podIndex;

  /// The content time offset at which the current ad pod was scheduled.
  ///
  /// For preroll pod, 0 is returned. For midrolls, the scheduled time is
  /// returned. For postroll, -1 is returned. Defaults to 0 if this ad is not
  /// part of a pod, or the pod is not part of an ad playlist.
  final Duration timeOffset;

  /// Total number of ads in the pod this ad belongs to, including bumpers.
  ///
  /// Will be 1 for standalone ads.
  final int totalAds;

  /// Specifies whether the ad is a bumper.
  ///
  /// Bumpers are short videos used to open and close ad breaks.
  final bool isBumper;
}

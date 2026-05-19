// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// An object that holds data corresponding to the companion Ad.
base class PlatformCompanionAd {
  /// Constructs a [PlatformCompanionAd].
  PlatformCompanionAd({
    required this.width,
    required this.height,
    required this.apiFramework,
    required this.resourceValue,
  });

  /// The width of the companion in pixels.
  ///
  /// `null` if unavailable.
  final int? width;

  /// The height of the companion in pixels.
  ///
  /// `null` if unavailable.
  final int? height;

  /// The API needed to execute this ad, or null if unavailable.
  final String? apiFramework;

  /// The URL for the static resource of this companion.
  final String? resourceValue;
}

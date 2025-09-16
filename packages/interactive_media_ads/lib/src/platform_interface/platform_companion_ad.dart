// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// An object that holds data corresponding to the companion Ad.
base class PlatformCompanionAd {
  /// Constructs a [PlatformCompanionAd].
  PlatformCompanionAd({
    required this.apiFramework,
    required this.height,
    required this.resourceValue,
    required this.width,
  });

  /// The API needed to execute this ad, or null if unavailable.
  final String? apiFramework;

  /// The height of the companion in pixels.
  final int? height;

  /// The URL for the static resource of this companion.
  final String? resourceValue;

  /// The width of the companion in pixels.
  final int? width;
}

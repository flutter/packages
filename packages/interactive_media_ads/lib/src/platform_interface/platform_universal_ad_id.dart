// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Simple data object containing universal ad ID information.
base class PlatformUniversalAdId {
  /// Constructs a [PlatformUniversalAdId].
  PlatformUniversalAdId({required this.adIdValue, required this.adIdRegistry});

  /// The universal ad ID value.
  ///
  /// This will be null if it isn’t defined by the ad.
  final String? adIdValue;

  /// The universal ad ID registry with which the value is registered.
  ///
  /// This will be null if it isn’t defined by the ad.
  final String? adIdRegistry;
}

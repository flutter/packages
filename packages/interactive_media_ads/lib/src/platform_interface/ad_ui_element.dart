// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Describes an element of the ad UI, to be requested or rendered by the SDK.
enum AdUIElement {
  /// The ad attribution UI element, for example, "Ad".
  adAttribution,

  /// Ad attribution is required for a countdown timer to be displayed.
  countdown,
}

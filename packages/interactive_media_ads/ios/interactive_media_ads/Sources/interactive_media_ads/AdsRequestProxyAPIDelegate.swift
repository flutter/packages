// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// ProxyApi delegate implementation for `IMAAdsRequest`.
///
/// This class may handle instantiating native object instances that are attached to a Dart
/// instance or handle method calls on the associated native class or an instance of that class.
class AdsRequestProxyAPIDelegate: PigeonApiDelegateIMAAdsRequest {
  /// The current version of the `interactive_media_ads` plugin.
  ///
  /// This must match the version in pubspec.yaml.
  static let pluginVersion = "0.2.3+7"

  func pigeonDefaultConstructor(
    pigeonApi: PigeonApiIMAAdsRequest, adTagUrl: String, adDisplayContainer: IMAAdDisplayContainer,
    contentPlayhead: IMAContentPlayhead?
  ) throws -> IMAAdsRequest {
    // Ensure adTag can append a custom parameter.
    assert(adTagUrl.contains("?"))
    assert(!adTagUrl.contains("#"))

    let adTagWithRequestAgent =
      "\(adTagUrl)&request_agent=Flutter-IMA-\(AdsRequestProxyAPIDelegate.pluginVersion)"
    return IMAAdsRequest(
      adTagUrl: adTagWithRequestAgent, adDisplayContainer: adDisplayContainer,
      contentPlayhead: contentPlayhead as? ContentPlayheadImpl, userContext: nil)
  }
}

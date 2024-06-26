// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

class AdsRequestProxyAPIDelegate: PigeonDelegateIMAAdsRequest {
  func pigeonDefaultConstructor(
    pigeonApi: PigeonApiIMAAdsRequest, adTagUrl: String, adDisplayContainer: IMAAdDisplayContainer,
    contentPlayhead: IMAContentPlayhead?
  ) throws -> IMAAdsRequest {
    return IMAAdsRequest(
      adTagUrl: adTagUrl, adDisplayContainer: adDisplayContainer,
      contentPlayhead: contentPlayhead as? ContentPlayheadImpl, userContext: nil)
  }
}

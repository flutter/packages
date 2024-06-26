// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

class AdsManagerDelegateImpl: NSObject, IMAAdsManagerDelegate {
  let api: PigeonApiIMAAdsManagerDelegate

  init(api: PigeonApiIMAAdsManagerDelegate) {
    self.api = api
  }

  func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
    api.didReceiveAdEvent(pigeonInstance: self, adsManager: adsManager, event: event) { _ in }
  }

  func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
    api.didReceiveAdError(pigeonInstance: self, adsManager: adsManager, error: error) { _ in }
  }

  func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
    api.didRequestContentPause(pigeonInstance: self, adsManager: adsManager) { _ in }
  }

  func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
    api.didRequestContentResume(pigeonInstance: self, adsManager: adsManager) { _ in }
  }
}

class AdsManagerDelegateProxyAPIDelegate: PigeonDelegateIMAAdsManagerDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiIMAAdsManagerDelegate) throws
    -> IMAAdsManagerDelegate
  {
    return AdsManagerDelegateImpl(api: pigeonApi)
  }
}

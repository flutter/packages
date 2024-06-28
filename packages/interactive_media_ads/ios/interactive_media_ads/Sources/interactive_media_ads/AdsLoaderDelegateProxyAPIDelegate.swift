// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

class AdsLoaderDelegateImpl: IMAAdsLoaderDelegate {
  let api: PigeonApiProtocolIMAAdsLoaderDelegate

  init(api: PigeonApiProtocolIMAAdsLoaderDelegate) {
    self.api = api
  }

  func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
    api.adLoaderLoadedWith(pigeonInstance: self, loader: loader, adsLoadedData: adsLoadedData) {
      _ in
    }
  }

  func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
    api.adsLoaderFailedWithErrorData(pigeonInstance: self, loader: loader, adErrorData: adErrorData)
    { _ in }
  }
}

class AdsLoaderDelegateProxyAPIDelegate: PigeonDelegateIMAAdsLoaderDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiIMAAdsLoaderDelegate) throws
    -> IMAAdsLoaderDelegate
  {
    return AdsLoaderDelegateImpl(api: pigeonApi)
  }
}

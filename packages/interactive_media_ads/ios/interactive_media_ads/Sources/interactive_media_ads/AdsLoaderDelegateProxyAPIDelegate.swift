// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// Implementation of `IMAAdsManagerDelegate` that calls to Dart in callback methods.
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

/// ProxyApi delegate implementation for `IMAAdsLoaderDelegate`.
///
/// This class may handle instantiating native object instances that are attached to a Dart
/// instance or handle method calls on the associated native class or an instance of that class.
class AdsLoaderDelegateProxyAPIDelegate: PigeonApiDelegateIMAAdsLoaderDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiIMAAdsLoaderDelegate) throws
    -> IMAAdsLoaderDelegate
  {
    return AdsLoaderDelegateImpl(api: pigeonApi)
  }
}

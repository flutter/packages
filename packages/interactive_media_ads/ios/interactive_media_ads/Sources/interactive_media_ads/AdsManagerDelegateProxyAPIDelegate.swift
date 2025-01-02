// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// Implementation of `IMAAdsManagerDelegate` that calls to Dart in callback methods.
class AdsManagerDelegateImpl: NSObject, IMAAdsManagerDelegate {
  let api: PigeonApiProtocolIMAAdsManagerDelegate

  init(api: PigeonApiProtocolIMAAdsManagerDelegate) {
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

/// ProxyApi delegate implementation for `IMAAdsManagerDelegate`.
///
/// This class may handle instantiating native object instances that are attached to a Dart
/// instance or handle method calls on the associated native class or an instance of that class.
class AdsManagerDelegateProxyAPIDelegate: PigeonApiDelegateIMAAdsManagerDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiIMAAdsManagerDelegate) throws
    -> IMAAdsManagerDelegate
  {
    return AdsManagerDelegateImpl(api: pigeonApi)
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// ProxyApi implementation for `IMAAdPodInfo`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class AdPodInfoProxyAPIDelegate: PigeonApiDelegateIMAAdPodInfo {
  func adPosition(pigeonApi: PigeonApiIMAAdPodInfo, pigeonInstance: IMAAdPodInfo) throws -> Int64 {
    return Int64(pigeonInstance.adPosition)
  }

  func maxDuration(pigeonApi: PigeonApiIMAAdPodInfo, pigeonInstance: IMAAdPodInfo) throws -> Double
  {
    return pigeonInstance.maxDuration
  }

  func podIndex(pigeonApi: PigeonApiIMAAdPodInfo, pigeonInstance: IMAAdPodInfo) throws -> Int64 {
    return Int64(pigeonInstance.podIndex)
  }

  func timeOffset(pigeonApi: PigeonApiIMAAdPodInfo, pigeonInstance: IMAAdPodInfo) throws -> Double {
    return pigeonInstance.timeOffset
  }

  func totalAds(pigeonApi: PigeonApiIMAAdPodInfo, pigeonInstance: IMAAdPodInfo) throws -> Int64 {
    return Int64(pigeonInstance.totalAds)
  }

  func isBumper(pigeonApi: PigeonApiIMAAdPodInfo, pigeonInstance: IMAAdPodInfo) throws -> Bool {
    return pigeonInstance.isBumper
  }
}

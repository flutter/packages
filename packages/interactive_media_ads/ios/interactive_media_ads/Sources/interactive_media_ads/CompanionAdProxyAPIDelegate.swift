// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// ProxyApi implementation for [IMACompanionAd].
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class CompanionAdProxyAPIDelegate: PigeonApiDelegateIMACompanionAd {
  func resourceValue(pigeonApi: PigeonApiIMACompanionAd, pigeonInstance: IMACompanionAd) throws
    -> String?
  {
    return pigeonInstance.resourceValue
  }

  func apiFramework(pigeonApi: PigeonApiIMACompanionAd, pigeonInstance: IMACompanionAd) throws
    -> String?
  {
    return pigeonInstance.apiFramework
  }

  func width(pigeonApi: PigeonApiIMACompanionAd, pigeonInstance: IMACompanionAd) throws -> Int64 {
    return Int64(pigeonInstance.width)
  }

  func height(pigeonApi: PigeonApiIMACompanionAd, pigeonInstance: IMACompanionAd) throws -> Int64 {
    return Int64(pigeonInstance.height)
  }
}

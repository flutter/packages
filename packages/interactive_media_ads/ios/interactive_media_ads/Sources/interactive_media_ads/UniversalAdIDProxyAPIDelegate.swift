// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// ProxyApi implementation for `IMAUniversalAdID`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class UniversalAdIDProxyAPIDelegate: PigeonApiDelegateIMAUniversalAdID {
  func adIDValue(pigeonApi: PigeonApiIMAUniversalAdID, pigeonInstance: IMAUniversalAdID) throws
    -> String
  {
    return pigeonInstance.adIDValue
  }

  func adIDRegistry(pigeonApi: PigeonApiIMAUniversalAdID, pigeonInstance: IMAUniversalAdID) throws
    -> String
  {
    return pigeonInstance.adIDRegistry
  }
}

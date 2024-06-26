// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

class AdsLoadedDataProxyAPIDelegate: PigeonDelegateIMAAdsLoadedData {
  func adsManager(pigeonApi: PigeonApiIMAAdsLoadedData, pigeonInstance: IMAAdsLoadedData) throws
    -> IMAAdsManager?
  {
    return pigeonInstance.adsManager
  }
}

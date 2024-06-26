// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

class AdLoadingErrorDataProxyAPIDelegate: PigeonDelegateIMAAdLoadingErrorData {
  func adError(pigeonApi: PigeonApiIMAAdLoadingErrorData, pigeonInstance: IMAAdLoadingErrorData)
    throws -> IMAAdError
  {
    return pigeonInstance.adError
  }
}

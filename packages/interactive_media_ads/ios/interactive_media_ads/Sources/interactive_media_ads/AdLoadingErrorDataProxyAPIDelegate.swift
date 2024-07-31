// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// ProxyApi delegate implementation for `IMAAdLoadingErrorData`.
///
/// This class may handle instantiating native object instances that are attached to a Dart
/// instance or handle method calls on the associated native class or an instance of that class.
class AdLoadingErrorDataProxyAPIDelegate: PigeonApiDelegateIMAAdLoadingErrorData {
  func adError(pigeonApi: PigeonApiIMAAdLoadingErrorData, pigeonInstance: IMAAdLoadingErrorData)
    throws -> IMAAdError
  {
    return pigeonInstance.adError
  }
}

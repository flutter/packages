// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// Implementation of `IMACompanionDelegate` that calls to Dart in callback methods.
class CompanionDelegateImpl: NSObject, IMACompanionDelegate {
  let api: PigeonApiProtocolIMACompanionDelegate

  init(api: PigeonApiProtocolIMACompanionDelegate) {
    self.api = api
  }

  func companionSlot(_ slot: IMACompanionAdSlot, filled: Bool) {
    api.companionAdSlotFilled(pigeonInstance: self, slot: slot, filled: filled) { _ in }
  }

  func companionSlotWasClicked(_ slot: IMACompanionAdSlot) {
    api.companionSlotWasClicked(pigeonInstance: self, slot: slot) { _ in }
  }
}

/// ProxyApi implementation for [IMACompanionDelegate].
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class CompanionDelegateProxyAPIDelegate: PigeonApiDelegateIMACompanionDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiIMACompanionDelegate) throws
    -> IMACompanionDelegate
  {
    return CompanionDelegateImpl(api: pigeonApi)
  }
}

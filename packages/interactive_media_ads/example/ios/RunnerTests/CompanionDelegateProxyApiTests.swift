// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing
import UIKit

@testable import interactive_media_ads

@MainActor
struct CompanionDelegateProxyApiTests {
  @Test
  func pigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMACompanionDelegate(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
    #expect(instance != nil)
  }

  @Test
  func companionAdSlotFilled() {
    let api = TestCompanionDelegateApi()
    let instance = CompanionDelegateImpl(api: api)
    let slot = IMACompanionAdSlot(view: UIView())
    let filled = true
    instance.companionSlot(slot, filled: filled)

    #expect(api.companionAdSlotFilledArgs == [slot, filled])
  }

  @Test
  func companionSlotWasClicked() {
    let api = TestCompanionDelegateApi()
    let instance = CompanionDelegateImpl(api: api)
    let slot = IMACompanionAdSlot(view: UIView())
    instance.companionSlotWasClicked(slot)

    #expect(api.companionSlotWasClickedArgs == [slot])
  }
}

class TestCompanionDelegateApi: PigeonApiProtocolIMACompanionDelegate {
  var companionAdSlotFilledArgs: [AnyHashable?]? = nil
  var companionSlotWasClickedArgs: [AnyHashable?]? = nil

  func companionAdSlotFilled(
    pigeonInstance pigeonInstanceArg: IMACompanionDelegate, slot slotArg: IMACompanionAdSlot,
    filled filledArg: Bool,
    completion: @escaping (Result<Void, interactive_media_ads.PigeonError>) -> Void
  ) {
    companionAdSlotFilledArgs = [slotArg, filledArg]
  }

  func companionSlotWasClicked(
    pigeonInstance pigeonInstanceArg: IMACompanionDelegate, slot slotArg: IMACompanionAdSlot,
    completion: @escaping (Result<Void, interactive_media_ads.PigeonError>) -> Void
  ) {
    companionSlotWasClickedArgs = [slotArg]
  }
}

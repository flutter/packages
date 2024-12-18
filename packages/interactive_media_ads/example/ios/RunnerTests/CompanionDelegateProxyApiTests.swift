// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import UIKit
import XCTest

@testable import interactive_media_ads

class CompanionDelegateProxyApiTests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMACompanionDelegate(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
    XCTAssertNotNil(instance)
  }

  func testCompanionAdSlotFilled() {
    let api = TestCompanionDelegateApi()
    let instance = CompanionDelegateImpl(api: api)
    let slot = IMACompanionAdSlot(view: UIView())
    let filled = true
    instance.companionSlot(slot, filled: filled)

    XCTAssertEqual(api.companionAdSlotFilledArgs, [slot, filled])
  }

  func testCompanionSlotWasClicked() {
    let api = TestCompanionDelegateApi()
    let instance = CompanionDelegateImpl(api: api)
    let slot = IMACompanionAdSlot(view: UIView())
    instance.companionSlotWasClicked(slot)

    XCTAssertEqual(api.companionSlotWasClickedArgs, [slot])
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

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import UIKit
import XCTest

@testable import interactive_media_ads

class FriendlyObstructionProxyApiTests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAFriendlyObstruction(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, view: UIView(), purpose: .mediaControls, detailedReason: "myString")
    XCTAssertNotNil(instance)
  }

  func testPigeonDefaultConstructorWithUnknownPurpose() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAFriendlyObstruction(registrar)

    XCTAssertThrowsError(
      try api.pigeonDelegate.pigeonDefaultConstructor(
        pigeonApi: api, view: UIView(), purpose: .unknown, detailedReason: "myString")
    ) { error in
      XCTAssertTrue(error is PigeonError)
    }
  }

  func testView() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAFriendlyObstruction(registrar)

    let instance = IMAFriendlyObstruction(
      view: UIView(), purpose: IMAFriendlyObstructionPurpose.closeAd, detailedReason: "reason")
    let value = try? api.pigeonDelegate.view(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.view)
  }

  func testPurpose() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAFriendlyObstruction(registrar)

    let instance = IMAFriendlyObstruction(
      view: UIView(), purpose: IMAFriendlyObstructionPurpose.closeAd, detailedReason: "reason")
    let value = try? api.pigeonDelegate.purpose(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, FriendlyObstructionPurpose.closeAd)
  }

  func testDetailedReason() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAFriendlyObstruction(registrar)

    let instance = IMAFriendlyObstruction(
      view: UIView(), purpose: IMAFriendlyObstructionPurpose.closeAd, detailedReason: "reason")
    let value = try? api.pigeonDelegate.detailedReason(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.detailedReason)
  }
}

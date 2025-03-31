// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

final class AdDisplayContainerTests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, adContainer: UIView(), companionSlots: [],
      adContainerViewController: UIViewController())
    XCTAssertNotNil(instance)
  }

  func testAdContainer() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer()
    let value = try? api.pigeonDelegate.adContainer(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.adContainer)
  }

  func testCompanionSlots() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer()
    let value = try? api.pigeonDelegate.companionSlots(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.companionSlots)
  }

  func testSetAdContainerViewController() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer()
    let controller = UIViewController()
    try? api.pigeonDelegate.setAdContainerViewController(
      pigeonApi: api, pigeonInstance: instance, controller: controller)

    XCTAssertEqual(instance.adContainerViewController, controller)
  }

  func testGetAdContainerViewController() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer()
    let adContainerViewController = UIViewController()
    instance.adContainerViewController = adContainerViewController
    let value = try? api.pigeonDelegate.getAdContainerViewController(
      pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, adContainerViewController)
  }

  func testRegisterFriendlyObstruction() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer()
    let friendlyObstruction = IMAFriendlyObstruction(
      view: UIView(), purpose: IMAFriendlyObstructionPurpose.closeAd, detailedReason: "reason")
    try? api.pigeonDelegate.registerFriendlyObstruction(
      pigeonApi: api, pigeonInstance: instance, friendlyObstruction: friendlyObstruction)

    XCTAssertEqual(instance.registerFriendlyObstructionArgs, [friendlyObstruction])
  }

  func testUnregisterAllFriendlyObstructions() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer()
    try? api.pigeonDelegate.unregisterAllFriendlyObstructions(
      pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(instance.unregisterAllFriendlyObstructionsCalled)
  }
}

class TestAdDisplayContainer: IMAAdDisplayContainer {
  private var adContainerTestValue = UIView()
  private var companionSlotsTestValue = [IMACompanionAdSlot(view: UIView())]
  var registerFriendlyObstructionArgs: [AnyHashable?]? = nil
  var unregisterAllFriendlyObstructionsCalled = false

  convenience init() {
    self.init(adContainer: UIView(), viewController: UIViewController())
  }

  override var adContainer: UIView {
    return adContainerTestValue
  }

  override var companionSlots: [IMACompanionAdSlot] {
    return companionSlotsTestValue
  }

  override func register(_ friendlyObstruction: IMAFriendlyObstruction) {
    registerFriendlyObstructionArgs = [friendlyObstruction]
  }

  override func unregisterAllFriendlyObstructions() {
    unregisterAllFriendlyObstructionsCalled = true
  }
}

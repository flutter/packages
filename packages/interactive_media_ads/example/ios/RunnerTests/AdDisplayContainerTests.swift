// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing

@testable import interactive_media_ads

@MainActor
struct AdDisplayContainerTests {
  @Test func pigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, adContainer: UIView(), companionSlots: [],
      adContainerViewController: UIViewController())
    #expect(instance != nil)
  }

  @Test func adContainer() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer()
    let value = try? api.pigeonDelegate.adContainer(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.adContainer)
  }

  @Test func companionSlots() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer()
    let value = try? api.pigeonDelegate.companionSlots(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.companionSlots)
  }

  @Test func setAdContainerViewController() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer()
    let controller = UIViewController()
    try? api.pigeonDelegate.setAdContainerViewController(
      pigeonApi: api, pigeonInstance: instance, controller: controller)

    #expect(instance.adContainerViewController == controller)
  }

  @Test func getAdContainerViewController() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer()
    let adContainerViewController = UIViewController()
    instance.adContainerViewController = adContainerViewController
    let value = try? api.pigeonDelegate.getAdContainerViewController(
      pigeonApi: api, pigeonInstance: instance)

    #expect(value == adContainerViewController)
  }

  @Test func registerFriendlyObstruction() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer()
    let friendlyObstruction = IMAFriendlyObstruction(
      view: UIView(), purpose: IMAFriendlyObstructionPurpose.closeAd, detailedReason: "reason")
    try? api.pigeonDelegate.registerFriendlyObstruction(
      pigeonApi: api, pigeonInstance: instance, friendlyObstruction: friendlyObstruction)

    #expect(instance.registerFriendlyObstructionArgs as! [AnyHashable] == [friendlyObstruction])
  }

  @Test func unregisterAllFriendlyObstructions() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer()
    try? api.pigeonDelegate.unregisterAllFriendlyObstructions(
      pigeonApi: api, pigeonInstance: instance)

    #expect(instance.unregisterAllFriendlyObstructionsCalled)
  }
}

@MainActor
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

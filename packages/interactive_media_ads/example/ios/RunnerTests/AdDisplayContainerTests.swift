// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing

@testable import interactive_media_ads

@MainActor
struct AdDisplayContainerTests {
  @Test func pigeonDefaultConstructor() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = try api.pigeonDelegate.pigeonDefaultConstructor(
        pigeonApi: api, adContainer: UIView(), companionSlots: [],
        adContainerViewController: UIViewController())
  }

  @Test func adContainer() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer(
      adContainer: UIView(), viewController: UIViewController())
    let value = try api.pigeonDelegate.adContainer(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.adContainer)
  }

  @Test func companionSlots() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer(
      adContainer: UIView(),
      viewController: UIViewController(),
      companionSlots: [IMACompanionAdSlot(view: UIView())])
    let value = try api.pigeonDelegate.companionSlots(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.companionSlots)
  }

  @Test func setAdContainerViewController() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer(
      adContainer: UIView(), viewController: UIViewController())
    let controller = UIViewController()
    try api.pigeonDelegate.setAdContainerViewController(
      pigeonApi: api, pigeonInstance: instance, controller: controller)

    #expect(instance.adContainerViewController == controller)
  }

  @Test func getAdContainerViewController() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer(
      adContainer: UIView(), viewController: UIViewController())
    let adContainerViewController = UIViewController()
    instance.adContainerViewController = adContainerViewController
    let value = try api.pigeonDelegate.getAdContainerViewController(
        pigeonApi: api, pigeonInstance: instance)

    #expect(value == adContainerViewController)
  }

  @Test func registerFriendlyObstruction() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer(
      adContainer: UIView(), viewController: UIViewController())
    let friendlyObstruction = IMAFriendlyObstruction(
      view: UIView(), purpose: IMAFriendlyObstructionPurpose.closeAd, detailedReason: "reason")
    try api.pigeonDelegate.registerFriendlyObstruction(
      pigeonApi: api, pigeonInstance: instance, friendlyObstruction: friendlyObstruction)

    #expect(instance.registerFriendlyObstructionArgs as! [AnyHashable] == [friendlyObstruction])
  }

  @Test func unregisterAllFriendlyObstructions() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdDisplayContainer(registrar)

    let instance = TestAdDisplayContainer(
      adContainer: UIView(), viewController: UIViewController())
    try api.pigeonDelegate.unregisterAllFriendlyObstructions(
      pigeonApi: api, pigeonInstance: instance)

    #expect(instance.unregisterAllFriendlyObstructionsCalled)
  }
}

class TestAdDisplayContainer: IMAAdDisplayContainer, @unchecked Sendable {
  var registerFriendlyObstructionArgs: [AnyHashable?]? = nil
  var unregisterAllFriendlyObstructionsCalled = false

  override func register(_ friendlyObstruction: IMAFriendlyObstruction) {
    registerFriendlyObstructionArgs = [friendlyObstruction]
  }

  override func unregisterAllFriendlyObstructions() {
    unregisterAllFriendlyObstructionsCalled = true
  }
}

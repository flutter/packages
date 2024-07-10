// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

final class AdsManagerTests: XCTestCase {
  func testSetDelegate() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    let delegate = AdsManagerDelegateImpl(
      api: registrar.apiDelegate.pigeonApiIMAAdsManagerDelegate(registrar))
    try? api.pigeonDelegate.setDelegate(
      pigeonApi: api, pigeonInstance: instance, delegate: delegate)

    XCTAssertIdentical(instance.delegate, delegate)
  }

  func testInitialize() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    let renderingSettings = IMAAdsRenderingSettings()
    try? api.pigeonDelegate.initialize(
      pigeonApi: api, pigeonInstance: instance, adsRenderingSettings: renderingSettings)

    XCTAssertEqual(instance.renderingSettings, renderingSettings)
  }

  func testStart() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    try? api.pigeonDelegate.start(pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(instance.startCalled)
  }

  func testPause() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    try? api.pigeonDelegate.pause(pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(instance.pauseCalled)
  }

  func testSkip() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    try? api.pigeonDelegate.skip(pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(instance.skipCalled)
  }

  func testDiscardAdBreak() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    try? api.pigeonDelegate.discardAdBreak(pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(instance.discardAdBreakCalled)
  }

  func testResume() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    try? api.pigeonDelegate.resume(pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(instance.resumeCalled)
  }

  func testDestroy() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    try? api.pigeonDelegate.destroy(pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(instance.destroyCalled)
  }
}

class TestAdsManager: IMAAdsManager {
  var renderingSettings: IMAAdsRenderingSettings? = nil
  var startCalled = false
  var pauseCalled = false
  var skipCalled = false
  var discardAdBreakCalled = false
  var resumeCalled = false
  var destroyCalled = false

  // Workaround to subclass an Objective-C class that has an `init` constructor with NS_UNAVAILABLE
  static func customInit() -> TestAdsManager {
    let instance =
      TestAdsManager.perform(NSSelectorFromString("new")).takeRetainedValue() as! TestAdsManager
    return instance
  }

  override func initialize(with adsRenderingSettings: IMAAdsRenderingSettings?) {
    renderingSettings = adsRenderingSettings
  }

  override func start() {
    startCalled = true
  }

  override func pause() {
    pauseCalled = true
  }

  override func skip() {
    skipCalled = true
  }

  override func discardAdBreak() {
    discardAdBreakCalled = true
  }

  override func resume() {
    resumeCalled = true
  }

  override func destroy() {
    destroyCalled = true
  }
}

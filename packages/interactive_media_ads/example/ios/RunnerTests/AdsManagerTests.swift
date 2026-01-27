// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing

@testable import interactive_media_ads

@MainActor
struct AdsManagerTests {
  @Test func setDelegate() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    let delegate = AdsManagerDelegateImpl(
      api: registrar.apiDelegate.pigeonApiIMAAdsManagerDelegate(registrar))
    try api.pigeonDelegate.setDelegate(
      pigeonApi: api, pigeonInstance: instance, delegate: delegate)

    #expect(instance.delegate === delegate)
  }

  @Test func initialize() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    let renderingSettings = IMAAdsRenderingSettings()
    try api.pigeonDelegate.initialize(
      pigeonApi: api, pigeonInstance: instance, adsRenderingSettings: renderingSettings)

    #expect(instance.renderingSettings == renderingSettings)
  }

  @Test func start() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    try api.pigeonDelegate.start(pigeonApi: api, pigeonInstance: instance)

    #expect(instance.startCalled)
  }

  @Test func pause() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    try api.pigeonDelegate.pause(pigeonApi: api, pigeonInstance: instance)

    #expect(instance.pauseCalled)
  }

  @Test func skip() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    try api.pigeonDelegate.skip(pigeonApi: api, pigeonInstance: instance)

    #expect(instance.skipCalled)
  }

  @Test func discardAdBreak() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    try api.pigeonDelegate.discardAdBreak(pigeonApi: api, pigeonInstance: instance)

    #expect(instance.discardAdBreakCalled)
  }

  @Test func resume() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    try api.pigeonDelegate.resume(pigeonApi: api, pigeonInstance: instance)

    #expect(instance.resumeCalled)
  }

  @Test func destroy() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    try api.pigeonDelegate.destroy(pigeonApi: api, pigeonInstance: instance)

    #expect(instance.destroyCalled)
  }

  @Test func adCuePoints() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)

    let instance = TestAdsManager.customInit()

    let value = try api.pigeonDelegate.adCuePoints(pigeonApi: api, pigeonInstance: instance)

    #expect(value == [2.2, 3.3])
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
      try! #require(
        TestAdsManager.perform(NSSelectorFromString("new")).takeRetainedValue() as? TestAdsManager)
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

  override var adCuePoints: [Any] {
    return [2.2, 3.3]
  }
}

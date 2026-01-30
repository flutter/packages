// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing

@testable import interactive_media_ads

struct AdEventTests {
  @Test func type() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdEvent(registrar)

    let instance = TestAdEvent.customInit()

    let value = try api.pigeonDelegate.type(pigeonApi: api, pigeonInstance: instance)

    #expect(value == .adBreakEnded)
  }

  @Test func message() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdEvent(registrar)

    let instance = TestAdEvent.customInit()

    let value = try api.pigeonDelegate.typeString(pigeonApi: api, pigeonInstance: instance)

    #expect(value == "message")
  }

  @Test func adData() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdEvent(registrar)

    let instance = TestAdEvent.customInit()

    let value = try api.pigeonDelegate.adData(pigeonApi: api, pigeonInstance: instance)

    let adData = try #require(value as? [String: String])
    #expect(adData == ["my": "string"])
  }

  @Test func ad() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdEvent(registrar)

    let instance = TestAdEvent.customInit()
    let value = try api.pigeonDelegate.ad(pigeonApi: api, pigeonInstance: instance)

    #expect(value != nil)
    #expect(value == instance.ad)
  }
}

class TestAdEvent: IMAAdEvent {
  // Workaround to subclass an Objective-C class that has an `init` constructor with NS_UNAVAILABLE
  static func customInit() -> TestAdEvent {
    let instance =
      try! #require(
        TestAdEvent.perform(NSSelectorFromString("new")).takeRetainedValue() as? TestAdEvent)
    instance._ad = TestAd.customInit()
    return instance
  }

  var _ad: TestAd?

  override var type: IMAAdEventType {
    return .AD_BREAK_ENDED
  }

  override var typeString: String {
    return "message"
  }

  override var adData: [String: Any]? {
    return ["my": "string"]
  }

  override var ad: IMAAd? {
    return _ad
  }
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing

@testable import interactive_media_ads

struct AdPodInfoProxyAPITests {
  @Test
  func adPosition() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdPodInfo(registrar)

    let instance = TestAdPodInfo.customInit()
    let value = try? api.pigeonDelegate.adPosition(pigeonApi: api, pigeonInstance: instance)

    #expect(value == Int64(instance.adPosition))
  }

  @Test
  func maxDuration() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdPodInfo(registrar)

    let instance = TestAdPodInfo.customInit()
    let value = try? api.pigeonDelegate.maxDuration(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.maxDuration)
  }

  @Test
  func podIndex() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdPodInfo(registrar)

    let instance = TestAdPodInfo.customInit()
    let value = try? api.pigeonDelegate.podIndex(pigeonApi: api, pigeonInstance: instance)

    #expect(value == Int64(instance.podIndex))
  }

  @Test
  func timeOffset() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdPodInfo(registrar)

    let instance = TestAdPodInfo.customInit()
    let value = try? api.pigeonDelegate.timeOffset(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.timeOffset)
  }

  @Test
  func totalAds() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdPodInfo(registrar)

    let instance = TestAdPodInfo.customInit()
    let value = try? api.pigeonDelegate.totalAds(pigeonApi: api, pigeonInstance: instance)

    #expect(value == Int64(instance.totalAds))
  }

  @Test
  func isBumper() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdPodInfo(registrar)

    let instance = TestAdPodInfo.customInit()
    let value = try? api.pigeonDelegate.isBumper(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.isBumper)
  }
}

class TestAdPodInfo: IMAAdPodInfo {
  // Workaround to subclass an Objective-C class that has an `init` constructor with NS_UNAVAILABLE
  static func customInit() -> TestAdPodInfo {
    let instance =
      TestAdPodInfo.perform(NSSelectorFromString("new")).takeRetainedValue() as! TestAdPodInfo
    return instance
  }

  override var adPosition: Int {
    return 5
  }

  override var maxDuration: TimeInterval {
    return 2.0
  }

  override var podIndex: Int {
    return 3
  }

  override var timeOffset: TimeInterval {
    return 6.0
  }

  override var totalAds: Int {
    return 7
  }

  override var isBumper: Bool {
    return false
  }
}

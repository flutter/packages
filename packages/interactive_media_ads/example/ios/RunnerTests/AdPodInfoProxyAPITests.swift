// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

class AdPodInfoProxyAPITests: XCTestCase {
  func testAdPosition() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdPodInfo(registrar)

    let instance = TestAdPodInfo.customInit()
    let value = try? api.pigeonDelegate.adPosition(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, Int64(instance.adPosition))
  }

  func testMaxDuration() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdPodInfo(registrar)

    let instance = TestAdPodInfo.customInit()
    let value = try? api.pigeonDelegate.maxDuration(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.maxDuration)
  }

  func testPodIndex() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdPodInfo(registrar)

    let instance = TestAdPodInfo.customInit()
    let value = try? api.pigeonDelegate.podIndex(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, Int64(instance.podIndex))
  }

  func testTimeOffset() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdPodInfo(registrar)

    let instance = TestAdPodInfo.customInit()
    let value = try? api.pigeonDelegate.timeOffset(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.timeOffset)
  }

  func testTotalAds() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdPodInfo(registrar)

    let instance = TestAdPodInfo.customInit()
    let value = try? api.pigeonDelegate.totalAds(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, Int64(instance.totalAds))
  }

  func testIsBumper() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdPodInfo(registrar)

    let instance = TestAdPodInfo.customInit()
    let value = try? api.pigeonDelegate.isBumper(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.isBumper)
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

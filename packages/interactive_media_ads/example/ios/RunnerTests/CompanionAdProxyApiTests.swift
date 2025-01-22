// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

class CompanionAdProxyApiTests: XCTestCase {
  func testResourceValue() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMACompanionAd(registrar)

    let instance = TestCompanionAd.customInit()
    let value = try? api.pigeonDelegate.resourceValue(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.resourceValue)
  }

  func testApiFramework() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMACompanionAd(registrar)

    let instance = TestCompanionAd.customInit()
    let value = try? api.pigeonDelegate.apiFramework(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.apiFramework)
  }

  func testWidth() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMACompanionAd(registrar)

    let instance = TestCompanionAd.customInit()
    let value = try? api.pigeonDelegate.width(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, Int64(instance.width))
  }

  func testHeight() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMACompanionAd(registrar)

    let instance = TestCompanionAd.customInit()
    let value = try? api.pigeonDelegate.height(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, Int64(instance.height))
  }

}

class TestCompanionAd: IMACompanionAd {
  // Workaround to subclass an Objective-C class that has an `init` constructor with NS_UNAVAILABLE
  static func customInit() -> TestCompanionAd {
    let instance =
      TestCompanionAd.perform(NSSelectorFromString("new")).takeRetainedValue() as! TestCompanionAd
    return instance
  }

  override var resourceValue: String? {
    return "resourceValue"
  }

  override var apiFramework: String? {
    return "apiFramework"
  }

  override var width: Int {
    return 0
  }

  override var height: Int {
    return 1
  }
}

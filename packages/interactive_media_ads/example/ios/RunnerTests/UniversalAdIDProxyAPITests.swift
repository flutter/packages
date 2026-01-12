// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

class UniversalAdIDProxyAPITests: XCTestCase {
  func testAdIDValue() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAUniversalAdID(registrar)

    let instance = TestUniversalAdID.customInit()
    let value = try? api.pigeonDelegate.adIDValue(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.adIDValue)
  }

  func testAdIDRegistry() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAUniversalAdID(registrar)

    let instance = TestUniversalAdID.customInit()
    let value = try? api.pigeonDelegate.adIDRegistry(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.adIDRegistry)
  }
}

class TestUniversalAdID: IMAUniversalAdID {
  // Workaround to subclass an Objective-C class that has an `init` constructor with NS_UNAVAILABLE
  static func customInit() -> TestUniversalAdID {
    let instance =
      TestUniversalAdID.perform(NSSelectorFromString("new")).takeRetainedValue()
      as! TestUniversalAdID
    return instance
  }

  override var adIDValue: String {
    return "string1"
  }

  override var adIDRegistry: String {
    return "string2"
  }
}

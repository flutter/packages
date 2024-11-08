// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

final class AdEventTests: XCTestCase {
  func testType() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdEvent(registrar)

    let instance = TestAdEvent.customInit()

    let value = try? api.pigeonDelegate.type(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, .adBreakEnded)
  }

  func testMessage() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdEvent(registrar)

    let instance = TestAdEvent.customInit()

    let value = try? api.pigeonDelegate.typeString(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, "message")
  }

  func testAdData() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdEvent(registrar)

    let instance = TestAdEvent.customInit()

    let value = try? api.pigeonDelegate.adData(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value as! [String: String], ["my": "string"])
  }
}

class TestAdEvent: IMAAdEvent {
  // Workaround to subclass an Objective-C class that has an `init` constructor with NS_UNAVAILABLE
  static func customInit() -> TestAdEvent {
    let instance =
      TestAdEvent.perform(NSSelectorFromString("new")).takeRetainedValue() as! TestAdEvent
    return instance
  }

  override var type: IMAAdEventType {
    return .AD_BREAK_ENDED
  }

  override var typeString: String {
    return "message"
  }

  override var adData: [String: Any]? {
    return ["my": "string"]
  }
}

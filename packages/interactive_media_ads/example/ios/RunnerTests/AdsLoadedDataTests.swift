// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

final class AdsLoadedDataTests: XCTestCase {
  func testAdsManager() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsLoadedData(registrar)

    let instance = TestAdsLoadedData.customInit()

    let value = try? api.pigeonDelegate.adsManager(pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(value is TestAdsManager)
  }
}

class TestAdsLoadedData: IMAAdsLoadedData {
  // Workaround to subclass an Objective-C class that has an `init` constructor with NS_UNAVAILABLE
  static func customInit() -> TestAdsLoadedData {
    let instance =
      TestAdsLoadedData.perform(NSSelectorFromString("new")).takeRetainedValue()
      as! TestAdsLoadedData
    return instance
  }

  override var adsManager: IMAAdsManager? {
    return TestAdsManager.customInit()
  }
}

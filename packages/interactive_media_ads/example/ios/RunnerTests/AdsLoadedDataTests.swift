// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import interactive_media_ads
import GoogleInteractiveMediaAds

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
  static func customInit() -> TestAdsLoadedData {
      let instance = TestAdsLoadedData.perform(NSSelectorFromString("new")).takeRetainedValue() as! TestAdsLoadedData
      return instance
  }
  
  override var adsManager: IMAAdsManager? {
    return TestAdsManager.customInit()
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import interactive_media_ads
import GoogleInteractiveMediaAds

final class AdsLoadedDataTests: XCTestCase {
  func testAdError() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdLoadingErrorData(registrar)
    
    let instance = TestAdLoadingErrorData.customInit()
    
    let value = try? api.pigeonDelegate.adError(pigeonApi: api, pigeonInstance: instance)
    
    XCTAssertTrue(value is TestAdError)
  }
}

class TestAdsLoadedData: IMAAdsLoadedData {
  static func customInit() -> TestAdsLoadedData {
      let instance = TestAdsLoadedData.perform(NSSelectorFromString("new")).takeRetainedValue() as! TestAdsLoadedData
      return instance
  }
  
  override var adsManager: IMAAdsManager? {
    // return
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import interactive_media_ads
import GoogleInteractiveMediaAds

final class AdLoadingErrorTests: XCTestCase {
  func testAdError() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdLoadingErrorData(registrar)
    
    let instance = TestAdLoadingErrorData.customInit()
    
    let value = try? api.pigeonDelegate.adError(pigeonApi: api, pigeonInstance: instance)
    
    XCTAssertTrue(value is TestAdError)
  }
}

class TestAdLoadingErrorData: IMAAdLoadingErrorData {
  static func customInit() -> TestAdLoadingErrorData {
      let instance = TestAdLoadingErrorData.perform(NSSelectorFromString("new")).takeRetainedValue() as! TestAdLoadingErrorData
      return instance
  }
  
  override var adError: IMAAdError {
    return TestAdError.customInit()
  }
}

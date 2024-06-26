// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import interactive_media_ads
import GoogleInteractiveMediaAds

final class AdErrorTests: XCTestCase {
  func testType() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdError(registrar)
    
    let instance = TestAdError.customInit()
    
    let value = try? api.pigeonDelegate.type(pigeonApi: api, pigeonInstance: instance)
    
    XCTAssertEqual(value, .loadingFailed)
  }
  
  func testCode() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdError(registrar)
    
    let instance = TestAdError.customInit()
    
    let value = try? api.pigeonDelegate.code(pigeonApi: api, pigeonInstance: instance)
    
    XCTAssertEqual(value, .apiError)
  }
  
  func testMessage() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdError(registrar)
    
    let instance = TestAdError.customInit()
    
    let value = try? api.pigeonDelegate.message(pigeonApi: api, pigeonInstance: instance)
    
    XCTAssertEqual(value, "message")
  }
}

class TestAdError: IMAAdError {
  static func customInit() -> IMAAdError {
      let instance = TestAdError.perform(NSSelectorFromString("new")).takeRetainedValue() as! TestAdError
      return instance
  }
  
  override var type: IMAErrorType {
    return .adLoadingFailed
  }
  
  override var code: IMAErrorCode {
    return .API_ERROR
  }
  
  override var message: String? {
    return "message"
  }
}

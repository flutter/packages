// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

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
  // Workaround to subclass an Objective-C class that has an `init` constructor with NS_UNAVAILABLE
  static func customInit() -> TestAdLoadingErrorData {
    let instance =
      TestAdLoadingErrorData.perform(NSSelectorFromString("new")).takeRetainedValue()
      as! TestAdLoadingErrorData
    return instance
  }

  override var adError: IMAAdError {
    return TestAdError.customInit()
  }
}

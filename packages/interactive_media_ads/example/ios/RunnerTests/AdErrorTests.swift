// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing

@testable import interactive_media_ads

struct AdErrorTests {
  @Test func type() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdError(registrar)

    let instance = TestAdError.customInit()

    let value = try api.pigeonDelegate.type(pigeonApi: api, pigeonInstance: instance)

    #expect(value == .loadingFailed)
  }

  @Test func code() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdError(registrar)

    let instance = TestAdError.customInit()

    let value = try api.pigeonDelegate.code(pigeonApi: api, pigeonInstance: instance)

    #expect(value == .apiError)
  }

  @Test func message() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdError(registrar)

    let instance = TestAdError.customInit()

    let value = try api.pigeonDelegate.message(pigeonApi: api, pigeonInstance: instance)

    #expect(value == "message")
  }
}

class TestAdError: IMAAdError {
  // Workaround to subclass an Objective-C class that has an `init` constructor with NS_UNAVAILABLE
  static func customInit() -> IMAAdError {
    let instance =
      try! #require(
        TestAdError.perform(NSSelectorFromString("new")).takeRetainedValue() as? TestAdError)
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

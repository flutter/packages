// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

final class ContentPlayheadTests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAContentPlayhead(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api)

    XCTAssertNotNil(instance)
  }

  func testSetCurrentTime() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAContentPlayhead(registrar)

    let instance = ContentPlayheadImpl()
    try? api.pigeonDelegate.setCurrentTime(
      pigeonApi: api, pigeonInstance: instance, timeInterval: 12)

    XCTAssertEqual(instance.currentTime, 12)
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

final class AdsRequestTests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, adTagUrl: "adTag?", adDisplayContainer: container,
      contentPlayhead: contentPlayhead)

    XCTAssertNotNil(instance)
    XCTAssertEqual(
      instance?.adTagUrl,
      "adTag?&request_agent=Flutter-IMA-\(AdsRequestProxyAPIDelegate.pluginVersion)")
    XCTAssertIdentical(instance?.adDisplayContainer, container)
  }
}

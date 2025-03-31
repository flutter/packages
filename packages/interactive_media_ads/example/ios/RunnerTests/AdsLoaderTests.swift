// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

final class AdsLoaderTests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsLoader(registrar)

    let settings = IMASettings()
    settings.ppid = "ppid"
    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, settings: settings)

    XCTAssertNotNil(instance)
    XCTAssertEqual(instance?.settings.ppid, settings.ppid)
  }

  func testContentComplete() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsLoader(registrar)

    let instance = TestAdsLoader(settings: nil)

    try? api.pigeonDelegate.contentComplete(pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(instance.contentCompleteCalled)
  }

  func testRequestAds() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsLoader(registrar)

    let instance = TestAdsLoader(settings: nil)

    let request = IMAAdsRequest(
      adTagUrl: "",
      adDisplayContainer: IMAAdDisplayContainer(adContainer: UIView(), viewController: nil),
      contentPlayhead: ContentPlayheadImpl(), userContext: nil)
    try? api.pigeonDelegate.requestAds(
      pigeonApi: api, pigeonInstance: instance, request: request)

    XCTAssertIdentical(instance.adsRequested, request)
  }

  func testSetDelegate() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsLoader(registrar)

    let instance = TestAdsLoader(settings: nil)

    let delegate = AdsLoaderDelegateImpl(
      api: registrar.apiDelegate.pigeonApiIMAAdsLoaderDelegate(registrar))
    try? api.pigeonDelegate.setDelegate(
      pigeonApi: api, pigeonInstance: instance, delegate: delegate)

    XCTAssertIdentical(instance.delegate, delegate)
  }
}

class TestAdsLoader: IMAAdsLoader {
  var contentCompleteCalled = false
  var adsRequested: IMAAdsRequest? = nil

  override init(settings: IMASettings?) {
    super.init(settings: settings)
  }

  override func contentComplete() {
    contentCompleteCalled = true
  }

  override func requestAds(with request: IMAAdsRequest) {
    adsRequested = request
  }
}

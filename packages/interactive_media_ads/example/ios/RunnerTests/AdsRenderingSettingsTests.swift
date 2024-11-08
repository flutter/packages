// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

final class AdsRenderingSettingsTests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api)

    XCTAssertTrue(instance != nil)
  }

  func testSetMimeTypes() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = IMAAdsRenderingSettings()
    let types = ["myString"]
    try? api.pigeonDelegate.setMimeTypes(pigeonApi: api, pigeonInstance: instance, types: types)

    XCTAssertEqual(instance.mimeTypes, types)
  }

  func testSetBitrate() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = IMAAdsRenderingSettings()
    let bitrate = 0
    try? api.pigeonDelegate.setBitrate(
      pigeonApi: api, pigeonInstance: instance, bitrate: Int64(bitrate))

    XCTAssertEqual(instance.bitrate, bitrate)
  }

  func testSetLoadVideoTimeout() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = IMAAdsRenderingSettings()
    let seconds = 1.0
    try? api.pigeonDelegate.setLoadVideoTimeout(
      pigeonApi: api, pigeonInstance: instance, seconds: seconds)

    XCTAssertEqual(instance.loadVideoTimeout, seconds)
  }

  func testSetPlayAdsAfterTime() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = IMAAdsRenderingSettings()
    let seconds = 1.0
    try? api.pigeonDelegate.setPlayAdsAfterTime(
      pigeonApi: api, pigeonInstance: instance, seconds: seconds)

    XCTAssertEqual(instance.playAdsAfterTime, seconds)
  }

  func testSetUIElements() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = IMAAdsRenderingSettings()
    let types = [UIElementType.adAttribution]
    try? api.pigeonDelegate.setUIElements(pigeonApi: api, pigeonInstance: instance, types: types)

    XCTAssertEqual(
      instance.uiElements, [IMAUiElementType.elements_AD_ATTRIBUTION.rawValue as NSNumber])
  }

  func testSetEnablePreloading() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = IMAAdsRenderingSettings()
    let enable = true
    try? api.pigeonDelegate.setEnablePreloading(
      pigeonApi: api, pigeonInstance: instance, enable: enable)

    XCTAssertTrue(instance.enablePreloading)
  }

  func testSetLinkOpenerPresentingController() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = IMAAdsRenderingSettings()
    let controller = UIViewController()
    try? api.pigeonDelegate.setLinkOpenerPresentingController(
      pigeonApi: api, pigeonInstance: instance, controller: controller)

    XCTAssertEqual(instance.linkOpenerPresentingController, controller)
  }
}

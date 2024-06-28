// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

final class AdsLoaderTests: XCTestCase {
//  func testSetDelegate() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)
//
//    let instance = TestAdsManager.customInit()
//
//    let delegate = AdsManagerDelegateImpl(
//      api: registrar.apiDelegate.pigeonApiIMAAdsManagerDelegate(registrar))
//    try? api.pigeonDelegate.setDelegate(
//      pigeonApi: api, pigeonInstance: instance, delegate: delegate)
//
//    XCTAssertIdentical(instance.delegate, delegate)
//  }
//
//  func testInitialize() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)
//
//    let instance = TestAdsManager.customInit()
//
//    let renderingSettings = IMAAdsRenderingSettings()
//    try? api.pigeonDelegate.initialize(
//      pigeonApi: api, pigeonInstance: instance, adsRenderingSettings: renderingSettings)
//
//    XCTAssertEqual(instance.renderingSettings, renderingSettings)
//  }
//
//  func testStart() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)
//
//    let instance = TestAdsManager.customInit()
//
//    try? api.pigeonDelegate.start(pigeonApi: api, pigeonInstance: instance)
//
//    XCTAssertTrue(instance.startCalled)
//  }
//
//  func testDestroy() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiIMAAdsManager(registrar)
//
//    let instance = TestAdsManager.customInit()
//
//    try? api.pigeonDelegate.destroy(pigeonApi: api, pigeonInstance: instance)
//
//    XCTAssertTrue(instance.destroyCalled)
//  }
}

//class TestAdsLoader: IMAAdsLoader {
//  var renderingSettings: IMAAdsRenderingSettings? = nil
//  var startCalled = false
//  var destroyCalled = false
//
//  static func customInit() -> TestAdsManager {
//    let instance =
//      TestAdsManager.perform(NSSelectorFromString("new")).takeRetainedValue() as! TestAdsManager
//    return instance
//  }
//
//  override func initialize(with adsRenderingSettings: IMAAdsRenderingSettings?) {
//    renderingSettings = adsRenderingSettings
//  }
//
//  override func start() {
//    startCalled = true
//  }
//
//  override func destroy() {
//    destroyCalled = true
//  }
//}

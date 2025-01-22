// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

final class AdsManagerDelegateTests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManagerDelegate(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)

    XCTAssertTrue(instance is AdsManagerDelegateImpl)
  }

  func testDidReceiveAdEvent() {
    let api = TestAdsManagerDelegateApi()
    let instance = AdsManagerDelegateImpl(api: api)

    let manager = TestAdsManager.customInit()
    let event = TestAdEvent.customInit()
    instance.adsManager(manager, didReceive: event)

    XCTAssertEqual(api.didReceiveAdEventArgs, [manager, event])
  }

  func testDidReceiveAdError() {
    let api = TestAdsManagerDelegateApi()
    let instance = AdsManagerDelegateImpl(api: api)

    let manager = TestAdsManager.customInit()
    let error = TestAdError.customInit()
    instance.adsManager(manager, didReceive: error)

    XCTAssertEqual(api.didReceiveAdErrorArgs, [manager, error])
  }

  func testDidRequestContentPause() {
    let api = TestAdsManagerDelegateApi()
    let instance = AdsManagerDelegateImpl(api: api)

    let manager = TestAdsManager.customInit()
    instance.adsManagerDidRequestContentPause(manager)

    XCTAssertEqual(api.didRequestContentPauseArgs, [manager])
  }

  func testDidRequestContentResume() {
    let api = TestAdsManagerDelegateApi()
    let instance = AdsManagerDelegateImpl(api: api)

    let manager = TestAdsManager.customInit()
    instance.adsManagerDidRequestContentResume(manager)

    XCTAssertEqual(api.didRequestContentResumeArgs, [manager])
  }
}

class TestAdsManagerDelegateApi: PigeonApiProtocolIMAAdsManagerDelegate {
  var didReceiveAdEventArgs: [AnyHashable?]? = nil
  var didReceiveAdErrorArgs: [AnyHashable?]? = nil
  var didRequestContentPauseArgs: [AnyHashable?]? = nil
  var didRequestContentResumeArgs: [AnyHashable?]? = nil

  func didReceiveAdEvent(
    pigeonInstance pigeonInstanceArg: IMAAdsManagerDelegate,
    adsManager adsManagerArg: IMAAdsManager, event eventArg: IMAAdEvent,
    completion: @escaping (Result<Void, interactive_media_ads.PigeonError>) -> Void
  ) {
    didReceiveAdEventArgs = [adsManagerArg, eventArg]
  }

  func didReceiveAdError(
    pigeonInstance pigeonInstanceArg: IMAAdsManagerDelegate,
    adsManager adsManagerArg: IMAAdsManager, error errorArg: IMAAdError,
    completion: @escaping (Result<Void, interactive_media_ads.PigeonError>) -> Void
  ) {
    didReceiveAdErrorArgs = [adsManagerArg, errorArg]
  }

  func didRequestContentPause(
    pigeonInstance pigeonInstanceArg: IMAAdsManagerDelegate,
    adsManager adsManagerArg: IMAAdsManager,
    completion: @escaping (Result<Void, interactive_media_ads.PigeonError>) -> Void
  ) {
    didRequestContentPauseArgs = [adsManagerArg]
  }

  func didRequestContentResume(
    pigeonInstance pigeonInstanceArg: IMAAdsManagerDelegate,
    adsManager adsManagerArg: IMAAdsManager,
    completion: @escaping (Result<Void, interactive_media_ads.PigeonError>) -> Void
  ) {
    didRequestContentResumeArgs = [adsManagerArg]
  }
}

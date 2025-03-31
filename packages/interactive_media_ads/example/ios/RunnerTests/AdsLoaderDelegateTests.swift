// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

final class AdsLoaderDelegateTests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsLoaderDelegate(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)

    XCTAssertTrue(instance is AdsLoaderDelegateImpl)
  }

  func testAdLoaderLoadedWith() {
    let api = TestAdsLoaderDelegateApi()
    let instance = AdsLoaderDelegateImpl(api: api)

    let adsLoader = IMAAdsLoader(settings: nil)
    let data = TestAdsLoadedData()
    instance.adsLoader(adsLoader, adsLoadedWith: data)

    XCTAssertEqual(api.adLoaderLoadedWithArgs, [adsLoader, data])
  }

  func testAdsLoaderFailedWithErrorData() {
    let api = TestAdsLoaderDelegateApi()
    let instance = AdsLoaderDelegateImpl(api: api)

    let adsLoader = IMAAdsLoader(settings: nil)
    let error = TestAdLoadingErrorData.customInit()
    instance.adsLoader(adsLoader, failedWith: error)

    XCTAssertEqual(api.adsLoaderFailedWithErrorDataArgs, [adsLoader, error])
  }
}

class TestAdsLoaderDelegateApi: PigeonApiProtocolIMAAdsLoaderDelegate {
  var adLoaderLoadedWithArgs: [AnyHashable?]? = nil
  var adsLoaderFailedWithErrorDataArgs: [AnyHashable?]? = nil

  func adLoaderLoadedWith(
    pigeonInstance pigeonInstanceArg: IMAAdsLoaderDelegate, loader loaderArg: IMAAdsLoader,
    adsLoadedData adsLoadedDataArg: IMAAdsLoadedData,
    completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {
    adLoaderLoadedWithArgs = [loaderArg, adsLoadedDataArg]
  }

  func adsLoaderFailedWithErrorData(
    pigeonInstance pigeonInstanceArg: IMAAdsLoaderDelegate, loader loaderArg: IMAAdsLoader,
    adErrorData adErrorDataArg: IMAAdLoadingErrorData,
    completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {
    adsLoaderFailedWithErrorDataArgs = [loaderArg, adErrorDataArg]
  }
}

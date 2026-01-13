// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing

@testable import interactive_media_ads

@MainActor
struct AdsLoaderDelegateTests {
  @Test func pigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsLoaderDelegate(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)

    #expect(instance is AdsLoaderDelegateImpl)
  }

  @Test func adLoaderLoadedWith() {
    let api = TestAdsLoaderDelegateApi()
    let instance = AdsLoaderDelegateImpl(api: api)

    let adsLoader = IMAAdsLoader(settings: nil)
    let data = TestAdsLoadedData()
    instance.adsLoader(adsLoader, adsLoadedWith: data)

    #expect(api.adLoaderLoadedWithArgs as! [AnyHashable] == [adsLoader, data])
  }

  @Test func adsLoaderFailedWithErrorData() {
    let api = TestAdsLoaderDelegateApi()
    let instance = AdsLoaderDelegateImpl(api: api)

    let adsLoader = IMAAdsLoader(settings: nil)
    let error = TestAdLoadingErrorData.customInit()
    instance.adsLoader(adsLoader, failedWith: error)

    #expect(api.adsLoaderFailedWithErrorDataArgs as! [AnyHashable] == [adsLoader, error])
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

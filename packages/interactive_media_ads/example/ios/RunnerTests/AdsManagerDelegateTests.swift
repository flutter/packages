// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing

@testable import interactive_media_ads

@MainActor
struct AdsManagerDelegateTests {
  @Test func pigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsManagerDelegate(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)

    #expect(instance is AdsManagerDelegateImpl)
  }

  @Test func didReceiveAdEvent() {
    let api = TestAdsManagerDelegateApi()
    let instance = AdsManagerDelegateImpl(api: api)

    let manager = TestAdsManager.customInit()
    let event = TestAdEvent.customInit()
    instance.adsManager(manager, didReceive: event)

    #expect(api.didReceiveAdEventArgs == [manager, event])
  }

  @Test func didReceiveAdError() {
    let api = TestAdsManagerDelegateApi()
    let instance = AdsManagerDelegateImpl(api: api)

    let manager = TestAdsManager.customInit()
    let error = TestAdError.customInit()
    instance.adsManager(manager, didReceive: error)

    #expect(api.didReceiveAdErrorArgs == [manager, error])
  }

  @Test func didRequestContentPause() {
    let api = TestAdsManagerDelegateApi()
    let instance = AdsManagerDelegateImpl(api: api)

    let manager = TestAdsManager.customInit()
    instance.adsManagerDidRequestContentPause(manager)

    #expect(api.didRequestContentPauseArgs == [manager])
  }

  @Test func didRequestContentResume() {
    let api = TestAdsManagerDelegateApi()
    let instance = AdsManagerDelegateImpl(api: api)

    let manager = TestAdsManager.customInit()
    instance.adsManagerDidRequestContentResume(manager)

    #expect(api.didRequestContentResumeArgs == [manager])
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

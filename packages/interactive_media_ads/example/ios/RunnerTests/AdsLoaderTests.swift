// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing

@testable import interactive_media_ads

@MainActor
struct AdsLoaderTests {
  @Test func pigeonDefaultConstructor() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsLoader(registrar)

    let settings = IMASettings()
    settings.ppid = "ppid"
    let instance = try api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, settings: settings)

    #expect(instance.settings.ppid == settings.ppid)
  }

  @Test func contentComplete() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsLoader(registrar)

    let instance = TestAdsLoader(settings: nil)

    try api.pigeonDelegate.contentComplete(pigeonApi: api, pigeonInstance: instance)

    #expect(instance.contentCompleteCalled)
  }

  @Test func requestAds() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsLoader(registrar)

    let instance = TestAdsLoader(settings: nil)

    let request = IMAAdsRequest(
      adTagUrl: "",
      adDisplayContainer: IMAAdDisplayContainer(adContainer: UIView(), viewController: nil),
      contentPlayhead: ContentPlayheadImpl(), userContext: nil)
    try api.pigeonDelegate.requestAds(
      pigeonApi: api, pigeonInstance: instance, request: request)

    #expect(instance.adsRequested === request)
  }

  @Test func setDelegate() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsLoader(registrar)

    let instance = TestAdsLoader(settings: nil)

    let delegate = AdsLoaderDelegateImpl(
      api: registrar.apiDelegate.pigeonApiIMAAdsLoaderDelegate(registrar))
    try api.pigeonDelegate.setDelegate(
      pigeonApi: api, pigeonInstance: instance, delegate: delegate)

    #expect(instance.delegate === delegate)
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

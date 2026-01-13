// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing

@testable import interactive_media_ads

@MainActor
struct AdsRequestTests {
  @Test func pigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, adTagUrl: "adTag?", adDisplayContainer: container,
      contentPlayhead: contentPlayhead)

    #expect(instance != nil)
    #expect(
      instance?.adTagUrl
        == "adTag?&request_agent=Flutter-IMA-\(AdsRequestProxyAPIDelegate.pluginVersion)")
    #expect(instance?.adDisplayContainer === container)
  }

  @Test func pigeonDefaultConstructorDoesNotAddRequestAgentToIncompatibleURLs() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()

    var instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, adTagUrl: "adTag#", adDisplayContainer: container,
      contentPlayhead: contentPlayhead)
    #expect(instance != nil)
    #expect(instance?.adTagUrl == "adTag#")

    instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, adTagUrl: "adTag#?", adDisplayContainer: container,
      contentPlayhead: contentPlayhead)
    #expect(instance != nil)
    #expect(instance?.adTagUrl == "adTag#?")
  }

  @Test func withAdsResponse() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = try? api.pigeonDelegate.withAdsResponse(
      pigeonApi: api, adsResponse: "response", adDisplayContainer: container,
      contentPlayhead: contentPlayhead)

    #expect(instance != nil)
    #expect(instance?.adsResponse == "response")
    #expect(instance?.adDisplayContainer === container)
  }

  @Test func getAdTagUrl() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let adTagUrl = "url"
    let instance = IMAAdsRequest(
      adTagUrl: adTagUrl, adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let value = try? api.pigeonDelegate.getAdTagUrl(pigeonApi: api, pigeonInstance: instance)

    #expect(value == adTagUrl)
  }

  @Test func getAdsResponse() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let adsResponse = "url"
    let instance = IMAAdsRequest(
      adsResponse: adsResponse, adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let value = try? api.pigeonDelegate.getAdsResponse(pigeonApi: api, pigeonInstance: instance)

    #expect(value == adsResponse)
  }

  @Test func getAdDisplayContainer() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = IMAAdsRequest(
      adTagUrl: "url", adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let value = try? api.pigeonDelegate.getAdDisplayContainer(
      pigeonApi: api, pigeonInstance: instance)

    #expect(value == container)
  }

  @Test func setAdWillAutoPlay() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = IMAAdsRequest(
      adTagUrl: "url", adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let adWillAutoPlay = true
    try? api.pigeonDelegate.setAdWillAutoPlay(
      pigeonApi: api, pigeonInstance: instance, adWillAutoPlay: adWillAutoPlay)

    #expect(instance.adWillAutoPlay == adWillAutoPlay)
  }

  @Test func setAdWillPlayMuted() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = IMAAdsRequest(
      adTagUrl: "url", adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let adWillPlayMuted = false
    try? api.pigeonDelegate.setAdWillPlayMuted(
      pigeonApi: api, pigeonInstance: instance, adWillPlayMuted: adWillPlayMuted)

    #expect(instance.adWillPlayMuted == adWillPlayMuted)
  }

  @Test func setContinuousPlayback() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = IMAAdsRequest(
      adTagUrl: "url", adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let continuousPlayback = true
    try? api.pigeonDelegate.setContinuousPlayback(
      pigeonApi: api, pigeonInstance: instance, continuousPlayback: continuousPlayback)

    #expect(instance.continuousPlayback == continuousPlayback)
  }

  @Test func setContentDuration() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = IMAAdsRequest(
      adTagUrl: "url", adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let duration = 3.0
    try? api.pigeonDelegate.setContentDuration(
      pigeonApi: api, pigeonInstance: instance, duration: duration)

    #expect(instance.contentDuration == Float(duration))
  }

  @Test func setContentKeywords() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = IMAAdsRequest(
      adTagUrl: "url", adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let keywords = ["hello"]
    try? api.pigeonDelegate.setContentKeywords(
      pigeonApi: api, pigeonInstance: instance, keywords: keywords)

    #expect(instance.contentKeywords == keywords)
  }

  @Test func setContentTitle() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = IMAAdsRequest(
      adTagUrl: "url", adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let title = "hello"
    try? api.pigeonDelegate.setContentTitle(pigeonApi: api, pigeonInstance: instance, title: title)

    #expect(instance.contentTitle == title)
  }

  @Test func setContentURL() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = IMAAdsRequest(
      adTagUrl: "url", adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let contentURL = "https://www.google.com"
    try? api.pigeonDelegate.setContentURL(
      pigeonApi: api, pigeonInstance: instance, contentURL: contentURL)

    #expect(instance.contentURL == URL(string: contentURL))
  }

  @Test func setVastLoadTimeout() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = IMAAdsRequest(
      adTagUrl: "url", adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let timeout = 3.0
    try? api.pigeonDelegate.setVastLoadTimeout(
      pigeonApi: api, pigeonInstance: instance, timeout: timeout)

    #expect(instance.vastLoadTimeout == Float(timeout))
  }

  @Test func setLiveStreamPrefetchSeconds() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = IMAAdsRequest(
      adTagUrl: "url", adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let seconds = 3.0
    try? api.pigeonDelegate.setLiveStreamPrefetchSeconds(
      pigeonApi: api, pigeonInstance: instance, seconds: seconds)

    #expect(instance.liveStreamPrefetchSeconds == Float(seconds))
  }
}

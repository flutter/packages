// Copyright 2013 The Flutter Authors
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

  func testPigeonDefaultConstructorDoesNotAddRequestAgentToIncompatibleURLs() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()

    var instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, adTagUrl: "adTag#", adDisplayContainer: container,
      contentPlayhead: contentPlayhead)
    XCTAssertNotNil(instance)
    XCTAssertEqual(
      instance?.adTagUrl,
      "adTag#")

    instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, adTagUrl: "adTag#?", adDisplayContainer: container,
      contentPlayhead: contentPlayhead)
    XCTAssertNotNil(instance)
    XCTAssertEqual(
      instance?.adTagUrl,
      "adTag#?")
  }

  func testWithAdsResponse() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = try? api.pigeonDelegate.withAdsResponse(
      pigeonApi: api, adsResponse: "response", adDisplayContainer: container,
      contentPlayhead: contentPlayhead)

    XCTAssertNotNil(instance)
    XCTAssertEqual(
      instance?.adsResponse,
      "response")
    XCTAssertIdentical(instance?.adDisplayContainer, container)
  }

  func testGetAdTagUrl() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let adTagUrl = "url"
    let instance = IMAAdsRequest(
      adTagUrl: adTagUrl, adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let value = try? api.pigeonDelegate.getAdTagUrl(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, adTagUrl)
  }

  func testGetAdsResponse() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let adsResponse = "url"
    let instance = IMAAdsRequest(
      adsResponse: adsResponse, adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let value = try? api.pigeonDelegate.getAdsResponse(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, adsResponse)
  }

  func testGetAdDisplayContainer() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = IMAAdsRequest(
      adTagUrl: "url", adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let value = try? api.pigeonDelegate.getAdDisplayContainer(
      pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, container)
  }

  func testSetAdWillAutoPlay() {
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

    XCTAssertEqual(instance.adWillAutoPlay, adWillAutoPlay)
  }

  func testSetAdWillPlayMuted() {
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

    XCTAssertEqual(instance.adWillPlayMuted, adWillPlayMuted)
  }

  func testSetContinuousPlayback() {
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

    XCTAssertEqual(instance.continuousPlayback, continuousPlayback)
  }

  func testSetContentDuration() {
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

    XCTAssertEqual(instance.contentDuration, Float(duration))
  }

  func testSetContentKeywords() {
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

    XCTAssertEqual(instance.contentKeywords, keywords)
  }

  func testSetContentTitle() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRequest(registrar)

    let container = IMAAdDisplayContainer(adContainer: UIView(), viewController: nil)
    let contentPlayhead = ContentPlayheadImpl()
    let instance = IMAAdsRequest(
      adTagUrl: "url", adDisplayContainer: container, contentPlayhead: contentPlayhead,
      userContext: nil)

    let title = "hello"
    try? api.pigeonDelegate.setContentTitle(pigeonApi: api, pigeonInstance: instance, title: title)

    XCTAssertEqual(instance.contentTitle, title)
  }

  func testSetContentURL() {
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

    XCTAssertEqual(instance.contentURL, URL(string: contentURL))
  }

  func testSetVastLoadTimeout() {
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

    XCTAssertEqual(instance.vastLoadTimeout, Float(timeout))
  }

  func testSetLiveStreamPrefetchSeconds() {
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

    XCTAssertEqual(instance.liveStreamPrefetchSeconds, Float(seconds))
  }
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing

@testable import interactive_media_ads

@MainActor
struct AdsRenderingSettingsTests {
  @Test func pigeonDefaultConstructor() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = try api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api)

    #expect(instance != nil)
  }

  @Test func setMimeTypes() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = IMAAdsRenderingSettings()
    let types = ["myString"]
    try api.pigeonDelegate.setMimeTypes(pigeonApi: api, pigeonInstance: instance, types: types)

    #expect(instance.mimeTypes == types)
  }

  @Test func setBitrate() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = IMAAdsRenderingSettings()
    let bitrate = 0
    try api.pigeonDelegate.setBitrate(
      pigeonApi: api, pigeonInstance: instance, bitrate: Int64(bitrate))

    #expect(instance.bitrate == bitrate)
  }

  @Test func setLoadVideoTimeout() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = IMAAdsRenderingSettings()
    let seconds = 1.0
    try api.pigeonDelegate.setLoadVideoTimeout(
      pigeonApi: api, pigeonInstance: instance, seconds: seconds)

    #expect(instance.loadVideoTimeout == seconds)
  }

  @Test func setPlayAdsAfterTime() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = IMAAdsRenderingSettings()
    let seconds = 1.0
    try api.pigeonDelegate.setPlayAdsAfterTime(
      pigeonApi: api, pigeonInstance: instance, seconds: seconds)

    #expect(instance.playAdsAfterTime == seconds)
  }

  @Test func setUIElements() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = IMAAdsRenderingSettings()
    let types = [UIElementType.adAttribution]
    try api.pigeonDelegate.setUIElements(pigeonApi: api, pigeonInstance: instance, types: types)

    #expect(
      instance.uiElements == [IMAUiElementType.elements_AD_ATTRIBUTION.rawValue as NSNumber])
  }

  @Test func setEnablePreloading() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = IMAAdsRenderingSettings()
    let enable = true
    try api.pigeonDelegate.setEnablePreloading(
      pigeonApi: api, pigeonInstance: instance, enable: enable)

    #expect(instance.enablePreloading)
  }

  @Test func setLinkOpenerPresentingController() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAdsRenderingSettings(registrar)

    let instance = IMAAdsRenderingSettings()
    let controller = UIViewController()
    try api.pigeonDelegate.setLinkOpenerPresentingController(
      pigeonApi: api, pigeonInstance: instance, controller: controller)

    #expect(instance.linkOpenerPresentingController == controller)
  }
}

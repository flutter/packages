// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing

@testable import interactive_media_ads

struct SettingsTests {
  @Test func pigeonDefaultConstructor() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = try api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
  }

  @Test func setPPID() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let ppid = "myString"
    try api.pigeonDelegate.setPPID(pigeonApi: api, pigeonInstance: instance, ppid: ppid)

    #expect(instance.ppid == ppid)
  }

  @Test func setLanguage() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let language = "en"
    try api.pigeonDelegate.setLanguage(
      pigeonApi: api, pigeonInstance: instance, language: language)

    #expect(instance.language == language)
  }

  @Test func setMaxRedirects() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let max = 0
    try api.pigeonDelegate.setMaxRedirects(
      pigeonApi: api, pigeonInstance: instance, max: Int64(max))

    #expect(instance.maxRedirects == UInt(max))
  }

  @Test func setFeatureFlags() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let flags = ["myString": "myString"]
    try api.pigeonDelegate.setFeatureFlags(pigeonApi: api, pigeonInstance: instance, flags: flags)

    #expect(instance.featureFlags == flags)
  }

  @Test func setEnableBackgroundPlayback() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let enabled = true
    try api.pigeonDelegate.setEnableBackgroundPlayback(
      pigeonApi: api, pigeonInstance: instance, enabled: enabled)

    #expect(instance.enableBackgroundPlayback == enabled)
  }

  @Test func setAutoPlayAdBreaks() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let autoPlay = true
    try api.pigeonDelegate.setAutoPlayAdBreaks(
      pigeonApi: api, pigeonInstance: instance, autoPlay: autoPlay)

    #expect(instance.autoPlayAdBreaks == autoPlay)
  }

  @Test func setDisableNowPlayingInfo() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let disable = true
    try api.pigeonDelegate.setDisableNowPlayingInfo(
      pigeonApi: api, pigeonInstance: instance, disable: disable)

    #expect(instance.disableNowPlayingInfo == disable)
  }

  @Test func setPlayerType() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let type = "myString"
    try api.pigeonDelegate.setPlayerType(pigeonApi: api, pigeonInstance: instance, type: type)

    #expect(instance.playerType == type)
  }

  @Test func setPlayerVersion() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let version = "myString"
    try api.pigeonDelegate.setPlayerVersion(
      pigeonApi: api, pigeonInstance: instance, version: version)

    #expect(instance.playerVersion == version)
  }

  @Test func setSessionID() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let sessionID = "myString"
    try api.pigeonDelegate.setSessionID(
      pigeonApi: api, pigeonInstance: instance, sessionID: sessionID)

    #expect(instance.sessionID == sessionID)
  }

  @Test func setSameAppKeyEnabled() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let enabled = true
    try api.pigeonDelegate.setSameAppKeyEnabled(
      pigeonApi: api, pigeonInstance: instance, enabled: enabled)

    #expect(instance.sameAppKeyEnabled == enabled)
  }

  @Test func setEnableDebugMode() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let enable = true
    try api.pigeonDelegate.setEnableDebugMode(
      pigeonApi: api, pigeonInstance: instance, enable: enable)

    #expect(instance.enableDebugMode == enable)
  }
}

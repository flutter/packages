// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import XCTest

@testable import interactive_media_ads

class SettingsTests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
    XCTAssertNotNil(instance)
  }

  func testSetPPID() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let ppid = "myString"
    try? api.pigeonDelegate.setPPID(pigeonApi: api, pigeonInstance: instance, ppid: ppid)

    XCTAssertEqual(instance.ppid, ppid)
  }

  func testSetLanguage() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let language = "en"
    try? api.pigeonDelegate.setLanguage(
      pigeonApi: api, pigeonInstance: instance, language: language)

    XCTAssertEqual(instance.language, language)
  }

  func testSetMaxRedirects() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let max = 0
    try? api.pigeonDelegate.setMaxRedirects(
      pigeonApi: api, pigeonInstance: instance, max: Int64(max))

    XCTAssertEqual(instance.maxRedirects, UInt(max))
  }

  func testSetFeatureFlags() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let flags = ["myString": "myString"]
    try? api.pigeonDelegate.setFeatureFlags(pigeonApi: api, pigeonInstance: instance, flags: flags)

    XCTAssertEqual(instance.featureFlags, flags)
  }

  func testSetEnableBackgroundPlayback() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let enabled = true
    try? api.pigeonDelegate.setEnableBackgroundPlayback(
      pigeonApi: api, pigeonInstance: instance, enabled: enabled)

    XCTAssertEqual(instance.enableBackgroundPlayback, enabled)
  }

  func testSetAutoPlayAdBreaks() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let autoPlay = true
    try? api.pigeonDelegate.setAutoPlayAdBreaks(
      pigeonApi: api, pigeonInstance: instance, autoPlay: autoPlay)

    XCTAssertEqual(instance.autoPlayAdBreaks, autoPlay)
  }

  func testSetDisableNowPlayingInfo() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let disable = true
    try? api.pigeonDelegate.setDisableNowPlayingInfo(
      pigeonApi: api, pigeonInstance: instance, disable: disable)

    XCTAssertEqual(instance.disableNowPlayingInfo, disable)
  }

  func testSetPlayerType() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let type = "myString"
    try? api.pigeonDelegate.setPlayerType(pigeonApi: api, pigeonInstance: instance, type: type)

    XCTAssertEqual(instance.playerType, type)
  }

  func testSetPlayerVersion() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let version = "myString"
    try? api.pigeonDelegate.setPlayerVersion(
      pigeonApi: api, pigeonInstance: instance, version: version)

    XCTAssertEqual(instance.playerVersion, version)
  }

  func testSetSessionID() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let sessionID = "myString"
    try? api.pigeonDelegate.setSessionID(
      pigeonApi: api, pigeonInstance: instance, sessionID: sessionID)

    XCTAssertEqual(instance.sessionID, sessionID)
  }

  func testSetSameAppKeyEnabled() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let enabled = true
    try? api.pigeonDelegate.setSameAppKeyEnabled(
      pigeonApi: api, pigeonInstance: instance, enabled: enabled)

    XCTAssertEqual(instance.sameAppKeyEnabled, enabled)
  }

  func testSetEnableDebugMode() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMASettings(registrar)

    let instance = IMASettings()
    let enable = true
    try? api.pigeonDelegate.setEnableDebugMode(
      pigeonApi: api, pigeonInstance: instance, enable: enable)

    XCTAssertEqual(instance.enableDebugMode, enable)
  }
}

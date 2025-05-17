// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

class WebViewConfigurationProxyAPITests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
    XCTAssertNotNil(instance)
  }

  @MainActor func testSetUserContentController() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let controller = WKUserContentController()
    try? api.pigeonDelegate.setUserContentController(
      pigeonApi: api, pigeonInstance: instance, controller: controller)

    XCTAssertEqual(instance.userContentController, controller)
  }

  @MainActor func testGetUserContentController() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let value = try? api.pigeonDelegate.getUserContentController(
      pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.userContentController)
  }

  @MainActor func testSetWebsiteDataStore() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let dataStore = WKWebsiteDataStore.default()
    try? api.pigeonDelegate.setWebsiteDataStore(
      pigeonApi: api, pigeonInstance: instance, dataStore: dataStore)

    XCTAssertEqual(instance.websiteDataStore, dataStore)
  }

  @MainActor func testGetWebsiteDataStore() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let value = try? api.pigeonDelegate.getWebsiteDataStore(
      pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.websiteDataStore)
  }

  @MainActor func testSetPreferences() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let preferences = WKPreferences()
    try? api.pigeonDelegate.setPreferences(
      pigeonApi: api, pigeonInstance: instance, preferences: preferences)

    XCTAssertEqual(instance.preferences, preferences)
  }

  @MainActor func testGetPreferences() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let value = try? api.pigeonDelegate.getPreferences(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.preferences)
  }

  @MainActor func testSetAllowsInlineMediaPlayback() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let allow = true
    try? api.pigeonDelegate.setAllowsInlineMediaPlayback(
      pigeonApi: api, pigeonInstance: instance, allow: allow)

    // setAllowsInlineMediaPlayback does not existing on macOS; the call above should no-op for macOS.
    #if !os(macOS)
      XCTAssertEqual(instance.allowsInlineMediaPlayback, allow)
    #endif
  }

  @available(iOS 14.0, macOS 11.0, *)
  @MainActor func testSetLimitsNavigationsToAppBoundDomains() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let limit = true
    try? api.pigeonDelegate.setLimitsNavigationsToAppBoundDomains(
      pigeonApi: api, pigeonInstance: instance, limit: limit)

    XCTAssertEqual(instance.limitsNavigationsToAppBoundDomains, limit)
  }

  @MainActor func testSetMediaTypesRequiringUserActionForPlayback() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let type: AudiovisualMediaType = .none
    try? api.pigeonDelegate.setMediaTypesRequiringUserActionForPlayback(
      pigeonApi: api, pigeonInstance: instance, type: type)

    XCTAssertEqual(instance.mediaTypesRequiringUserActionForPlayback, [])
  }

  @available(iOS 13.0, macOS 10.15, *)
  @MainActor func testGetDefaultWebpagePreferences() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let value = try? api.pigeonDelegate.getDefaultWebpagePreferences(
      pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.defaultWebpagePreferences)
  }
}

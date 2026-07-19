// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@Suite struct WebViewConfigurationProxyAPITests {
  @Test func pigeonDefaultConstructor() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
    #expect(instance != nil)
  }

  @MainActor @Test func setUserContentController() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let controller = WKUserContentController()
    try? api.pigeonDelegate.setUserContentController(
      pigeonApi: api, pigeonInstance: instance, controller: controller)

    #expect(instance.userContentController == controller)
  }

  @MainActor @Test func getUserContentController() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let value = try? api.pigeonDelegate.getUserContentController(
      pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.userContentController)
  }

  @MainActor @Test func setWebsiteDataStore() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let dataStore = WKWebsiteDataStore.default()
    try? api.pigeonDelegate.setWebsiteDataStore(
      pigeonApi: api, pigeonInstance: instance, dataStore: dataStore)

    #expect(instance.websiteDataStore == dataStore)
  }

  @MainActor @Test func getWebsiteDataStore() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let value = try? api.pigeonDelegate.getWebsiteDataStore(
      pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.websiteDataStore)
  }

  @MainActor @Test func setPreferences() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let preferences = WKPreferences()
    try? api.pigeonDelegate.setPreferences(
      pigeonApi: api, pigeonInstance: instance, preferences: preferences)

    #expect(instance.preferences == preferences)
  }

  @MainActor @Test func getPreferences() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let value = try? api.pigeonDelegate.getPreferences(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.preferences)
  }

  @MainActor @Test func setAllowsInlineMediaPlayback() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let allow = true
    try? api.pigeonDelegate.setAllowsInlineMediaPlayback(
      pigeonApi: api, pigeonInstance: instance, allow: allow)

    // setAllowsInlineMediaPlayback does not existing on macOS; the call above should no-op for macOS.
    #if !os(macOS)
      #expect(instance.allowsInlineMediaPlayback == allow)
    #endif
  }

  @available(iOS 14.0, macOS 11.0, *)
  @MainActor @Test func setLimitsNavigationsToAppBoundDomains() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let limit = true
    try? api.pigeonDelegate.setLimitsNavigationsToAppBoundDomains(
      pigeonApi: api, pigeonInstance: instance, limit: limit)

    #expect(instance.limitsNavigationsToAppBoundDomains == limit)
  }

  @MainActor @Test func setMediaTypesRequiringUserActionForPlayback() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let type: AudiovisualMediaType = .none
    try? api.pigeonDelegate.setMediaTypesRequiringUserActionForPlayback(
      pigeonApi: api, pigeonInstance: instance, type: type)

    #expect(instance.mediaTypesRequiringUserActionForPlayback == [])
  }

  @MainActor @Test func getDefaultWebpagePreferences() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebViewConfiguration(registrar)

    let instance = WKWebViewConfiguration()
    let value = try? api.pigeonDelegate.getDefaultWebpagePreferences(
      pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.defaultWebpagePreferences)
  }
}

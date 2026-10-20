// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@Suite struct PreferencesProxyAPITests {
  @MainActor @Test func setJavaScriptEnabledThrowsUnsupported() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKPreferences(registrar)

    let instance = WKPreferences()
    #expect(throws: (any Error).self) {
      try api.pigeonDelegate.setJavaScriptEnabled(
        pigeonApi: api, pigeonInstance: instance, enabled: true)
    }
  }

  @MainActor @Test func setJavaScriptCanOpenWindowsAutomatically() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKPreferences(registrar)

    let instance = WKPreferences()
    let enabled = true
    try api.pigeonDelegate.setJavaScriptCanOpenWindowsAutomatically(
      pigeonApi: api, pigeonInstance: instance, enabled: enabled)

    #expect(instance.javaScriptCanOpenWindowsAutomatically == enabled)
  }
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@Suite struct PreferencesProxyAPITests {
  @MainActor @Test func setJavaScriptEnabled() throws {
    if #available(iOS 14.0, macOS 11.0, *) {
      return

    } else {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiWKPreferences(registrar)

      let instance = WKPreferences()
      let enabled = true
      try api.pigeonDelegate.setJavaScriptEnabled(
        pigeonApi: api, pigeonInstance: instance, enabled: enabled)

      #expect(instance.javaScriptEnabled == enabled)
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

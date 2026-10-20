// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@Suite struct WebpagePreferencesProxyAPITests {
  @MainActor @Test func setAllowsContentJavaScript() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebpagePreferences(registrar)

    let instance = WKWebpagePreferences()
    let allow = true
    try api.pigeonDelegate.setAllowsContentJavaScript(
      pigeonApi: api, pigeonInstance: instance, allow: allow)

    #expect(instance.allowsContentJavaScript == allow)
  }
}

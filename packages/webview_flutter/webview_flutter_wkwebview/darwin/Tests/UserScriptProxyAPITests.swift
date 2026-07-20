// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@Suite struct UserScriptProxyAPITests {
  @MainActor @Test func pigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserScript(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, source: "myString", injectionTime: .atDocumentStart, isForMainFrameOnly: true)
    #expect(instance != nil)
  }

  @MainActor @Test func source() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserScript(registrar)

    let instance = WKUserScript(
      source: "source", injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    let value = try api.pigeonDelegate.source(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.source)
  }

  @MainActor @Test func injectionTime() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserScript(registrar)

    let instance = WKUserScript(
      source: "source", injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    let value = try api.pigeonDelegate.injectionTime(pigeonApi: api, pigeonInstance: instance)

    #expect(value == .atDocumentEnd)
  }

  @MainActor @Test func isMainFrameOnly() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserScript(registrar)

    let instance = WKUserScript(
      source: "source", injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    let value = try api.pigeonDelegate.isForMainFrameOnly(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.isForMainFrameOnly)
  }
}

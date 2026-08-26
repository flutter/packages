// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@Suite struct UserContentControllerProxyAPITests {
  @MainActor @Test func addScriptMessageHandler() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserContentController(registrar)

    let instance = TestUserContentController()
    let handler = ScriptMessageHandlerImpl(
      api: registrar.apiDelegate.pigeonApiWKScriptMessageHandler(registrar), registrar: registrar)
    let name = "myString"
    try api.pigeonDelegate.addScriptMessageHandler(
      pigeonApi: api, pigeonInstance: instance, handler: handler, name: name)

    #expect(instance.addScriptMessageHandlerArgs == [handler, name])
  }

  @MainActor @Test func removeScriptMessageHandler() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserContentController(registrar)

    let instance = TestUserContentController()
    let name = "myString"
    try api.pigeonDelegate.removeScriptMessageHandler(
      pigeonApi: api, pigeonInstance: instance, name: name)

    #expect(instance.removeScriptMessageHandlerArgs == [name])
  }

  @MainActor @Test func removeAllScriptMessageHandlers() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserContentController(registrar)

    let instance = TestUserContentController()
    try api.pigeonDelegate.removeAllScriptMessageHandlers(pigeonApi: api, pigeonInstance: instance)

    #expect(instance.removeAllScriptMessageHandlersCalled)
  }

  @MainActor @Test func addUserScript() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserContentController(registrar)

    let instance = TestUserContentController()
    let userScript = WKUserScript(source: "", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    try api.pigeonDelegate.addUserScript(
      pigeonApi: api, pigeonInstance: instance, userScript: userScript)

    #expect(instance.addUserScriptArgs == [userScript])
  }

  @MainActor @Test func removeAllUserScripts() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserContentController(registrar)

    let instance = TestUserContentController()
    try api.pigeonDelegate.removeAllUserScripts(pigeonApi: api, pigeonInstance: instance)

    #expect(instance.removeAllUserScriptsCalled)
  }

}

class TestUserContentController: WKUserContentController {
  var addScriptMessageHandlerArgs: [AnyHashable?]? = nil
  var removeScriptMessageHandlerArgs: [AnyHashable?]? = nil
  var removeAllScriptMessageHandlersCalled = false
  var addUserScriptArgs: [AnyHashable?]? = nil
  var removeAllUserScriptsCalled = false

  override func add(_ scriptMessageHandler: WKScriptMessageHandler, name: String) {
    addScriptMessageHandlerArgs = [scriptMessageHandler as! NSObject, name]
  }

  override func removeScriptMessageHandler(forName name: String) {
    removeScriptMessageHandlerArgs = [name]
  }

  override func removeAllScriptMessageHandlers() {
    removeAllScriptMessageHandlersCalled = true
  }

  override func addUserScript(_ userScript: WKUserScript) {
    addUserScriptArgs = [userScript]
  }

  override func removeAllUserScripts() {
    removeAllUserScriptsCalled = true
  }
}

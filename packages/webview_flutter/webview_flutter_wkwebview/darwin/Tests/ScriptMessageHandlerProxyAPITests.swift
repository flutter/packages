// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@Suite struct ScriptMessageHandlerProxyAPITests {
  @Test func pigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKScriptMessageHandler(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
    #expect(instance != nil)
  }

  @MainActor @Test func didReceiveScriptMessage() throws {
    let api = TestScriptMessageHandlerApi()
    let registrar = TestProxyApiRegistrar()
    let instance = ScriptMessageHandlerImpl(api: api, registrar: registrar)
    let controller = WKUserContentController()
    let message = WKScriptMessage()

    instance.userContentController(controller, didReceive: message)

    #expect(api.didReceiveScriptMessageArgs == [controller, message])
  }
}

class TestScriptMessageHandlerApi: PigeonApiProtocolWKScriptMessageHandler {
  var didReceiveScriptMessageArgs: [AnyHashable?]? = nil

  func didReceiveScriptMessage(
    pigeonInstance pigeonInstanceArg: WKScriptMessageHandler,
    controller controllerArg: WKUserContentController, message messageArg: WKScriptMessage,
    completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {
    didReceiveScriptMessageArgs = [controllerArg, messageArg]
  }
}

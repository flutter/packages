// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

class UserContentControllerProxyAPITests: XCTestCase {
  @MainActor func testAddScriptMessageHandler() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserContentController(registrar)

    let instance = TestUserContentController()
    let handler = ScriptMessageHandlerImpl(
      api: registrar.apiDelegate.pigeonApiWKScriptMessageHandler(registrar), registrar: registrar)
    let name = "myString"
    try? api.pigeonDelegate.addScriptMessageHandler(
      pigeonApi: api, pigeonInstance: instance, handler: handler, name: name)

    XCTAssertEqual(instance.addScriptMessageHandlerArgs, [handler, name])
  }

  @MainActor func testRemoveScriptMessageHandler() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserContentController(registrar)

    let instance = TestUserContentController()
    let name = "myString"
    try? api.pigeonDelegate.removeScriptMessageHandler(
      pigeonApi: api, pigeonInstance: instance, name: name)

    XCTAssertEqual(instance.removeScriptMessageHandlerArgs, [name])
  }

  @MainActor func testRemoveAllScriptMessageHandlers() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserContentController(registrar)

    let instance = TestUserContentController()
    try? api.pigeonDelegate.removeAllScriptMessageHandlers(pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(instance.removeAllScriptMessageHandlersCalled)
  }

  @MainActor func testAddUserScript() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserContentController(registrar)

    let instance = TestUserContentController()
    let userScript = WKUserScript(source: "", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    try? api.pigeonDelegate.addUserScript(
      pigeonApi: api, pigeonInstance: instance, userScript: userScript)

    XCTAssertEqual(instance.addUserScriptArgs, [userScript])
  }

  @MainActor func testRemoveAllUserScripts() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserContentController(registrar)

    let instance = TestUserContentController()
    try? api.pigeonDelegate.removeAllUserScripts(pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(instance.removeAllUserScriptsCalled)
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

// Mock that simulates WKUserContentController's behavior of crashing/complaining
// when adding a duplicate script message handler.
// Mock that verifies remove is called before add, and enforces uniqueness
class MockVerifyingUserContentController: WKUserContentController {
  var registeredNames: Set<String> = []
  var removeCalledFor: String? = nil

  override func add(_ scriptMessageHandler: WKScriptMessageHandler, name: String) {
    if registeredNames.contains(name) {
      // If we are here, it means remove wasn't called or failed to remove
      // In logical flow, remove() should have been called first.
      // But implementation-wise, we just want to ensure we don't crash.
      // Ideally, the 'remove' call below should have cleared it.
      NSException(name: NSExceptionName.invalidArgumentException, reason: "Duplicate handler name", userInfo: nil).raise()
    }
    registeredNames.insert(name)
  }

  override func removeScriptMessageHandler(forName name: String) {
    removeCalledFor = name
    registeredNames.remove(name)
  }
}

extension UserContentControllerProxyAPITests {
  @MainActor func testAddScriptMessageHandlerHandlesDuplicates() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserContentController(registrar)
    
    let instance = MockVerifyingUserContentController()
    let handler = ScriptMessageHandlerImpl(
      api: registrar.apiDelegate.pigeonApiWKScriptMessageHandler(registrar), registrar: registrar)
    let name = "myString"

    // First add
    try? api.pigeonDelegate.addScriptMessageHandler(
      pigeonApi: api, pigeonInstance: instance, handler: handler, name: name)
    XCTAssertTrue(instance.registeredNames.contains(name))

    // Second add - should NOT crash because implementation calls remove first
    try? api.pigeonDelegate.addScriptMessageHandler(
        pigeonApi: api, pigeonInstance: instance, handler: handler, name: name)
    
    // Check that it's still registered (or re-registered)
    XCTAssertTrue(instance.registeredNames.contains(name))
    // Verify remove was called
    XCTAssertEqual(instance.removeCalledFor, name)
  }
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

class URLSchemeHandlerProxyAPITests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKURLSchemeHandler(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
    XCTAssertNotNil(instance)
  }

  @MainActor func testStartUrlSchemeTask() {
    let api = TestURLSchemeHandlerApi()
    let registrar = TestProxyApiRegistrar()
    let instance = URLSchemeHandlerImpl(api: api, registrar: registrar)
    let webView = WKWebView()
    let task = TestURLSchemeTask()

    instance.webView(webView, start: task)

    XCTAssertEqual(api.startUrlSchemeTaskArgs, [webView, task])
    XCTAssertFalse(URLSchemeTaskState.isStopped(task))
  }

  @MainActor func testStopUrlSchemeTask() {
    let api = TestURLSchemeHandlerApi()
    let registrar = TestProxyApiRegistrar()
    let instance = URLSchemeHandlerImpl(api: api, registrar: registrar)
    let webView = WKWebView()
    let task = TestURLSchemeTask()

    instance.webView(webView, stop: task)

    XCTAssertEqual(api.stopUrlSchemeTaskArgs, [webView, task])
    XCTAssertTrue(URLSchemeTaskState.isStopped(task))
  }
}

class TestURLSchemeHandlerApi: PigeonApiProtocolWKURLSchemeHandler {
  var startUrlSchemeTaskArgs: [AnyHashable?]? = nil
  var stopUrlSchemeTaskArgs: [AnyHashable?]? = nil

  func startUrlSchemeTask(
    pigeonInstance pigeonInstanceArg: WKURLSchemeHandler, webView webViewArg: WKWebView,
    urlSchemeTask urlSchemeTaskArg: WKURLSchemeTask,
    completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {
    startUrlSchemeTaskArgs = [webViewArg, urlSchemeTaskArg as? NSObject]
  }

  func stopUrlSchemeTask(
    pigeonInstance pigeonInstanceArg: WKURLSchemeHandler, webView webViewArg: WKWebView,
    urlSchemeTask urlSchemeTaskArg: WKURLSchemeTask,
    completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {
    stopUrlSchemeTaskArgs = [webViewArg, urlSchemeTaskArg as? NSObject]
  }
}

class TestURLSchemeTask: NSObject, WKURLSchemeTask {
  var request: URLRequest = URLRequest(url: URL(string: "test-scheme://host/resource")!)

  var didReceiveResponseArg: URLResponse? = nil
  var didReceiveDataArg: Data? = nil
  var didFinishCalled = false
  var didFailWithErrorArg: (any Error)? = nil

  func didReceive(_ response: URLResponse) {
    didReceiveResponseArg = response
  }

  func didReceive(_ data: Data) {
    didReceiveDataArg = data
  }

  func didFinish() {
    didFinishCalled = true
  }

  func didFailWithError(_ error: any Error) {
    didFailWithErrorArg = error
  }
}

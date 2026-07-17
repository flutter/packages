// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

class URLSchemeTaskProxyAPITests: XCTestCase {
  func testRequest() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKURLSchemeTask(registrar)

    let instance = TestURLSchemeTask()
    let value = try? api.pigeonDelegate.request(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value?.value, instance.request)
  }

  func testDidReceiveResponse() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKURLSchemeTask(registrar)

    let instance = TestURLSchemeTask()
    let response = URLResponse(
      url: URL(string: "test-scheme://host/resource")!, mimeType: "image/png",
      expectedContentLength: 3, textEncodingName: nil)
    try? api.pigeonDelegate.didReceiveResponse(
      pigeonApi: api, pigeonInstance: instance, response: response)

    XCTAssertEqual(instance.didReceiveResponseArg, response)
  }

  func testDidReceiveData() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKURLSchemeTask(registrar)

    let instance = TestURLSchemeTask()
    let data = Data([1, 2, 3])
    try? api.pigeonDelegate.didReceiveData(
      pigeonApi: api, pigeonInstance: instance, data: FlutterStandardTypedData(bytes: data))

    XCTAssertEqual(instance.didReceiveDataArg, data)
  }

  func testDidFinish() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKURLSchemeTask(registrar)

    let instance = TestURLSchemeTask()
    try? api.pigeonDelegate.didFinish(pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(instance.didFinishCalled)
  }

  func testDidFailWithError() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKURLSchemeTask(registrar)

    let instance = TestURLSchemeTask()
    let error = NSError(domain: "domain", code: 42)
    try? api.pigeonDelegate.didFailWithError(
      pigeonApi: api, pigeonInstance: instance, error: error)

    XCTAssertEqual(instance.didFailWithErrorArg as? NSError, error)
  }

  func testCallsAreNoOpsAfterTaskWasStopped() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKURLSchemeTask(registrar)

    let instance = TestURLSchemeTask()
    URLSchemeTaskState.markStopped(instance)

    let response = URLResponse(
      url: URL(string: "test-scheme://host/resource")!, mimeType: nil,
      expectedContentLength: 0, textEncodingName: nil)
    try? api.pigeonDelegate.didReceiveResponse(
      pigeonApi: api, pigeonInstance: instance, response: response)
    try? api.pigeonDelegate.didReceiveData(
      pigeonApi: api, pigeonInstance: instance,
      data: FlutterStandardTypedData(bytes: Data([1])))
    try? api.pigeonDelegate.didFinish(pigeonApi: api, pigeonInstance: instance)
    try? api.pigeonDelegate.didFailWithError(
      pigeonApi: api, pigeonInstance: instance, error: NSError(domain: "", code: 0))

    XCTAssertNil(instance.didReceiveResponseArg)
    XCTAssertNil(instance.didReceiveDataArg)
    XCTAssertFalse(instance.didFinishCalled)
    XCTAssertNil(instance.didFailWithErrorArg)
  }
}

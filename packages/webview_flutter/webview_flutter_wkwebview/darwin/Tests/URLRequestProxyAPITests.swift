// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

class RequestProxyAPITests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api, url: "myString")
    XCTAssertNotNil(instance)
  }

  func testGetUrl() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let value = try? api.pigeonDelegate.getUrl(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.value.url?.absoluteString)
  }

  func testSetHttpMethod() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let method = "GET"
    try? api.pigeonDelegate.setHttpMethod(pigeonApi: api, pigeonInstance: instance, method: method)

    XCTAssertEqual(instance.value.httpMethod, method)
  }

  func testGetHttpMethod() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))

    let method = "POST"
    instance.value.httpMethod = method
    let value = try? api.pigeonDelegate.getHttpMethod(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, method)
  }

  func testSetHttpBody() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let body = FlutterStandardTypedData(bytes: Data())
    try? api.pigeonDelegate.setHttpBody(pigeonApi: api, pigeonInstance: instance, body: body)

    XCTAssertEqual(instance.value.httpBody, body.data)
  }

  func testGetHttpBody() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let body = FlutterStandardTypedData(bytes: Data())
    instance.value.httpBody = body.data
    let value = try? api.pigeonDelegate.getHttpBody(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value?.data, body.data)
  }

  func testSetAllHttpHeaderFields() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let fields = ["key": "value"]
    try? api.pigeonDelegate.setAllHttpHeaderFields(
      pigeonApi: api, pigeonInstance: instance, fields: fields)

    XCTAssertEqual(instance.value.allHTTPHeaderFields, fields)
  }

  func testGetAllHttpHeaderFields() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let fields = ["key": "value"]
    instance.value.allHTTPHeaderFields = fields

    let value = try? api.pigeonDelegate.getAllHttpHeaderFields(
      pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, fields)
  }
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

@Suite struct RequestProxyAPITests {
  @Test func pigeonDefaultConstructor() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api, url: "myString")
    #expect(instance != nil)
  }

  @Test func getUrl() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let value = try? api.pigeonDelegate.getUrl(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.value.url?.absoluteString)
  }

  @Test func setHttpMethod() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let method = "GET"
    try? api.pigeonDelegate.setHttpMethod(pigeonApi: api, pigeonInstance: instance, method: method)

    #expect(instance.value.httpMethod == method)
  }

  @Test func getHttpMethod() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))

    let method = "POST"
    instance.value.httpMethod = method
    let value = try? api.pigeonDelegate.getHttpMethod(pigeonApi: api, pigeonInstance: instance)

    #expect(value == method)
  }

  @Test func setHttpBody() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let body = FlutterStandardTypedData(bytes: Data())
    try? api.pigeonDelegate.setHttpBody(pigeonApi: api, pigeonInstance: instance, body: body)

    #expect(instance.value.httpBody == body.data)
  }

  @Test func getHttpBody() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let body = FlutterStandardTypedData(bytes: Data())
    instance.value.httpBody = body.data
    let value = try? api.pigeonDelegate.getHttpBody(pigeonApi: api, pigeonInstance: instance)

    #expect(value?.data == body.data)
  }

  @Test func setAllHttpHeaderFields() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let fields = ["key": "value"]
    try? api.pigeonDelegate.setAllHttpHeaderFields(
      pigeonApi: api, pigeonInstance: instance, fields: fields)

    #expect(instance.value.allHTTPHeaderFields == fields)
  }

  @Test func getAllHttpHeaderFields() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let fields = ["key": "value"]
    instance.value.allHTTPHeaderFields = fields

    let value = try? api.pigeonDelegate.getAllHttpHeaderFields(
      pigeonApi: api, pigeonInstance: instance)

    #expect(value == fields)
  }
}

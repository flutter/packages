// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@Suite struct HTTPCookieStoreProxyAPITests {
  @MainActor @Test func setCookie() async throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKHTTPCookieStore(registrar)

    let instance: TestCookieStore? = TestCookieStore.customInit()
    let cookie = HTTPCookie(properties: [
      .name: "foo", .value: "bar", .domain: "http://google.com",
      .path: "/anything",
    ])!

    try await withCheckedThrowingContinuation { continuation in
      api.pigeonDelegate.setCookie(
        pigeonApi: api,
        pigeonInstance: instance!,
        cookie: cookie
      ) { result in
        switch result {
        case .success(_):
          continuation.resume()
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
    #expect(instance!.setCookieArg == cookie)
  }

  @MainActor @Test func getCookies() async throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKHTTPCookieStore(registrar)

    let cookie1 = HTTPCookie(properties: [
      .name: "foo", .value: "bar", .domain: "google.com", .path: "/",
    ])!
    let cookie2 = HTTPCookie(properties: [
      .name: "baz", .value: "qux", .domain: "example.com", .path: "/",
    ])!

    let instance: TestCookieStore? = TestCookieStore.customInit()
    instance!.allCookies = [cookie1, cookie2]

    // Test fetching all cookies
    let cookies = try await withCheckedThrowingContinuation { continuation in
      api.pigeonDelegate.getAllCookies(
        pigeonApi: api,
        pigeonInstance: instance!
      ) { result in
        switch result {
        case .success(let cookies):
          continuation.resume(returning: cookies)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
    #expect(cookies == [cookie1, cookie2])
  }
}

class TestCookieStore: WKHTTPCookieStore {
  var setCookieArg: HTTPCookie? = nil
  var allCookies: [HTTPCookie] = []

  // Workaround to subclass an Objective-C class that has an `init` constructor with NS_UNAVAILABLE
  static func customInit() -> TestCookieStore {
    let instance =
      TestCookieStore.perform(NSSelectorFromString("new"))
      .takeRetainedValue() as! TestCookieStore
    return instance
  }

  #if compiler(>=6.0)
    public override func setCookie(
      _ cookie: HTTPCookie,
      completionHandler: (@MainActor () -> Void)? = nil
    ) {
      setCookieArg = cookie
      DispatchQueue.main.async {
        completionHandler?()
      }
    }
  #else
    public override func setCookie(
      _ cookie: HTTPCookie,
      completionHandler: (() -> Void)? = nil
    ) {
      setCookieArg = cookie
      DispatchQueue.main.async {
        completionHandler?()
      }
    }
  #endif

  override func getAllCookies(
    _ completionHandler: @escaping @MainActor ([HTTPCookie]) -> Void
  ) {
    DispatchQueue.main.async {
      completionHandler(self.allCookies)
    }
  }
}

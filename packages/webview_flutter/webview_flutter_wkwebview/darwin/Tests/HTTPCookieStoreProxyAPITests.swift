// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

class HTTPCookieStoreProxyAPITests: XCTestCase {
  @MainActor func testSetCookie() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKHTTPCookieStore(registrar)

    let instance: TestCookieStore? = TestCookieStore.customInit()
    let cookie = HTTPCookie(properties: [
      .name: "foo", .value: "bar", .domain: "http://google.com",
      .path: "/anything",
    ])!

    let expect = expectation(description: "Wait for setCookie.")
    api.pigeonDelegate.setCookie(
      pigeonApi: api,
      pigeonInstance: instance!,
      cookie: cookie
    ) {
      result in
      switch result {
      case .success(_):
        expect.fulfill()
      case .failure(_):
        break
      }
    }

    wait(for: [expect], timeout: 1.0)
    XCTAssertEqual(instance!.setCookieArg, cookie)
  }

  @MainActor func testGetCookies() {
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
    let expectAll = expectation(description: "Wait for getAllCookies.")
    api.pigeonDelegate.getCookies(
      pigeonApi: api,
      pigeonInstance: instance!,
      domain: nil
    ) { result in
      switch result {
      case .success(let cookies):
        XCTAssertEqual(cookies.count, 2)
        XCTAssertTrue(cookies.contains(cookie1))
        XCTAssertTrue(cookies.contains(cookie2))
        expectAll.fulfill()
      case .failure(_):
        break
      }
    }

    // Test fetching cookies filtered by domain
    let expectFiltered = expectation(
      description: "Wait for getCookies filtered."
    )
    api.pigeonDelegate.getCookies(
      pigeonApi: api,
      pigeonInstance: instance!,
      domain: "google.com"
    ) { result in
      switch result {
      case .success(let cookies):
        XCTAssertEqual(cookies.count, 1)
        XCTAssertEqual(cookies.first, cookie1)
        expectFiltered.fulfill()
      case .failure(_):
        break
      }
    }

    wait(for: [expectAll, expectFiltered], timeout: 1.0)
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

  public override func getAllCookies(
    _ completionHandler: @escaping ([HTTPCookie]) -> Void
  ) {
    DispatchQueue.main.async {
      completionHandler(self.allCookies)
    }
  }
}

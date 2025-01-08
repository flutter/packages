// Copyright 2013 The Flutter Authors. All rights reserved.
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
      .name: "foo", .value: "bar", .domain: "http://google.com", .path: "/anything",
    ])!

    let expect = expectation(description: "Wait for setCookie.")
    api.pigeonDelegate.setCookie(pigeonApi: api, pigeonInstance: instance!, cookie: cookie) {
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
}

class TestCookieStore: WKHTTPCookieStore {
  var setCookieArg: HTTPCookie? = nil

  // Workaround to subclass an Objective-C class that has an `init` constructor with NS_UNAVAILABLE
  static func customInit() -> TestCookieStore {
    let instance =
      TestCookieStore.perform(NSSelectorFromString("new")).takeRetainedValue() as! TestCookieStore
    return instance
  }

  #if compiler(>=6.0)
    public override func setCookie(
      _ cookie: HTTPCookie, completionHandler: (@MainActor () -> Void)? = nil
    ) {
      setCookieArg = cookie
      DispatchQueue.main.async {
        completionHandler?()
      }
    }
  #else
    public override func setCookie(_ cookie: HTTPCookie, completionHandler: (() -> Void)? = nil) {
      setCookieArg = cookie
      DispatchQueue.main.async {
        completionHandler?()
      }
    }
  #endif
}

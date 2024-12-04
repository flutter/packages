// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import Flutter
import XCTest

@testable import webview_flutter_wkwebview


class HTTPCookieStoreProxyAPITests: XCTestCase {
  @MainActor func testSetCookie() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKHTTPCookieStore(registrar)

    var instance: TestCookieStore? = TestCookieStore.customInit()
    let cookie = HTTPCookie(properties: [.name : "foo", .value: "bar", .domain: "http://google.com", .path: "/anything"])!
    api.pigeonDelegate.setCookie(pigeonApi: api, pigeonInstance: instance!, cookie: cookie) { _ in
      
    }

    XCTAssertEqual(instance!.setCookieArg, cookie)
    
    DispatchQueue.main.async {
      instance = nil
    }
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
  
  override func setCookie(_ cookie: HTTPCookie, completionHandler: (@MainActor () -> Void)? = nil) {
    setCookieArg = cookie
  }
}

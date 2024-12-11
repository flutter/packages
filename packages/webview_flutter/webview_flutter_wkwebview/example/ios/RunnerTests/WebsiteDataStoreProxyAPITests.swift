// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import Flutter
import XCTest

@testable import webview_flutter_wkwebview

class WebsiteDataStoreProxyAPITests: XCTestCase {
  @available(iOS 17.0, *)
  @MainActor func testHttpCookieStore() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebsiteDataStore(registrar)

    let instance = WKWebsiteDataStore(forIdentifier: UUID())
    let value = try? api.pigeonDelegate.httpCookieStore(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.httpCookieStore)
  }

  @available(iOS 17.0, *)
  @MainActor func testRemoveDataOfTypes() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebsiteDataStore(registrar)

    let instance = WKWebsiteDataStore(forIdentifier: UUID())
    let dataTypes: [WebsiteDataType] = [.cookies]
    let modificationTimeInSecondsSinceEpoch = 0.0
    
    let expect = expectation(description: "Wait for cookie result to reutrn.")
    
    var hasCookiesResult: Bool?
    api.pigeonDelegate.removeDataOfTypes(pigeonApi: api, pigeonInstance: instance, dataTypes: dataTypes, modificationTimeInSecondsSinceEpoch: modificationTimeInSecondsSinceEpoch, completion: { result in
      switch result {
      case .success(let hasCookies):
        hasCookiesResult = hasCookies
      case .failure(_): break
      }
      
      expect.fulfill()
    })

    waitForExpectations(timeout: 5.0)
    XCTAssertNotNil(hasCookiesResult)
  }
}

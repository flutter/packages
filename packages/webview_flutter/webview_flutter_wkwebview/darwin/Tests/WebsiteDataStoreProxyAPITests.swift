// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

class WebsiteDataStoreProxyAPITests: XCTestCase {
  @available(iOS 17.0, *)
  @MainActor func testHttpCookieStore() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebsiteDataStore(registrar)

    let instance = WKWebsiteDataStore.default()
    let value = try? api.pigeonDelegate.httpCookieStore(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.httpCookieStore)
  }

  @available(iOS 17.0, *)
  @MainActor func testRemoveDataOfTypes() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebsiteDataStore(registrar)

    let instance = WKWebsiteDataStore.default()
    let dataTypes: [WebsiteDataType] = [.localStorage]
    let modificationTimeInSecondsSinceEpoch = 0.0

    let removeDataOfTypesExpectation = expectation(
      description: "Wait for result of removeDataOfTypes.")

    var removeDataOfTypesResult: Bool?
    api.pigeonDelegate.removeDataOfTypes(
      pigeonApi: api, pigeonInstance: instance, dataTypes: dataTypes,
      modificationTimeInSecondsSinceEpoch: modificationTimeInSecondsSinceEpoch,
      completion: { result in
        switch result {
        case .success(let hasRecords):
          removeDataOfTypesResult = hasRecords
        case .failure(_): break
        }

        removeDataOfTypesExpectation.fulfill()
      })

    wait(for: [removeDataOfTypesExpectation], timeout: 10.0)
    XCTAssertNotNil(removeDataOfTypesResult)
  }
}

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

    let instance = TestWebsiteDataStore(hello: UUID())
    let value = try? api.pigeonDelegate.httpCookieStore(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.httpCookieStore)
  }

  @available(iOS 17.0, *)
  @MainActor func testRemoveDataOfTypes() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebsiteDataStore(registrar)

    let instance = TestWebsiteDataStore(hello: UUID())
    let dataTypes: [WebsiteDataType] = [.cookies]
    let modificationTimeInSecondsSinceEpoch = 1.0

    var hasCookiesResult: Bool?
    api.pigeonDelegate.removeDataOfTypes(pigeonApi: api, pigeonInstance: instance, dataTypes: dataTypes, modificationTimeInSecondsSinceEpoch: modificationTimeInSecondsSinceEpoch, completion: { result in
      switch result {
      case .success(let hasCookies):
        hasCookiesResult = hasCookies
      case .failure(_): break
      }
    })

    XCTAssertEqual(instance.removeDataOfTypesArgs, [dataTypes, modificationTimeInSecondsSinceEpoch])
    XCTAssertEqual(hasCookiesResult, true)
  }
}

class TestWebsiteDataStore: WKWebsiteDataStore {
  private var httpCookieStoreTestValue = TestCookieStore.customInit()
  var removeDataOfTypesArgs: [AnyHashable?]? = nil
  
  @available(iOS 17.0, *)
  init(hello: UUID) {
    super.init(forIdentifier: hello)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func fetchDataRecords(ofTypes dataTypes: Set<String>, completionHandler: @escaping @MainActor ([WKWebsiteDataRecord]) -> Void) {
    completionHandler([WKWebsiteDataRecord()])
  }

  override var httpCookieStore: WKHTTPCookieStore {
    return httpCookieStoreTestValue
  }
  
  override func removeData(ofTypes dataTypes: Set<String>, modifiedSince date: Date, completionHandler: @escaping @MainActor () -> Void) {
    removeDataOfTypesArgs = [dataTypes, date]
  }
}

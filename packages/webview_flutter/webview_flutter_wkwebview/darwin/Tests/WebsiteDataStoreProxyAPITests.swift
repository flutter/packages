// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@Suite struct WebsiteDataStoreProxyAPITests {
  @available(iOS 17.0, *)
  @MainActor @Test func httpCookieStore() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebsiteDataStore(registrar)

    let instance = WKWebsiteDataStore.default()
    let value = try? api.pigeonDelegate.httpCookieStore(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.httpCookieStore)
  }

  @available(iOS 17.0, *)
  @MainActor @Test func removeDataOfTypes() async throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebsiteDataStore(registrar)

    let instance = WKWebsiteDataStore.default()
    let dataTypes: [WebsiteDataType] = [.localStorage]
    let modificationTimeInSecondsSinceEpoch = 0.0

    let _ = try await withCheckedThrowingContinuation {
      (continuation: CheckedContinuation<Bool, Error>) in
      api.pigeonDelegate.removeDataOfTypes(
        pigeonApi: api, pigeonInstance: instance, dataTypes: dataTypes,
        modificationTimeInSecondsSinceEpoch: modificationTimeInSecondsSinceEpoch,
        completion: { result in
          switch result {
          case .success(let hasRecords):
            continuation.resume(returning: hasRecords)
          case .failure(let error):
            continuation.resume(throwing: error)
          }
        })
    }
    // If the test doesn't throw, it has succeeded.
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// ProxyApi implementation for `WKWebsiteDataStore`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class WebsiteDataStoreProxyAPIDelegate: PigeonApiDelegateWKWebsiteDataStore {
  func defaultDataStore(pigeonApi: PigeonApiWKWebsiteDataStore) -> WKWebsiteDataStore {
    return WKWebsiteDataStore.default()
  }

  func httpCookieStore(pigeonApi: PigeonApiWKWebsiteDataStore, pigeonInstance: WKWebsiteDataStore)
    -> WKHTTPCookieStore
  {
    return pigeonInstance.httpCookieStore
  }

  func removeDataOfTypes(
    pigeonApi: PigeonApiWKWebsiteDataStore, pigeonInstance: WKWebsiteDataStore,
    dataTypes: [WebsiteDataType], modificationTimeInSecondsSinceEpoch: Double,
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    let nativeDataTypes = Set(
      dataTypes.map {
        switch $0 {
        case .cookies:
          return WKWebsiteDataTypeCookies
        case .memoryCache:
          return WKWebsiteDataTypeMemoryCache
        case .diskCache:
          return WKWebsiteDataTypeDiskCache
        case .offlineWebApplicationCache:
          return WKWebsiteDataTypeOfflineWebApplicationCache
        case .localStorage:
          return WKWebsiteDataTypeLocalStorage
        case .sessionStorage:
          return WKWebsiteDataTypeSessionStorage
        case .webSQLDatabases:
          return WKWebsiteDataTypeWebSQLDatabases
        case .indexedDBDatabases:
          return WKWebsiteDataTypeIndexedDBDatabases
        }
      })

    pigeonInstance.fetchDataRecords(ofTypes: nativeDataTypes) { records in
      if records.isEmpty {
        completion(.success(false))
      } else {
        pigeonInstance.removeData(
          ofTypes: nativeDataTypes,
          modifiedSince: Date(timeIntervalSince1970: modificationTimeInSecondsSinceEpoch)
        ) {
          completion(.success(true))
        }
      }
    }
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for `URLCredential`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class URLCredentialProxyAPIDelegate: PigeonApiDelegateURLCredential {
  func withUser(
    pigeonApi: PigeonApiURLCredential, user: String, password: String,
    persistence: UrlCredentialPersistence
  ) throws -> URLCredential {
    let nativePersistence: URLCredential.Persistence
    switch persistence {
    case .none:
      nativePersistence = .none
    case .forSession:
      nativePersistence = .forSession
    case .permanent:
      nativePersistence = .permanent
    case .synchronizable:
      nativePersistence = .synchronizable
    }
    return URLCredential(user: user, password: password, persistence: nativePersistence)
  }

  func withUserAsync(
    pigeonApi: PigeonApiURLCredential, user: String, password: String,
    persistence: UrlCredentialPersistence,
    completion: @escaping (Result<URLCredential, Error>) -> Void
  ) {
    completion(
      Result.success(
        try! withUser(
          pigeonApi: pigeonApi, user: user, password: password, persistence: persistence)))
  }

  func serverTrustAsync(
    pigeonApi: PigeonApiURLCredential, trust: SecTrustWrapper,
    completion: @escaping (Result<URLCredential, Error>) -> Void
  ) {
    completion(Result.success(URLCredential(trust: trust.value)))
  }
}

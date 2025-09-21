// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import WebKit

/// ProxyApi implementation for `WKHTTPCookieStore`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class HTTPCookieStoreProxyAPIDelegate: PigeonApiDelegateWKHTTPCookieStore {
  func setCookie(
    pigeonApi: PigeonApiWKHTTPCookieStore, pigeonInstance: WKHTTPCookieStore, cookie: HTTPCookie,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    pigeonInstance.setCookie(cookie) {
      completion(.success(Void()))
    }
  }
}

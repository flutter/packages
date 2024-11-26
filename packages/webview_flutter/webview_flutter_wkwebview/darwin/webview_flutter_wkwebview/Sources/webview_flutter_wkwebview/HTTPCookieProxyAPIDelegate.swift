// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for `HTTPCookie`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class CookieProxyAPIDelegate : PigeonApiDelegateHTTPCookie {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiHTTPCookie, properties: [HttpCookiePropertyKey: Any?]) throws -> HTTPCookie {
    return HTTPCookie()
  }

  func properties(pigeonApi: PigeonApiHTTPCookie, pigeonInstance: HTTPCookie) throws -> [HttpCookiePropertyKey: Any?] {
    return pigeonInstance.properties
  }
}

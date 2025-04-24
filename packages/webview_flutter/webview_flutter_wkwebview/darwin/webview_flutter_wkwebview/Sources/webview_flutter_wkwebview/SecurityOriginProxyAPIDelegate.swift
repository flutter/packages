// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// ProxyApi implementation for `WKSecurityOrigin`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class SecurityOriginProxyAPIDelegate: PigeonApiDelegateWKSecurityOrigin {
  func host(pigeonApi: PigeonApiWKSecurityOrigin, pigeonInstance: WKSecurityOrigin) throws -> String
  {
    return pigeonInstance.host
  }

  func port(pigeonApi: PigeonApiWKSecurityOrigin, pigeonInstance: WKSecurityOrigin) throws -> Int64
  {
    return Int64(pigeonInstance.port)
  }

  func securityProtocol(pigeonApi: PigeonApiWKSecurityOrigin, pigeonInstance: WKSecurityOrigin)
    throws -> String
  {
    return pigeonInstance.protocol
  }
}

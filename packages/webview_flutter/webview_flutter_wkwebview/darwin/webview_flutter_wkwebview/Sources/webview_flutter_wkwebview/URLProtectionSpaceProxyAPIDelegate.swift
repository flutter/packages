// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for `URLProtectionSpace`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class URLProtectionSpaceProxyAPIDelegate: PigeonApiDelegateURLProtectionSpace {
  func host(pigeonApi: PigeonApiURLProtectionSpace, pigeonInstance: URLProtectionSpace) throws
    -> String
  {
    return pigeonInstance.host
  }

  func port(pigeonApi: PigeonApiURLProtectionSpace, pigeonInstance: URLProtectionSpace) throws
    -> Int64
  {
    return Int64(pigeonInstance.port)
  }

  func realm(pigeonApi: PigeonApiURLProtectionSpace, pigeonInstance: URLProtectionSpace) throws
    -> String?
  {
    return pigeonInstance.realm
  }

  func authenticationMethod(
    pigeonApi: PigeonApiURLProtectionSpace, pigeonInstance: URLProtectionSpace
  ) throws -> String? {
    return pigeonInstance.authenticationMethod
  }
}

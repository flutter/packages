// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for `NSError`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class ErrorProxyAPIDelegate: PigeonApiDelegateNSError {
  func code(pigeonApi: PigeonApiNSError, pigeonInstance: NSError) throws -> Int64 {
    return Int64(pigeonInstance.code)
  }

  func domain(pigeonApi: PigeonApiNSError, pigeonInstance: NSError) throws -> String {
    return pigeonInstance.domain
  }

  func userInfo(pigeonApi: PigeonApiNSError, pigeonInstance: NSError) throws -> [String: Any?] {
    return pigeonInstance.userInfo
  }
}

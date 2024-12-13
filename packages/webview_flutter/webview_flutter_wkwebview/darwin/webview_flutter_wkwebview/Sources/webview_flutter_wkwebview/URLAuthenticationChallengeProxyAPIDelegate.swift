// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for `URLAuthenticationChallenge`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class URLAuthenticationChallengeProxyAPIDelegate: PigeonApiDelegateURLAuthenticationChallenge {
  func getProtectionSpace(
    pigeonApi: PigeonApiURLAuthenticationChallenge, pigeonInstance: URLAuthenticationChallenge
  ) throws -> URLProtectionSpace {
    return pigeonInstance.protectionSpace
  }
}
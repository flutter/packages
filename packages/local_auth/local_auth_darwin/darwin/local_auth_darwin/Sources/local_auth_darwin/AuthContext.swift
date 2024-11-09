// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import LocalAuthentication

/// Protocol for the LocalAuthentication API.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
protocol AuthContext {
  var biometryType: LABiometryType { get }
  var localizedFallbackTitle: String? { get set }

  func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
  func evaluatePolicy(
    _ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void)
}

/// Default implementation of AuthContext.
class DefaultAuthContext: AuthContext {
  private let context = LAContext()
}

/// Default implementation of AuthContext. This is a thin wrapper around LAContext.
extension DefaultAuthContext {
  var biometryType: LABiometryType {
    context.biometryType
  }

  var localizedFallbackTitle: String? {
    get { context.localizedFallbackTitle }
    set { context.localizedFallbackTitle = newValue }
  }

  func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
    context.canEvaluatePolicy(policy, error: error)
  }

  func evaluatePolicy(
    _ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void
  ) {
    context.evaluatePolicy(policy, localizedReason: localizedReason, reply: reply)
  }
}

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

extension LAContext: AuthContext {}

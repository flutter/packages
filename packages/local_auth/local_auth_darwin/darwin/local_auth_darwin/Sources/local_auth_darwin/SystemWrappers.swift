// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import LocalAuthentication

#if os(macOS)
  import Cocoa
  import FlutterMacOS
#elseif os(iOS)
  import Flutter
  import UIKit
#endif

/// Protocol for interacting with LAContext instances, abstracted to allow using mock/fake instances
/// in unit tests.
protocol AuthContext {
  /// Direct passthrough to LAContext's localizedFallbackTitle.
  var localizedFallbackTitle: String? { get set }

  /// Direct passthrough to LAContext's biometry type.
  var biometryType: LABiometryType { get }

  /// Direct passthrough to LAContext's canEvaluatePolicy.
  func canEvaluatePolicy(
    _ policy: LAPolicy,
    error: NSErrorPointer
  ) -> Bool

  /// Direct passthrough to LAContext's evaluatePolicy.
  func evaluatePolicy(
    _ policy: LAPolicy,
    localizedReason: String,
    reply: @escaping @Sendable (Bool, Error?) -> Void
  )
}

/// AuthContext is intentionally a direct passthroguh to LAContext.
extension LAContext: AuthContext {}

/// Protocol for a source of AuthContext instances. Used to allow context injection in unit
/// tests.
protocol AuthContextFactory {
  /// Creates a new instance of an implementation of the AuthContext abstraction.
  ///
  /// In production code, this should return an LAContext.
  func createAuthContext() -> AuthContext
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import LocalAuthentication
import Testing

@testable import local_auth_darwin

#if os(iOS)
  import Flutter
#else
  import FlutterMacOS
#endif

// Set a long timeout to avoid flake due to slow CI.
private let timeout: TimeInterval = 30.0

/// A context factory that returns preset contexts.
final class StubAuthContextFactory: AuthContextFactory {
  var contexts: [AuthContext]

  init(contexts: [AuthContext]) {
    self.contexts = contexts
  }

  func createAuthContext() -> AuthContext {
    #expect(self.contexts.count > 0, "Insufficient test contexts provided")
    return self.contexts.removeFirst()
  }
}

final class StubAuthContext: NSObject, AuthContext, @unchecked Sendable {
  /// Whether calls to this stub are expected to be for biometric authentication.
  ///
  /// While this object could be set up to return different values for different policies, in
  /// practice only one policy is needed by any given test, so this just allows asserting that the
  /// code is calling with the intended policy.
  var expectBiometrics = false
  /// The error to return from canEvaluatePolicy.
  var canEvaluateError: NSError?
  /// The value to return from evaluatePolicy.
  var evaluateResponse = false
  /// The error to return from evaluatePolicy.
  var evaluateError: NSError?

  // Overridden as read-write to allow stubbing.
  var biometryType: LABiometryType = .none
  var localizedFallbackTitle: String?

  func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
    #expect(
      policy
        == (expectBiometrics
          ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication)
    )
    if let canEvaluateError = canEvaluateError {
      error?.pointee = canEvaluateError
    }
    return canEvaluateError == nil
  }

  func evaluatePolicy(
    _ policy: LAPolicy, localizedReason: String, reply: @escaping @Sendable (Bool, Error?) -> Void
  ) {
    #expect(
      policy
        == (expectBiometrics
          ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication)
    )
    // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
    // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
    // a background thread.
    DispatchQueue.global(qos: .background).async {
      reply(self.evaluateResponse, self.evaluateError)
    }
  }
}

// MARK: -

@MainActor
struct LocalAuthPluginTests {

  @Test
  func successfullAuthWithBiometrics() async {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.expectBiometrics = true
    stubAuthContext.evaluateResponse = true

    await withCheckedContinuation { continuation in
      plugin.authenticate(
        options: AuthOptions(biometricOnly: true, sticky: false),
        strings: strings
      ) { resultDetails in
        switch resultDetails {
        case .success(let successDetails):
          #expect(successDetails.result == .success)
        case .failure(let error):
          Issue.record("Unexpected error: \(error)")
        }
        continuation.resume()
      }
    }
  }

  @Test
  func successfullAuthWithoutBiometrics() async {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.evaluateResponse = true

    await withCheckedContinuation { continuation in
      plugin.authenticate(
        options: AuthOptions(biometricOnly: false, sticky: false),
        strings: strings
      ) { resultDetails in
        switch resultDetails {
        case .success(let successDetails):
          #expect(successDetails.result == .success)
        case .failure(let error):
          Issue.record("Unexpected error: \(error)")
        }
        continuation.resume()
      }
    }
  }

  @Test(arguments: [
    (LAError.authenticationFailed.rawValue, AuthResult.authenticationFailed, true),
    (LAError.appCancel.rawValue, .appCancel, false),
    (LAError.systemCancel.rawValue, .systemCancel, false),
    (LAError.userCancel.rawValue, .userCancel, false),
    (LAError.userFallback.rawValue, .userFallback, false),
    (99, .unknownError, false),
    (LAError.authenticationFailed.rawValue, .authenticationFailed, false),
  ])
  func failedAuthWithEvaluateError(
    errorCode: Int,
    expectedResult: AuthResult,
    expectBiometrics: Bool
  ) async {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.expectBiometrics = expectBiometrics
    stubAuthContext.evaluateError = NSError(
      domain: (errorCode == 99) ? "error" : "LocalAuthentication",
      code: errorCode
    )

    await withCheckedContinuation { continuation in
      plugin.authenticate(
        options: AuthOptions(biometricOnly: expectBiometrics, sticky: false),
        strings: strings
      ) { resultDetails in
        switch resultDetails {
        case .success(let successDetails):
          #expect(successDetails.result == expectedResult)
        case .failure(let error):
          Issue.record("Unexpected error: \(error)")
        }
        continuation.resume()
      }
    }
  }

  #if os(macOS)
    @available(macOS 11.2, *)
    @Test
    func failedAuthWithErrorBiometricDisconnected() async {
      let stubAuthContext = StubAuthContext()
      let plugin = LocalAuthPlugin(
        contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

      let strings = createAuthStrings()
      stubAuthContext.canEvaluateError = NSError(
        domain: "LocalAuthentication", code: LAError.biometryDisconnected.rawValue)

      await withCheckedContinuation { continuation in
        plugin.authenticate(
          options: AuthOptions(biometricOnly: false, sticky: false),
          strings: strings
        ) { resultDetails in
          switch resultDetails {
          case .success(let successDetails):
            #expect(successDetails.result == .biometryDisconnected)
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
          continuation.resume()
        }
      }
    }

    @available(macOS 11.2, *)
    @Test
    func failedAuthWithErrorBiometricNotPaired() async {
      let stubAuthContext = StubAuthContext()
      let plugin = LocalAuthPlugin(
        contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

      let strings = createAuthStrings()
      stubAuthContext.canEvaluateError = NSError(
        domain: "LocalAuthentication", code: LAError.biometryNotPaired.rawValue)

      await withCheckedContinuation { continuation in
        plugin.authenticate(
          options: AuthOptions(biometricOnly: false, sticky: false),
          strings: strings
        ) { resultDetails in
          switch resultDetails {
          case .success(let successDetails):
            #expect(successDetails.result == .biometryNotPaired)
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
          continuation.resume()
        }
      }
    }

    @available(macOS 12.0, *)
    @Test
    func failedAuthWithErrorBiometricInvalidDimensions() async {
      let stubAuthContext = StubAuthContext()
      let plugin = LocalAuthPlugin(
        contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

      let strings = createAuthStrings()
      stubAuthContext.canEvaluateError = NSError(
        domain: "LocalAuthentication", code: LAError.invalidDimensions.rawValue)

      await withCheckedContinuation { continuation in
        plugin.authenticate(
          options: AuthOptions(biometricOnly: false, sticky: false),
          strings: strings
        ) { resultDetails in
          switch resultDetails {
          case .success(let successDetails):
            #expect(successDetails.result == .invalidDimensions)
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
          continuation.resume()
        }
      }
    }
  #endif

  @Test(arguments: [
    (LAError.biometryLockout, AuthResult.biometryLockout),
    (.biometryNotAvailable, .biometryNotAvailable),
    (.biometryNotEnrolled, .biometryNotEnrolled),
    (.invalidContext, .invalidContext),
    (.notInteractive, .notInteractive),
    (.passcodeNotSet, .passcodeNotSet),
  ])
  func failedAuthWithCanEvaluateError(
    error: LAError.Code,
    expectedResult: AuthResult
  ) async {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.canEvaluateError = NSError(
      domain: "LocalAuthentication", code: error.rawValue)

    await withCheckedContinuation { continuation in
      plugin.authenticate(
        options: AuthOptions(biometricOnly: false, sticky: false),
        strings: strings
      ) { resultDetails in
        switch resultDetails {
        case .success(let successDetails):
          #expect(successDetails.result == expectedResult)
        case .failure(let error):
          Issue.record("Unexpected error: \(error)")
        }
        continuation.resume()
      }
    }
  }

  @Test
  func localizedFallbackTitle() async {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings(localizedFallbackTitle: "a title")
    stubAuthContext.evaluateResponse = true

    await withCheckedContinuation { continuation in
      plugin.authenticate(
        options: AuthOptions(biometricOnly: false, sticky: false),
        strings: strings
      ) { resultDetails in
        #expect(stubAuthContext.localizedFallbackTitle == strings.localizedFallbackTitle)
        continuation.resume()
      }
    }
  }

  @Test
  func skippedLocalizedFallbackTitle() async {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings(localizedFallbackTitle: nil)
    stubAuthContext.evaluateResponse = true

    await withCheckedContinuation { continuation in
      plugin.authenticate(
        options: AuthOptions(biometricOnly: false, sticky: false),
        strings: strings
      ) { resultDetails in
        #expect(stubAuthContext.localizedFallbackTitle == nil)
        continuation.resume()
      }
    }
  }

  @Test
  func deviceSupportsBiometricsWithEnrolledHardware() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true

    let result = try plugin.deviceCanSupportBiometrics()
    #expect(result)
  }

  @Test
  func deviceSupportsBiometricsWithNonEnrolledHardware() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    let result = try plugin.deviceCanSupportBiometrics()
    #expect(result)
  }

  @Test
  func deviceSupportsBiometricsWithBiometryNotAvailable() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotAvailable.rawValue)

    let result = try plugin.deviceCanSupportBiometrics()
    #expect(!result)
  }

  @Test
  func deviceSupportsBiometricsWithBiometryNotAvailableWhenPermissionsDenied() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.biometryType = LABiometryType.touchID
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotAvailable.rawValue)

    let result = try plugin.deviceCanSupportBiometrics()
    #expect(result)
  }

  @Test
  func getEnrolledBiometricsWithFaceID() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.biometryType = .faceID

    let result = try plugin.getEnrolledBiometrics()
    #expect(result.count == 1)
    let first = try #require(result.first)
    #expect(first == .face)
  }

  @Test
  func getEnrolledBiometricsWithTouchID() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.biometryType = .touchID

    let result = try plugin.getEnrolledBiometrics()
    #expect(result.count == 1)
    let first = try #require(result.first)
    #expect(first == .fingerprint)
  }

  @Test
  func getEnrolledBiometricsWithoutEnrolledHardware() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    let result = try plugin.getEnrolledBiometrics()
    #expect(result.isEmpty)
  }

  @Test
  func isDeviceSupportedHandlesSupported() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let result = try plugin.isDeviceSupported()
    #expect(result)
  }

  @Test
  func isDeviceSupportedHandlesUnsupported() throws {
    let stubAuthContext = StubAuthContext()
    // An arbitrary error to cause canEvaluatePolicy to return false.
    stubAuthContext.canEvaluateError = NSError(domain: "error", code: 1)
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let result = try plugin.isDeviceSupported()
    #expect(!result)
  }

  // Creates an AuthStrings with placeholder values.
  func createAuthStrings(localizedFallbackTitle: String? = nil) -> AuthStrings {
    return AuthStrings(
      reason: "a reason",
      cancelButton: "Cancel",
      localizedFallbackTitle: localizedFallbackTitle)
  }

}

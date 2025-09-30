// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import LocalAuthentication
import XCTest

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
    XCTAssert(self.contexts.count > 0, "Insufficient test contexts provided")
    return self.contexts.removeFirst()
  }
}

final class StubAuthContext: NSObject, AuthContext {
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
    XCTAssertEqual(
      policy,
      expectBiometrics ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication)
    if let canEvaluateError = canEvaluateError {
      error?.pointee = canEvaluateError
    }
    return canEvaluateError == nil
  }

  func evaluatePolicy(
    _ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void
  ) {
    XCTAssertEqual(
      policy,
      expectBiometrics ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication)
    // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
    // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
    // a background thread.
    DispatchQueue.global(qos: .background).async {
      reply(self.evaluateResponse, self.evaluateError)
    }
  }
}

// MARK: -

class LocalAuthPluginTests: XCTestCase {

  @MainActor
  func testSuccessfullAuthWithBiometrics() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.expectBiometrics = true
    stubAuthContext.evaluateResponse = true
    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: true, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .success)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testSuccessfullAuthWithoutBiometrics() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.evaluateResponse = true

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .success)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testFailedAuthWithBiometrics() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.expectBiometrics = true
    stubAuthContext.evaluateError = NSError(
      domain: "error", code: LAError.authenticationFailed.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: true, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .authenticationFailed)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testFailedAuthWithErrorAppCancel() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(
      domain: "LocalAuthentication", code: LAError.appCancel.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .appCancel)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testFailedAuthWithErrorSystemCancel() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(
      domain: "LocalAuthentication", code: LAError.systemCancel.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .systemCancel)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testFailedAuthWithErrorUserCancel() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(
      domain: "LocalAuthentication", code: LAError.userCancel.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .userCancel)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testFailedAuthWithErrorUserFallback() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(
      domain: "LocalAuthentication", code: LAError.userFallback.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .userFallback)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  #if os(macOS)
    @available(macOS 11.2, *)
    @MainActor
    func testFailedAuthWithErrorBiometricDisconnected() {
      let stubAuthContext = StubAuthContext()
      let plugin = LocalAuthPlugin(
        contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

      let strings = createAuthStrings()
      stubAuthContext.canEvaluateError = NSError(
        domain: "LocalAuthentication", code: LAError.biometryDisconnected.rawValue)

      let expectation = expectation(description: "Result is called")
      plugin.authenticate(
        options: AuthOptions(biometricOnly: false, sticky: false),
        strings: strings
      ) { resultDetails in
        switch resultDetails {
        case .success(let successDetails):
          XCTAssertEqual(successDetails.result, .biometryDisconnected)
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
        expectation.fulfill()
      }
      self.waitForExpectations(timeout: timeout)
    }

    @available(macOS 11.2, *)
    @MainActor
    func testFailedAuthWithErrorBiometricNotPaired() {
      let stubAuthContext = StubAuthContext()
      let plugin = LocalAuthPlugin(
        contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

      let strings = createAuthStrings()
      stubAuthContext.canEvaluateError = NSError(
        domain: "LocalAuthentication", code: LAError.biometryNotPaired.rawValue)

      let expectation = expectation(description: "Result is called")
      plugin.authenticate(
        options: AuthOptions(biometricOnly: false, sticky: false),
        strings: strings
      ) { resultDetails in
        switch resultDetails {
        case .success(let successDetails):
          XCTAssertEqual(successDetails.result, .biometryNotPaired)
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
        expectation.fulfill()
      }
      self.waitForExpectations(timeout: timeout)
    }

    @available(macOS 12.0, *)
    @MainActor
    func testFailedAuthWithErrorBiometricInvalidDimensions() {
      let stubAuthContext = StubAuthContext()
      let plugin = LocalAuthPlugin(
        contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

      let strings = createAuthStrings()
      stubAuthContext.canEvaluateError = NSError(
        domain: "LocalAuthentication", code: LAError.invalidDimensions.rawValue)

      let expectation = expectation(description: "Result is called")
      plugin.authenticate(
        options: AuthOptions(biometricOnly: false, sticky: false),
        strings: strings
      ) { resultDetails in
        switch resultDetails {
        case .success(let successDetails):
          XCTAssertEqual(successDetails.result, .invalidDimensions)
        case .failure(let error):
          XCTFail("Unexpected error: \(error)")
        }
        expectation.fulfill()
      }
      self.waitForExpectations(timeout: timeout)
    }
  #endif

  @MainActor
  func testFailedAuthWithErrorBiometricLockout() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.canEvaluateError = NSError(
      domain: "LocalAuthentication", code: LAError.biometryLockout.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .biometryLockout)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testFailedAuthWithErrorBiometricNotAvailable() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.canEvaluateError = NSError(
      domain: "LocalAuthentication", code: LAError.biometryNotAvailable.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .biometryNotAvailable)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testFailedAuthWithErrorBiometricNotEnrolled() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.canEvaluateError = NSError(
      domain: "LocalAuthentication", code: LAError.biometryNotEnrolled.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .biometryNotEnrolled)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testFailedAuthWithErrorBiometricInvalidContext() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.canEvaluateError = NSError(
      domain: "LocalAuthentication", code: LAError.invalidContext.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .invalidContext)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testFailedAuthWithErrorBiometricNotInteractive() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.canEvaluateError = NSError(
      domain: "LocalAuthentication", code: LAError.notInteractive.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .notInteractive)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testFailedAuthWithErrorBiometricPasscodeNotSet() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.canEvaluateError = NSError(
      domain: "LocalAuthentication", code: LAError.passcodeNotSet.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .passcodeNotSet)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testFailedWithUnknownErrorCode() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(domain: "error", code: 99)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .unknownError)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testSystemCancelledWithoutStickyAuth() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(domain: "error", code: LAError.systemCancel.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .systemCancel)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testFailedAuthWithoutBiometrics() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(
      domain: "error", code: LAError.authenticationFailed.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .authenticationFailed)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testLocalizedFallbackTitle() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings(localizedFallbackTitle: "a title")
    stubAuthContext.evaluateResponse = true

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      XCTAssertEqual(stubAuthContext.localizedFallbackTitle, strings.localizedFallbackTitle)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testSkippedLocalizedFallbackTitle() {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings(localizedFallbackTitle: nil)
    stubAuthContext.evaluateResponse = true

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false),
      strings: strings
    ) { resultDetails in
      XCTAssertNil(stubAuthContext.localizedFallbackTitle)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testDeviceSupportsBiometrics_withEnrolledHardware() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true

    let result = try plugin.deviceCanSupportBiometrics()
    XCTAssertTrue(result)
  }

  func testDeviceSupportsBiometrics_withNonEnrolledHardware() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    let result = try plugin.deviceCanSupportBiometrics()
    XCTAssertTrue(result)
  }

  func testDeviceSupportsBiometrics_withBiometryNotAvailable() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotAvailable.rawValue)

    let result = try plugin.deviceCanSupportBiometrics()
    XCTAssertFalse(result)
  }

  func testDeviceSupportsBiometrics_withBiometryNotAvailableWhenPermissionsDenied() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.biometryType = LABiometryType.touchID
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotAvailable.rawValue)

    let result = try plugin.deviceCanSupportBiometrics()
    XCTAssertTrue(result)
  }

  func testGetEnrolledBiometricsWithFaceID() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.biometryType = .faceID

    let result = try plugin.getEnrolledBiometrics()
    XCTAssertEqual(result.count, 1)
    XCTAssertEqual(result[0], .face)
  }

  func testGetEnrolledBiometricsWithTouchID() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.biometryType = .touchID

    let result = try plugin.getEnrolledBiometrics()
    XCTAssertEqual(result.count, 1)
    XCTAssertEqual(result[0], .fingerprint)
  }

  func testGetEnrolledBiometricsWithoutEnrolledHardware() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    let result = try plugin.getEnrolledBiometrics()
    XCTAssertTrue(result.isEmpty)
  }

  func testIsDeviceSupportedHandlesSupported() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let result = try plugin.isDeviceSupported()
    XCTAssertTrue(result)
  }

  func testIsDeviceSupportedHandlesUnsupported() throws {
    let stubAuthContext = StubAuthContext()
    // An arbitrary error to cause canEvaluatePolicy to return false.
    stubAuthContext.canEvaluateError = NSError(domain: "error", code: 1)
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let result = try plugin.isDeviceSupported()
    XCTAssertFalse(result)
  }

  // Creates an AuthStrings with placeholder values.
  func createAuthStrings(localizedFallbackTitle: String? = nil) -> AuthStrings {
    return AuthStrings(
      reason: "a reason",
      cancelButton: "Cancel",
      localizedFallbackTitle: localizedFallbackTitle)
  }

}

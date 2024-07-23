// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import local_auth_darwin

// Set a long timeout to avoid flake due to slow CI.
private let timeout: TimeInterval = 30.0

/// A context factory that returns preset contexts.
final class StubAuthContextFactory: NSObject, FLADAuthContextFactory {
  var contexts: [FLADAuthContext]
  init(contexts: [FLADAuthContext]) {
    self.contexts = contexts
  }

  func createAuthContext() -> FLADAuthContext {
    XCTAssert(self.contexts.count > 0, "Insufficient test contexts provided")
    return self.contexts.removeFirst()
  }
}

final class StubAuthContext: NSObject, FLADAuthContext {
  /// Whether calls to this stub are expected to be for biometric authentication.
  ///
  /// While this object could be set up to return different values for different policies, in
  /// practice only one policy is needed by any given test, so this just allows asserting that the
  /// code is calling with the intended policy.
  var expectBiometrics = false
  /// The error to return from canEvaluatePolicy.
  var canEvaluateError: NSError?
  /// The value to return from evaluatePolicy:error:.
  var evaluateResponse = false
  /// The error to return from evaluatePolicy:error:.
  var evaluateError: NSError?

  // Overridden as read-write to allow stubbing.
  var biometryType: LABiometryType = .none
  var localizedFallbackTitle: String?

  func canEvaluatePolicy(_ policy: LAPolicy) throws {
    XCTAssertEqual(
      policy,
      expectBiometrics
        ? LAPolicy.deviceOwnerAuthenticationWithBiometrics
        : LAPolicy.deviceOwnerAuthentication)
    if let canEvaluateError = canEvaluateError {
      throw canEvaluateError
    }
  }

  func evaluatePolicy(
    _ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void
  ) {
    XCTAssertEqual(
      policy,
      expectBiometrics
        ? LAPolicy.deviceOwnerAuthenticationWithBiometrics
        : LAPolicy.deviceOwnerAuthentication)
    // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
    // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
    // a background thread.
    DispatchQueue.global(qos: .background).async {
      reply(self.evaluateResponse, self.evaluateError)
    }
  }
}

// MARK: -

class FLALocalAuthPluginTests: XCTestCase {

  func testSuccessfullAuthWithBiometrics() throws {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.expectBiometrics = true
    stubAuthContext.evaluateResponse = true
    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      with: FLADAuthOptions.make(
        withBiometricOnly: true,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails, error in
      XCTAssertTrue(Thread.isMainThread)
      XCTAssertEqual(resultDetails?.result, FLADAuthResult.success)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testSuccessfullAuthWithoutBiometrics() {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.evaluateResponse = true

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      with: FLADAuthOptions.make(
        withBiometricOnly: false,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails, error in
      XCTAssertTrue(Thread.isMainThread)
      XCTAssertEqual(resultDetails?.result, FLADAuthResult.success)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testFailedAuthWithBiometrics() {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.expectBiometrics = true
    stubAuthContext.evaluateError = NSError(
      domain: "error", code: LAError.authenticationFailed.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      with: FLADAuthOptions.make(
        withBiometricOnly: true,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails, error in
      XCTAssertTrue(Thread.isMainThread)
      // TODO(stuartmorgan): Fix this; this was the pre-Pigeon-migration
      // behavior, so is preserved as part of the migration, but a failed
      // authentication should return failure, not an error that results in a
      // PlatformException.
      XCTAssertEqual(resultDetails?.result, FLADAuthResult.errorNotAvailable)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testFailedWithUnknownErrorCode() {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(domain: "error", code: 99)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      with: FLADAuthOptions.make(
        withBiometricOnly: false,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails, error in
      XCTAssertTrue(Thread.isMainThread)
      XCTAssertEqual(resultDetails?.result, FLADAuthResult.errorNotAvailable)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testSystemCancelledWithoutStickyAuth() {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(domain: "error", code: LAError.systemCancel.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      with: FLADAuthOptions.make(
        withBiometricOnly: false,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails, error in
      XCTAssertTrue(Thread.isMainThread)
      XCTAssertEqual(resultDetails?.result, FLADAuthResult.failure)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testFailedAuthWithoutBiometrics() {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(
      domain: "error", code: LAError.authenticationFailed.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      with: FLADAuthOptions.make(
        withBiometricOnly: false,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails, error in
      XCTAssertTrue(Thread.isMainThread)
      // TODO(stuartmorgan): Fix this; this was the pre-Pigeon-migration
      // behavior, so is preserved as part of the migration, but a failed
      // authentication should return failure, not an error that results in a
      // PlatformException.
      XCTAssertEqual(resultDetails?.result, FLADAuthResult.errorNotAvailable)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testLocalizedFallbackTitle() {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    strings.localizedFallbackTitle = "a title"
    stubAuthContext.evaluateResponse = true

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      with: FLADAuthOptions.make(
        withBiometricOnly: false,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails, error in
      XCTAssertEqual(
        stubAuthContext.localizedFallbackTitle,
        strings.localizedFallbackTitle)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testSkippedLocalizedFallbackTitle() {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    let strings = createAuthStrings()
    strings.localizedFallbackTitle = nil
    stubAuthContext.evaluateResponse = true

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      with: FLADAuthOptions.make(
        withBiometricOnly: false,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails, error in
      XCTAssertNil(stubAuthContext.localizedFallbackTitle)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testDeviceSupportsBiometrics_withEnrolledHardware() {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true

    var error: FlutterError?
    let result = plugin.deviceCanSupportBiometricsWithError(&error)
    XCTAssertTrue(result!.boolValue)
    XCTAssertNil(error)
  }

  func testDeviceSupportsBiometrics_withNonEnrolledHardware() {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    var error: FlutterError?
    let result = plugin.deviceCanSupportBiometricsWithError(&error)
    XCTAssertTrue(result!.boolValue)
    XCTAssertNil(error)
  }

  func testDeviceSupportsBiometrics_withNoBiometricHardware() {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(domain: "error", code: 0)

    var error: FlutterError?
    let result = plugin.deviceCanSupportBiometricsWithError(&error)
    XCTAssertFalse(result!.boolValue)
    XCTAssertNil(error)
  }

  func testGetEnrolledBiometricsWithFaceID() {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.biometryType = .faceID

    var error: FlutterError?
    let result = plugin.getEnrolledBiometricsWithError(&error)
    XCTAssertEqual(result!.count, 1)
    XCTAssertEqual(result![0].value, FLADAuthBiometric.face)
    XCTAssertNil(error)
  }

  func testGetEnrolledBiometricsWithTouchID() {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.biometryType = .touchID

    var error: FlutterError?
    let result = plugin.getEnrolledBiometricsWithError(&error)
    XCTAssertEqual(result!.count, 1)
    XCTAssertEqual(result![0].value, FLADAuthBiometric.fingerprint)
    XCTAssertNil(error)
  }

  func testGetEnrolledBiometricsWithoutEnrolledHardware() {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    var error: FlutterError?
    let result = plugin.getEnrolledBiometricsWithError(&error)
    XCTAssertTrue(result!.isEmpty)
    XCTAssertNil(error)
  }

  func testIsDeviceSupportedHandlesSupported() {
    let stubAuthContext = StubAuthContext()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    var error: FlutterError?
    let result = plugin.isDeviceSupportedWithError(&error)
    XCTAssertTrue(result!.boolValue)
    XCTAssertNil(error)
  }

  func testIsDeviceSupportedHandlesUnsupported() {
    let stubAuthContext = StubAuthContext()
    // An arbitrary error to cause canEvaluatePolicy to return false.
    stubAuthContext.canEvaluateError = NSError(domain: "error", code: 1)
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]))

    var error: FlutterError?
    let result = plugin.isDeviceSupportedWithError(&error)
    XCTAssertFalse(result!.boolValue)
    XCTAssertNil(error)
  }

  // Creates an FLADAuthStrings with placeholder values.
  func createAuthStrings() -> FLADAuthStrings {
    return FLADAuthStrings.make(
      withReason: "a reason", lockOut: "locked out", goToSettingsButton: "Go To Settings",
      goToSettingsDescription: "Settings", cancelButton: "Cancel", localizedFallbackTitle: nil)
  }

}

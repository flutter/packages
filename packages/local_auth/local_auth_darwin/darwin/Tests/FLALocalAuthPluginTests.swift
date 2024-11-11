// Copyright 2013 The Flutter Authors. All rights reserved.
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

 class MockAuthContext: AuthContext {
   var biometryType: LABiometryType
   var expectBiometrics = false
   var canEvaluatePolicyReturnValue: Bool = true
   var canEvaluateError: NSError?
   var evaluatePolicyResult: (Bool, NSError?) = (true, nil)
   var localizedFallbackTitle: String?

   init(biometryType: LABiometryType = .none) {
     self.biometryType = biometryType
   }

   func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
     XCTAssertEqual(
       policy,
       expectBiometrics
         ? LAPolicy.deviceOwnerAuthenticationWithBiometrics
         : LAPolicy.deviceOwnerAuthentication
     )

     if let canEvaluateError = canEvaluateError {
       error?.pointee = canEvaluateError
       return false
     }

     return canEvaluatePolicyReturnValue
   }

   func evaluatePolicy(
     _ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, (any Error)?) -> Void
   ) {
     XCTAssertEqual(
       policy,
       expectBiometrics
         ? LAPolicy.deviceOwnerAuthenticationWithBiometrics
         : LAPolicy.deviceOwnerAuthentication
     )

     DispatchQueue.global(qos: .background).async {
       reply(self.evaluatePolicyResult.0, self.evaluatePolicyResult.1)
     }
   }
 }

final class StubAuthContext: NSObject, AuthContextProtocol {
  var biometryType: LABiometryType = .none
  var expectBiometrics = false
  var evaluateResponse = false
  var evaluateError: NSError?

  func canEvaluatePolicy(_ policy: LAPolicy) throws {
    if let error = evaluateError {
      throw error
    }
  }

  func evaluatePolicy(
    _ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void
  ) {
    DispatchQueue.global(qos: .background).async {
      reply(self.evaluateResponse, self.evaluateError)
    }
  }
}

class MockAlertController: AlertController {
  var showAlertCalled = false
  var showAlertCompletionResult: Bool = false

  func showAlert(
    message: String,
    dismissTitle dismissButtonTitle: String,
    openSettingsTitle openSettingsButtonTitle: String?,
    completion: @escaping (Bool) -> Void
  ) {
    showAlertCalled = true
    completion(showAlertCompletionResult)
  }
}

class FLALocalAuthPluginTests: XCTestCase {
  var plugin: LocalAuthPlugin!
  var mockAuthContext: MockAuthContext!
  var mockAlertController: MockAlertController!

  override func setUp() {
    super.setUp()
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)
  }

  func testSuccessfullAuthWithBiometrics() throws {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    let strings = createAuthStrings()
    mockAuthContext.expectBiometrics = true
    mockAuthContext.evaluatePolicyResult = (true, nil)
    mockAuthContext.canEvaluatePolicyReturnValue = true

    let expectation = expectation(description: "Result is called")

    plugin.authenticate(
      options: AuthOptions(
        biometricOnly: true,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)

      switch resultDetails {
      case .success(let authResultDetails):
        XCTAssertEqual(authResultDetails.result, AuthResult.success)
        XCTAssertNil(authResultDetails.errorMessage)
      case .failure(let error):
        XCTFail("Expected success but got failure with error: \(error)")
      }

      expectation.fulfill()
    }

    self.waitForExpectations(timeout: timeout)
  }

  func testSuccessfullAuthWithoutBiometrics() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()

    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    let strings = createAuthStrings()
    mockAuthContext.evaluatePolicyResult = (true, nil)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(
        biometricOnly: false,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { result in
      XCTAssertTrue(Thread.isMainThread)

      switch result {
      case .success(let resultDetails):
        XCTAssertEqual(resultDetails.result, AuthResult.success)
        XCTAssertNil(resultDetails.errorMessage)
      case .failure(let flutterError):
        XCTFail("Expected success, but got error: \(flutterError)")
      }

      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testFailedAuthWithBiometrics() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    let strings = createAuthStrings()
    mockAuthContext.expectBiometrics = true
    mockAuthContext.evaluatePolicyResult = (
      false, NSError(domain: "error", code: LAError.authenticationFailed.rawValue)
    )

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: true, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      switch resultDetails {
      case .success(let authResultDetails):
        XCTAssertEqual(authResultDetails.result, .errorNotAvailable)
      case .failure:
        XCTFail("Expected success with authenticationFailed result, but got failure.")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testFailedWithUnknownErrorCode() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    let strings = createAuthStrings()
    mockAuthContext.evaluatePolicyResult = (false, NSError(domain: "error", code: 99))

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      switch resultDetails {
      case .success(let authResultDetails):
        XCTAssertEqual(authResultDetails.result, .errorNotAvailable)
      case .failure:
        XCTFail("Expected success with errorNotAvailable result, but got failure.")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testSystemCancelledWithoutStickyAuth() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    let strings = createAuthStrings()
    mockAuthContext.evaluatePolicyResult = (
      false, NSError(domain: "error", code: LAError.systemCancel.rawValue)
    )

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      switch resultDetails {
      case .success(let authResultDetails):
        XCTAssertEqual(authResultDetails.result, .failure)
      case .failure:
        XCTFail("Expected success with errorNotAvailable result, but got failure.")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testFailedAuthWithoutBiometrics() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    let strings = createAuthStrings()
    mockAuthContext.evaluatePolicyResult = (
      false, NSError(domain: "error", code: LAError.authenticationFailed.rawValue)
    )

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      switch resultDetails {
      case .success(let authResultDetails):
        XCTAssertEqual(authResultDetails.result, .errorNotAvailable)
      case .failure:
        XCTFail("Expected success with errorNotAvailable result, but got failure.")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testFailedAuthShowsAlert() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    let strings = createAuthStrings()
    mockAuthContext.evaluatePolicyResult = (
      false, NSError(domain: "error", code: LAError.biometryNotEnrolled.rawValue)
    )

    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: true),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      XCTAssertTrue(self.mockAlertController.showAlertCalled)
    }
  }

  func testLocalizedFallbackTitle() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    var strings = createAuthStrings()
    strings.localizedFallbackTitle = "a title"
    mockAuthContext.evaluatePolicyResult = (true, nil)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { [self] resultDetails in
      XCTAssertEqual(
        self.mockAuthContext.localizedFallbackTitle, strings.localizedFallbackTitle)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testSkippedLocalizedFallbackTitle() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    var strings = createAuthStrings()
    strings.localizedFallbackTitle = nil
    mockAuthContext.evaluatePolicyResult = (true, nil)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { [self] resultDetails in
      XCTAssertNil(self.mockAuthContext.localizedFallbackTitle)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testDeviceSupportsBiometrics_withEnrolledHardware() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    mockAuthContext.expectBiometrics = true

    var error: FlutterError?

    do {
      let result = try plugin.deviceCanSupportBiometrics()
      XCTAssertTrue(result)
    } catch let thrownError as FlutterError {
      error = thrownError
    } catch {
      XCTFail("Unexpected error thrown: \(error)")
    }
    XCTAssertNil(error)
  }

  func testDeviceSupportsBiometrics_withNonEnrolledHardware() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    mockAuthContext.expectBiometrics = true
    mockAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    var error: FlutterError?
    do {
      let result = try plugin.deviceCanSupportBiometrics()
      XCTAssertTrue(result)
    } catch let thrownError as FlutterError {
      error = thrownError
    } catch {
      XCTFail("Unexpected error thrown: \(error)")
    }

    XCTAssertNil(error)

  }

  func testDeviceSupportsBiometrics_withNoBiometricHardware() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    mockAuthContext.expectBiometrics = true
    mockAuthContext.canEvaluateError = NSError(domain: "error", code: 0)

    var error: FlutterError?
    do {
      let result = try plugin.deviceCanSupportBiometrics()
      XCTAssertFalse(result)
    } catch let thrownError as FlutterError {
      error = thrownError
    } catch {
      XCTFail("Unexpected error thrown: \(error)")
    }

    XCTAssertNil(error)
  }

  func testGetEnrolledBiometricsWithFaceID() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    mockAuthContext.expectBiometrics = true
    if #available(iOS 11, macOS 10.15, *) {
      mockAuthContext.biometryType = .faceID
    }

    var error: FlutterError?

    do {
      let result = try plugin.getEnrolledBiometrics()
      XCTAssertEqual(result.count, 1)
      XCTAssertEqual(result[0], .face)
    } catch let thrownError as FlutterError {
      error = thrownError
    } catch {
      XCTFail("Unexpected error thrown: \(error)")
    }

    XCTAssertNil(error)
  }

  func testGetEnrolledBiometricsWithTouchID() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    mockAuthContext.expectBiometrics = true
    mockAuthContext.biometryType = .touchID

    var error: FlutterError?
    do {
      let result = try plugin.getEnrolledBiometrics()
      XCTAssertEqual(result.count, 1)
      XCTAssertEqual(result[0], .fingerprint)
    } catch let thrownError as FlutterError {
      error = thrownError
    } catch {
      XCTFail("Unexpected error thrown: \(error)")
    }

    XCTAssertNil(error)
  }

  func testGetEnrolledBiometricsWithoutEnrolledHardware() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    mockAuthContext.expectBiometrics = true
    mockAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    var error: FlutterError?
    do {
      let result = try plugin.getEnrolledBiometrics()
      XCTAssertTrue(result.isEmpty)
    } catch let thrownError as FlutterError {
      error = thrownError
    } catch {
      XCTFail("Unexpected error thrown: \(error)")
    }

    XCTAssertNil(error)

  }

  func testIsDeviceSupportedHandlesSupported() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    var error: FlutterError?
    do {
      let result = try plugin.isDeviceSupported()
      XCTAssertTrue(result)
    } catch let thrownError as FlutterError {
      error = thrownError
    } catch {
      XCTFail("Unexpected error thrown: \(error)")
    }

    XCTAssertNil(error)
  }

  func testIsDeviceSupportedHandlesUnsupported() {
    mockAuthContext = MockAuthContext()
    mockAlertController = MockAlertController()
    plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)

    mockAuthContext.canEvaluateError = NSError(domain: "error", code: 1)

    var error: FlutterError?

    do {
      let result = try plugin.isDeviceSupported()
      XCTAssertFalse(result)
    } catch let thrownError as FlutterError {
      error = thrownError
    } catch {
      XCTFail("Unexpected error thrown: \(error)")
    }

    XCTAssertNil(error)
  }

  func createAuthStrings() -> AuthStrings {
    return AuthStrings(
      reason: "a reason", lockOut: "locked out", goToSettingsButton: "Go To Settings",
      goToSettingsDescription: "Settings", cancelButton: "Cancel", localizedFallbackTitle: nil
    )
  }
}

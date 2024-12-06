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
  /// Whether calls to this stub are expected to be for biometric authentication.
  ///
  /// While this object could be set up to return different values for different policies, in
  /// practice only one policy is needed by any given test, so this just allows asserting that the
  /// code is calling with the intended policy.
  var expectBiometrics = false

  /// The error to return from the next call to `canEvaluatePolicy`.
  var canEvaluatePolicy: Bool = true

  /// The error to return from the next call to `evaluatePolicy`.
  var canEvaluateError: NSError?

  /// The result to return from the next call to `evaluatePolicy`.
  var evaluatePolicyResult: (Bool, NSError?) = (true, nil)

  // Overridden as read-write to allow stubbing.
  var biometryType: LABiometryType
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

    return canEvaluatePolicy
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

    // evaluatePolicy:localizedReason:reply: calls back on an internal queue, which is not
    // guaranteed to be on the main thread. Ensure that's handled correctly by calling back on
    // a background thread.
    DispatchQueue.global(qos: .background).async {
      reply(self.evaluatePolicyResult.0, self.evaluatePolicyResult.1)
    }
  }
}

class MockAuthContextFactory: AuthContextFactory {
  let authContext: AuthContext

  init(authContext: AuthContext) {
    self.authContext = authContext
  }

  func createAuthContext() -> AuthContext {
    return authContext
  }
}

#if os(macOS)
  final class MockAlert: NSObject, Alert {
    var buttons: [String] = []
    var presentingWindow: NSWindow?

    func addButton(withTitle title: String) -> NSButton {
      buttons.append(title)
      return NSButton()
    }

    func beginSheetModal(for sheetWindow: NSWindow) async -> NSApplication.ModalResponse {
      presentingWindow = sheetWindow
      return .OK
    }
  }

#elseif os(iOS)
final class MockAlertController: NSObject, AlertController {
    var actions: [UIAlertAction] = []
    var presented = false
    var presentingViewController: UIViewController?

    func addAction(_ action: UIAlertAction) {
      actions.append(action)
    }

    func present(
      _ viewControllerToPresent: UIViewController,
      animated flag: Bool,
      completion: (() -> Void)? = nil
    ) {
      presented = true
      self.presentingViewController = viewControllerToPresent
    }
  }
#endif

class MockAlertFactory: AlertFactory {
  #if os(macOS)
    var alert: MockAlert = MockAlert()
  #else
    var alertController: MockAlertController = MockAlertController()
  #endif

  #if os(macOS)
    var createdAlert: MockAlert?

    func createAlert() -> Alert {
      self.createdAlert = alert
      return alert
    }
  #elseif os(iOS)
    func createAlertController(
      title: String?, message: String?, preferredStyle: UIAlertController.Style
    ) -> AlertController {
      return alertController
    }
  #endif
}

class MockViewProvider: ViewProvider {
  #if os(macOS)
    var view: NSView
    var window: NSWindow
    override init() {
      self.window = NSWindow()
      self.view = NSView()
      self.window.contentView = self.view
    }
  #endif
}

class FLALocalAuthPluginTests: XCTestCase {
  func testSuccessfullAuthWithBiometrics() throws {
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

    let strings = createAuthStrings()
    mockAuthContext.expectBiometrics = true
    mockAuthContext.evaluatePolicyResult = (true, nil)
    mockAuthContext.canEvaluatePolicy = true

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
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

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
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

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
      // TODO(stuartmorgan): Fix this; this was the pre-Pigeon-migration
      // behavior, so is preserved as part of the migration, but a failed
      // authentication should return failure, not an error that results in a
      // PlatformException.
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
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

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
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

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
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

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
      // TODO(stuartmorgan): Fix this; this was the pre-Pigeon-migration
      // behavior, so is preserved as part of the migration, but a failed
      // authentication should return failure, not an error that results in a
      // PlatformException.
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
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

    let strings = createAuthStrings()
    mockAuthContext.evaluatePolicyResult = (
      false, NSError(domain: "error", code: LAError.biometryNotEnrolled.rawValue)
    )

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: true),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      // TODO(stuartmorgan): Add a wrapper around UIAction to allow accessing the handler, so
      // that the test can trigger the callback on iOS as well, and then unfork this.
      expectation.fulfill()
    }
    #if os(macOS)
      self.waitForExpectations(timeout: timeout)
      XCTAssertEqual(mockAlertFactory.alert.presentingWindow, viewProvider.view.window)
    #else
      XCTAssertTrue(mockAlertFactory.alertController.presented)
      XCTAssertEqual(mockAlertFactory.alertController.actions.count, 2)
    #endif
    self.waitForExpectations(timeout: timeout)
  }

  func testLocalizedFallbackTitle() {
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

    var strings = createAuthStrings()
    strings.localizedFallbackTitle = "a title"
    mockAuthContext.evaluatePolicyResult = (true, nil)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertEqual(mockAuthContext.localizedFallbackTitle, strings.localizedFallbackTitle)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testSkippedLocalizedFallbackTitle() {
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

    var strings = createAuthStrings()
    strings.localizedFallbackTitle = nil
    mockAuthContext.evaluatePolicyResult = (true, nil)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertNil(mockAuthContext.localizedFallbackTitle)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testDeviceSupportsBiometrics_withEnrolledHardware() {
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

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
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

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
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

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
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

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
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

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
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

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
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

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
    let mockAuthContext = MockAuthContext()
    let mockAuthContextFactory = MockAuthContextFactory(authContext: mockAuthContext)
    let mockAlertFactory = MockAlertFactory()
    let mockViewProvider = MockViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: mockAuthContextFactory, alertFactory: mockAlertFactory,
      viewProvider: mockViewProvider)

    // An arbitrary error to cause canEvaluatePolicy to return false.
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

  // Creates an AuthStrings with placeholder values.
  func createAuthStrings() -> AuthStrings {
    return AuthStrings(
      reason: "a reason", lockOut: "locked out", goToSettingsButton: "Go To Settings",
      goToSettingsDescription: "Settings", cancelButton: "Cancel", localizedFallbackTitle: nil
    )
  }
}

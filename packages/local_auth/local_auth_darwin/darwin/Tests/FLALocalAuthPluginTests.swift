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

/// A context factory that returns preset contexts.
final class StubAuthContextFactory: NSObject, AuthContextFactory {

  var contexts: [AuthContext]
  init(contexts: [AuthContext]) {
    self.contexts = contexts
  }

  func createAuthContext() -> AuthContext {
    XCTAssert(self.contexts.count > 0, "Insufficient test contexts provided")
    return self.contexts.removeFirst()
  }
}

final class StubViewProvider: NSObject, ViewProvider {
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

#if os(macOS)
  final class TestAlert: NSObject, Alert {
    var messageText: String = ""
    var buttons: [String] = []
    var presentingWindow: NSWindow?

    func addButton(withTitle title: String) -> NSButton {
      buttons.append(title)
      return NSButton()  // The return value is not used by the plugin.
    }

    func beginSheetModal(for sheetWindow: NSWindow) async -> NSApplication.ModalResponse {
      presentingWindow = sheetWindow
      return NSApplication.ModalResponse.OK
    }
  }
#else
  final class TestAlertController: NSObject, AlertController {
    var actions: [UIAlertAction] = []
    var presented = false
    var presentingViewController: UIViewController?

    func addAction(_ action: UIAlertAction) {
      actions.append(action)
    }

    func present(
      _ presentingViewController: UIViewController, animated flag: Bool,
      completion: (() -> Void)? = nil
    ) {
      presented = true
      self.presentingViewController = presentingViewController
    }
  }
#endif

final class StubAlertFactory: NSObject, AlertFactory {
  #if os(macOS)
    var alert: TestAlert = TestAlert()
  #else
    var alertController: TestAlertController = TestAlertController()
  #endif

  #if os(macOS)
    func createAlert() -> Alert {
      return self.alert
    }
  #else
    func createAlertController(
      title: String?, message: String?, preferredStyle: UIAlertController.Style
    ) -> AlertController {
      return self.alertController
    }
  #endif
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
  /// The value to return from evaluatePolicy:error:.
  var evaluateResponse = false
  /// The error to return from evaluatePolicy:error:.
  var evaluateError: NSError?

  // Overridden as read-write to allow stubbing.
  var biometryType: LABiometryType = .none
  var localizedFallbackTitle: String?

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

    return evaluateResponse
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
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    let strings = createAuthStrings()
    stubAuthContext.expectBiometrics = true
    stubAuthContext.evaluateResponse = true

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
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    let strings = createAuthStrings()
    stubAuthContext.evaluateResponse = true

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
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    let strings = createAuthStrings()
    stubAuthContext.expectBiometrics = true
    stubAuthContext.evaluateError = NSError(
      domain: "error", code: LAError.authenticationFailed.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: true, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      switch resultDetails {
      case .success(let authResultDetails):
        XCTAssertEqual(authResultDetails.result, .failure)
      case .failure:
        XCTFail("Expected success with failure result, but got authenticationFailed.")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testFailedWithUnknownErrorCode() {
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(domain: "error", code: 99)

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
        XCTFail("Expected success with failure result, but got errorNotAvailable.")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testSystemCancelledWithoutStickyAuth() {
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(domain: "error", code: LAError.systemCancel.rawValue)

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
        XCTFail("Expected success with failure result, but got errorNotAvailable.")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testFailedAuthWithoutBiometrics() {
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(
      domain: "error", code: LAError.authenticationFailed.rawValue)

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
        XCTFail("Expected success with failure result, but got errorNotAvailable.")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testFailedAuthShowsAlert() {
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    let strings = createAuthStrings()
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    #if os(macOS)
      let expectation = expectation(description: "Result is called")
    #endif
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: true),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      // TODO(stuartmorgan): Add a wrapper around UIAction to allow accessing the handler, so
      // that the test can trigger the callback on iOS as well, and then unfork this.
      #if os(macOS)
        expectation.fulfill()
      #endif
    }

    #if os(macOS)
      self.waitForExpectations(timeout: timeout)
      XCTAssertEqual(stubAlertFactory.alert.presentingWindow, viewProvider.view.window)
    #else
      XCTAssertTrue(stubAlertFactory.alertController.presented)
      XCTAssertEqual(stubAlertFactory.alertController.actions.count, 2)
    #endif
  }

  func testLocalizedFallbackTitle() {
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    var strings = createAuthStrings()
    strings.localizedFallbackTitle = "a title"
    stubAuthContext.evaluateResponse = true

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertEqual(stubAuthContext.localizedFallbackTitle, strings.localizedFallbackTitle)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testSkippedLocalizedFallbackTitle() {
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    var strings = createAuthStrings()
    strings.localizedFallbackTitle = nil
    stubAuthContext.evaluateResponse = true

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertNil(stubAuthContext.localizedFallbackTitle)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testDeviceSupportsBiometrics_withEnrolledHardware() {
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.evaluateResponse = true

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
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
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
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(domain: "error", code: 0)

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
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.evaluateResponse = true
    if #available(iOS 11, macOS 10.15, *) {
      stubAuthContext.biometryType = .faceID
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
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.evaluateResponse = true
    stubAuthContext.biometryType = .touchID

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
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
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
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    stubAuthContext.evaluateResponse = true

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
    let stubAuthContext = StubAuthContext()
    let stubAuthContextFactory = StubAuthContextFactory(contexts: [stubAuthContext])
    let stubAlertFactory = StubAlertFactory()
    let stubViewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      authContextFactory: stubAuthContextFactory, alertFactory: stubAlertFactory,
      viewProvider: stubViewProvider)

    // An arbitrary error to cause canEvaluatePolicy to return false.
    stubAuthContext.canEvaluateError = NSError(domain: "error", code: 1)

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

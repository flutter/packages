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

final class StubViewProvider: ViewProvider {
  #if os(macOS)
    var view: NSView?
    var window: NSWindow
    init() {
      self.window = NSWindow()
      self.view = NSView()
      self.window.contentView = self.view
    }
  #endif
}

#if os(macOS)
  final class TestAlert: AuthAlert {
    var messageText: String = ""
    var buttons: [String] = []
    var presentingWindow: NSWindow?

    func addButton(withTitle title: String) -> NSButton {
      buttons.append(title)
      return NSButton()  // The return value is not used by the plugin.
    }

    func beginSheetModal(
      for sheetWindow: NSWindow,
      completionHandler handler: ((NSApplication.ModalResponse) -> Void)? = nil
    ) {
      presentingWindow = sheetWindow
      handler?(NSApplication.ModalResponse.OK)
    }

    func runModal() -> NSApplication.ModalResponse {
      return NSApplication.ModalResponse.OK
    }
  }
#else
  final class TestAlertController: AuthAlertController {
    var actions: [UIAlertAction] = []
    var presented = false
    var presentingViewController: UIViewController?
    // The handler to trigger when present is called, to simulate an action selection.
    var onPresentActionHandler: ((UIAlertAction) -> Void)?

    func addAction(_ action: UIAlertAction) {
      actions.append(action)
    }

    func present(
      on presentingViewController: UIViewController, animated: Bool,
      completion: (() -> Void)? = nil
    ) {
      presented = true
      self.presentingViewController = presentingViewController
      // The plugin does not use the passed action, so just send a dummy value. If that ever
      // changes, the test will need to track the action along with the handler.
      onPresentActionHandler?(UIAlertAction())
    }
  }

#endif

final class StubAlertFactory: AuthAlertFactory {
  #if os(macOS)
    var alert: TestAlert = TestAlert()
  #else
    var alertController: TestAlertController = TestAlertController()
  #endif

  #if os(macOS)
    func createAlert() -> AuthAlert {
      return self.alert
    }
  #else
    func createAlertController(
      title: String?, message: String?, preferredStyle: UIAlertController.Style
    ) -> AuthAlertController {
      return self.alertController
    }

    func createAlertAction(
      title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?
    ) -> UIAlertAction {
      // Configure the fake controller to trigger this button when presented. This is currently an
      // arbitrary button, just to ensure that the completion handler is triggered so that the
      // test can wait for the full cycle of async calls to complete.
      alertController.onPresentActionHandler = handler
      return UIAlertAction(title: title, style: style, handler: handler)
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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider
    )

    let strings = createAuthStrings()
    stubAuthContext.expectBiometrics = true
    stubAuthContext.evaluateResponse = true
    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: true, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()

    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.evaluateResponse = true

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

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
      // TODO(stuartmorgan): Fix this; this was the pre-Pigeon-migration
      // behavior, so is preserved as part of the migration, but a failed
      // authentication should return failure, not an error that results in a
      // PlatformException.
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .errorNotAvailable)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testFailedAuthWithErrorUserCancelled() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(
      domain: "LocalAuthentication", code: LAError.userCancel.rawValue)

    let expectation = expectation(description: "Result is called for user cancel")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .errorUserCancelled)
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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(
      domain: "LocalAuthentication", code: LAError.userFallback.rawValue)

    let expectation = expectation(description: "Result is called for user fallback")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .errorUserFallback)
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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.canEvaluateError = NSError(
      domain: "LocalAuthentication", code: LAError.biometryNotAvailable.rawValue)

    let expectation = expectation(description: "Result is called for biometric not available")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .errorBiometricNotAvailable)
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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(domain: "error", code: 99)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .errorNotAvailable)
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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(domain: "error", code: LAError.systemCancel.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .failure)
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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(
      domain: "error", code: LAError.authenticationFailed.rawValue)

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
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, .errorNotAvailable)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  @MainActor
  func testFailedAuthShowsAlert() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(biometricOnly: false, sticky: false, useErrorDialogs: true),
      strings: strings
    ) { resultDetails in
      expectation.fulfill()
    }

    self.waitForExpectations(timeout: timeout)
    #if os(macOS)
      XCTAssertEqual(alertFactory.alert.presentingWindow, viewProvider.view?.window)
    #else
      XCTAssertTrue(alertFactory.alertController.presented)
      XCTAssertEqual(alertFactory.alertController.actions.count, 2)
    #endif
  }

  @MainActor
  func testLocalizedFallbackTitle() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    let strings = createAuthStrings(localizedFallbackTitle: "a title")
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

  @MainActor
  func testSkippedLocalizedFallbackTitle() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    let strings = createAuthStrings(localizedFallbackTitle: nil)
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

  func testDeviceSupportsBiometrics_withEnrolledHardware() throws {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true

    let result = try plugin.deviceCanSupportBiometrics()
    XCTAssertTrue(result)
  }

  func testDeviceSupportsBiometrics_withNonEnrolledHardware() throws {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    let result = try plugin.deviceCanSupportBiometrics()
    XCTAssertTrue(result)
  }

  func testDeviceSupportsBiometrics_withBiometryNotAvailable() throws {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotAvailable.rawValue)

    let result = try plugin.deviceCanSupportBiometrics()
    XCTAssertFalse(result)
  }

  func testDeviceSupportsBiometrics_withBiometryNotAvailableWhenPermissionsDenied() throws {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.biometryType = LABiometryType.touchID
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotAvailable.rawValue)

    let result = try plugin.deviceCanSupportBiometrics()
    XCTAssertTrue(result)
  }

  func testGetEnrolledBiometricsWithFaceID() throws {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    if #available(iOS 11, macOS 10.15, *) {
      stubAuthContext.biometryType = .faceID
    }

    let result = try plugin.getEnrolledBiometrics()
    XCTAssertEqual(result.count, 1)
    XCTAssertEqual(result[0], .face)
  }

  func testGetEnrolledBiometricsWithTouchID() throws {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.biometryType = .touchID

    let result = try plugin.getEnrolledBiometrics()
    XCTAssertEqual(result.count, 1)
    XCTAssertEqual(result[0], .fingerprint)
  }

  func testGetEnrolledBiometricsWithoutEnrolledHardware() throws {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    let result = try plugin.getEnrolledBiometrics()
    XCTAssertTrue(result.isEmpty)
  }

  func testIsDeviceSupportedHandlesSupported() throws {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    let result = try plugin.isDeviceSupported()
    XCTAssertTrue(result)
  }

  func testIsDeviceSupportedHandlesUnsupported() throws {
    let stubAuthContext = StubAuthContext()
    // An arbitrary error to cause canEvaluatePolicy to return false.
    stubAuthContext.canEvaluateError = NSError(domain: "error", code: 1)
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory,
      viewProvider: viewProvider)

    let result = try plugin.isDeviceSupported()
    XCTAssertFalse(result)
  }

  // Creates an AuthStrings with placeholder values.
  func createAuthStrings(localizedFallbackTitle: String? = nil) -> AuthStrings {
    return AuthStrings(
      reason: "a reason",
      lockOut: "locked out",
      goToSettingsButton: "Go To Settings",
      goToSettingsDescription: "Settings",
      cancelButton: "Cancel",
      localizedFallbackTitle: localizedFallbackTitle)
  }

}

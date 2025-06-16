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
    var view: NSView?
    var window: NSWindow
    override init() {
      self.window = NSWindow()
      self.view = NSView()
      self.window.contentView = self.view
    }
  #endif
}

#if os(macOS)
  final class TestAlert: NSObject, AuthAlert {
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
      if let handler = handler {
        handler(NSApplication.ModalResponse.OK)
      }
    }

    func runModal() -> NSApplication.ModalResponse {
      return NSApplication.ModalResponse.OK
    }
  }
#else
  final class TestAlertController: NSObject, AuthAlertController {
    var actions: [UIAlertAction] = []
    var presented = false
    var presentingViewController: UIViewController?

    func addAction(_ action: UIAlertAction) {
      actions.append(action)
    }

    func present(
      on presentingViewController: UIViewController, animated: Bool,
      completion: (() -> Void)? = nil
    ) {
      presented = true
      self.presentingViewController = presentingViewController
    }
  }
#endif

final class StubAlertFactory: NSObject, AuthAlertFactory {
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
      expectBiometrics
        ? LAPolicy.deviceOwnerAuthenticationWithBiometrics
        : LAPolicy.deviceOwnerAuthentication)
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

class LocalAuthPluginTests: XCTestCase {

  @MainActor
  func testSuccessfullAuthWithBiometrics() throws {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider
    )

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
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, AuthResult.success)
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
      alertFactory: alertFactory, viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.evaluateResponse = true

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(
        biometricOnly: false,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, AuthResult.success)
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
      alertFactory: alertFactory, viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.expectBiometrics = true
    stubAuthContext.evaluateError = NSError(
      domain: "error", code: LAError.authenticationFailed.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(
        biometricOnly: true,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      // TODO(stuartmorgan): Fix this; this was the pre-Pigeon-migration
      // behavior, so is preserved as part of the migration, but a failed
      // authentication should return failure, not an error that results in a
      // PlatformException.
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, AuthResult.errorNotAvailable)
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
      alertFactory: alertFactory, viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(domain: "error", code: 99)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(
        biometricOnly: false,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, AuthResult.errorNotAvailable)
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
      alertFactory: alertFactory, viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(domain: "error", code: LAError.systemCancel.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(
        biometricOnly: false,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, AuthResult.failure)
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
      alertFactory: alertFactory, viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.evaluateError = NSError(
      domain: "error", code: LAError.authenticationFailed.rawValue)

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(
        biometricOnly: false,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertTrue(Thread.isMainThread)
      // TODO(stuartmorgan): Fix this; this was the pre-Pigeon-migration
      // behavior, so is preserved as part of the migration, but a failed
      // authentication should return failure, not an error that results in a
      // PlatformException.
      switch resultDetails {
      case .success(let successDetails):
        XCTAssertEqual(successDetails.result, AuthResult.errorNotAvailable)
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
      alertFactory: alertFactory, viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    #if os(macOS)
      let expectation = expectation(description: "Result is called")
    #endif
    plugin.authenticate(
      options: AuthOptions(
        biometricOnly: false,
        sticky: false,
        useErrorDialogs: true),
      strings: strings
    ) { resultDetails in
      // TODO(stuartmorgan): Add a wrapper around UIAction to allow accessing the handler, so
      // that the test can trigger the callback on iOS as well, and then unfork this.
      #if os(macOS)
        expectation.fulfill()
      #endif
    }
    #if os(macOS)
      self.waitForExpectations(timeout: timeout)
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
      alertFactory: alertFactory, viewProvider: viewProvider)

    let strings = createAuthStrings(localizedFallbackTitle: "a title")
    stubAuthContext.evaluateResponse = true

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(
        biometricOnly: false,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertEqual(
        stubAuthContext.localizedFallbackTitle,
        strings.localizedFallbackTitle)
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
      alertFactory: alertFactory, viewProvider: viewProvider)

    let strings = createAuthStrings(localizedFallbackTitle: nil)
    stubAuthContext.evaluateResponse = true

    let expectation = expectation(description: "Result is called")
    plugin.authenticate(
      options: AuthOptions(
        biometricOnly: false,
        sticky: false,
        useErrorDialogs: false),
      strings: strings
    ) { resultDetails in
      XCTAssertNil(stubAuthContext.localizedFallbackTitle)
      expectation.fulfill()
    }
    self.waitForExpectations(timeout: timeout)
  }

  func testDeviceSupportsBiometrics_withEnrolledHardware() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true

    do {
      let result = try plugin.deviceCanSupportBiometrics()
      XCTAssertTrue(result)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testDeviceSupportsBiometrics_withNonEnrolledHardware() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    do {
      let result = try plugin.deviceCanSupportBiometrics()
      XCTAssertTrue(result)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testDeviceSupportsBiometrics_withBiometryNotAvailable() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotAvailable.rawValue)

    do {
      let result = try plugin.deviceCanSupportBiometrics()
      XCTAssertFalse(result)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testDeviceSupportsBiometrics_withBiometryNotAvailableWhenPermissionsDenied() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.biometryType = LABiometryType.touchID
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotAvailable.rawValue)

    do {
      let result = try plugin.deviceCanSupportBiometrics()
      XCTAssertTrue(result)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testGetEnrolledBiometricsWithFaceID() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    if #available(iOS 11, macOS 10.15, *) {
      stubAuthContext.biometryType = .faceID
    }

    do {
      let result = try plugin.getEnrolledBiometrics()
      XCTAssertEqual(result.count, 1)
      XCTAssertEqual(result[0], AuthBiometric.face)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testGetEnrolledBiometricsWithTouchID() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.biometryType = .touchID

    do {
      let result = try plugin.getEnrolledBiometrics()
      XCTAssertEqual(result.count, 1)
      XCTAssertEqual(result[0], AuthBiometric.fingerprint)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testGetEnrolledBiometricsWithoutEnrolledHardware() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    do {
      let result = try plugin.getEnrolledBiometrics()
      XCTAssertTrue(result.isEmpty)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testIsDeviceSupportedHandlesSupported() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    do {
      let result = try plugin.isDeviceSupported()
      XCTAssertTrue(result)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testIsDeviceSupportedHandlesUnsupported() {
    let stubAuthContext = StubAuthContext()
    // An arbitrary error to cause canEvaluatePolicy to return false.
    stubAuthContext.canEvaluateError = NSError(domain: "error", code: 1)
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = LocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    do {
      let result = try plugin.isDeviceSupported()
      XCTAssertFalse(result)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  // Creates an AuthStrings with placeholder values.
  func createAuthStrings(localizedFallbackTitle: String? = nil) -> AuthStrings {
    return AuthStrings(
      reason: "a reason", lockOut: "locked out", goToSettingsButton: "Go To Settings",
      goToSettingsDescription: "Settings", cancelButton: "Cancel",
      localizedFallbackTitle: localizedFallbackTitle)
  }

}

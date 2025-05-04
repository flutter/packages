// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

final class StubViewProvider: NSObject, FLAViewProvider {
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
  final class TestAlert: NSObject, FLANSAlert {
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
  final class TestAlertController: NSObject, FLAUIAlertController {
    var actions: [UIAlertAction] = []
    var presented = false
    var presentingViewController: UIViewController?

    func add(_ action: UIAlertAction) {
      actions.append(action)
    }

    func present(
      on presentingViewController: UIViewController, animated flag: Bool,
      completion: (() -> Void)? = nil
    ) {
      presented = true
      self.presentingViewController = presentingViewController
    }
  }
#endif

final class StubAlertFactory: NSObject, FLADAlertFactory {
  #if os(macOS)
    var alert: TestAlert = TestAlert()
  #else
    var alertController: TestAlertController = TestAlertController()
  #endif

  #if os(macOS)
    func createAlert() -> FLANSAlert {
      return self.alert
    }
  #else
    func createAlertController(
      withTitle title: String?, message: String?, preferredStyle: UIAlertController.Style
    ) -> FLAUIAlertController {
      return self.alertController
    }
  #endif
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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider
    )

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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()

    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

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

  func testFailedAuthShowsAlert() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    let strings = createAuthStrings()
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    #if os(macOS)
      let expectation = expectation(description: "Result is called")
    #endif
    plugin.authenticate(
      with: FLADAuthOptions.make(
        withBiometricOnly: false,
        sticky: false,
        useErrorDialogs: true),
      strings: strings
    ) { resultDetails, error in
      // TODO(stuartmorgan): Add a wrapper around UIAction to allow accessing the handler, so
      // that the test can trigger the callback on iOS as well, and then unfork this.
      #if os(macOS)
        expectation.fulfill()
      #endif
    }
    #if os(macOS)
      self.waitForExpectations(timeout: timeout)
      XCTAssertEqual(alertFactory.alert.presentingWindow, viewProvider.view.window)
    #else
      XCTAssertTrue(alertFactory.alertController.presented)
      XCTAssertEqual(alertFactory.alertController.actions.count, 2)
    #endif
  }

  func testLocalizedFallbackTitle() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true

    var error: FlutterError?
    let result = plugin.deviceCanSupportBiometricsWithError(&error)
    XCTAssertTrue(result!.boolValue)
    XCTAssertNil(error)
  }

  func testDeviceSupportsBiometrics_withNonEnrolledHardware() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotEnrolled.rawValue)

    var error: FlutterError?
    let result = plugin.deviceCanSupportBiometricsWithError(&error)
    XCTAssertTrue(result!.boolValue)
    XCTAssertNil(error)
  }

  func testDeviceSupportsBiometrics_withBiometryNotAvailable() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotAvailable.rawValue)

    var error: FlutterError?
    let result = plugin.deviceCanSupportBiometricsWithError(&error)
    XCTAssertFalse(result!.boolValue)
    XCTAssertNil(error)
  }

  func testDeviceSupportsBiometrics_withBiometryNotAvailableWhenPermissionsDenied() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    stubAuthContext.biometryType = LABiometryType.touchID
    stubAuthContext.canEvaluateError = NSError(
      domain: "error", code: LAError.biometryNotAvailable.rawValue)

    var error: FlutterError?
    let result = plugin.deviceCanSupportBiometricsWithError(&error)
    XCTAssertTrue(result!.boolValue)
    XCTAssertNil(error)
  }

  func testGetEnrolledBiometricsWithFaceID() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    stubAuthContext.expectBiometrics = true
    if #available(iOS 11, macOS 10.15, *) {
      stubAuthContext.biometryType = .faceID

    }

    var error: FlutterError?
    let result = plugin.getEnrolledBiometricsWithError(&error)
    XCTAssertEqual(result!.count, 1)
    XCTAssertEqual(result![0].value, FLADAuthBiometric.face)
    XCTAssertNil(error)
  }

  func testGetEnrolledBiometricsWithTouchID() {
    let stubAuthContext = StubAuthContext()
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

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
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

    var error: FlutterError?
    let result = plugin.isDeviceSupportedWithError(&error)
    XCTAssertTrue(result!.boolValue)
    XCTAssertNil(error)
  }

  func testIsDeviceSupportedHandlesUnsupported() {
    let stubAuthContext = StubAuthContext()
    // An arbitrary error to cause canEvaluatePolicy to return false.
    stubAuthContext.canEvaluateError = NSError(domain: "error", code: 1)
    let alertFactory = StubAlertFactory()
    let viewProvider = StubViewProvider()
    let plugin = FLALocalAuthPlugin(
      contextFactory: StubAuthContextFactory(contexts: [stubAuthContext]),
      alertFactory: alertFactory, viewProvider: viewProvider)

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

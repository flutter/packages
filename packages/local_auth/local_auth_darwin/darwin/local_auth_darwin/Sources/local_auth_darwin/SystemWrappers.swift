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

// MARK: -

#if os(macOS)
  /// Protocol for interacting with NSAlert instances, abstracted to allow using mock/fake instances
  /// in unit tests.
  protocol AuthAlert {
    /// Direct passthrough to NSAlert's messageText.
    @MainActor
    var messageText: String { get set }

    /// Direct passthrough to NSAlert's addButton.
    @MainActor
    @discardableResult func addButton(withTitle title: String) -> NSButton

    /// Direct passthrough to NSAlert's beginSheetModal.
    @MainActor
    func beginSheetModal(
      for sheetWindow: NSWindow,
      completionHandler handler: ((NSApplication.ModalResponse) -> Void)?
    )

    /// Direct passthrough to NSAlert's runModal.
    @MainActor
    @discardableResult func runModal() -> NSApplication.ModalResponse
  }

  /// AuthAlert is intentionally a direct passthroguh to NSAlert.
  extension NSAlert: AuthAlert {}
#endif  // macOS

#if os(iOS)
  /// Protocol for interacting with UIAlertController instances, abstracted to allow using mock/fake
  /// instances in unit tests.
  protocol AuthAlertController {
    /// Direct passthrough to UIAlertController's addAction.
    @MainActor
    func addAction(_ action: UIAlertAction)

    /// Reversed wrapper of presentViewController:... since the protocol can't be passed to the real
    /// method.
    @MainActor
    func present(
      on presentingViewController: UIViewController,
      animated: Bool,
      completion: (() -> Void)?
    )
  }
#endif  // iOS

/// Protocol for a factory that wraps standard UIAlertController and NSAlert creation for
/// iOS and macOS. Used to allow context injection in unit tests.
protocol AuthAlertFactory {
  #if os(macOS)
    /// Creates a new instance of an implementation of the AuthAlert abstraction.
    ///
    /// In production code, this should return an NSAlert.
    func createAlert() -> AuthAlert
  #elseif os(iOS)
    /// Creates a new instance of an implementation of the AuthAlertController abstraction.
    ///
    /// In production code, this should return something as close as possible to a direct passthrough
    /// to UIAlertController.
    func createAlertController(
      title: String?,
      message: String?,
      preferredStyle: UIAlertController.Style
    ) -> AuthAlertController

    /// Creates a new instance of a UIAlertAction.
    ///
    /// Abstracted to allow unit tests to capture the handler, since UIAlertAction does not provide
    /// a getter for the handler.
    func createAlertAction(
      title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?
    ) -> UIAlertAction
  #endif
}

/// Protocol for a provider of the view containing the Flutter content, abstracted to allow using
/// mock/fake instances in unit tests.
protocol ViewProvider {
  #if os(macOS)
    /// Returns the view displaying the Flutter content, if any.
    var view: NSView? { get }
  #elseif os(iOS)
    // TODO(stuartmorgan): Add a view accessor once https://github.com/flutter/flutter/issues/104117
    // is resolved, and use that in 'showAlertWithMessage:...'.
  #endif
}

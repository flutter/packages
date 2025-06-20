// Copyright 2013 The Flutter Authors. All rights reserved.
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
  var localizedFallbackTitle: String? { get set }
  var biometryType: LABiometryType { get }
  func canEvaluatePolicy(
    _ policy: LAPolicy,
    error: NSErrorPointer
  ) -> Bool
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
  func createAuthContext() -> AuthContext
}

// MARK: -

#if os(macOS)
  /// Protocol for interacting with NSAlert instances, abstracted to allow using mock/fake instances
  /// in unit tests.
  protocol AuthAlert {
    @MainActor
    var messageText: String { get set }
    @MainActor
    @discardableResult func addButton(withTitle title: String) -> NSButton
    @MainActor
    func beginSheetModal(
      for sheetWindow: NSWindow,
      completionHandler handler: ((NSApplication.ModalResponse) -> Void)?
    )
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
    @MainActor
    func addAction(_ action: UIAlertAction)
    // Reversed wrapper of presentViewController:... since the protocol can't be passed to the real
    // method.
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
    func createAlert() -> AuthAlert
  #elseif os(iOS)
    func createAlertController(
      title: String?,
      message: String?,
      preferredStyle: UIAlertController.Style
    ) -> AuthAlertController
    func createAlertAction(
      title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?
    ) -> UIAlertAction
  #endif
}

/// Protocol for a provider of the view containing the Flutter content, abstracted to allow using
/// mock/fake instances in unit tests.
protocol ViewProvider {
  #if os(macOS)
    var view: NSView? { get }
  #elseif os(iOS)
    // TODO(stuartmorgan): Add a view accessor once https://github.com/flutter/flutter/issues/104117
    // is resolved, and use that in 'showAlertWithMessage:...'.
  #endif
}

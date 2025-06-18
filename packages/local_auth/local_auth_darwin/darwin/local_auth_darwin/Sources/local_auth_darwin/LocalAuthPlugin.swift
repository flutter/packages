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

/// A default context factory that wraps standard LAContext allocation.
struct DefaultAuthContextFactory: AuthContextFactory {
  func createAuthContext() -> AuthContext {
    return LAContext()
  }
}

// MARK: -

#if os(iOS)
  /// A default alert controller that wraps UIAlertController.
  struct DefaultAlertController: AuthAlertController {
    /// The wrapped alert controller.
    var controller: UIAlertController

    /// Returns a wrapper for the given UIAlertController.
    init(wrapping controller: UIAlertController) {
      self.controller = controller
    }

    @MainActor
    func addAction(_ action: UIAlertAction) {
      controller.addAction(action)
    }

    @MainActor
    func present(
      on presentingViewController: UIViewController,
      animated: Bool,
      completion: (() -> Void)? = nil
    ) {
      presentingViewController.present(controller, animated: animated, completion: completion)
    }
  }
#endif  // os(iOS)

/// A default alert factory that wraps standard UIAlertController and NSAlert allocation for iOS and
/// macOS respectfully.
struct DefaultAlertFactory: AuthAlertFactory {
  #if os(macOS)
    func createAlert() -> AuthAlert {
      return NSAlert()
    }
  #elseif os(iOS)
    func createAlertController(
      title: String?,
      message: String?,
      preferredStyle: UIAlertController.Style
    ) -> AuthAlertController {
      return DefaultAlertController(
        wrapping:
          UIAlertController(
            title: title,
            message: message,
            preferredStyle: preferredStyle))
    }

    func createAlertAction(
      title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil
    ) -> UIAlertAction {
      return UIAlertAction(title: title, style: style, handler: handler)
    }
  #endif
}

// MARK: -

/// A default view provider that wraps the FlutterPluginRegistrar.
struct DefaultViewProvider: ViewProvider {
  /// The wrapped registrar.
  let registrar: FlutterPluginRegistrar

  #if os(macOS)
    var view: NSView? {
      return registrar.view
    }
  #endif  // os(macOS)
}

// MARK: -

/// A data container for sticky auth state.
struct StickyAuthState {
  let options: AuthOptions
  let strings: AuthStrings
  let resultHandler: (Result<AuthResultDetails, Error>) -> Void
}

// MARK: -

/// A flutter plugin for local authentication.
// TODO(stuartmorgan): Remove the @unchecked Sendable, and convert to strict thread enforcement.
// This was added to minimize the changes while converting from Swift to Objective-C.
public class LocalAuthPlugin: NSObject, FlutterPlugin, LocalAuthApi, @unchecked Sendable {

  /// Manages the last call state for sticky auth.
  var lastCallState: StickyAuthState?
  /// The factory to create LAContexts.
  var authContextFactory: AuthContextFactory
  /// The factory to create alerts.
  var alertFactory: AuthAlertFactory
  /// The Flutter view provider.
  var viewProvider: ViewProvider

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = LocalAuthPlugin(
      contextFactory: DefaultAuthContextFactory(),
      alertFactory: DefaultAlertFactory(),
      viewProvider: DefaultViewProvider(registrar: registrar))
    registrar.addApplicationDelegate(instance)
    // Workaround for https://github.com/flutter/flutter/issues/118103.
    #if os(iOS)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif
    LocalAuthApiSetup.setUp(binaryMessenger: messenger, api: instance)
  }

  /// Returns an instance that uses the given factory to create LAContexts.
  init(
    contextFactory: AuthContextFactory,
    alertFactory: AuthAlertFactory,
    viewProvider: ViewProvider
  ) {
    self.authContextFactory = contextFactory
    self.alertFactory = alertFactory
    self.viewProvider = viewProvider
  }

  // MARK: LocalAuthApi

  func authenticate(
    options: AuthOptions, strings: AuthStrings,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    var context = authContextFactory.createAuthContext()
    lastCallState = nil
    context.localizedFallbackTitle = strings.localizedFallbackTitle

    let policy =
      options.biometricOnly
      ? LAPolicy.deviceOwnerAuthenticationWithBiometrics
      : LAPolicy.deviceOwnerAuthentication
    var authError: NSError?
    if context.canEvaluatePolicy(policy, error: &authError) {
      context.evaluatePolicy(
        policy,
        localizedReason: strings.reason
      ) { (success: Bool, error: (any Error)?) in
        DispatchQueue.main.async {
          self.handleAuthReply(
            success: success,
            error: error,
            options: options,
            strings: strings,
            completion: completion)
        }
      }
    } else {
      if let authError = authError {
        self.handleError(authError, options: options, strings: strings, completion: completion)
      } else {
        // This should not happen according to docs, but if it ever does the plugin should still
        // fire the completion.
        completion(
          .success(
            AuthResultDetails(
              result: AuthResult.failure,
              errorMessage: "evaluatePolicy failed without an error"
            )))
      }
    }
  }

  func deviceCanSupportBiometrics() throws -> Bool {
    let context = authContextFactory.createAuthContext()
    var authError: NSError?
    // Check if authentication with biometrics is possible.
    if context.canEvaluatePolicy(
      LAPolicy.deviceOwnerAuthenticationWithBiometrics,
      error: &authError)
    {
      if authError == nil {
        return true
      }
    }
    // If not, check if it is because no biometrics are enrolled (but still present).
    if let authError = authError {
      if authError.code == LAError.biometryNotEnrolled.rawValue {
        return true
      }
      // Biometry hardware is available, but possibly permissions were denied.
      if authError.code == LAError.biometryNotAvailable.rawValue
        && context.biometryType != LABiometryType.none
      {
        return true
      }
    }

    return false
  }

  func getEnrolledBiometrics() throws -> [AuthBiometric] {
    let context = authContextFactory.createAuthContext()
    var biometrics: [AuthBiometric] = []
    if context.canEvaluatePolicy(
      LAPolicy.deviceOwnerAuthenticationWithBiometrics,
      error: nil)
    {
      if #available(macOS 10.15, iOS 11.0, *) {
        if context.biometryType == LABiometryType.faceID {
          biometrics.append(AuthBiometric.face)
          return biometrics
        }
      }
      if context.biometryType == LABiometryType.touchID {
        biometrics.append(AuthBiometric.fingerprint)
      }
    }
    return biometrics
  }

  func isDeviceSupported() throws -> Bool {
    let context = authContextFactory.createAuthContext()
    return context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil)
  }

  // MARK: Private Methods

  @MainActor
  private func showAlert(
    message: String,
    dismissButtonTitle: String,
    openSettingsButtonTitle: String?,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    #if os(macOS)
      var alert = alertFactory.createAlert()
      alert.messageText = message
      alert.addButton(withTitle: dismissButtonTitle)
      if let window = viewProvider.view?.window {
        alert.beginSheetModal(
          for: window
        ) { code in
          self.handleResult(succeeded: false, completion: completion)
        }
      } else {
        alert.runModal()
        self.handleResult(succeeded: false, completion: completion)
      }
    #elseif os(iOS)
      // TODO(stuartmorgan): Get the view controller from the view provider once it's possible.
      // See https://github.com/flutter/flutter/issues/104117.
      if let controller = UIApplication.shared.delegate?.window??.rootViewController {
        let alert =
          alertFactory.createAlertController(
            title: "",
            message: message,
            preferredStyle: UIAlertController.Style.alert)

        let defaultAction = alertFactory.createAlertAction(
          title: dismissButtonTitle,
          style: UIAlertAction.Style.default
        ) { action in
          self.handleResult(
            succeeded: false,
            completion: completion)
        }

        alert.addAction(defaultAction)
        if let openSettingsButtonTitle = openSettingsButtonTitle {
          let url = URL(string: UIApplication.openSettingsURLString)
          if let url = url {
            let additionalAction = UIAlertAction(
              title: openSettingsButtonTitle,
              style: UIAlertAction.Style.default
            ) { action in
              UIApplication.shared.open(
                url,
                options: [:],
                completionHandler: nil)
              self.handleResult(succeeded: false, completion: completion)
            }
            alert.addAction(additionalAction)
          }
        }
        alert.present(
          on: controller,
          animated: true,
          completion: nil)
      } else {
        // TODO(stuartmorgan): Create a new error code for failure to show UI, and return it here.
        self.handleResult(succeeded: false, completion: completion)
      }
    #endif
  }

  private func handleAuthReply(
    success: Bool,
    error: (any Error)?,
    options: AuthOptions,
    strings: AuthStrings,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    if success {
      handleResult(succeeded: true, completion: completion)
    } else {
      if let error = error as? NSError {
        switch LAError.Code(rawValue: error.code) {
        case LAError.biometryNotAvailable,
          LAError.biometryNotEnrolled,
          LAError.biometryLockout,
          LAError.userFallback,
          LAError.passcodeNotSet,
          LAError.authenticationFailed:
          handleError(error, options: options, strings: strings, completion: completion)
        case LAError.systemCancel:
          if options.sticky {
            lastCallState = StickyAuthState(
              options: options,
              strings: strings,
              resultHandler: completion)
          } else {
            handleResult(succeeded: false, completion: completion)
          }
        default:
          handleError(error, options: options, strings: strings, completion: completion)
        }
      } else {
        // The Obj-C declaration of evaluatePolicy defines the callback type as NSError*, but the
        // Swift version is (any Error)?, so provide a fallback in case somehow the type is not
        // NSError.
        // TODO(stuartmorgan): Add an "unknown error" enum option and return that here instead of
        // failure.
        completion(
          .success(
            AuthResultDetails(
              result: AuthResult.failure,
              errorMessage: "Unknown error from evaluatePolicy",
              errorDetails: error?.localizedDescription)
          ))
      }
    }
  }

  private func handleResult(
    succeeded: Bool, completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    completion(
      .success(
        AuthResultDetails(
          result: succeeded ? AuthResult.success : AuthResult.failure,
          errorMessage: nil,
          errorDetails: nil)
      ))
  }

  private func handleError(
    _ authError: NSError,
    options: AuthOptions,
    strings: AuthStrings,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    var result = AuthResult.errorNotAvailable
    let errorCode = LAError.Code(rawValue: authError.code)
    switch errorCode {
    case LAError.passcodeNotSet,
      LAError.biometryNotEnrolled:
      if options.useErrorDialogs {
        DispatchQueue.main.async {
          self.showAlert(
            message: strings.goToSettingsDescription,
            dismissButtonTitle: strings.cancelButton,
            openSettingsButtonTitle: strings.goToSettingsButton,
            completion: completion)
        }
        return
      }
      result =
        errorCode == LAError.passcodeNotSet
        ? AuthResult.errorPasscodeNotSet
        : AuthResult.errorNotEnrolled
    case LAError.biometryLockout:
      DispatchQueue.main.async {
        self.showAlert(
          message: strings.lockOut,
          dismissButtonTitle: strings.cancelButton,
          openSettingsButtonTitle: nil,
          completion: completion)
      }
      return
    default:
      // TODO(stuartmorgan): Improve the error mapping as part of a cross-platform overhaul of
      // error handling. See https://github.com/flutter/flutter/issues/113687
      result = AuthResult.errorNotAvailable
    }
    completion(
      .success(
        AuthResultDetails(
          result: result,
          errorMessage: authError.localizedDescription,
          errorDetails: authError.domain)
      ))
  }

  // MARK: App delegate

  // This method is called when the app is resumed from the background only on iOS
  #if os(iOS)
    public func applicationDidBecomeActive(_ application: UIApplication) {
      if let lastCallState = self.lastCallState {
        authenticate(
          options: lastCallState.options,
          strings: lastCallState.strings,
          completion: lastCallState.resultHandler)
      }
    }
  #endif  // os(iOS)

}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import LocalAuthentication

#if canImport(FlutterMacOS)
  import FlutterMacOS
#elseif canImport(Flutter)
  import Flutter
#endif

/// Protocol for a provider of the view containing the Flutter content, abstracted to allow using
/// mock/fake instances in unit tests.

protocol ViewProvider {
  #if os(macOS)
    var view: NSView { get }
  #elseif os(iOS)
    // TODO(stuartmorgan): Add a view accessor once https://github.com/flutter/flutter/issues/104117
    // is resolved, and use that in 'showAlert:...'.
  #endif
}

class DefaultViewProvider: ViewProvider {
  private var registrar: FlutterPluginRegistrar

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
  }

  #if os(macOS)
    var view: NSView {
      return NSView()
    }
  #elseif os(iOS)

  #endif
}

class StickyAuthState {
  let options: AuthOptions
  let strings: AuthStrings
  let resultHandler: (Result<AuthResultDetails, Error>) -> Void

  init(
    options: AuthOptions, strings: AuthStrings,
    resultHandler: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    self.options = options
    self.strings = strings
    self.resultHandler = resultHandler
  }
}

public final class LocalAuthPlugin: NSObject, FlutterPlugin, LocalAuthApi {
  private let authContextFactory: AuthContextFactory
  private let alertFactory: AlertFactory
  private let viewProvider: ViewProvider
  private var lastCallState: StickyAuthState?

  init(
    authContextFactory: AuthContextFactory,
    alertFactory: AlertFactory,
    viewProvider: ViewProvider
  ) {
    self.authContextFactory = authContextFactory
    self.alertFactory = alertFactory
    self.viewProvider = viewProvider
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let alertFactory = DefaultAlertFactory()
    let authContextFactory = DefaultAuthContextFactory()
    let viewProvider = DefaultViewProvider(registrar: registrar)
    let instance = LocalAuthPlugin(
      authContextFactory: authContextFactory,
      alertFactory: alertFactory,
      viewProvider: viewProvider
    )
    #if os(iOS)
      let messenger = registrar.messenger()
    #elseif os(macOS)
      let messenger = registrar.messenger
    #endif
    registrar.addApplicationDelegate(instance)
    LocalAuthApiSetup.setUp(binaryMessenger: messenger, api: instance)
  }

  func isDeviceSupported() throws -> Bool {
    let context = authContextFactory.createAuthContext()
    return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
  }

  func deviceCanSupportBiometrics() throws -> Bool {
    let context = authContextFactory.createAuthContext()
    var authError: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
      return true
    }

    if let error = authError, error.code == LAError.biometryNotEnrolled.rawValue {
      return true
    }

    return false
  }

  func getEnrolledBiometrics() throws -> [AuthBiometric] {
    let context = authContextFactory.createAuthContext()
    var biometrics: [AuthBiometric] = []

    var authError: NSError?
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
      if authError == nil {
        if #available(macOS 10.15, iOS 11.0, *) {
          if context.biometryType == .faceID {
            biometrics.append(.face)
            return biometrics
          }
        }

        if context.biometryType == .touchID {
          biometrics.append(.fingerprint)
        }
      }
    }

    return biometrics
  }

  func authenticate(
    options: AuthOptions,
    strings: AuthStrings,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    var context = authContextFactory.createAuthContext()
    context.localizedFallbackTitle = strings.localizedFallbackTitle
    self.lastCallState = nil

    let policy: LAPolicy =
      options.biometricOnly ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication
    var authError: NSError?

    if context.canEvaluatePolicy(policy, error: &authError) {
      context.evaluatePolicy(policy, localizedReason: strings.reason) { success, error in
        DispatchQueue.main.async {
          self.handleAuthReply(
            success: success,
            error: error as NSError?,
            options: options,
            strings: strings,
            completion: completion
          )
        }
      }
    } else {
      let error =
        authError
        ?? NSError(
          domain: "LocalAuthError", code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "Failed to initialize authentication context."
          ])
      handleError(
        authError: error,
        options: options,
        strings: strings,
        completion: completion
      )
    }
  }

  func handleAuthReply(
    success: Bool,
    error: NSError?,
    options: AuthOptions,
    strings: AuthStrings,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    assert(Thread.isMainThread, "Response handling must be done on the main thread.")

    if success {
      handleSucceeded(succeeded: true, completion: completion)
    } else {
      if let error = error {
        switch error.code {
        case LAError.biometryNotAvailable.rawValue,
          LAError.biometryNotEnrolled.rawValue,
          LAError.biometryLockout.rawValue,
          LAError.userFallback.rawValue,
          LAError.passcodeNotSet.rawValue,
          LAError.authenticationFailed.rawValue:
          handleError(authError: error, options: options, strings: strings, completion: completion)
          return

        case LAError.systemCancel.rawValue:
          if options.sticky {
            lastCallState = StickyAuthState(
              options: options, strings: strings, resultHandler: completion)
          } else {
            handleSucceeded(succeeded: false, completion: completion)
          }
          return

        default:
          handleError(authError: error, options: options, strings: strings, completion: completion)
        }
      } else {
        handleSucceeded(succeeded: false, completion: completion)
      }
    }
  }

  func handleSucceeded(
    succeeded: Bool,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    let result: AuthResult = succeeded ? .success : .failure
    let resultDetails = AuthResultDetails(result: result, errorMessage: nil, errorDetails: nil)
    completion(.success(resultDetails))
  }

  func handleError(
    authError: NSError,
    options: AuthOptions,
    strings: AuthStrings,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    var result = AuthResult.errorNotAvailable

    switch authError.code {
    case LAError.passcodeNotSet.rawValue,
      LAError.biometryNotEnrolled.rawValue:
      if options.useErrorDialogs {
        showAlert(
          message: strings.goToSettingsDescription ?? "",
          dismissButtonTitle: strings.cancelButton,
          openSettingsButtonTitle: strings.goToSettingsButton,
          completion: completion
        )
        return
      }

      result =
        authError.code == LAError.passcodeNotSet.rawValue
        ? .errorPasscodeNotSet
        : .errorNotEnrolled

    case LAError.biometryLockout.rawValue:
      showAlert(
        message: strings.lockOut,
        dismissButtonTitle: strings.cancelButton,
        openSettingsButtonTitle: nil,
        completion: completion
      )
      return
    default:
      break
    }

    let details = AuthResultDetails(
      result: result,
      errorMessage: authError.localizedDescription,
      errorDetails: authError.domain
    )
    completion(.success(details))
  }

  func showAlert(
    message: String,
    dismissButtonTitle: String,
    openSettingsButtonTitle: String?,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    #if os(macOS)
      let alert = alertFactory.createAlert()
      alert.messageText = message
      alert.addButton(withTitle: dismissButtonTitle)

      guard let window = viewProvider.view.window else { return }

      alert.beginSheetModal(for: window) { _ in
        self.handleSucceeded(succeeded: false, completion: completion)
      }

    #elseif os(iOS)
      let alert = alertFactory.createAlertController(
        title: "",
        message: message,
        preferredStyle: .alert
      )

      let defaultAction = UIAlertAction(
        title: dismissButtonTitle,
        style: .default
      ) { _ in
        self.handleSucceeded(succeeded: false, completion: completion)
      }

      alert.addAction(defaultAction)

      if let openSettingsButtonTitle = openSettingsButtonTitle {
        let additionalAction = UIAlertAction(
          title: openSettingsButtonTitle,
          style: .default
        ) { _ in
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
          self.handleSucceeded(succeeded: false, completion: completion)
        }
        alert.addAction(additionalAction)
      }

      if let viewController = UIApplication.shared.windows.first?.rootViewController {
        alert.present(viewController, animated: true, completion: nil)
      }
    #endif
  }

  #if os(iOS)
    public func applicationDidBecomeActive(_ application: UIApplication) {
      if let lastCallState = lastCallState {
        authenticate(
          options: lastCallState.options,
          strings: lastCallState.strings,
          completion: lastCallState.resultHandler
        )
      }
    }
  #endif
}

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

//TODO (Mairramer): Put in a new file?
protocol AuthContextProtocol {
  var biometryType: LABiometryType { get }
  var localizedFallbackTitle: String? { get set }

  func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
  func evaluatePolicy(
    _ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void)
}

class DefaultAuthContext: AuthContextProtocol {
  private let context = LAContext()

  var biometryType: LABiometryType {
    context.biometryType
  }

  var localizedFallbackTitle: String? {
    get { context.localizedFallbackTitle }
    set { context.localizedFallbackTitle = newValue }
  }

  func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
    context.canEvaluatePolicy(policy, error: error)
  }

  func evaluatePolicy(
    _ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void
  ) {
    context.evaluatePolicy(policy, localizedReason: localizedReason, reply: reply)
  }
}

//TODO (Mairramer): Put in a new file?
protocol AlertControllerProtocol {
  func showAlert(
    message: String, dismissTitle: String, openSettingsTitle: String?,
    completion: @escaping (Bool) -> Void)
}

#if os(iOS)
  import UIKit

  class DefaultAlertController: AlertControllerProtocol {
    func showAlert(
      message: String, dismissTitle: String, openSettingsTitle: String?,
      completion: @escaping (Bool) -> Void
    ) {
      let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      let dismissAction = UIAlertAction(title: dismissTitle, style: .default) { _ in
        completion(false)
      }
      alert.addAction(dismissAction)

      if let openSettingsTitle = openSettingsTitle {
        let openSettingsAction = UIAlertAction(title: openSettingsTitle, style: .default) { _ in
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
          completion(true)
        }
        alert.addAction(openSettingsAction)
      }

      UIApplication.shared.delegate?.window??.rootViewController?.present(alert, animated: true)
    }
  }

#elseif os(macOS)
  import AppKit

  class DefaultAlertController: AlertControllerProtocol {
    func showAlert(
      message: String, dismissTitle: String, openSettingsTitle: String?,
      completion: @escaping (Bool) -> Void
    ) {
      let alert = NSAlert()
      alert.messageText = message
      alert.addButton(withTitle: dismissTitle)

      if let openSettingsTitle = openSettingsTitle {
        alert.addButton(withTitle: openSettingsTitle)
      }

      alert.beginSheetModal(for: NSApplication.shared.keyWindow!) { response in
        if response == .alertSecondButtonReturn,
          let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Biometric")
        {
          NSWorkspace.shared.open(url)
        }
        completion(response == .alertSecondButtonReturn)
      }
    }
  }
#endif

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
  private var authContext: AuthContextProtocol
  private let alertController: AlertControllerProtocol
  private var lastCallState: StickyAuthState?

  init(
    authContext: AuthContextProtocol = DefaultAuthContext(),
    alertController: AlertControllerProtocol = DefaultAlertController()
  ) {
    self.authContext = authContext
    self.alertController = alertController
      
    super.init()
    #if os(iOS)
      NotificationCenter.default.addObserver(
        self, selector: #selector(applicationDidBecomeActive),
        name: UIApplication.didBecomeActiveNotification, object: nil)
    #endif
  }

  deinit {
    #if os(iOS)
      NotificationCenter.default.removeObserver(
        self, name: UIApplication.didBecomeActiveNotification, object: nil)
    #endif
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = LocalAuthPlugin()
    #if os(iOS)
      // iOS-specific implementation
      let messenger = registrar.messenger()
      LocalAuthApiSetup.setUp(binaryMessenger: messenger, api: instance)
    #elseif os(macOS)
      // macOS-specific implementation
      let messenger = registrar.messenger
      LocalAuthApiSetup.setUp(binaryMessenger: messenger, api: instance)
    #endif
  }

  func isDeviceSupported() throws -> Bool {
    var error: NSError?
    return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
  }

  func deviceCanSupportBiometrics() throws -> Bool {
    var authError: NSError?

    if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
      return true
    }

    if let error = authError, error.code == LAError.biometryNotEnrolled.rawValue {
      return true
    }

    return false
  }

  func getEnrolledBiometrics() throws -> [AuthBiometric] {
    var enrolledBiometrics: [AuthBiometric] = []

    if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
      if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
        if authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
          enrolledBiometrics.append(.face)
        } else if authContext.canEvaluatePolicy(
          .deviceOwnerAuthenticationWithBiometrics, error: nil)
        {
          enrolledBiometrics.append(.fingerprint)
        }
      }
    }

    return enrolledBiometrics
  }

  func authenticate(
    options: AuthOptions, strings: AuthStrings,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    self.authContext.localizedFallbackTitle = strings.localizedFallbackTitle
    self.lastCallState = StickyAuthState(
      options: options, strings: strings, resultHandler: completion)

    let policy: LAPolicy =
      options.biometricOnly ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication
    var authError: NSError?

    if authContext.canEvaluatePolicy(policy, error: &authError) {
      authContext.evaluatePolicy(policy, localizedReason: strings.reason) { success, error in
        DispatchQueue.main.async {
          self.handleAuthReply(
            success: success, error: error as NSError?, options: options, strings: strings,
            completion: completion)
        }
      }
    } else {
      let error = authError ?? NSError(domain: "", code: 0, userInfo: nil)
      handleError(authError: error, options: options, strings: strings, completion: completion)
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
      guard let error = error else {
        handleError(
          authError: NSError(domain: "", code: 0, userInfo: nil), options: options,
          strings: strings, completion: completion)
        return
      }

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
    }
  }

  func handleSucceeded(
    succeeded: Bool, completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    let result: AuthResult = succeeded ? .success : .failure

    let resultDetails = AuthResultDetails(
      result: result,
      errorMessage: nil,
      errorDetails: nil)

    completion(.success(resultDetails))
  }

  func handleError(
    authError: NSError,
    options: AuthOptions,
    strings: AuthStrings,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    var result: AuthResult = .errorNotAvailable

    switch authError.code {
    case LAError.passcodeNotSet.rawValue,
      LAError.biometryNotEnrolled.rawValue:
      if options.useErrorDialogs {
        alertController.showAlert(
          message: strings.goToSettingsDescription ?? "",
          dismissTitle: strings.cancelButton,
          openSettingsTitle: strings.goToSettingsButton
        ) { success in
          let result: Result<AuthResultDetails, Error> =
            success
            ? .success(AuthResultDetails(result: .success, errorMessage: nil, errorDetails: nil))
            : .failure(NSError(domain: "AuthError", code: 1, userInfo: nil))
          completion(result)
        }
        return
      }
      result =
        authError.code == LAError.passcodeNotSet.rawValue ? .errorPasscodeNotSet : .errorNotEnrolled
      break

    case LAError.biometryLockout.rawValue:
      alertController.showAlert(
        message: strings.lockOut,
        dismissTitle: strings.cancelButton,
        openSettingsTitle: nil
      ) { success in
        let result: Result<AuthResultDetails, Error> =
          success
          ? .success(AuthResultDetails(result: .success, errorMessage: nil, errorDetails: nil))
          : .failure(NSError(domain: "AuthError", code: 2, userInfo: nil))
        completion(result)
      }
      return
    default:
      break
    }

    let resultDetails = AuthResultDetails(
      result: result,
      errorMessage: authError.localizedDescription,
      errorDetails: authError.domain)
    completion(.success(resultDetails))
  }

  @objc private func applicationDidBecomeActive() {
    guard let lastCallState = lastCallState else { return }
    authenticate(
      options: lastCallState.options, strings: lastCallState.strings,
      completion: lastCallState.resultHandler
    )
  }
}

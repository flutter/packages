import Cocoa
import Foundation
import LocalAuthentication

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#if canImport(FlutterMacOS)
  import FlutterMacOS
#elseif canImport(Flutter)
  import Flutter
#endif

public final class LocalAuthPlugin: NSObject, FlutterPlugin, LocalAuthApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = LocalAuthPlugin()
    LocalAuthApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)
  }

  private var lastCallState: StickyAuthState?

  func isDeviceSupported() throws -> Bool {
    let context = LAContext()
    var error: NSError?
    return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
  }

  func deviceCanSupportBiometrics() throws -> Bool {
    let context = LAContext()
    var authError: NSError?
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
      if authError == nil {
        return true
      }
    }
    if let error = authError {
      if error.code == LAError.biometryNotEnrolled.rawValue {
        return true
      }
    }

    return false
  }

  func getEnrolledBiometrics() throws -> [AuthBiometricWrapper] {
    let context = LAContext()
    var enrolledBiometrics: [AuthBiometricWrapper] = []

    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
      if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
          enrolledBiometrics.append(AuthBiometricWrapper(value: .face))
        } else if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
          enrolledBiometrics.append(AuthBiometricWrapper(value: .fingerprint))
        }
      }
    }

    return enrolledBiometrics
  }

  func authenticate(
    options: AuthOptions, strings: AuthStrings,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    let context = LAContext()
    var authError: NSError?
    self.lastCallState = nil
    context.localizedFallbackTitle = strings.localizedFallbackTitle

    let policy: LAPolicy =
      options.biometricOnly ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication

    if context.canEvaluatePolicy(policy, error: &authError) {
      context.evaluatePolicy(policy, localizedReason: strings.reason) { success, error in
        DispatchQueue.main.async {
          self.handleAuthReply(
            success: success, error: error as NSError?, options: options, strings: strings,
            completion: completion)
        }
      }
    } else {
      self.handleError(
        authError: authError!, options: options, strings: strings, completion: completion)
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
        showAlert(
          message: strings.goToSettingsDescription,
          dismissButtonTitle: strings.cancelButton,
          openSettingsButtonTitle: strings.goToSettingsButton,
          completion: completion)
        return
      }
      result =
        authError.code == LAError.passcodeNotSet.rawValue ? .errorPasscodeNotSet : .errorNotEnrolled
      break

    case LAError.biometryLockout.rawValue:
      showAlert(
        message: strings.lockOut,
        dismissButtonTitle: strings.cancelButton,
        openSettingsButtonTitle: nil,
        completion: completion)
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

  func showAlert(
    message: String,
    dismissButtonTitle: String,
    openSettingsButtonTitle: String?,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    #if os(macOS)
      let alert = NSAlert()
      alert.messageText = message
      alert.addButton(withTitle: dismissButtonTitle)

      if let openSettingsButtonTitle = openSettingsButtonTitle {
        alert.addButton(withTitle: openSettingsButtonTitle)
      }

      // Obtain the key window for displaying the alert
      let window = NSApplication.shared.keyWindow

      if let window = window {
        alert.beginSheetModal(for: window) { response in
          switch response {
          case .alertFirstButtonReturn:
            self.handleSucceeded(succeeded: false, completion: completion)
          case .alertSecondButtonReturn:
            if let url = URL(
              string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Biometric")
            {
              NSWorkspace.shared.open(url)
            }
            self.handleSucceeded(succeeded: false, completion: completion)
          default:
            break
          }
        }
      } else {
        // Handle the case where no key window is available
        self.handleSucceeded(succeeded: false, completion: completion)
      }
    #elseif os(iOS)
      let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

      let defaultAction = UIAlertAction(title: dismissButtonTitle, style: .default) { action in
        self.handleSucceeded(succeeded: false, completion: completion)
      }
      alert.addAction(defaultAction)

      if let openSettingsButtonTitle = openSettingsButtonTitle {
        let additionalAction = UIAlertAction(title: openSettingsButtonTitle, style: .default) {
          action in
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
          self.handleSucceeded(succeeded: false, completion: completion)
        }
        alert.addAction(additionalAction)
      }

      if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
        rootViewController.present(alert, animated: true, completion: nil)
      }
    #endif
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

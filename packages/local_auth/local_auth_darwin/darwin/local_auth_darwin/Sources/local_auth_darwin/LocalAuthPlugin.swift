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

enum LocalAuthError: Error {
  case biometryNotAvailable
  case biometryNotEnrolled
  case biometryLockout
  case passcodeNotSet
  case systemCancel
  case userCancel
  case authenticationFailed

  init?(from laError: LAError) {
    switch laError.code {
    case .biometryNotAvailable: self = .biometryNotAvailable
    case .biometryNotEnrolled: self = .biometryNotEnrolled
    case .biometryLockout: self = .biometryLockout
    case .passcodeNotSet: self = .passcodeNotSet
    case .systemCancel: self = .systemCancel
    case .userCancel: self = .userCancel
    case .authenticationFailed: self = .authenticationFailed
    default: return nil
    }
  }
}

enum BiometricState {
  case none
  case faceID
  case touchID
}

struct StickyAuthState {
  let options: AuthOptions
  let strings: AuthStrings
  let resultHandler: (Result<AuthResultDetails, Error>) -> Void
}

public final class LocalAuthPlugin: NSObject, FlutterPlugin, LocalAuthApi {
  private var lastCallState: StickyAuthState?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = LocalAuthPlugin()
    #if os(iOS)
      let messenger = registrar.messenger()
      LocalAuthApiSetup.setUp(binaryMessenger: messenger, api: instance)
    #elseif os(macOS)
      let messenger = registrar.messenger
      LocalAuthApiSetup.setUp(binaryMessenger: messenger, api: instance)
    #endif
  }

  func getBiometricState() -> BiometricState {
    let context = LAContext()
    var error: NSError?

    let canEvaluate = context.canEvaluatePolicy(
      .deviceOwnerAuthenticationWithBiometrics, error: &error)

    if canEvaluate {
      switch context.biometryType {
      case .faceID: return .faceID
      case .touchID: return .touchID
      default: return .none
      }
    }
    return .none
  }

  func isDeviceSupported() throws -> Bool {
    let context = LAContext()
    var error: NSError?
    return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
  }

  func deviceCanSupportBiometrics() throws -> Bool {
    let context = LAContext()
    var authError: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
      return authError == nil
    }

    if let error = authError, error.code == LAError.biometryNotEnrolled.rawValue {
      return true
    }

    return false
  }

  func getEnrolledBiometrics() throws -> [AuthBiometricWrapper] {
    let context = LAContext()
    var enrolledBiometrics: [AuthBiometricWrapper] = []

    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
      if context.biometryType == .faceID {
        enrolledBiometrics.append(AuthBiometricWrapper(value: .face))
      } else if context.biometryType == .touchID {
        enrolledBiometrics.append(AuthBiometricWrapper(value: .fingerprint))
      }
    }

    return enrolledBiometrics
  }

  func authenticate(
    options: AuthOptions,
    strings: AuthStrings,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    let context = LAContext()
    var authError: NSError?
    lastCallState = nil
    context.localizedFallbackTitle = strings.localizedFallbackTitle

    let policy: LAPolicy =
      options.biometricOnly ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication

    if context.canEvaluatePolicy(policy, error: &authError) {
      context.evaluatePolicy(policy, localizedReason: strings.reason) {
        [weak self] success, error in
        DispatchQueue.main.async {
          self?.handleAuthReply(
            success: success,
            error: error as NSError?,
            options: options,
            strings: strings,
            completion: completion
          )
        }
      }
    } else {
      handleError(
        authError: authError ?? NSError(domain: "", code: 0, userInfo: nil),
        options: options,
        strings: strings,
        completion: completion
      )
    }
  }

  private func handleAuthReply(
    success: Bool,
    error: NSError?,
    options: AuthOptions,
    strings: AuthStrings,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    assert(Thread.isMainThread, "Response handling must be done on the main thread.")

    if success {
      handleSucceeded(succeeded: true, completion: completion)
      return
    }

    guard let error = error else {
      handleError(
        authError: NSError(domain: "", code: 0, userInfo: nil),
        options: options,
        strings: strings,
        completion: completion
      )
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

    case LAError.systemCancel.rawValue:
      if options.sticky {
        lastCallState = StickyAuthState(
          options: options,
          strings: strings,
          resultHandler: completion
        )
      } else {
        handleSucceeded(succeeded: false, completion: completion)
      }

    default:
      handleError(authError: error, options: options, strings: strings, completion: completion)
    }
  }

  private func handleSucceeded(
    succeeded: Bool,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    let result: AuthResult = succeeded ? .success : .failure
    let resultDetails = AuthResultDetails(
      result: result,
      errorMessage: nil,
      errorDetails: nil
    )
    completion(.success(resultDetails))
  }

  private func handleError(
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
          completion: completion
        )
        return
      }
      result =
        authError.code == LAError.passcodeNotSet.rawValue ? .errorPasscodeNotSet : .errorNotEnrolled

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

    let resultDetails = AuthResultDetails(
      result: result,
      errorMessage: authError.localizedDescription,
      errorDetails: authError.domain
    )
    completion(.success(resultDetails))
  }

  #if os(iOS)
    private func topViewController() -> UIViewController? {
      var topController = UIApplication.shared.keyWindow?.rootViewController
      while let presentedController = topController?.presentedViewController {
        topController = presentedController
      }
      return topController
    }
  #endif

  private func showAlert(
    message: String,
    dismissButtonTitle: String,
    openSettingsButtonTitle: String?,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    #if os(iOS)
      guard let topVC = topViewController() else {
        handleSucceeded(succeeded: false, completion: completion)
        return
      }

      let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: dismissButtonTitle, style: .default) {
        [weak self] _ in
        self?.handleSucceeded(succeeded: false, completion: completion)
      }
      alert.addAction(defaultAction)

      if let settingsTitle = openSettingsButtonTitle {
        let settingsAction = UIAlertAction(title: settingsTitle, style: .default) { [weak self] _ in
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
          }
          self?.handleSucceeded(succeeded: false, completion: completion)
        }
        alert.addAction(settingsAction)
      }

      topVC.present(alert, animated: true)

    #elseif os(macOS)
      let alert = NSAlert()
      alert.messageText = message
      alert.addButton(withTitle: dismissButtonTitle)

      if let settingsTitle = openSettingsButtonTitle {
        alert.addButton(withTitle: settingsTitle)
      }

      if let window = NSApplication.shared.keyWindow {
        alert.beginSheetModal(for: window) { [weak self] response in
          switch response {
          case .alertFirstButtonReturn:
            self?.handleSucceeded(succeeded: false, completion: completion)
          case .alertSecondButtonReturn:
            if let url = URL(
              string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Biometric")
            {
              NSWorkspace.shared.open(url)
            }
            self?.handleSucceeded(succeeded: false, completion: completion)
          default:
            break
          }
        }
      }
    #endif
  }
}

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
  private var authContext: AuthContext
  private let alertController: AlertController
  private var lastCallState: StickyAuthState?

  init(
    authContext: AuthContext = LAContext(),
    alertController: AlertController = DefaultAlertController()
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
      let messenger = registrar.messenger()
    #elseif os(macOS)
      let messenger = registrar.messenger
    #endif

    LocalAuthApiSetup.setUp(binaryMessenger: messenger, api: instance)
  }

  func isDeviceSupported() throws -> Bool {
    return authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
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
    var biometrics: [AuthBiometric] = []

    var authError: NSError?
    if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
      if authError == nil {
        if #available(macOS 10.15, iOS 11.0, *) {
          if authContext.biometryType == .faceID {
            biometrics.append(.face)
            return biometrics
          }
        }

        if authContext.biometryType == .touchID {
          biometrics.append(.fingerprint)
        }
      }
    }

    return biometrics
  }

  func authenticate(
    options: AuthOptions, strings: AuthStrings,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    self.authContext.localizedFallbackTitle = strings.localizedFallbackTitle
    self.lastCallState = nil

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
    var result: AuthResult = .errorNotAvailable

    switch authError.code {
    case LAError.passcodeNotSet.rawValue, LAError.biometryNotEnrolled.rawValue:
      if options.useErrorDialogs {
        alertController.showAlert(
          message: strings.goToSettingsDescription ?? "",
          dismissTitle: strings.cancelButton,
          openSettingsTitle: strings.goToSettingsButton
        ) { success in
          let result: Result<AuthResultDetails, Error> =
            success
            ? .success(AuthResultDetails(result: .success, errorMessage: nil, errorDetails: nil))
            : .failure(
              NSError(domain: authError.domain, code: authError.code, userInfo: authError.userInfo))
          completion(result)
        }
        return
      }
      result =
        authError.code == LAError.passcodeNotSet.rawValue ? .errorPasscodeNotSet : .errorNotEnrolled

    case LAError.biometryLockout.rawValue:
      alertController.showAlert(
        message: strings.lockOut,
        dismissTitle: strings.cancelButton,
        openSettingsTitle: nil
      ) { success in
        let result: Result<AuthResultDetails, Error> =
          success
          ? .success(AuthResultDetails(result: .success, errorMessage: nil, errorDetails: nil))
          : .failure(
            NSError(domain: authError.domain, code: authError.code, userInfo: authError.userInfo))
        completion(result)
      }
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

  public func applicationDidBecomeActive(_ application: UIApplication) {
    if let lastCallState = lastCallState {
      authenticate(
        options: lastCallState.options,
        strings: lastCallState.strings,
        completion: lastCallState.resultHandler
      )
    }
  }
}

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

/// A default context factory that wraps standard LAContext allocation.
final class DefaultAuthContextFactory: AuthContextFactory {
  func createAuthContext() -> AuthContext {
    return LAContext()
  }
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
public final class LocalAuthPlugin: NSObject, FlutterPlugin, LocalAuthApi, @unchecked Sendable {

  /// The factory to create LAContexts.
  private let authContextFactory: AuthContextFactory
  /// Manages the last call state for sticky auth.
  private var lastCallState: StickyAuthState?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = LocalAuthPlugin(
      contextFactory: DefaultAuthContextFactory())
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
    contextFactory: AuthContextFactory
  ) {
    self.authContextFactory = contextFactory
  }

  // MARK: LocalAuthApi

  func authenticate(
    options: AuthOptions,
    strings: AuthStrings,
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
      ) { [weak self] (success: Bool, error: Error?) in
        DispatchQueue.main.async {
          self?.handleAuthReply(
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
              result: .unknownError,
              errorMessage: "canEvaluatePolicy failed without an error"
            )))
      }
    }
  }

  func deviceCanSupportBiometrics() throws -> Bool {
    let context = authContextFactory.createAuthContext()
    var authError: NSError?
    // Check if authentication with biometrics is possible.
    if context.canEvaluatePolicy(
      .deviceOwnerAuthenticationWithBiometrics,
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
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
      if context.biometryType == LABiometryType.faceID {
        biometrics.append(AuthBiometric.face)
      }
      if context.biometryType == LABiometryType.touchID {
        biometrics.append(AuthBiometric.fingerprint)
      }
    }
    return biometrics
  }

  func isDeviceSupported() throws -> Bool {
    let context = authContextFactory.createAuthContext()
    return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
  }

  // MARK: Private Methods

  private func handleAuthReply(
    success: Bool,
    error: Error?,
    options: AuthOptions,
    strings: AuthStrings,
    completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    if success {
      handleResult(result: .success, completion: completion)
      return
    }

    if let error = error as? NSError {
      if error.code == LAError.Code.systemCancel.rawValue && options.sticky {
        lastCallState = StickyAuthState(
          options: options,
          strings: strings,
          resultHandler: completion)
      } else {
        handleError(error, options: options, strings: strings, completion: completion)
      }
    } else {
      // This should not happen according to docs, but if it ever does the plugin should still
      // fire the completion.
      completion(
        .success(
          AuthResultDetails(
            result: .unknownError,
            errorMessage: "evaluatePolicy failed without an error"
          )))
    }
  }

  private func handleResult(
    result: AuthResult, completion: @escaping (Result<AuthResultDetails, Error>) -> Void
  ) {
    completion(
      .success(
        AuthResultDetails(
          result: result,
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
    let result: AuthResult
    let errorCode = LAError.Code(rawValue: authError.code)
    switch errorCode {
    case .appCancel:
      result = .appCancel
    case .systemCancel:
      result = .systemCancel
    case .userCancel:
      result = .userCancel
    case .biometryDisconnected:
      result = .biometryDisconnected
    case .biometryLockout:
      result = .biometryLockout
    case .biometryNotAvailable:
      result = .biometryNotAvailable
    case .biometryNotEnrolled:
      result = .biometryNotEnrolled
    case .biometryNotPaired:
      result = .biometryNotPaired
    case .authenticationFailed:
      result = .authenticationFailed
    case .invalidContext:
      result = .invalidContext
    case .invalidDimensions:
      result = .invalidDimensions
    case .notInteractive:
      result = .notInteractive
    case .passcodeNotSet:
      result = .passcodeNotSet
    case .userFallback:
      result = .userFallback
    default:
      result = .unknownError
    }
    completion(
      .success(
        AuthResultDetails(
          result: result,
          errorMessage: authError.localizedDescription,
          errorDetails: "\(authError.domain): \(authError.code)")
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

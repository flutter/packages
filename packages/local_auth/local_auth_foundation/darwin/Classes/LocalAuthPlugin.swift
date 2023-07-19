// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif
import LocalAuthentication

typealias AuthCompletion = (Result<AuthResultDetails, Error>) -> Void

class StickyAuthState {
    var options: AuthOptions
    var strings: AuthStrings
    var resultHandler: AuthCompletion

    init(options: AuthOptions, strings: AuthStrings, resultHandler: @escaping AuthCompletion) {
        self.options = options
        self.strings = strings
        self.resultHandler = resultHandler
    }
}

extension LocalAuthPlugin {
    func handleAuth(withSuccess success: Bool, error: NSError?, options: AuthOptions, strings: AuthStrings, completion: @escaping AuthCompletion) {
        if success {
            handleSucceeded(true, withCompletion: completion)
            return
        }

        if let error = error, let errorCode = .some(Int32(error.code))  {
            switch errorCode {
                case kLAErrorSystemCancel:
                    if options.sticky {
                        lastCallState = StickyAuthState(options: options, strings: strings, resultHandler: completion)
                    } else {
                        handleSucceeded(false, withCompletion: completion)
                    }
                    return
                default:
                    break
            }
        }

        handleError(error: error, options: options, strings: strings, completion: completion)
    }
}

extension LocalAuthPlugin {
    func handleSucceeded(_ succeeded: Bool, withCompletion completion: @escaping AuthCompletion) {
        completion(.success(.init(result: succeeded ? .success : .failure)))
    }

    func handleError(error: NSError?, options: AuthOptions, strings: AuthStrings, completion: @escaping AuthCompletion) {
        var result = AuthResult.errorNotAvailable

        if let error = error, let errorCode = .some(Int32(error.code))  {
            switch errorCode {
                case kLAErrorBiometryNotEnrolled,
                     kLAErrorPasscodeNotSet:
                    if options.useErrorDialogs {
                        showAlert(withMessage: strings.goToSettingsDescription, dismissButtonTitle: strings.cancelButton, openSettingsButtonTitle: strings.goToSettingsButton, completion: completion)
                        return
                    }

                    result = errorCode == kLAErrorPasscodeNotSet ? .errorPasscodeNotSet : .errorNotEnrolled
                case kLAErrorBiometryLockout:
                    showAlert(withMessage: strings.lockOut, dismissButtonTitle: strings.cancelButton, openSettingsButtonTitle: nil, completion: completion)
                    return
                default:
                    break
            }
        }

        completion(.success(.init(result: result, errorMessage: error?.localizedDescription, errorDetails: error?.domain)))
    }
}

#if os(iOS)
extension LocalAuthPlugin {
    func showAlert(withMessage message: String,
                   dismissButtonTitle: String,
                   openSettingsButtonTitle: String?,
                   completion: @escaping AuthCompletion)
    {
        let alert = UIAlertController(title: "",
                                      message: message,
                                      preferredStyle: .alert)

        let defaultAction = UIAlertAction(title: dismissButtonTitle,
                                          style: .default)
        { _ in
            self.handleSucceeded(false, withCompletion: completion)
        }
        alert.addAction(defaultAction)

        if let openSettingsTitle = openSettingsButtonTitle {
            let additionalAction = UIAlertAction(title: openSettingsTitle,
                                                 style: .default)
            { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                    self.handleSucceeded(false, withCompletion: completion)
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                self.handleSucceeded(false, withCompletion: completion)
            }
            alert.addAction(additionalAction)
        }

        guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
            handleSucceeded(false, withCompletion: completion)
            return
        }
        rootViewController.present(alert, animated: true, completion: nil)
    }
}

public extension LocalAuthPlugin {
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let lastCallState = lastCallState {
            authenticate(options: lastCallState.options, strings: lastCallState.strings, completion: lastCallState.resultHandler)
        }
    }
}
#endif

#if os(macOS)
extension LocalAuthPlugin {
    func showAlert(withMessage message: String,
                   dismissButtonTitle: String,
                   openSettingsButtonTitle: String?,
                   completion: @escaping AuthCompletion)
    {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: dismissButtonTitle)

        if let openSettingsTitle = openSettingsButtonTitle {
            alert.addButton(withTitle: openSettingsTitle)
            alert.buttons[1].keyEquivalent = "\r"
            alert.buttons[1].target = self
            alert.buttons[1].action = #selector(openSystemPreferences)
        }

        guard let keyWindow = NSApplication.shared.keyWindow else {
            print("fuck no keyWindow")
            handleSucceeded(false, withCompletion: completion)
            return
        }

        alert.beginSheetModal(for: keyWindow) { response in
            if response == .alertFirstButtonReturn {
                self.handleSucceeded(false, withCompletion: completion)
            } else if response == .alertSecondButtonReturn {
                self.openSystemPreferences()
                self.handleSucceeded(false, withCompletion: completion)
            }
        }
    }

    @objc private func openSystemPreferences() {
        guard let url = URL(string: "x-apple.systempreferences:") else { return }
        NSWorkspace.shared.open(url)
    }
}
#endif

class DefaultAuthContextFactory: AuthContextFactory {
    func createAuthContext() -> LAContext {
        return LAContext()
    }
}

public class LocalAuthPlugin: NSObject, FlutterPlugin, LocalAuthApi {
    private var lastCallState: StickyAuthState?
    private let contextFactory: AuthContextFactory

    override init() {
        self.contextFactory = DefaultAuthContextFactory()
    }

    init(contextFactory: AuthContextFactory) {
        self.contextFactory = contextFactory
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = LocalAuthPlugin()
// Workaround for https://github.com/flutter/flutter/issues/118103 .
#if os(iOS)
        let messenger = registrar.messenger()
#else
        let messenger = registrar.messenger
#endif
        LocalAuthApiSetup.setUp(binaryMessenger: messenger, api: instance)
    }

    func isDeviceSupported() throws -> Bool {
        true
    }

    func deviceCanSupportBiometrics() throws -> Bool {
        let context = contextFactory.createAuthContext()
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
        let context = contextFactory.createAuthContext()
        var authError: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            if authError == nil {
                if #available(iOS 11.0, macOS 10.15, *) {
                    if context.biometryType == .faceID {
                        return [AuthBiometricWrapper(value: .face)]
                    }
                }

                if context.biometryType == .touchID {
                    return [AuthBiometricWrapper(value: .fingerprint)]
                }
            }
        }
        return []
    }

    func authenticate(options: AuthOptions, strings: AuthStrings, completion: @escaping AuthCompletion) {
        lastCallState = nil

        let context = contextFactory.createAuthContext()
        var authError: NSError?
        context.localizedFallbackTitle = strings.localizedFallbackTitle

        let policy: LAPolicy = options.biometricOnly ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication

        if context.canEvaluatePolicy(policy, error: &authError) {
            context.evaluatePolicy(policy, localizedReason: strings.reason) { success, error in
                DispatchQueue.main.async {
                    self.handleAuth(withSuccess: success, error: error as? NSError, options: options, strings: strings, completion: completion)
                }
            }
        } else {
            handleError(error: authError, options: options, strings: strings, completion: completion)
        }
    }
}

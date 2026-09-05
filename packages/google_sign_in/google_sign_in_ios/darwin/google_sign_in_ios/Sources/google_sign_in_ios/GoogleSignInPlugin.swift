// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Darwin
import Foundation
import GoogleSignIn

#if canImport(google_sign_in_ios_objc)
  import google_sign_in_ios_objc
#endif

#if os(macOS)
  import FlutterMacOS
#else
  import Flutter
  import UIKit
#endif

/// The key within `GoogleService-Info.plist` used to hold the application's
/// client id.  See https://developers.google.com/identity/sign-in/ios/start
/// for more info.
private let clientIdKey = "CLIENT_ID"
private let serverClientIdKey = "SERVER_CLIENT_ID"

private func loadGoogleServiceInfo() -> [String: Any]? {
  guard let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
  else {
    return nil
  }
  return NSDictionary(contentsOfFile: plistPath) as? [String: Any]
}

/// Deep-converts values to something that can be safely encoded with the standard message codec,
/// for use in making NSError userInfo values safe to send as FlutterError details.
private func sanitizedUserInfo(_ value: Any?) -> Any {
  switch value {
  case let error as NSError:
    return [
      "domain": error.domain,
      "code": "\(error.code)",
      "localizedDescription": error.localizedDescription,
      "userInfo": sanitizedUserInfo(error.userInfo),
    ]
  case let string as String:
    return string
  case let url as URL:
    return url.absoluteString
  case let number as NSNumber:
    return number
  case let array as [Any]:
    return array.map { sanitizedUserInfo($0) }
  case let dict as [AnyHashable: Any]:
    var safeValues: [AnyHashable: Any] = [:]
    safeValues.reserveCapacity(dict.count)
    for (key, nestedValue) in dict {
      safeValues[key] = sanitizedUserInfo(nestedValue)
    }
    return safeValues
  default:
    if let value {
      return "[Unsupported type: \(String(describing: type(of: value)))]"
    }
    return "[Unsupported type: nil]"
  }
}

/// Maps an NSError to a corresponding FlutterError.
///
/// This should only be used when an error can't be recognized and mapped to a
/// GoogleSignInErrorCode.
private func flutterError(from error: NSError?) -> FlutterError {
  return FlutterError(
    code: String(format: "%@: %ld", error?.domain ?? "(null)", error?.code ?? 0),
    message: error?.localizedDescription,
    details: sanitizedUserInfo(error?.userInfo))
}

/// Maps a GIDSignInErrorCode to the corresponding Pigeon GoogleSignInErrorCode.
private func pigeonErrorCode(for gidSignInErrorCode: Int) -> FSIGoogleSignInErrorCode {
  switch gidSignInErrorCode {
  case GIDSignInError.keychain.rawValue:
    return .keychainError
  case GIDSignInError.canceled.rawValue:
    return .canceled
  case GIDSignInError.hasNoAuthInKeychain.rawValue:
    return .noAuthInKeychain
  case GIDSignInError.EMM.rawValue:
    return .eemError
  case GIDSignInError.scopesAlreadyGranted.rawValue:
    return .scopesAlreadyGranted
  case GIDSignInError.mismatchWithCurrentUser.rawValue:
    return .userMismatch
  default:
    return .unknown
  }
}

public final class GoogleSignInPlugin: NSObject, FlutterPlugin, FSIGoogleSignInApi {
  /// Instance used to manage Google Sign In authentication including
  /// sign in, sign out, and requesting additional scopes.
  let signIn: any FSIGIDSignIn

  /// A mapping of user IDs to GIDGoogleUser instances to use for follow-up calls.
  var usersByIdentifier: [String: any FSIGIDGoogleUser] = [:]

  /// The contents of GoogleService-Info.plist, if it exists.
  private let googleServiceProperties: [String: Any]?

  /// The view provider, to access the current Flutter view.
  private let viewProvider: any FSIViewProvider

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = GoogleSignInPlugin(
      viewProvider: FSIDefaultViewProvider(registrar: registrar))
    registrar.addApplicationDelegate(instance)
    #if os(iOS)
      registrar.addSceneDelegate(instance)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif
    SetUpFSIGoogleSignInApi(messenger, instance)
  }

  /// Inject view provider for testing.
  convenience init(viewProvider: any FSIViewProvider) {
    self.init(signIn: FSIGIDSignInWrapper(), viewProvider: viewProvider)
  }

  /// Inject `FSIGIDSignIn` for testing.
  convenience init(signIn: any FSIGIDSignIn, viewProvider: any FSIViewProvider) {
    self.init(
      signIn: signIn,
      viewProvider: viewProvider,
      googleServiceProperties: loadGoogleServiceInfo())
  }

  /// Inject `FSIGIDSignIn` and `googleServiceProperties` for testing.
  init(
    signIn: any FSIGIDSignIn,
    viewProvider: any FSIViewProvider,
    googleServiceProperties: [String: Any]?
  ) {
    self.signIn = signIn
    self.viewProvider = viewProvider
    self.googleServiceProperties = googleServiceProperties
    super.init()

    // On the iOS simulator, we get "Broken pipe" errors after sign-in for some
    // unknown reason. We can avoid crashing the app by ignoring them.
    signal(SIGPIPE, SIG_IGN)
  }

  // MARK: - FlutterPlugin

  #if os(iOS)
    public func application(
      _ application: UIApplication,
      open url: URL,
      options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
      return signIn.handle(url)
    }

    /// Forwards each URL to GIDSignIn. Extracted so tests can cover scene URL
    /// handling without constructing `UIOpenURLContext`.
    ///
    /// Returns `true` if GIDSignIn handled any of the URLs.
    func handleURLs(_ urls: [URL]) -> Bool {
      var handled = false
      for url in urls {
        handled = signIn.handle(url) || handled
      }
      return handled
    }
  #else
    public func handleOpen(_ urls: [URL]) -> Bool {
      var handled = false
      for url in urls {
        handled = signIn.handle(url) || handled
      }
      return handled
    }
  #endif

  // MARK: - FSIGoogleSignInApi

  public func configure(
    withParameters params: FSIPlatformConfigurationParams,
    error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    // If configuration information was passed from Dart, or present in GoogleService-Info.plist,
    // use that. Otherwise, keep the default configuration, which GIDSignIn will automatically
    // populate from Info.plist values (the recommended configuration method).
    if let configuration = configuration(
      clientIdentifier: params.clientId,
      serverClientIdentifier: params.serverClientId,
      hostedDomain: params.hostedDomain)
    {
      signIn.configuration = configuration
    }
  }

  public func restorePreviousSignIn(
    completion: @escaping (FSISignInResult?, FlutterError?) -> Void
  ) {
    signIn.restorePreviousSignIn { [weak self] user, error in
      self?.handleAuthResult(
        user: user, serverAuthCode: nil, error: error, completion: completion)
    }
  }

  public func signIn(
    withScopeHint scopeHint: [String],
    nonce: String?,
    completion: @escaping (FSISignInResult?, FlutterError?) -> Void
  ) {
    let exception = performSignIn(hint: nil, additionalScopes: scopeHint, nonce: nonce) {
      [weak self] signInResult, error in
      self?.handleAuthResult(
        user: signInResult?.user,
        serverAuthCode: signInResult?.serverAuthCode,
        error: error,
        completion: completion)
    }
    if let exception {
      completion(
        nil,
        FlutterError(
          code: "google_sign_in", message: exception.reason, details: exception.name.rawValue))
    }
  }

  public func refreshedAuthorizationTokens(
    forUser userId: String,
    completion: @escaping (FSISignInResult?, FlutterError?) -> Void
  ) {
    guard let user = usersByIdentifier[userId] else {
      completion(
        FSISignInResult.make(
          with: nil,
          error: FSISignInFailure.make(
            withType: .userMismatch,
            message: "The user is no longer signed in.",
            details: nil)),
        nil)
      return
    }

    user.refreshTokensIfNeeded { [weak self] refreshedUser, error in
      self?.handleAuthResult(
        user: refreshedUser, serverAuthCode: nil, error: error, completion: completion)
    }
  }

  public func addScopes(
    _ scopes: [String],
    forUser userId: String,
    completion: @escaping (FSISignInResult?, FlutterError?) -> Void
  ) {
    guard let user = usersByIdentifier[userId] else {
      completion(
        FSISignInResult.make(
          with: nil,
          error: FSISignInFailure.make(
            withType: .userMismatch,
            message: "The user is no longer signed in.",
            details: nil)),
        nil)
      return
    }

    let exception = performAddScopes(scopes, for: user) { [weak self] signInResult, error in
      self?.handleAuthResult(
        user: signInResult?.user,
        serverAuthCode: signInResult?.serverAuthCode,
        error: error,
        completion: completion)
    }
    if let exception {
      completion(
        nil,
        FlutterError(
          code: "request_scopes", message: exception.reason, details: exception.name.rawValue))
    }
  }

  public func signOutWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    signIn.signOut()
    // usersByIdentifier is left populated, because the SDK may still support some operations on the
    // GIDGoogleUser object (e.g., returning existing, non-expired tokens). Operations that the SDK
    // doesn't support will return SDK errors that we can handle as normal.
  }

  public func disconnect(completion: @escaping (FlutterError?) -> Void) {
    signIn.disconnect { error in
      if let error {
        completion(flutterError(from: error as NSError))
      } else {
        completion(nil)
      }
    }
  }

  // MARK: - Private

  /// Wraps the iOS and macOS sign in display methods.
  ///
  /// Returns any `NSException` raised by the SDK, or nil. The exception catcher
  /// wraps only the SDK call itself, since Obj-C exception unwinding through
  /// Swift frames is undefined behavior.
  private func performSignIn(
    hint: String?,
    additionalScopes: [String]?,
    nonce: String?,
    completion: @escaping (FSIGIDSignInResult?, Error?) -> Void
  ) -> NSException? {
    #if os(macOS)
      let presenting = viewProvider.view?.window
    #else
      let presenting = topViewController
    #endif
    return GoogleSignInCatchException {
      self.signIn.signIn(
        withPresenting: presenting,
        hint: hint,
        additionalScopes: additionalScopes,
        nonce: nonce,
        completion: completion)
    }
  }

  /// Wraps the iOS and macOS scope addition methods.
  ///
  /// Returns any `NSException` raised by the SDK, or nil. The exception catcher
  /// wraps only the SDK call itself, since Obj-C exception unwinding through
  /// Swift frames is undefined behavior.
  private func performAddScopes(
    _ scopes: [String],
    for user: any FSIGIDGoogleUser,
    completion: @escaping (FSIGIDSignInResult?, Error?) -> Void
  ) -> NSException? {
    #if os(macOS)
      let presenting = viewProvider.view?.window
    #else
      let presenting = topViewController
    #endif
    return GoogleSignInCatchException {
      user.addScopes(scopes, presenting: presenting, completion: completion)
    }
  }

  /// Returns nil if GoogleService-Info.plist not found and runtimeClientIdentifier is not provided.
  private func configuration(
    clientIdentifier runtimeClientIdentifier: String?,
    serverClientIdentifier runtimeServerClientIdentifier: String?,
    hostedDomain: String?
  ) -> GIDConfiguration? {
    guard
      let clientID = runtimeClientIdentifier
        ?? googleServiceProperties?[clientIdKey] as? String
    else {
      // Creating a GIDConfiguration requires a client identifier.
      return nil
    }
    let serverClientID =
      runtimeServerClientIdentifier
      ?? googleServiceProperties?[serverClientIdKey] as? String

    return GIDConfiguration(
      clientID: clientID,
      serverClientID: serverClientID,
      hostedDomain: hostedDomain,
      openIDRealm: nil)
  }

  private func handleAuthResult(
    user: (any FSIGIDGoogleUser)?,
    serverAuthCode: String?,
    error: Error?,
    completion: @escaping (FSISignInResult?, FlutterError?) -> Void
  ) {
    if let user {
      didSignIn(for: user, serverAuthCode: serverAuthCode, completion: completion)
      return
    }

    // Convert expected errors into structured failure return, and everything else
    // into a generic error.
    let nsError = error as NSError?
    if let nsError, nsError.domain == kGIDSignInErrorDomain {
      completion(
        FSISignInResult.make(
          with: nil,
          error: FSISignInFailure.make(
            withType: pigeonErrorCode(for: nsError.code),
            message: nsError.localizedDescription,
            details: sanitizedUserInfo(nsError.userInfo))),
        nil)
    } else {
      completion(nil, flutterError(from: nsError))
    }
  }

  private func didSignIn(
    for user: any FSIGIDGoogleUser,
    serverAuthCode: String?,
    completion: @escaping (FSISignInResult?, FlutterError?) -> Void
  ) {
    if let userID = user.userID {
      usersByIdentifier[userID] = user
    }

    var photoURL: URL?
    if user.profile?.hasImage == true {
      // Placeholder that will be replaced by on the Dart side based on screen size.
      photoURL = user.profile?.imageURL(withDimension: 1337)
    }

    let userData = FSIUserData.make(
      withDisplayName: user.profile?.name,
      email: user.profile?.email ?? "",
      userId: user.userID ?? "",
      photoUrl: photoURL?.absoluteString,
      idToken: user.idToken?.tokenString)
    let result = FSISignInResult.make(
      with: FSISignInSuccess.make(
        withUser: userData,
        accessToken: user.accessToken.tokenString,
        grantedScopes: user.grantedScopes ?? [],
        serverAuthCode: serverAuthCode),
      error: nil)
    completion(result, nil)
  }

  #if os(iOS)
    private var topViewController: UIViewController? {
      return topViewController(from: viewProvider.viewController)
    }

    /// Recursively iterates through the view hierarchy to return the top most view controller.
    ///
    /// It supports the following scenarios:
    ///
    /// - The view controller is presenting another view.
    /// - The view controller is a UINavigationController.
    /// - The view controller is a UITabBarController.
    ///
    /// - Returns: The top most view controller.
    private func topViewController(from viewController: UIViewController?) -> UIViewController? {
      if let navigationController = viewController as? UINavigationController {
        return topViewController(from: navigationController.viewControllers.last)
      }
      if let tabController = viewController as? UITabBarController {
        return topViewController(from: tabController.selectedViewController)
      }
      if let presentedViewController = viewController?.presentedViewController {
        return topViewController(from: presentedViewController)
      }
      return viewController
    }
  #endif
}

#if os(iOS)
  extension GoogleSignInPlugin: FlutterSceneLifeCycleDelegate {
    public func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) -> Bool
    {
      return handleURLs(urlContexts.map { $0.url })
    }
  }
#endif

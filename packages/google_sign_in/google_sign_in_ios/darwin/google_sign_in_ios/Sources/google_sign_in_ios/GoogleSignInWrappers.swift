// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleSignIn

#if os(macOS)
  import AppKit
#else
  import UIKit
#endif

/// Implementation of `GIDSignInProtocol` that passes through to GIDSignIn.
final class GIDSignInWrapper: GIDSignInProtocol {
  /// The underlying GIDSignIn instance.
  let signIn: GIDSignIn

  init(signIn: GIDSignIn = .sharedInstance) {
    self.signIn = signIn
  }

  var configuration: GIDConfiguration? {
    get { signIn.configuration }
    set { signIn.configuration = newValue }
  }

  func handle(_ url: URL) -> Bool {
    return signIn.handle(url)
  }

  func restorePreviousSignIn(completion: ((GIDGoogleUserProtocol?, Error?) -> Void)?) {
    signIn.restorePreviousSignIn { user, error in
      completion?(user.flatMap { GIDGoogleUserWrapper(user: $0) }, error)
    }
  }

  func signOut() {
    signIn.signOut()
  }

  func disconnect(completion: ((Error?) -> Void)?) {
    signIn.disconnect(completion: completion)
  }

  #if os(iOS) || targetEnvironment(macCatalyst)
    func signIn(
      withPresenting presentingViewController: UIViewController?,
      hint: String?,
      additionalScopes: [String]?,
      nonce: String?,
      completion: ((GIDSignInResultProtocol?, Error?) -> Void)?
    ) {
      // The SDK's Swift API is non-optional; Obj-C passed nil through at runtime.
      signIn.signIn(
        withPresenting: presentingViewController!,
        hint: hint,
        additionalScopes: additionalScopes,
        nonce: nonce
      ) { result, error in
        completion?(result.flatMap { GIDSignInResultWrapper(result: $0) }, error)
      }
    }
  #elseif os(macOS)
    func signIn(
      withPresenting presentingWindow: NSWindow?,
      hint: String?,
      additionalScopes: [String]?,
      nonce: String?,
      completion: ((GIDSignInResultProtocol?, Error?) -> Void)?
    ) {
      signIn.signIn(
        withPresenting: presentingWindow!,
        hint: hint,
        additionalScopes: additionalScopes,
        nonce: nonce
      ) { result, error in
        completion?(result.flatMap { GIDSignInResultWrapper(result: $0) }, error)
      }
    }
  #endif
}

/// Implementation of `GIDSignInResultProtocol` that passes through to GIDSignInResult.
final class GIDSignInResultWrapper: GIDSignInResultProtocol {
  /// The underlying GIDSignInResult instance.
  let result: GIDSignInResult

  init?(result: GIDSignInResult?) {
    guard let result else { return nil }
    self.result = result
  }

  var user: GIDGoogleUserProtocol {
    return GIDGoogleUserWrapper(user: result.user)!
  }

  var serverAuthCode: String? {
    return result.serverAuthCode
  }
}

/// Implementation of `GIDGoogleUserProtocol` that passes through to GIDGoogleUser.
final class GIDGoogleUserWrapper: GIDGoogleUserProtocol {
  /// The underlying GIDGoogleUser instance.
  let user: GIDGoogleUser

  init?(user: GIDGoogleUser?) {
    guard let user else { return nil }
    self.user = user
  }

  var userID: String? {
    return user.userID
  }

  var profile: GIDProfileDataProtocol? {
    return GIDProfileDataWrapper(profileData: user.profile)
  }

  var grantedScopes: [String]? {
    return user.grantedScopes
  }

  var accessToken: GIDTokenProtocol {
    return GIDTokenWrapper(token: user.accessToken)!
  }

  var refreshToken: GIDTokenProtocol {
    return GIDTokenWrapper(token: user.refreshToken)!
  }

  var idToken: GIDTokenProtocol? {
    return GIDTokenWrapper(token: user.idToken)
  }

  func refreshTokensIfNeeded(completion: @escaping (GIDGoogleUserProtocol?, Error?) -> Void) {
    user.refreshTokensIfNeeded { user, error in
      completion(user.flatMap { GIDGoogleUserWrapper(user: $0) }, error)
    }
  }

  #if os(iOS) || targetEnvironment(macCatalyst)
    func addScopes(
      _ scopes: [String],
      presenting presentingViewController: UIViewController?,
      completion: ((GIDSignInResultProtocol?, Error?) -> Void)?
    ) {
      user.addScopes(
        scopes,
        presenting: presentingViewController!
      ) { result, error in
        completion?(result.flatMap { GIDSignInResultWrapper(result: $0) }, error)
      }
    }
  #elseif os(macOS)
    func addScopes(
      _ scopes: [String],
      presenting presentingWindow: NSWindow?,
      completion: ((GIDSignInResultProtocol?, Error?) -> Void)?
    ) {
      user.addScopes(scopes, presenting: presentingWindow!) { result, error in
        completion?(result.flatMap { GIDSignInResultWrapper(result: $0) }, error)
      }
    }
  #endif
}

/// Implementation of `GIDProfileDataProtocol` that passes through to GIDProfileData.
final class GIDProfileDataWrapper: GIDProfileDataProtocol {
  /// The underlying GIDProfileData instance.
  let profileData: GIDProfileData

  init?(profileData: GIDProfileData?) {
    guard let profileData else { return nil }
    self.profileData = profileData
  }

  var email: String {
    return profileData.email
  }

  var name: String {
    return profileData.name
  }

  var hasImage: Bool {
    return profileData.hasImage
  }

  func imageURL(withDimension dimension: UInt) -> URL? {
    return profileData.imageURL(withDimension: dimension)
  }
}

/// Implementation of `GIDTokenProtocol` that passes through to GIDToken.
final class GIDTokenWrapper: GIDTokenProtocol {
  /// The underlying GIDToken instance.
  let token: GIDToken

  init?(token: GIDToken?) {
    guard let token else { return nil }
    self.token = token
  }

  var tokenString: String {
    return token.tokenString
  }

  var expirationDate: Date? {
    return token.expirationDate
  }
}

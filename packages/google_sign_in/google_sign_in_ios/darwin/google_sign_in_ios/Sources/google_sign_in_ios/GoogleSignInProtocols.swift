// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleSignIn

#if os(macOS)
  import AppKit
#else
  import UIKit
#endif

/// An abstraction around the GIDProfileData methods used by the plugin, to allow injecting an
/// alternate implementation in unit tests.
///
/// See GIDProfileData for documentation, as this should always be implemented as a direct
/// passthrough to GIDProfileData.
protocol GIDProfileDataProtocol: AnyObject {
  var email: String { get }
  var name: String { get }
  var hasImage: Bool { get }
  func imageURL(withDimension dimension: UInt) -> URL?
}

/// An abstraction around the GIDToken methods used by the plugin, to allow injecting an
/// alternate implementation in unit tests.
///
/// See GIDToken for documentation, as this should always be implemented as a direct
/// passthrough to GIDToken.
protocol GIDTokenProtocol: AnyObject {
  var tokenString: String { get }
  var expirationDate: Date? { get }
}

/// An abstraction around the GIDSignInResult methods used by the plugin, to allow injecting an
/// alternate implementation in unit tests.
///
/// See GIDSignInResult for documentation, as this should always be implemented as a direct
/// passthrough to GIDSignInResult.
protocol GIDSignInResultProtocol: AnyObject {
  var user: GIDGoogleUserProtocol { get }
  var serverAuthCode: String? { get }
}

/// An abstraction around the GIDGoogleUser methods used by the plugin, to allow injecting an
/// alternate implementation in unit tests.
///
/// See GIDGoogleUser for documentation, as this should always be implemented as a direct
/// passthrough to GIDGoogleUser.
protocol GIDGoogleUserProtocol: AnyObject {
  var userID: String? { get }
  var profile: GIDProfileDataProtocol? { get }
  var grantedScopes: [String]? { get }
  var accessToken: GIDTokenProtocol { get }
  var refreshToken: GIDTokenProtocol { get }
  var idToken: GIDTokenProtocol? { get }

  func refreshTokensIfNeeded(completion: @escaping (GIDGoogleUserProtocol?, Error?) -> Void)

  #if os(iOS) || targetEnvironment(macCatalyst)
    func addScopes(
      _ scopes: [String],
      presenting presentingViewController: UIViewController?,
      completion: ((GIDSignInResultProtocol?, Error?) -> Void)?
    )
  #elseif os(macOS)
    func addScopes(
      _ scopes: [String],
      presenting presentingWindow: NSWindow?,
      completion: ((GIDSignInResultProtocol?, Error?) -> Void)?
    )
  #endif
}

/// An abstraction around the GIDSignIn methods used by the plugin, to allow injecting an alternate
/// implementation in unit tests.
///
/// See GIDSignIn for documentation, as this should always be implemented as a direct passthrough
/// to GIDSignIn.
protocol GIDSignInProtocol: AnyObject {
  var configuration: GIDConfiguration? { get set }

  func handle(_ url: URL) -> Bool

  func restorePreviousSignIn(completion: ((GIDGoogleUserProtocol?, Error?) -> Void)?)

  func signOut()

  func disconnect(completion: ((Error?) -> Void)?)

  #if os(iOS) || targetEnvironment(macCatalyst)
    func signIn(
      withPresenting presentingViewController: UIViewController?,
      hint: String?,
      additionalScopes: [String]?,
      nonce: String?,
      completion: ((GIDSignInResultProtocol?, Error?) -> Void)?
    )
  #elseif os(macOS)
    func signIn(
      withPresenting presentingWindow: NSWindow?,
      hint: String?,
      additionalScopes: [String]?,
      nonce: String?,
      completion: ((GIDSignInResultProtocol?, Error?) -> Void)?
    )
  #endif
}

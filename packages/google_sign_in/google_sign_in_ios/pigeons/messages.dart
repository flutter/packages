// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    objcHeaderOut:
        'darwin/google_sign_in_ios/Sources/google_sign_in_ios/include/google_sign_in_ios/messages.g.h',
    objcSourceOut:
        'darwin/google_sign_in_ios/Sources/google_sign_in_ios/messages.g.m',
    objcOptions: ObjcOptions(
      prefix: 'FSI',
      headerIncludePath: './include/google_sign_in_ios/messages.g.h',
    ),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
class PlatformConfigurationParams {
  PlatformConfigurationParams({
    this.clientId,
    this.serverClientId,
    this.hostedDomain,
  });

  final String? clientId;
  final String? serverClientId;
  final String? hostedDomain;
}

/// Pigeon version of GoogleSignInUserData + AuthenticationTokenData.
///
/// See GoogleSignInUserData and AuthenticationTokenData for details.
class UserData {
  UserData({
    required this.email,
    required this.userId,
    this.displayName,
    this.photoUrl,
    this.idToken,
  });

  final String? displayName;
  final String email;
  final String userId;
  final String? photoUrl;
  final String? idToken;
}

/// Enum mapping of known codes from
/// https://developers.google.com/identity/sign-in/ios/reference/Enums/GIDSignInErrorCode
enum GoogleSignInErrorCode {
  /// Either the underlying kGIDSignInErrorCodeUnknown, or a code that isn't
  /// a known code mapped to a value below.
  unknown,

  /// kGIDSignInErrorCodeKeychain; an error reading or writing to keychain.
  keychainError,

  /// kGIDSignInErrorCodeHasNoAuthInKeychain; no auth present in the keychain.
  ///
  /// For restorePreviousSignIn, this indicates that there is no sign in to
  /// restore.
  noAuthInKeychain,

  /// kGIDSignInErrorCodeCanceled; the request was canceled by the user.
  canceled,

  /// kGIDSignInErrorCodeEMM; an enterprise management error occurred.
  eemError,

  /// kGIDSignInErrorCodeScopesAlreadyGranted; the requested scopes have already
  /// been granted.
  scopesAlreadyGranted,

  /// kGIDSignInErrorCodeMismatchWithCurrentUser; an operation was requested on
  /// a non-current user.
  userMismatch,
}

/// The response from an auth call.
// TODO(stuartmorgan): Switch to a sealed base class with two subclasses instead
// of using composition when the plugin is migrated to Swift.
class SignInResult {
  /// The success result, if any.
  ///
  /// Exactly one of success and error will be non-nil.
  SignInSuccess? success;

  /// The error result, if any.
  ///
  /// Exactly one of success and error will be non-nil.
  SignInFailure? error;
}

/// An sign in failure.
class SignInFailure {
  /// The type of failure.
  late GoogleSignInErrorCode type;

  /// The message associated with the failure, if any.
  String? message;

  /// Extra details about the failure, if any.
  Object? details;
}

/// A successful auth result.
///
/// Corresponds to the information in a native GIDSignInResult. Because of the
/// structure of the Google Sign In SDK, this has information corresponding to
/// both authn and authz steps, even though incremental authorization is
/// supported.
class SignInSuccess {
  late UserData user;

  late String accessToken;

  late List<String> grantedScopes;

  // This is set only on a new sign in or scope grant, not a restored sign-in
  // or a call to getRefreshedAuthorizationTokens.
  // See https://github.com/google/GoogleSignIn-iOS/issues/202
  String? serverAuthCode;
}

@HostApi()
abstract class GoogleSignInApi {
  /// Configures the sign in object with application-level parameters.
  @ObjCSelector('configureWithParameters:')
  void configure(PlatformConfigurationParams params);

  /// Attempts to restore an existing sign-in, if any, with minimal user
  /// interaction.
  @async
  SignInResult restorePreviousSignIn();

  /// Starts a sign in with user interaction.
  @async
  @ObjCSelector('signInWithScopeHint:nonce:')
  SignInResult signIn(List<String> scopeHint, String? nonce);

  /// Requests the access token for the current sign in.
  @async
  @ObjCSelector('refreshedAuthorizationTokensForUser:')
  SignInResult getRefreshedAuthorizationTokens(String userId);

  /// Requests authorization of the given additional scopes.
  @async
  @ObjCSelector('addScopes:forUser:')
  SignInResult addScopes(List<String> scopes, String userId);

  /// Signs out the current user.
  void signOut();

  /// Revokes scope grants to the application.
  @async
  void disconnect();
}

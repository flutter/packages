// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

/// An exception throws by the plugin when there is authenication or
/// authorization failure, or some other error.
@immutable
class GoogleSignInException implements Exception {
  /// Crceates a new exception with the given information.
  const GoogleSignInException({
    required this.code,
    this.description,
    this.details,
  });

  /// The type of failure.
  final GoogleSignInExceptionCode code;

  /// A human-readable description of the failure.
  final String? description;

  /// Any additional details about the failure.
  final Object? details;

  @override
  String toString() =>
      'GoogleSignInException(code $code, $description, $details)';
}

/// Types of [GoogleSignInException]s, as indicated by
/// [GoogleSignInException.code].
///
/// Adding new values to this enum in the future will *not* be considered a
/// breaking change, so clients should not assume they can exhaustively match
/// exception codes. Clients should always include a default or other fallback.
enum GoogleSignInExceptionCode {
  /// A catch-all for implemenatations that need to return a code that does not
  /// have a corresponding known code.
  ///
  /// Whenever possible, implementators should update the platform interface to
  /// add new codes instead of using this type. When it is used, the
  /// [GoogleSignInException.description] should have information allowing
  /// developers to understand the issue.
  unknownError,

  /// The operation was canceled by the user.
  canceled,

  /// The operation was interrupted for a reason other than being intentionally
  /// canceled by the user.
  interrupted,

  /// The client is misconfigured.
  ///
  /// The [GoogleSignInException.description] should include details about the
  /// configuration problem.
  clientConfigurationError,

  /// The underlying auth SDK is unavailable or misconfigured.
  providerConfigurationError,

  /// UI needed to be displayed, but could not be.
  ///
  /// For example, this can be returned on Android if a call tries to show UI
  /// when no Activity is available.
  uiUnavailable,

  /// An operation was attempted on a user who is not the current user, on a
  /// platform where the SDK only supports a single user being signed in at a
  /// time.
  userMismatch,
}

/// The parameters to use when initializing the sign in process.
///
/// See:
/// https://developers.google.com/identity/sign-in/web/reference#gapiauth2initparams
@immutable
class InitParameters {
  /// The parameters to use when initializing the sign in process.
  const InitParameters({
    this.clientId,
    this.serverClientId,
    this.nonce,
    this.hostedDomain,
  });

  /// The OAuth client ID of the app.
  ///
  /// The default is null, which means that the client ID will be sourced from a
  /// configuration file, if required on the current platform. A value specified
  /// here takes precedence over a value specified in a configuration file.
  /// See also:
  ///
  ///   * [Platform Integration](https://github.com/flutter/packages/tree/main/packages/google_sign_in/google_sign_in#platform-integration),
  ///     where you can find the details about the configuration files.
  final String? clientId;

  /// The OAuth client ID of the backend server.
  ///
  /// The default is null, which means that the server client ID will be sourced
  /// from a configuration file, if available and supported on the current
  /// platform. A value specified here takes precedence over a value specified
  /// in a configuration file.
  ///
  /// See also:
  ///
  ///   * [Platform Integration](https://github.com/flutter/packages/tree/main/packages/google_sign_in/google_sign_in#platform-integration),
  ///     where you can find the details about the configuration files.
  final String? serverClientId;

  /// An optional nonce for added security in ID token requests.
  final String? nonce;

  /// A hosted domain to restrict accounts to.
  ///
  /// The default is null, meaning no restriction.
  ///
  /// How this restriction is interpreted if provided may vary by platform.
  // This is in init paramater because different platforms apply it at different
  // stages, and there is no expected use case for an instance varying in
  // hosting restriction across calls, so this allows each implemented to handle
  // it however best applies to its underlying SDK.
  final String? hostedDomain;
}

/// Parameters for the attemptLightweightAuthentication method.
@immutable
class AttemptLightweightAuthenticationParameters {
  /// Creates new authentication parameters.
  const AttemptLightweightAuthenticationParameters();

  // This class exists despite currently being empty to allow future addition of
  // parameters without breaking changes.
}

/// Parameters for the authenticate method.
@immutable
class AuthenticateParameters {
  /// Creates new authentication parameters.
  const AuthenticateParameters({this.scopeHint = const <String>[]});

  /// A list of scopes that the application will attempt to use/request
  /// immediately.
  ///
  /// Implementations should ignore this paramater unless the underlying SDK
  /// provides a combined authentication+authorization UI flow. Clients are
  /// responsible for triggering an explicit authorization flow if authorization
  /// isn't granted.
  final List<String> scopeHint;
}

/// Common elements of authorization method parameters.
///
/// Fields should be added here if they would apply to most or all authorization
/// requests, in particular if they apply to both
/// [ClientAuthorizationTokensForScopesParameters] and
/// [ServerAuthorizationTokensForScopesParameters].
@immutable
class AuthorizationRequestDetails {
  /// Creates a new authorization request specification.
  const AuthorizationRequestDetails({
    required this.scopes,
    required this.userId,
    required this.email,
    required this.promptIfUnauthorized,
  });

  /// The scopes to be authorized.
  final List<String> scopes;

  /// The account to authorize.
  ///
  /// If this is not specified, the platform implementation will determine the
  /// account, and the method of doing so may vary by platform. For instance,
  /// it may use the last account that was signed in, or it may prompt for
  /// authentication as part of the authorization flow.
  final String? userId;

  /// The email address of the account to authorize.
  ///
  /// Some platforms reference accounts by email at the SDK level, so this
  /// should be provided if userId is provided.
  final String? email;

  /// Whether to allow showing UI if the authorizations are not already
  /// available without UI.
  ///
  /// Implementations should guarantee the 'false' behavior; if an underlying
  /// SDK method may or may not show UI, and the wrapper cannot reliably
  /// determine in advance, it should fail rather than call that method if
  /// this parameter is false.
  final bool promptIfUnauthorized;
}

/// Parameters for the clientAuthorizationTokensForScopes method.
//
// This is distinct from [AuthorizationRequestDetails] to allow for divergence
// in method paramaters in the future without breaking changes.
@immutable
class ClientAuthorizationTokensForScopesParameters {
  /// Creates a new parameter object with the given details.
  const ClientAuthorizationTokensForScopesParameters({required this.request});

  /// Details about the authorization request.
  final AuthorizationRequestDetails request;
}

/// Parameters for the serverAuthorizationTokensForScopes method.
//
// This is distinct from [AuthorizationRequestDetails] to allow for divergence
// in method paramaters in the future without breaking changes.
@immutable
class ServerAuthorizationTokensForScopesParameters {
  /// Creates a new parameter object with the given details.
  const ServerAuthorizationTokensForScopesParameters({required this.request});

  /// Details about the authorization request.
  final AuthorizationRequestDetails request;
}

/// Holds information about the signed-in user.
@immutable
class GoogleSignInUserData {
  /// Uses the given data to construct an instance.
  const GoogleSignInUserData({
    required this.email,
    required this.id,
    this.displayName,
    this.photoUrl,
  });

  /// The user's display name.
  ///
  /// Not guaranteed to be present for all users, even when configured.
  final String? displayName;

  /// The user's email address.
  ///
  /// Applications should not key users by email address since a Google
  /// account's email address can change. Use [id] as a key instead.
  ///
  /// This should not be used to communicate the currently signed in user to a
  /// backend server. Instead, send an ID token which can be securely validated
  /// on the server. See [AuthenticationTokenData.idToken].
  final String email;

  /// The user's unique account ID.
  ///
  /// This is the preferred unique key to use for a user record.
  ///
  /// This should not be used to communicate the currently signed in user to a
  /// backend server. Instead, send an ID token which can be securely validated
  /// on the server. See [AuthenticationTokenData.idToken].
  final String id;

  /// The user's profile picture URL.
  ///
  /// Not guaranteed to be present for all users, even when configured.
  final String? photoUrl;

  @override
  int get hashCode => Object.hash(displayName, email, id, photoUrl);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GoogleSignInUserData &&
        other.displayName == displayName &&
        other.email == email &&
        other.id == id &&
        other.photoUrl == photoUrl;
  }
}

/// Holds tokens that result from authentication.
@immutable
class AuthenticationTokenData {
  /// Creates authentication data with the given tokens.
  const AuthenticationTokenData({required this.idToken});

  /// A token that can be sent to your own server to verify the authentication
  /// data.
  final String? idToken;

  @override
  int get hashCode => idToken.hashCode;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AuthenticationTokenData && other.idToken == idToken;
  }
}

/// Holds tokens that result from authorization for a client endpoint.
@immutable
class ClientAuthorizationTokenData {
  /// Creates authorization data with the given tokens.
  const ClientAuthorizationTokenData({required this.accessToken});

  /// The OAuth2 access token used to access Google services.
  final String accessToken;

  @override
  int get hashCode => accessToken.hashCode;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ClientAuthorizationTokenData &&
        other.accessToken == accessToken;
  }
}

/// Holds tokens that result from authorization for a server endpoint.
@immutable
class ServerAuthorizationTokenData {
  /// Creates authorization data with the given tokens.
  const ServerAuthorizationTokenData({required this.serverAuthCode});

  /// Auth code to provide to a backend server to exchange for access or
  /// refresh tokens.
  final String serverAuthCode;

  @override
  int get hashCode => serverAuthCode.hashCode;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ServerAuthorizationTokenData &&
        other.serverAuthCode == serverAuthCode;
  }
}

/// Return value for authentication request methods.
///
/// Contains information about the authenticated user, as well as authentication
/// tokens.
@immutable
class AuthenticationResults {
  /// Creates a new result object.
  const AuthenticationResults({
    required this.user,
    required this.authenticationTokens,
  });

  /// The user that was authenticated.
  final GoogleSignInUserData user;

  /// Authentication tokens for the signed-in user.
  final AuthenticationTokenData authenticationTokens;
}

/// Parameters for the clearAuthorizationToken method.
@immutable
class ClearAuthorizationTokenParams {
  /// Creates new parameters for clearAuthorizationToken with the given
  /// [accessToken]
  const ClearAuthorizationTokenParams({required this.accessToken});

  /// The OAuth2 access token to clear.
  final String accessToken;

  @override
  int get hashCode => accessToken.hashCode;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ClearAuthorizationTokenParams &&
        other.accessToken == accessToken;
  }
}

/// Parameters for the signOut method.
@immutable
class SignOutParams {
  /// Creates new sign-out parameters.
  const SignOutParams();

  // This class exists despite currently being empty to allow future addition of
  // parameters without breaking changes.
}

/// Parameters for the disconnect method.
@immutable
class DisconnectParams {
  /// Creates new disconnect parameters.
  const DisconnectParams();

  // This class exists despite currently being empty to allow future addition of
  // parameters without breaking changes.
}

/// A base class for authentication event streams.
@immutable
sealed class AuthenticationEvent {
  const AuthenticationEvent();
}

/// A sign-in event, corresponding to an authentication flow completing
/// successfully.
@immutable
class AuthenticationEventSignIn extends AuthenticationEvent {
  /// Creates an event for a successful sign in.
  const AuthenticationEventSignIn({
    required this.user,
    required this.authenticationTokens,
  });

  /// The user that was authenticated.
  final GoogleSignInUserData user;

  /// Authentication tokens for the signed-in user.
  final AuthenticationTokenData authenticationTokens;
}

/// A sign-out event, corresponding to a user having been signed out.
///
/// Implicit sign-outs (for example, due to server-side authentication
/// revocation, or timeouts) are not guaranteed to send events.
@immutable
class AuthenticationEventSignOut extends AuthenticationEvent {}

/// An authentication failure that resulted in an exception.
@immutable
class AuthenticationEventException extends AuthenticationEvent {
  /// Creates an exception event.
  const AuthenticationEventException(this.exception);

  /// The exception thrown during authentication.
  final GoogleSignInException exception;
}

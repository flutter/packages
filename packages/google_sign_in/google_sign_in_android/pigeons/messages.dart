// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut:
        'android/src/main/kotlin/io/flutter/plugins/googlesignin/Messages.kt',
    kotlinOptions: KotlinOptions(package: 'io.flutter.plugins.googlesignin'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// The information necessary to build an authorization request.
///
/// Corresponds to the native AuthorizationRequest object, but only contains
/// the fields used by this plugin.
class PlatformAuthorizationRequest {
  PlatformAuthorizationRequest({required this.scopes, this.hostedDomain});
  List<String> scopes;
  String? hostedDomain;
  String? accountEmail;

  /// If set, adds a call to requestOfflineAccess(this string, true);
  String? serverClientIdForForcedRefreshToken;
}

/// The information necessary to build a credential request.
///
/// Combines the parts of the native GetCredentialRequest and CredentialOption
/// classes that are used for this plugin.
class GetCredentialRequestParams {
  GetCredentialRequestParams({
    required this.useButtonFlow,
    required this.googleIdOptionParams,
    this.serverClientId,
    this.hostedDomain,
    this.nonce,
  });

  /// Whether to use the Sign in with Google button flow
  /// (GetSignInWithGoogleOption), corresponding to an explicit sign-in request,
  /// or not (GetGoogleIdOption), corresponding to an implicit potential
  /// sign-in.
  bool useButtonFlow;

  /// Parameters specific to GetGoogleIdOption.
  ///
  /// Ignored if useButtonFlow is true.
  GetCredentialRequestGoogleIdOptionParams googleIdOptionParams;

  String? serverClientId;
  String? hostedDomain;
  String? nonce;
}

class GetCredentialRequestGoogleIdOptionParams {
  GetCredentialRequestGoogleIdOptionParams({
    required this.filterToAuthorized,
    required this.autoSelectEnabled,
  });

  bool filterToAuthorized;
  bool autoSelectEnabled;
}

/// Parameters for revoking authorization.
///
/// Corresponds to the native RevokeAccessRequest.
/// https://developers.google.com/android/reference/com/google/android/gms/auth/api/identity/RevokeAccessRequest
class PlatformRevokeAccessRequest {
  PlatformRevokeAccessRequest({
    required this.accountEmail,
    required this.scopes,
  });

  /// The email for the Google account to revoke authorizations for.
  String accountEmail;

  /// A list of requested scopes.
  ///
  /// Per docs, all granted scopes will be revoked, not only the ones passed
  /// here. However, at least one currently-granted scope must be provided.
  List<String> scopes;
}

/// Pigeon equivalent of the native GoogleIdTokenCredential.
class PlatformGoogleIdTokenCredential {
  String? displayName;
  String? familyName;
  String? givenName;
  late String id;
  late String idToken;
  String? profilePictureUri;
}

enum GetCredentialFailureType {
  /// Indicates that a credential was returned, but it was not of the expected
  /// type.
  unexpectedCredentialType,

  /// Indicates that a server client ID was not provided.
  missingServerClientId,

  /// Indicates that the user needs to be prompted for authorization, but there
  /// is no current activity to prompt in.
  noActivity,

  // Types from https://developer.android.com/reference/android/credentials/GetCredentialException
  /// The request was internally interrupted.
  interrupted,

  /// The request was canceled by the user.
  canceled,

  /// No matching credential was found.
  noCredential,

  /// The provider was not properly configured.
  providerConfigurationIssue,

  /// The credential manager is not supported on this device.
  unsupported,

  /// The request failed for an unknown reason.
  unknown,
}

/// The response from a `getCredential` call.
///
/// This is not the same as a native GetCredentialResponse since modeling the
/// response type hierarchy and two-part callback in this interface layer would
/// add a lot of complexity that is not needed for the plugin's use case. It is
/// instead a processed version of the results of those callbacks.
sealed class GetCredentialResult {}

/// An authentication failure.
class GetCredentialFailure extends GetCredentialResult {
  /// The type of failure.
  late GetCredentialFailureType type;

  /// The message associated with the failure, if any.
  String? message;

  /// Extra details about the failure, if any.
  String? details;
}

/// A successful authentication result.
class GetCredentialSuccess extends GetCredentialResult {
  late PlatformGoogleIdTokenCredential credential;
}

enum AuthorizeFailureType {
  /// Indicates that the requested types are not currently authorized.
  ///
  /// This is returned only if promptIfUnauthorized is false, indicating that
  /// the user would need to be prompted for authorization.
  unauthorized,

  /// Indicates that the call to AuthorizationClient.authorize itself failed.
  authorizeFailure,

  /// Corresponds to SendIntentException, indicating that the pending intent is
  /// no longer available.
  pendingIntentException,

  /// Corresponds to an SendIntentException in onActivityResult, indicating that
  /// either authorization failed, or the result was not available for some
  /// reason.
  apiException,

  /// Indicates that the user needs to be prompted for authorization, but there
  /// is no current activity to prompt in.
  noActivity,
}

/// The response from an `authorize` call.
sealed class AuthorizeResult {}

/// An authorization failure
class AuthorizeFailure extends AuthorizeResult {
  /// The type of failure.
  late AuthorizeFailureType type;

  /// The message associated with the failure, if any.
  String? message;

  /// Extra details about the failure, if any.
  String? details;
}

/// A successful authorization result.
///
/// Corresponds to a native AuthorizationResult.
class PlatformAuthorizationResult extends AuthorizeResult {
  String? accessToken;
  String? serverAuthCode;
  late List<String> grantedScopes;
}

@HostApi()
abstract class GoogleSignInApi {
  /// Returns the server client ID parsed from google-services.json by the
  /// google-services Gradle script, if any.
  String? getGoogleServicesJsonServerClientId();

  /// Requests an authentication credential (sign in) via CredentialManager's
  /// getCredential.
  @async
  GetCredentialResult getCredential(GetCredentialRequestParams params);

  /// Clears CredentialManager credential state.
  @async
  void clearCredentialState();

  /// Clears the authorization cache for the given token.
  @async
  void clearAuthorizationToken(String token);

  /// Requests authorization tokens via AuthorizationClient.
  @async
  AuthorizeResult authorize(
    PlatformAuthorizationRequest params, {
    required bool promptIfUnauthorized,
  });

  @async
  void revokeAccess(PlatformRevokeAccessRequest params);
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'src/messages.g.dart';

/// Android implementation of [GoogleSignInPlatform].
class GoogleSignInAndroid extends GoogleSignInPlatform {
  /// Creates a new plugin implementation instance.
  GoogleSignInAndroid({@visibleForTesting GoogleSignInApi? api})
    : _hostApi = api ?? GoogleSignInApi();

  final GoogleSignInApi _hostApi;

  String? _serverClientId;
  String? _hostedDomain;
  String? _nonce;
  // A cache of accounts that have been successfully authenticated via this
  // plugin instance, and one of the scopes that has been authorized for it.
  final Map<String, String> _cachedAccounts = <String, String>{};

  /// Registers this class as the default instance of [GoogleSignInPlatform].
  static void registerWith() {
    GoogleSignInPlatform.instance = GoogleSignInAndroid();
  }

  @override
  Future<void> clearAuthorizationToken(ClearAuthorizationTokenParams params) {
    return _hostApi.clearAuthorizationToken(params.accessToken);
  }

  @override
  Future<void> init(InitParameters params) async {
    _hostedDomain = params.hostedDomain;
    _serverClientId =
        params.serverClientId ??
        await _hostApi.getGoogleServicesJsonServerClientId();
    _nonce = params.nonce;
    // The clientId parameter is not supported on Android.
    // Android apps are identified by their package name and the SHA-1 of their signing key.
  }

  @override
  Future<AuthenticationResults?> attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) async {
    // Attempt to auto-sign-in, for single-account or returning users.
    PlatformGoogleIdTokenCredential? credential = await _authenticate(
      useButtonFlow: false,
      nonButtonFlowOptions: _LightweightAuthenticationOptions(
        filterToAuthorized: true,
        autoSelectEnabled: true,
      ),
    );
    // If no auto-sign-in is available, potentially prompt for an account via
    // the bottom sheet flow. This is skipped if a hosted domain is set because
    // the one-tap (non-button) flow does not support hosted domain filterss, so
    // could result in authorizing with an account that doesn't match the
    // filter. (The previous should be safe even without a hosted domain filter
    // because filterToAuthorized will only allow accounts that have previously
    // signed in to the app, and an app that uses a hosted domain filter is
    // unlikely to change that filter dynamically.)
    // TODO(stuartmorgan): Remove this check if the SDK adds support for
    //  setHostedDomainFilter for one-tap.
    if (_hostedDomain == null) {
      credential ??= await _authenticate(
        useButtonFlow: false,
        nonButtonFlowOptions: _LightweightAuthenticationOptions(
          filterToAuthorized: false,
          autoSelectEnabled: false,
        ),
      );
    }
    return credential == null
        ? null
        : _authenticationResultFromPlatformCredential(credential);
  }

  @override
  bool supportsAuthenticate() => true;

  @override
  Future<AuthenticationResults> authenticate(
    AuthenticateParameters params,
  ) async {
    // Attempt to authorize with minimal interaction.
    final PlatformGoogleIdTokenCredential? credential = await _authenticate(
      useButtonFlow: true,
      throwForNoAuth: true,
      // Ignored, since useButtonFlow is true.
      nonButtonFlowOptions: _LightweightAuthenticationOptions(
        filterToAuthorized: false,
        autoSelectEnabled: false,
      ),
    );
    // It's not clear from the documentation if this can happen; if it does,
    // no information is available
    if (credential == null) {
      throw const GoogleSignInException(
        code: GoogleSignInExceptionCode.unknownError,
        description: 'Authenticate returned no credential without an error',
      );
    }
    return _authenticationResultFromPlatformCredential(credential);
  }

  @override
  Future<void> signOut(SignOutParams params) {
    return _hostApi.clearCredentialState();
  }

  @override
  Future<void> disconnect(DisconnectParams params) async {
    // AuthorizationClient requires an account, and at least one currently
    // granted scope, to request revocation. The app-facing API currently
    // does not take any parameters, and is documented to revoke all authorized
    // accounts, so disconnect every account that has been authorized.
    // TODO(stuartmorgan): Consider deprecating the account-less API at the
    //  app-facing level, and have it instead be an account-level method, to
    //  better align with the current SDKs.
    for (final MapEntry<String, String> entry in _cachedAccounts.entries) {
      // Because revokeAccess removes all authorizations for the app, not just
      // the scopes provided, (per
      // https://developer.android.com/identity/authorization#revoke-permissions)
      // an arbitrary granted scope is used here.
      await _hostApi.revokeAccess(
        PlatformRevokeAccessRequest(
          accountEmail: entry.key,
          scopes: <String>[entry.value],
        ),
      );
    }
    _cachedAccounts.clear();
    await signOut(const SignOutParams());
  }

  @override
  bool authorizationRequiresUserInteraction() => false;

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  ) async {
    final (:String? accessToken, :String? serverAuthCode) = await _authorize(
      params.request,
      requestOfflineAccess: false,
    );
    return accessToken == null
        ? null
        : ClientAuthorizationTokenData(accessToken: accessToken);
  }

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  ) async {
    final (:String? accessToken, :String? serverAuthCode) = await _authorize(
      params.request,
      requestOfflineAccess: true,
    );
    return serverAuthCode == null
        ? null
        : ServerAuthorizationTokenData(serverAuthCode: serverAuthCode);
  }

  /// Authenticates with the platform credential manager using either the
  /// button-initiated flow (useButtonFlow = true, nonButtonFlowOptions are
  /// ignored), or the lightweight flow (useButtonFlow = false,
  /// nonButtonFlowOptions are used to configure the request).
  ///
  /// See https://developer.android.com/identity/sign-in/credential-manager-siwg
  /// for discussion of the two different flows
  Future<PlatformGoogleIdTokenCredential?> _authenticate({
    required bool useButtonFlow,
    required _LightweightAuthenticationOptions nonButtonFlowOptions,
    bool throwForNoAuth = false,
  }) async {
    final GetCredentialResult authnResult = await _hostApi.getCredential(
      GetCredentialRequestParams(
        useButtonFlow: useButtonFlow,
        googleIdOptionParams: GetCredentialRequestGoogleIdOptionParams(
          filterToAuthorized: nonButtonFlowOptions.filterToAuthorized,
          autoSelectEnabled: nonButtonFlowOptions.autoSelectEnabled,
        ),
        serverClientId: _serverClientId,
        hostedDomain: _hostedDomain,
        nonce: _nonce,
      ),
    );
    switch (authnResult) {
      case GetCredentialFailure():
        String? message = authnResult.message;
        final GoogleSignInExceptionCode code;
        switch (authnResult.type) {
          case GetCredentialFailureType.noCredential:
            if (throwForNoAuth) {
              code = GoogleSignInExceptionCode.unknownError;
              message = 'No credential available: $message';
            } else {
              return null;
            }
          case GetCredentialFailureType.unexpectedCredentialType:
            // This should not actually be possible in practice, so it is
            // grouped under providerConfigurationError instead of given a
            // distinct code.
            code = GoogleSignInExceptionCode.providerConfigurationError;
            message = 'Unexpected credential type: $message';
          case GetCredentialFailureType.noActivity:
            code = GoogleSignInExceptionCode.uiUnavailable;
          case GetCredentialFailureType.interrupted:
            code = GoogleSignInExceptionCode.interrupted;
          case GetCredentialFailureType.providerConfigurationIssue:
            code = GoogleSignInExceptionCode.providerConfigurationError;
          case GetCredentialFailureType.unsupported:
            code = GoogleSignInExceptionCode.providerConfigurationError;
            message = 'Credential Manager not supported. $message';
          case GetCredentialFailureType.canceled:
            code = GoogleSignInExceptionCode.canceled;
          case GetCredentialFailureType.missingServerClientId:
            code = GoogleSignInExceptionCode.clientConfigurationError;
            message = 'serverClientId must be provided on Android';
          case GetCredentialFailureType.unknown:
            code = GoogleSignInExceptionCode.unknownError;
        }
        throw GoogleSignInException(
          code: code,
          description: message,
          details: authnResult.details,
        );
      case GetCredentialSuccess():
        // Store a preliminary entry using the 'openid' scope, which in practice
        // always seems to be granted at authentication time, so that an account
        // that is authenticated but never authorized can still be disconnected.
        _cachedAccounts[authnResult.credential.id] = 'openid';
        return authnResult.credential;
    }
  }

  Future<({String? accessToken, String? serverAuthCode})> _authorize(
    AuthorizationRequestDetails request, {
    required bool requestOfflineAccess,
  }) async {
    final String? email = request.email;
    final AuthorizeResult result = await _hostApi.authorize(
      PlatformAuthorizationRequest(
        scopes: request.scopes,
        accountEmail: email,
        hostedDomain: _hostedDomain,
        serverClientIdForForcedRefreshToken:
            requestOfflineAccess ? _serverClientId : null,
      ),
      promptIfUnauthorized: request.promptIfUnauthorized,
    );
    switch (result) {
      case AuthorizeFailure():
        String? message = result.message;
        final GoogleSignInExceptionCode code;
        switch (result.type) {
          case AuthorizeFailureType.unauthorized:
            // This indicates that there was no existing authorization and
            // prompting wasn't allowed, so just return null.
            return (accessToken: null, serverAuthCode: null);
          case AuthorizeFailureType.pendingIntentException:
            code = GoogleSignInExceptionCode.canceled;
          case AuthorizeFailureType.authorizeFailure:
            message = 'Authorization failed: $message';
            code = GoogleSignInExceptionCode.unknownError;
          case AuthorizeFailureType.apiException:
            message = 'SDK reported an exception: $message';
            code = GoogleSignInExceptionCode.unknownError;
          case AuthorizeFailureType.noActivity:
            code = GoogleSignInExceptionCode.uiUnavailable;
        }
        throw GoogleSignInException(
          code: code,
          description: message,
          details: result.details,
        );
      case PlatformAuthorizationResult():
        final String? accessToken = result.accessToken;
        if (accessToken == null) {
          return (accessToken: null, serverAuthCode: null);
        }
        // Update the account entry with a scope that was reported as granted,
        // just in case for some reason 'openid' isn't valid. If the request
        // wasn't associated with an account, then it won't be available to
        // disconnect.
        // TODO(stuartmorgan): If this becomes an issue, see if there is an
        //  indirect way to get the associated email address that's not
        //  deprecated.
        if (email != null) {
          final String? scope = result.grantedScopes.firstOrNull;
          if (scope != null) {
            _cachedAccounts[email] = scope;
          }
        }
        return (
          accessToken: accessToken,
          serverAuthCode: result.serverAuthCode,
        );
    }
  }

  AuthenticationResults _authenticationResultFromPlatformCredential(
    PlatformGoogleIdTokenCredential credential,
  ) {
    // GoogleIdTokenCredential's ID field is documented to return the
    // email address, not what the other platform SDKs call an ID.
    // The account ID returned by other platform SDKs and the legacy
    // Google Sign In for Android SDK is no longer directly exposed, so it
    // need to be extracted from the token. See
    // https://stackoverflow.com/a/78064720.
    // The ID should always be availabe from the token, but if for some reason
    // it can't be extracted, use the email address instead as a reasonable
    // fallback method of identifying the account.
    final String email = credential.id;
    final String userId = _idFromIdToken(credential.idToken) ?? email;

    return AuthenticationResults(
      user: GoogleSignInUserData(
        email: email,
        id: userId,
        displayName: credential.displayName,
        photoUrl: credential.profilePictureUri,
      ),
      authenticationTokens: AuthenticationTokenData(
        idToken: credential.idToken,
      ),
    );
  }
}

/// A codec that can encode/decode JWT payloads.
///
/// See https://www.rfc-editor.org/rfc/rfc7519#section-3
final Codec<Object?, String> _jwtCodec = json.fuse(utf8).fuse(base64);

/// Extracts the user ID from an idToken.
///
/// See https://stackoverflow.com/a/78064720
String? _idFromIdToken(String idToken) {
  final RegExp jwtTokenRegexp = RegExp(
    r'^(?<header>[^\.\s]+)\.(?<payload>[^\.\s]+)\.(?<signature>[^\.\s]+)$',
  );
  final RegExpMatch? match = jwtTokenRegexp.firstMatch(idToken);
  final String? payload = match?.namedGroup('payload');
  if (payload != null) {
    try {
      final Map<String, Object?>? contents =
          _jwtCodec.decode(base64.normalize(payload)) as Map<String, Object?>?;
      if (contents != null) {
        return contents['sub'] as String?;
      }
    } catch (_) {
      return null;
    }
  }
  return null;
}

/// Options specific to authentication with the lightweight authentication
/// flow, rather than the explict user-requested login flow.
///
/// These correspond to builder options specific to GetGoogleIdOption on the
/// platform side.
class _LightweightAuthenticationOptions {
  _LightweightAuthenticationOptions({
    required this.filterToAuthorized,
    required this.autoSelectEnabled,
  });

  /// If true, only allows selection of accounts that have already authorized
  /// the app.
  bool filterToAuthorized;

  /// If true, automatically selects an account if there is only one
  /// authorized account and no additional user action is required.
  bool autoSelectEnabled;
}

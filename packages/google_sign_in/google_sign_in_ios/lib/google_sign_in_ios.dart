// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'src/messages.g.dart';

/// iOS implementation of [GoogleSignInPlatform].
class GoogleSignInIOS extends GoogleSignInPlatform {
  /// Creates a new plugin implementation instance.
  GoogleSignInIOS({@visibleForTesting GoogleSignInApi? api})
    : _api = api ?? GoogleSignInApi();

  final GoogleSignInApi _api;

  String? _nonce;

  /// Registers this class as the default instance of [GoogleSignInPlatform].
  static void registerWith() {
    GoogleSignInPlatform.instance = GoogleSignInIOS();
  }

  @override
  Future<void> init(InitParameters params) async {
    _nonce = params.nonce;
    await _api.configure(
      PlatformConfigurationParams(
        clientId: params.clientId,
        serverClientId: params.serverClientId,
        hostedDomain: params.hostedDomain,
      ),
    );
  }

  @override
  Future<AuthenticationResults?> attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) async {
    final SignInResult result = await _api.restorePreviousSignIn();

    if (result.error?.type == GoogleSignInErrorCode.noAuthInKeychain) {
      return null;
    }

    final SignInFailure? failure = result.error;
    if (failure != null) {
      throw GoogleSignInException(
        code: _exceptionCodeForErrorPlatformErrorCode(failure.type),
        description: failure.message,
        details: failure.details,
      );
    }

    // The native code must never return a null success and a null error.
    // Switching the native implementation to Swift and using sealed classes
    // in the Pigeon definition (see Android's messages.dart) will allow
    // enforcing this via the type system instead of force unwrapping.
    final SignInSuccess success = result.success!;
    return _authenticationResultsFromSignInSuccess(success);
  }

  @override
  bool supportsAuthenticate() => true;

  @override
  Future<AuthenticationResults> authenticate(
    AuthenticateParameters params,
  ) async {
    final SignInResult result = await _api.signIn(params.scopeHint, _nonce);

    // This should never happen; the corresponding native error code is
    // documented as being specific to restorePreviousSignIn.
    if (result.error?.type == GoogleSignInErrorCode.noAuthInKeychain) {
      throw const GoogleSignInException(
        code: GoogleSignInExceptionCode.unknownError,
        description: 'No auth reported during interactive sign in.',
      );
    }

    final SignInFailure? failure = result.error;
    if (failure != null) {
      throw GoogleSignInException(
        code: _exceptionCodeForErrorPlatformErrorCode(failure.type),
        description: failure.message,
        details: failure.details,
      );
    }

    // The native code must never return a null success and a null error.
    // Switching the native implementation to Swift and using sealed classes
    // in the Pigeon definition (see Android's messages.dart) will allow
    // enforcing this via the type system instead of force unwrapping.
    final SignInSuccess success = result.success!;
    return _authenticationResultsFromSignInSuccess(success);
  }

  @override
  Future<void> signOut(SignOutParams params) {
    return _api.signOut();
  }

  @override
  Future<void> disconnect(DisconnectParams params) async {
    await _api.disconnect();
    await signOut(const SignOutParams());
  }

  @override
  bool authorizationRequiresUserInteraction() => false;

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  ) async {
    final String? accessToken =
        (await _getAuthorizationTokens(params.request)).accessToken;
    return accessToken == null
        ? null
        : ClientAuthorizationTokenData(accessToken: accessToken);
  }

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  ) async {
    final String? serverAuthCode =
        (await _getAuthorizationTokens(params.request)).serverAuthCode;
    return serverAuthCode == null
        ? null
        : ServerAuthorizationTokenData(serverAuthCode: serverAuthCode);
  }

  Future<({String? accessToken, String? serverAuthCode})>
  _getAuthorizationTokens(AuthorizationRequestDetails request) async {
    String? userId = request.userId;

    // The Google Sign In SDK requires authentication before authorization, so
    // if the authentication isn't associated with an existing sign-in user
    // run the authentication flow first.
    if (userId == null) {
      SignInResult result = await _api.restorePreviousSignIn();
      final SignInSuccess? success = result.success;
      if (success == null) {
        // There's no existing sign-in to use, so return the results of the
        // combined authn+authz flow, if prompting is allowed.
        if (request.promptIfUnauthorized) {
          result = await _api.signIn(request.scopes, _nonce);
          return _processAuthorizationResult(result);
        } else {
          // No existing authentication, and no prompting allowed, so return
          // no tokens.
          return (accessToken: null, serverAuthCode: null);
        }
      } else {
        // Discard the authentication information, and extract the user ID to
        // pass back to the authorization step so that it can re-associate
        // with the currently signed in user on the native side.
        userId = success.user.userId;
      }
    }

    final bool useExistingAuthorization = !request.promptIfUnauthorized;
    SignInResult result =
        useExistingAuthorization
            ? await _api.getRefreshedAuthorizationTokens(userId)
            : await _api.addScopes(request.scopes, userId);
    if (!useExistingAuthorization &&
        result.error?.type == GoogleSignInErrorCode.scopesAlreadyGranted) {
      // The Google Sign In SDK returns an error when requesting scopes that are
      // already authorized, so in that case request updated tokens instead to
      // construct a valid token response.
      result = await _api.getRefreshedAuthorizationTokens(userId);
    }
    if (result.error?.type == GoogleSignInErrorCode.noAuthInKeychain) {
      return (accessToken: null, serverAuthCode: null);
    }

    // If re-using an existing authorization, ensure that it has all of the
    // requested scopes before returning it, as the list of requested scopes
    // may have changed since the last authorization.
    if (useExistingAuthorization) {
      final SignInSuccess? success = result.success;
      // Don't validate the OpenID Connect scopes (see
      // https://developers.google.com/identity/protocols/oauth2/scopes#openid-connect
      // for details), as they should always be available, and the granted
      // scopes may not report them with the same string as the request.
      // For example, requesting 'email' can instead result in the grant
      // 'https://www.googleapis.com/auth/userinfo.email'.
      const Set<String> openIdConnectScopes = <String>{
        'email',
        'openid',
        'profile',
      };
      if (success != null) {
        if (request.scopes.any(
          (String scope) =>
              !openIdConnectScopes.contains(scope) &&
              !success.grantedScopes.contains(scope),
        )) {
          return (accessToken: null, serverAuthCode: null);
        }
      }
    }

    return _processAuthorizationResult(result);
  }

  Future<({String? accessToken, String? serverAuthCode})>
  _processAuthorizationResult(SignInResult result) async {
    final SignInFailure? failure = result.error;
    if (failure != null) {
      throw GoogleSignInException(
        code: _exceptionCodeForErrorPlatformErrorCode(failure.type),
        description: failure.message,
        details: failure.details,
      );
    }

    return _authorizationTokenDataFromSignInSuccess(result.success);
  }

  AuthenticationResults _authenticationResultsFromSignInSuccess(
    SignInSuccess result,
  ) {
    final UserData userData = result.user;
    final GoogleSignInUserData user = GoogleSignInUserData(
      email: userData.email,
      id: userData.userId,
      displayName: userData.displayName,
      photoUrl: userData.photoUrl,
    );
    return AuthenticationResults(
      user: user,
      authenticationTokens: AuthenticationTokenData(idToken: userData.idToken),
    );
  }

  ({String? accessToken, String? serverAuthCode})
  _authorizationTokenDataFromSignInSuccess(SignInSuccess? result) {
    return (
      accessToken: result?.accessToken,
      serverAuthCode: result?.serverAuthCode,
    );
  }

  GoogleSignInExceptionCode _exceptionCodeForErrorPlatformErrorCode(
    GoogleSignInErrorCode code,
  ) {
    return switch (code) {
      GoogleSignInErrorCode.unknown => GoogleSignInExceptionCode.unknownError,
      GoogleSignInErrorCode.keychainError =>
        GoogleSignInExceptionCode.providerConfigurationError,
      GoogleSignInErrorCode.canceled => GoogleSignInExceptionCode.canceled,
      GoogleSignInErrorCode.eemError =>
        GoogleSignInExceptionCode.providerConfigurationError,
      GoogleSignInErrorCode.userMismatch =>
        GoogleSignInExceptionCode.userMismatch,
      // These should never be mapped to a GoogleSignInException; the caller
      // should handle them.
      GoogleSignInErrorCode.noAuthInKeychain =>
        throw StateError(
          '_exceptionCodeForErrorPlatformErrorCode called with no auth.',
        ),
      GoogleSignInErrorCode.scopesAlreadyGranted =>
        throw StateError(
          '_exceptionCodeForErrorPlatformErrorCode called with scopes already granted.',
        ),
    };
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'src/messages.g.dart';

// These are magic string values that match the previous implementation on
// Android, docs in the app-facing package, and/or implementations on other
// platforms.
// TODO(stuartmorgan): Replace these with structured errors defined in the
// platform interface when reworking the API surface.
const String _errorCodeSignInCanceled = 'sign_in_canceled';
const String _errorCodeSignInRequired = 'sign_in_required';
const String _errorCodeSignInFailed = 'sign_in_failed';
const String _errorCodeUserRecoverableAuth = 'user_recoverable_auth';
const String _errorCodeIncorrectConfiguration = 'incorrect_configuration';

/// Android implementation of [GoogleSignInPlatform].
class GoogleSignInAndroid extends GoogleSignInPlatform {
  /// Creates a new plugin implementation instance.
  GoogleSignInAndroid({
    @visibleForTesting CredentialManagerApi? credentialManaagerApi,
    @visibleForTesting AuthorizationClientApi? authorizationClientApi,
  })  : _credentialManaagerApi =
            credentialManaagerApi ?? CredentialManagerApi(),
        _authorizationClientApi =
            authorizationClientApi ?? AuthorizationClientApi();

  final CredentialManagerApi _credentialManaagerApi;
  final AuthorizationClientApi _authorizationClientApi;

  String? _serverClientId;
  String? _hostedDomain;
  List<String> _desiredScopes = <String>[];
  bool _forceCodeForRefreshToken = false;
  String? _forcedAccountName;

  /// Registers this class as the default instance of [GoogleSignInPlatform].
  static void registerWith() {
    GoogleSignInPlatform.instance = GoogleSignInAndroid();
  }

  @override
  Future<void> init({
    List<String> scopes = const <String>[],
    SignInOption signInOption = SignInOption.standard,
    String? hostedDomain,
    String? clientId,
    String? forceAccountName,
  }) {
    return initWithParams(SignInInitParameters(
      signInOption: signInOption,
      scopes: scopes,
      hostedDomain: hostedDomain,
      clientId: clientId,
      forceAccountName: forceAccountName,
    ));
  }

  @override
  Future<void> initWithParams(SignInInitParameters params) async {
    _desiredScopes = params.scopes;
    _serverClientId = params.serverClientId;
    // The clientId parameter is not supported on Android.
    // Android apps are identified by their package name and the SHA-1 of their signing key.
    _hostedDomain = params.hostedDomain;
    _forceCodeForRefreshToken = params.forceCodeForRefreshToken;
    _forcedAccountName = params.forceAccountName;
    // TODO(stuartmorgan): Consider adding a prepareGetCredentials call here.
  }

  @override
  Future<GoogleSignInUserData?> signInSilently() async {
    // Attempt to authorize without user interaction.
    final PlatformGoogleIdTokenCredential? credential = await _authenticate(
      filterToAuthorized: true,
      autoSelectEnabled: true,
    );
    if (credential == null) {
      return null;
    }

    // For behavioral compatibility with the current plugin API, also attempt
    // to authorize scopes silently.
    // TODO(stuartmorgan): Restructure the plugin API to eliminate the need for
    // this; see https://github.com/flutter/flutter/issues/119300.
    final PlatformAuthorizationResult? authorization = await _authorize(
        promptIfUnauthorized: false,
        scopes: _desiredScopes,
        accountEmail: _forcedAccountName);
    if (authorization == null) {
      return null;
    }

    return GoogleSignInUserData(
        email: credential.id,
        id: credential.id,
        idToken: credential.idToken,
        serverAuthCode: authorization.serverAuthCode,
        displayName: credential.displayName,
        photoUrl: credential.profilePictureUri);
  }

  @override
  Future<GoogleSignInUserData?> signIn() async {
    // Attempt to authorize without user interaction.
    PlatformGoogleIdTokenCredential? credential = await _authenticate(
      filterToAuthorized: true,
      autoSelectEnabled: true,
    );
    // If no auto-sign-in is available, prompt for an account.
    credential ??= credential = await _authenticate(
      filterToAuthorized: false,
      autoSelectEnabled: false,
      throwGoogleSignInCompatExceptions: true,
    );
    if (credential == null) {
      return null;
    }

    // For behavioral compatibility with the current plugin API, also attempt
    // to authorize scopes.
    // TODO(stuartmorgan): Restructure the plugin API to eliminate the need for
    // this; see https://github.com/flutter/flutter/issues/119300.
    final PlatformAuthorizationResult? authorization = await _authorize(
        promptIfUnauthorized: true,
        scopes: _desiredScopes,
        accountEmail: _forcedAccountName);
    if (authorization == null) {
      return null;
    }

    return GoogleSignInUserData(
        email: credential.id,
        id: credential.id,
        idToken: credential.idToken,
        serverAuthCode: authorization.serverAuthCode,
        displayName: credential.displayName,
        photoUrl: credential.profilePictureUri);
  }

  Future<PlatformGoogleIdTokenCredential?> _authenticate(
      {required bool filterToAuthorized,
      required bool autoSelectEnabled,
      bool throwGoogleSignInCompatExceptions = false}) async {
    final GetCredentialResult authnResult =
        await _credentialManaagerApi.getCredential(GetCredentialRequestParams(
            filterToAuthorized: filterToAuthorized,
            autoSelectEnabled: autoSelectEnabled,
            serverClientId: _serverClientId));
    switch (authnResult) {
      case GetCredentialFailure():
        if (throwGoogleSignInCompatExceptions) {
          switch (authnResult.type) {
            // Most failures don't map directly to an existing failure, so use
            // the previous Google Sign-In's catch-all for most cases.
            case GetCredentialFailureType.unexpectedCredentialType:
            case GetCredentialFailureType.interrupted:
            case GetCredentialFailureType.noCredential:
            case GetCredentialFailureType.providerConfigurationIssue:
            case GetCredentialFailureType.unsupported:
            case GetCredentialFailureType.unknown:
              throw PlatformException(
                  code: _errorCodeSignInFailed, message: authnResult.message);
            case GetCredentialFailureType.canceled:
              throw PlatformException(
                  code: _errorCodeSignInCanceled, message: authnResult.message);
            case GetCredentialFailureType.missingServerClientId:
              throw PlatformException(
                  code: _errorCodeIncorrectConfiguration,
                  message: 'serverClientId must be provided on Android');
          }
        }
        return null;
      case GetCredentialSuccess():
        return authnResult.credential;
    }
  }

  Future<PlatformAuthorizationResult?> _authorize(
      {required bool promptIfUnauthorized,
      required List<String> scopes,
      String? accountEmail,
      bool throwGoogleSignInCompatExceptions = false}) async {
    final AuthorizeResult authzResult = await _authorizationClientApi.authorize(
        PlatformAuthorizationRequest(
          scopes: scopes,
          hostedDomain: _hostedDomain,
          serverClientIdForForcedRefreshToken:
              _forceCodeForRefreshToken ? _serverClientId : null,
          accountEmail: accountEmail,
        ),
        promptIfUnauthorized: promptIfUnauthorized);
    switch (authzResult) {
      case AuthorizeFailure():
        if (throwGoogleSignInCompatExceptions) {
          switch (authzResult.type) {
            case AuthorizeFailureType.unauthorized:
              // This is the closest error code in the legacy system, since it
              // would be resolved by calling signIn if the user allowed access.
              throw PlatformException(
                  code: _errorCodeSignInRequired, message: authzResult.message);
            case AuthorizeFailureType.noActivity:
              throw PlatformException(
                  code: _errorCodeUserRecoverableAuth,
                  message: authzResult.message);
            // Map everything else to the catch-all error for now.
            case AuthorizeFailureType.authorizeFailure:
            case AuthorizeFailureType.pendingIntentException:
            case AuthorizeFailureType.apiException:
              throw PlatformException(
                  code: _errorCodeSignInFailed, message: authzResult.message);
          }
        }
        return null;
      case PlatformAuthorizationResult():
        return authzResult;
    }
  }

  @override
  Future<GoogleSignInTokenData> getTokens(
      {required String email, bool? shouldRecoverAuth = true}) async {
    final bool promptIfUnauthorized = shouldRecoverAuth ?? false;
    // TODO(stuartmorgan): Eliminate or restructure this method in the new API,
    // since it mixes tokens from different steps.
    // See https://github.com/flutter/flutter/issues/119300.
    final PlatformAuthorizationResult? authorization = await _authorize(
        promptIfUnauthorized: promptIfUnauthorized,
        scopes: _desiredScopes,
        accountEmail: email,
        throwGoogleSignInCompatExceptions: true);
    if (authorization == null) {
      // This is explicitly documented behavior in the app-facing package,
      // unfortunately, so replicate it here.
      throw PlatformException(
          code: promptIfUnauthorized
              ? 'failed_to_recover_auth'
              : 'user_recoverable_auth');
    }

    return GoogleSignInTokenData(
      // idToken isn't available here; the app-facing code already caches it
      // for that reason, so for now just rely on that. After an API rework,
      // that shouldn't be necessary.
      accessToken: authorization.accessToken,
      serverAuthCode: authorization.serverAuthCode,
    );
  }

  @override
  Future<void> signOut() {
    return _credentialManaagerApi.clearCredentialState();
  }

  @override
  Future<void> disconnect() async {
    // This was a Google Sign-In API that does not appear to have a Credential
    // Manager equivalent; just sign out instead.
    return signOut();
  }

  @override
  Future<bool> isSignedIn() async {
    // TODO(stuartmorgan): Eliminate or restructure this method in the new API,
    // since this concept doesn't seem to exist any more.
    // See https://github.com/flutter/flutter/issues/119300.
    // For now, attempt a silent sign-in and see if it works.
    return (await _authenticate(
            filterToAuthorized: true, autoSelectEnabled: true)) !=
        null;
  }

  @override
  Future<void> clearAuthCache({required String token}) async {
    // This was a Google Sign-In API that does not appear to have a Credential
    // Manager equivalent.
  }

  @override
  Future<bool> requestScopes(List<String> scopes) async {
    final AuthorizeResult result = await _authorizationClientApi.authorize(
        PlatformAuthorizationRequest(
            scopes: scopes, hostedDomain: _hostedDomain),
        promptIfUnauthorized: true);
    switch (result) {
      case AuthorizeFailure():
        // TODO(stuartmorgan): Look into how failure should be communicated better.
        return false;
      case PlatformAuthorizationResult():
        return true;
    }
  }

  @override
  Future<bool> canAccessScopes(
    List<String> scopes, {
    String? accessToken,
  }) async {
    final AuthorizeResult result = await _authorizationClientApi.authorize(
        PlatformAuthorizationRequest(
            scopes: scopes, hostedDomain: _hostedDomain),
        promptIfUnauthorized: false);
    switch (result) {
      case AuthorizeFailure():
        return false;
      case PlatformAuthorizationResult():
        return true;
    }
  }
}

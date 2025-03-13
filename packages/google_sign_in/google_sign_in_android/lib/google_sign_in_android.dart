// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'src/messages.g.dart';

/// Android implementation of [GoogleSignInPlatform].
class GoogleSignInAndroid extends GoogleSignInPlatform {
  /// Creates a new plugin implementation instance.
  GoogleSignInAndroid({
    @visibleForTesting GoogleSignInApi? api,
  }) : _api = api ?? GoogleSignInApi();

  final GoogleSignInApi _api;

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
  Future<void> initWithParams(SignInInitParameters params) {
    return _api.init(InitParams(
      signInType: _signInTypeForOption(params.signInOption),
      scopes: params.scopes,
      hostedDomain: params.hostedDomain,
      clientId: params.clientId,
      serverClientId: params.serverClientId,
      forceCodeForRefreshToken: params.forceCodeForRefreshToken,
      forceAccountName: params.forceAccountName,
    ));
  }

  @override
  Future<GoogleSignInUserData?> signInSilently() {
    return _api.signInSilently().then(_signInUserDataFromChannelData);
  }

  @override
  Future<GoogleSignInUserData?> signIn() {
    return _api.signIn().then(_signInUserDataFromChannelData);
  }

  @override
  Future<GoogleSignInTokenData> getTokens(
      {required String email, bool? shouldRecoverAuth = true}) {
    return _api
        .getAccessToken(email, shouldRecoverAuth ?? true)
        .then((String result) => GoogleSignInTokenData(
              accessToken: result,
            ));
  }

  @override
  Future<void> signOut() {
    return _api.signOut();
  }

  @override
  Future<void> disconnect() {
    return _api.disconnect();
  }

  @override
  Future<bool> isSignedIn() {
    return _api.isSignedIn();
  }

  @override
  Future<void> clearAuthCache({required String token}) {
    return _api.clearAuthCache(token);
  }

  @override
  Future<bool> requestScopes(List<String> scopes) {
    return _api.requestScopes(scopes);
  }

  SignInType _signInTypeForOption(SignInOption option) {
    switch (option) {
      case SignInOption.standard:
        return SignInType.standard;
      case SignInOption.games:
        return SignInType.games;
    }
    // Handle the case where a new type is added to the platform interface in
    // the future, and this version of the package is used with it.
    // ignore: dead_code
    throw UnimplementedError('Unsupported sign in option: $option');
  }

  GoogleSignInUserData _signInUserDataFromChannelData(UserData data) {
    return GoogleSignInUserData(
      email: data.email,
      id: data.id,
      displayName: data.displayName,
      photoUrl: data.photoUrl,
      idToken: data.idToken,
      serverAuthCode: data.serverAuthCode,
    );
  }
}

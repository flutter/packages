// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'src/messages.g.dart';

/// iOS implementation of [GoogleSignInPlatform].
class GoogleSignInIOS extends GoogleSignInPlatform {
  /// Creates a new plugin implementation instance.
  GoogleSignInIOS({
    @visibleForTesting GoogleSignInApi? api,
  }) : _api = api ?? GoogleSignInApi();

  final GoogleSignInApi _api;

  /// Registers this class as the default instance of [GoogleSignInPlatform].
  static void registerWith() {
    GoogleSignInPlatform.instance = GoogleSignInIOS();
  }

  @override
  Future<void> init({
    List<String> scopes = const <String>[],
    SignInOption signInOption = SignInOption.standard,
    String? hostedDomain,
    String? clientId,
  }) {
    return initWithParams(SignInInitParameters(
      signInOption: signInOption,
      scopes: scopes,
      hostedDomain: hostedDomain,
      clientId: clientId,
    ));
  }

  @override
  Future<void> initWithParams(SignInInitParameters params) {
    if (params.signInOption == SignInOption.games) {
      throw PlatformException(
          code: 'unsupported-options',
          message: 'Games sign in is not supported on iOS');
    }
    if (params.forceAccountName != null) {
      throw ArgumentError('Force account name is not supported on iOS');
    }
    return _api.init(InitParams(
      scopes: params.scopes,
      hostedDomain: params.hostedDomain,
      clientId: params.clientId,
      serverClientId: params.serverClientId,
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
    return _api.getAccessToken().then(_signInTokenDataFromChannelData);
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
  Future<void> clearAuthCache({required String token}) async {
    // There's nothing to be done here on iOS since the expired/invalid
    // tokens are refreshed automatically by getTokens.
  }

  @override
  Future<bool> requestScopes(List<String> scopes) {
    return _api.requestScopes(scopes);
  }

  GoogleSignInUserData _signInUserDataFromChannelData(UserData data) {
    return GoogleSignInUserData(
      email: data.email,
      id: data.userId,
      displayName: data.displayName,
      photoUrl: data.photoUrl,
      serverAuthCode: data.serverAuthCode,
      idToken: data.idToken,
    );
  }

  GoogleSignInTokenData _signInTokenDataFromChannelData(TokenData data) {
    return GoogleSignInTokenData(
      idToken: data.idToken,
      accessToken: data.accessToken,
    );
  }
}

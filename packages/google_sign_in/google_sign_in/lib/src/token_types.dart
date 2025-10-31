// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Holds authentication tokens.
///
/// Currently there is only an idToken, but this wrapper class allows for the
/// posibility of adding additional information in the future without breaking
/// changes.
@immutable
class GoogleSignInAuthentication {
  /// Creates a new token container with the given tokens.
  const GoogleSignInAuthentication({required this.idToken});

  /// An OpenID Connect ID token that identifies the user.
  final String? idToken;

  @override
  String toString() => 'GoogleSignInAuthentication: $idToken';
}

/// Holds client authorization tokens.
///
/// Currently there is only an accessToken, but this wrapper class allows for
/// the posibility of adding additional information in the future without
/// breaking changes.
@immutable
class GoogleSignInClientAuthorization {
  /// Creates a new token container with the given tokens.
  const GoogleSignInClientAuthorization({required this.accessToken});

  /// The OAuth2 access token to access Google services.
  final String accessToken;

  @override
  String toString() => 'GoogleSignInClientAuthorization: $accessToken';
}

/// Holds server authorization tokens.
///
/// Currently there is only a serverAuthCode, but this wrapper class allows for
/// the posibility of adding additional information in the future without
/// breaking changes.
@immutable
class GoogleSignInServerAuthorization {
  /// Creates a new token container with the given tokens.
  const GoogleSignInServerAuthorization({required this.serverAuthCode});

  /// Auth code to provide to a backend server to exchange for access or
  /// refresh tokens.
  final String serverAuthCode;

  @override
  String toString() => 'GoogleSignInServerAuthorization: $serverAuthCode';
}

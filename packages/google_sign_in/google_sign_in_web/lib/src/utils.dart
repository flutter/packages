// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:google_identity_services_web/id.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

/// A codec that can encode/decode JWT payloads.
///
/// See https://www.rfc-editor.org/rfc/rfc7519#section-3
final Codec<Object?, String> jwtCodec = json.fuse(utf8).fuse(base64);

/// A RegExp that can match, and extract parts from a JWT Token.
///
/// A JWT token consists of 3 base-64 encoded parts of data separated by periods:
///
///   header.payload.signature
///
/// More info: https://regexr.com/789qc
final RegExp jwtTokenRegexp = RegExp(
  r'^(?<header>[^\.\s]+)\.(?<payload>[^\.\s]+)\.(?<signature>[^\.\s]+)$',
);

/// Decodes the `claims` of a JWT token and returns them as a Map.
///
/// JWT `claims` are stored as a JSON object in the `payload` part of the token.
///
/// (This method does not validate the signature of the token.)
///
/// See https://www.rfc-editor.org/rfc/rfc7519#section-3
Map<String, Object?>? getJwtTokenPayload(String? token) {
  if (token != null) {
    final RegExpMatch? match = jwtTokenRegexp.firstMatch(token);
    if (match != null) {
      return decodeJwtPayload(match.namedGroup('payload'));
    }
  }

  return null;
}

/// Decodes a JWT payload using the [jwtCodec].
Map<String, Object?>? decodeJwtPayload(String? payload) {
  try {
    // Payload must be normalized before passing it to the codec
    return jwtCodec.decode(base64.normalize(payload!)) as Map<String, Object?>?;
  } catch (_) {
    // Do nothing, we always return null for any failure.
  }
  return null;
}

/// Returns the payload of a [CredentialResponse].
Map<String, Object?>? getResponsePayload(CredentialResponse? response) {
  if (response?.credential == null) {
    return null;
  }

  return getJwtTokenPayload(response!.credential);
}

/// Converts a [CredentialResponse] into a [GoogleSignInUserData].
///
/// May return `null`, if the `credentialResponse` is null, or its `credential`
/// cannot be decoded.
AuthenticationEvent? gisResponsesToAuthenticationEvent(
  CredentialResponse? credentialResponse,
) {
  final Map<String, Object?>? payload = getResponsePayload(credentialResponse);
  if (payload == null) {
    return null;
  }

  assert(
    credentialResponse?.credential != null,
    'The CredentialResponse cannot be null and have a payload.',
  );

  return AuthenticationEventSignIn(
    user: GoogleSignInUserData(
      email: payload['email']! as String,
      id: payload['sub']! as String,
      displayName: payload['name'] as String?,
      photoUrl: payload['picture'] as String?,
    ),
    authenticationTokens: AuthenticationTokenData(
      idToken: credentialResponse!.credential,
    ),
  );
}

/// Returns the expiration timestamp ('exp') of a [CredentialResponse].
///
/// May return `null` if the `credentialResponse` is null, its `credential`
/// cannot be decoded, or the `exp` field is not set on the JWT payload.
DateTime? getCredentialResponseExpirationTimestamp(
  CredentialResponse? credentialResponse,
) {
  final Map<String, Object?>? payload = getResponsePayload(credentialResponse);
  // Get the 'exp' field from the payload, if present.
  final int? exp = (payload != null) ? payload['exp'] as int? : null;
  // Return 'exp' (a timestamp in seconds since Epoch) as a DateTime.
  return (exp != null) ? DateTime.fromMillisecondsSinceEpoch(exp * 1000) : null;
}

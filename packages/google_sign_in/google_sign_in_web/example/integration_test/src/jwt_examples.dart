// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_identity_services_web/id.dart';

import 'jsify_as.dart';

/// A CredentialResponse with null `credential`.
final CredentialResponse nullCredential = jsifyAs<CredentialResponse>(
  <String, Object?>{'credential': null},
);

/// A CredentialResponse wrapping a known good JWT Token as its `credential`.
final CredentialResponse goodCredential = jsifyAs<CredentialResponse>(
  <String, Object?>{'credential': goodJwtToken},
);

/// A CredentialResponse wrapping a known good JWT Token as its `credential`.
final CredentialResponse minimalCredential = jsifyAs<CredentialResponse>(
  <String, Object?>{'credential': minimalJwtToken},
);

final CredentialResponse expiredCredential = jsifyAs<CredentialResponse>(
  <String, Object?>{'credential': expiredJwtToken},
);

/// A JWT token with predefined values.
///
/// 'email': 'adultman@example.com',
/// 'sub': '123456',
/// 'name': 'Vincent Adultman',
/// 'picture': 'https://thispersondoesnotexist.com/image?x=.jpg',
///
/// Signed with HS256 and the private key: 'symmetric-encryption-is-weak'
const String goodJwtToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.$goodPayload.lqzULA_U3YzEl_-fL7YLU-kFXmdD2ttJLTv-UslaNQ4';

/// The payload of a JWT token that contains predefined values.
///
/// 'email': 'adultman@example.com',
/// 'sub': '123456',
/// 'name': 'Vincent Adultman',
/// 'picture': 'https://thispersondoesnotexist.com/image?x=.jpg',
const String goodPayload =
    'eyJlbWFpbCI6ImFkdWx0bWFuQGV4YW1wbGUuY29tIiwic3ViIjoiMTIzNDU2IiwibmFtZSI6IlZpbmNlbnQgQWR1bHRtYW4iLCJwaWN0dXJlIjoiaHR0cHM6Ly90aGlzcGVyc29uZG9lc25vdGV4aXN0LmNvbS9pbWFnZT94PS5qcGcifQ';

/// A JWT token with minimal set of predefined values.
///
/// 'email': 'adultman@example.com',
/// 'sub': '123456'
///
/// Signed with HS256 and the private key: 'symmetric-encryption-is-weak'
const String minimalJwtToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.$minimalPayload.UTAe7dpdtFIMwsOqkZkjyjqyHnho5xHCcQylUFmOutM';

/// The payload of a JWT token that contains only non-nullable values.
///
/// 'email': 'adultman@example.com',
/// 'sub': '123456'
const String minimalPayload =
    'eyJlbWFpbCI6ImFkdWx0bWFuQGV4YW1wbGUuY29tIiwic3ViIjoiMTIzNDU2In0';

/// A JWT token with minimal set of predefined values and an expiration timestamp.
///
/// 'email': 'adultman@example.com',
/// 'sub': '123456',
/// 'exp': 1430330400
///
/// Signed with HS256 and the private key: 'symmetric-encryption-is-weak'
const String expiredJwtToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.$expiredPayload.--gb5tnVSSsLg4zjjVH0FUUvT4rbehIcnBhB-8Iekm4';

/// The payload of a JWT token that contains only non-nullable values, and an
/// expiration timestamp of 1430330400 (Wednesday, April 29, 2015 6:00:00 PM UTC)
///
/// 'email': 'adultman@example.com',
/// 'sub': '123456',
/// 'exp': 1430330400
const String expiredPayload =
    'eyJlbWFpbCI6ImFkdWx0bWFuQGV4YW1wbGUuY29tIiwic3ViIjoiMTIzNDU2IiwiZXhwIjoxNDMwMzMwNDAwfQ';

// More encrypted JWT Tokens may be created on https://jwt.io.
//
// First, decode the `goodJwtToken` above, modify to your heart's
// content, and add a new credential here.
//
// (New tokens can also be created with `package:jose` and `dart:convert`.)

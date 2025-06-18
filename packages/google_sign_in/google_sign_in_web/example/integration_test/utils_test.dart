// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/oauth2.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/src/utils.dart';
import 'package:integration_test/integration_test.dart';

import 'src/jsify_as.dart';
import 'src/jwt_examples.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('gisResponsesToTokenData', () {
    testWidgets('null objects -> no problem', (_) async {
      final GoogleSignInTokenData tokens = gisResponsesToTokenData(null, null);

      expect(tokens.accessToken, isNull);
      expect(tokens.idToken, isNull);
      expect(tokens.serverAuthCode, isNull);
    });

    testWidgets('non-null objects are correctly used', (_) async {
      const String expectedIdToken = 'some-value-for-testing';
      const String expectedAccessToken = 'another-value-for-testing';

      final CredentialResponse credential =
          jsifyAs<CredentialResponse>(<String, Object?>{
        'credential': expectedIdToken,
      });
      final TokenResponse token = jsifyAs<TokenResponse>(<String, Object?>{
        'access_token': expectedAccessToken,
      });
      final GoogleSignInTokenData tokens =
          gisResponsesToTokenData(credential, token);

      expect(tokens.accessToken, expectedAccessToken);
      expect(tokens.idToken, expectedIdToken);
      expect(tokens.serverAuthCode, isNull);
    });
  });

  group('gisResponsesToUserData', () {
    testWidgets('happy case', (_) async {
      final GoogleSignInUserData data = gisResponsesToUserData(goodCredential)!;

      expect(data.displayName, 'Vincent Adultman');
      expect(data.id, '123456');
      expect(data.email, 'adultman@example.com');
      expect(data.photoUrl, 'https://thispersondoesnotexist.com/image?x=.jpg');
      expect(data.idToken, goodJwtToken);
    });

    testWidgets('happy case (minimal)', (_) async {
      final GoogleSignInUserData data =
          gisResponsesToUserData(minimalCredential)!;

      expect(data.displayName, isNull);
      expect(data.id, '123456');
      expect(data.email, 'adultman@example.com');
      expect(data.photoUrl, isNull);
      expect(data.idToken, minimalJwtToken);
    });

    testWidgets('null response -> null', (_) async {
      expect(gisResponsesToUserData(null), isNull);
    });

    testWidgets('null response.credential -> null', (_) async {
      expect(gisResponsesToUserData(nullCredential), isNull);
    });

    testWidgets('invalid payload -> null', (_) async {
      final CredentialResponse response =
          jsifyAs<CredentialResponse>(<String, Object?>{
        'credential': 'some-bogus.thing-that-is-not.valid-jwt',
      });
      expect(gisResponsesToUserData(response), isNull);
    });
  });

  group('getCredentialResponseExpirationTimestamp', () {
    testWidgets('Good payload -> data', (_) async {
      final DateTime? expiration =
          getCredentialResponseExpirationTimestamp(expiredCredential);

      expect(expiration, isNotNull);
      expect(expiration!.millisecondsSinceEpoch, 1430330400 * 1000);
    });

    testWidgets('No expiration -> null', (_) async {
      expect(
          getCredentialResponseExpirationTimestamp(minimalCredential), isNull);
    });

    testWidgets('Bad data -> null', (_) async {
      final CredentialResponse bogus =
          jsifyAs<CredentialResponse>(<String, Object?>{
        'credential': 'some-bogus.thing-that-is-not.valid-jwt',
      });

      expect(getCredentialResponseExpirationTimestamp(bogus), isNull);
    });
  });

  group('getJwtTokenPayload', () {
    testWidgets('happy case -> data', (_) async {
      final Map<String, Object?>? data = getJwtTokenPayload(goodJwtToken);

      expect(data, isNotNull);
      expect(data, containsPair('name', 'Vincent Adultman'));
      expect(data, containsPair('email', 'adultman@example.com'));
      expect(data, containsPair('sub', '123456'));
      expect(
          data,
          containsPair(
            'picture',
            'https://thispersondoesnotexist.com/image?x=.jpg',
          ));
    });

    testWidgets('happy case (minimal) -> data', (_) async {
      final Map<String, Object?>? data = getJwtTokenPayload(minimalJwtToken);

      expect(data, isNotNull);
      expect(data, containsPair('email', 'adultman@example.com'));
      expect(data, containsPair('sub', '123456'));
    });

    testWidgets('null Token -> null', (_) async {
      final Map<String, Object?>? data = getJwtTokenPayload(null);

      expect(data, isNull);
    });

    testWidgets('Token not matching the format -> null', (_) async {
      final Map<String, Object?>? data = getJwtTokenPayload('1234.4321');

      expect(data, isNull);
    });

    testWidgets('Bad token that matches the format -> null', (_) async {
      final Map<String, Object?>? data = getJwtTokenPayload('1234.abcd.4321');

      expect(data, isNull);
    });
  });

  group('decodeJwtPayload', () {
    testWidgets('Good payload -> data', (_) async {
      final Map<String, Object?>? data = decodeJwtPayload(goodPayload);

      expect(data, isNotNull);
      expect(data, containsPair('name', 'Vincent Adultman'));
      expect(data, containsPair('email', 'adultman@example.com'));
      expect(data, containsPair('sub', '123456'));
      expect(
          data,
          containsPair(
            'picture',
            'https://thispersondoesnotexist.com/image?x=.jpg',
          ));
    });

    testWidgets('Proper JSON payload -> data', (_) async {
      final String payload = base64.encode(utf8.encode('{"properJson": true}'));

      final Map<String, Object?>? data = decodeJwtPayload(payload);

      expect(data, isNotNull);
      expect(data, containsPair('properJson', true));
    });

    testWidgets('Not-normalized base-64 payload -> data', (_) async {
      // This is the payload generated by the "Proper JSON payload" test, but
      // we remove the leading "=" symbols so it's length is not a multiple of 4
      // anymore!
      final String payload = 'eyJwcm9wZXJKc29uIjogdHJ1ZX0='.replaceAll('=', '');

      final Map<String, Object?>? data = decodeJwtPayload(payload);

      expect(data, isNotNull);
      expect(data, containsPair('properJson', true));
    });

    testWidgets('Invalid JSON payload -> null', (_) async {
      final String payload = base64.encode(utf8.encode('{properJson: false}'));

      final Map<String, Object?>? data = decodeJwtPayload(payload);

      expect(data, isNull);
    });

    testWidgets('Non JSON payload -> null', (_) async {
      final String payload = base64.encode(utf8.encode('not-json'));

      final Map<String, Object?>? data = decodeJwtPayload(payload);

      expect(data, isNull);
    });

    testWidgets('Non base-64 payload -> null', (_) async {
      const String payload = 'not-base-64-at-all';

      final Map<String, Object?>? data = decodeJwtPayload(payload);

      expect(data, isNull);
    });
  });
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_test/flutter_test.dart';

const String SOME_FAKE_ACCESS_TOKEN = 'this-is-something-not-null';
const List<String> DEBUG_FAKE_SCOPES = <String>['some-scope', 'another-scope'];
const List<String> SIGN_IN_FAKE_SCOPES = <String>[
  'some-scope',
  'another-scope'
];

class FakeGoogleSignIn extends Fake implements GoogleSignIn {
  @override
  final List<String> scopes = SIGN_IN_FAKE_SCOPES;
}

class FakeGoogleSignInAuthentication extends Fake
    implements GoogleSignInAuthentication {
  @override
  final String accessToken = SOME_FAKE_ACCESS_TOKEN;
}

void main() {
  final GoogleSignIn signIn = FakeGoogleSignIn();
  final FakeGoogleSignInAuthentication authMock =
      FakeGoogleSignInAuthentication();

  test('authenticatedClient returns an authenticated client', () async {
    final gapis.AuthClient client = (await signIn.authenticatedClient(
      debugAuthentication: authMock,
    ))!;
    expect(client, isA<gapis.AuthClient>());
  });

  test('authenticatedClient uses GoogleSignIn scopes by default', () async {
    final gapis.AuthClient client = (await signIn.authenticatedClient(
      debugAuthentication: authMock,
    ))!;
    expect(client.credentials.accessToken.data, equals(SOME_FAKE_ACCESS_TOKEN));
    expect(client.credentials.scopes, equals(SIGN_IN_FAKE_SCOPES));
  });

  test('authenticatedClient returned client contains the passed-in credentials',
      () async {
    final gapis.AuthClient client = (await signIn.authenticatedClient(
      debugAuthentication: authMock,
      debugScopes: DEBUG_FAKE_SCOPES,
    ))!;
    expect(client.credentials.accessToken.data, equals(SOME_FAKE_ACCESS_TOKEN));
    expect(client.credentials.scopes, equals(DEBUG_FAKE_SCOPES));
  });
}

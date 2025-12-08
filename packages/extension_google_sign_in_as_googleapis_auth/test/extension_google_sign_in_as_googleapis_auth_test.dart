// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;

const String SOME_FAKE_ACCESS_TOKEN = 'this-is-something-not-null';

class FakeGoogleSignInClientAuthorization extends Fake
    implements GoogleSignInClientAuthorization {
  @override
  final String accessToken = SOME_FAKE_ACCESS_TOKEN;
}

void main() {
  test(
    'authClient returned client contains the expected information',
    () async {
      const scopes = <String>['some-scope', 'another-scope'];
      final signInAuth = FakeGoogleSignInClientAuthorization();
      final gapis.AuthClient client = signInAuth.authClient(scopes: scopes);
      expect(
        client.credentials.accessToken.data,
        equals(SOME_FAKE_ACCESS_TOKEN),
      );
      expect(client.credentials.scopes, equals(scopes));
    },
  );
}

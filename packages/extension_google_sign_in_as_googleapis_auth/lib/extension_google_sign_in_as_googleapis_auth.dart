// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

/// Extension on [GoogleSignIn] that adds an `authenticatedClient` method.
///
/// This method can be used to retrieve an authenticated [gapis.AuthClient]
/// client that can be used with the rest of the `googleapis` libraries.
extension GoogleApisGoogleSignInAuth on GoogleSignIn {
  /// Retrieve a `googleapis` authenticated client.
  Future<gapis.AuthClient?> authenticatedClient({
    @visibleForTesting GoogleSignInAuthentication? debugAuthentication,
    @visibleForTesting List<String>? debugScopes,
  }) async {
    final GoogleSignInAuthentication? auth =
        debugAuthentication ?? await currentUser?.authentication;
    final String? oauthTokenString = auth?.accessToken;
    if (oauthTokenString == null) {
      return null;
    }
    final gapis.AccessCredentials credentials = gapis.AccessCredentials(
      gapis.AccessToken(
        'Bearer',
        oauthTokenString,
        // TODO(kevmoo): Use the correct value once it's available from authentication
        // See https://github.com/flutter/flutter/issues/80905
        DateTime.now().toUtc().add(const Duration(days: 365)),
      ),
      null, // We don't have a refreshToken
      debugScopes ?? scopes,
    );

    return gapis.authenticatedClient(http.Client(), credentials);
  }
}

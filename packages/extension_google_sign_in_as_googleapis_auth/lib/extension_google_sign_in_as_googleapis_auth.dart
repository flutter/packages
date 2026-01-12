// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:http/http.dart' as http;

/// Extension on [GoogleSignInClientAuthorization] that adds an
/// `authClient` method.
extension GoogleApisGoogleSignInAuth on GoogleSignInClientAuthorization {
  /// Returns an authenticated [gapis.AuthClient] client that can be used with
  /// the rest of the `googleapis` libraries.
  ///
  /// The [scopes] passed here should be the same as the scopes used to request
  /// the authorization. Passing scopes here that have not been authorized will
  /// likely result in API errors when using the client.
  gapis.AuthClient authClient({required List<String> scopes}) {
    final gapis.AccessCredentials credentials = gapis.AccessCredentials(
      gapis.AccessToken(
        'Bearer',
        accessToken,
        // The underlying SDKs don't provide expiry information, so set an
        // arbitrary distant-future time.
        DateTime.now().toUtc().add(const Duration(days: 365)),
      ),
      null, // The underlying SDKs don't provide a refresh token.
      scopes,
    );

    return gapis.authenticatedClient(http.Client(), credentials);
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #docregion Import
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
// #enddocregion Import
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/people/v1.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

/// Demonstrates using GoogleSignIn authenticated client to use `googleapis` API clients
Future<ListConnectionsResponse> createAPIClient() async {
  // #docregion CreateAPIClient
  final PeopleServiceApi peopleApi =
      PeopleServiceApi((await _googleSignIn.authenticatedClient())!);
  final ListConnectionsResponse response =
      await peopleApi.people.connections.list(
    'people/me',
    personFields: 'names',
  );
  // #enddocregion CreateAPIClient

  return response;
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can instantiate the plugin', (WidgetTester tester) async {
    final GoogleSignInPlatform signIn = GoogleSignInPlatform.instance;
    expect(signIn, isNotNull);
  });

  testWidgets('Can initialize the plugin', (WidgetTester tester) async {
    // This is primarily to validate that the native method handler is present
    // and correctly set up to receive messages (i.e., that this doesn't
    // throw).
    try {
      // #docregion IDsInCode
      final GoogleSignInPlatform signIn = GoogleSignInPlatform.instance;
      await signIn.init(
        const InitParameters(
          // The OAuth client ID of your app. This is required.
          clientId: 'Your Client ID',
          // If you need to authenticate to a backend server, specify the server's
          // OAuth client ID. This is optional.
          serverClientId: 'Your Server ID',
        ),
      );
      // #enddocregion IDsInCode
    } catch (e) {
      fail('Initialization should succeed');
    }
  });
}

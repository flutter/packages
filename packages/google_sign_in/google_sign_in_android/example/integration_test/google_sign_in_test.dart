// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can instantiate the plugin', (WidgetTester tester) async {
    final GoogleSignInPlatform signIn = GoogleSignInPlatform.instance;
    expect(signIn, isNotNull);
  });

  testWidgets('Method channel handler is present', (WidgetTester tester) async {
    // Validate that the native method handler is present and configured.
    final GoogleSignInPlatform signIn = GoogleSignInPlatform.instance;
    try {
      await signIn.signOut(const SignOutParams());
    } on PlatformException catch (e) {
      if (e.code == 'Clear Failed') {
        // This is thrown when running on a device or emulator without Google
        // Sign in support. It comes from a call into the SDK, so is fine for
        // the purposes of this test since it means the native handler ran.
      } else {
        fail('Unexpected exception: e');
      }
    }
  });
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../app_router.dart';

/// The login page.
class LoginPage extends StatelessWidget {
  /// Construct the login page.
  const LoginPage({super.key});

  /// The path for the login page.
  static const String path = '/login';

  /// The name for the login page.
  static const String name = 'Login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Login Page'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => <void>{
                AppRouter.authenticatedNotifier.value = true,
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

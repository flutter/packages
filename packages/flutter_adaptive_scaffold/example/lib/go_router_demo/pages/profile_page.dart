// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../app_router.dart';

/// The profile page.
class ProfilePage extends StatelessWidget {
  /// Construct the profile page.
  const ProfilePage({super.key});

  /// The path for the profile page.
  static const String path = 'profile';

  /// The name for the profile page.
  static const String name = 'Profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => <void>{
                AppRouter.authenticatedNotifier.value = false,
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

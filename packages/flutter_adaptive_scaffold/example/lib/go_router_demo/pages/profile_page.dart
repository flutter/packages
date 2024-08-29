import 'package:flutter/material.dart';

import '../app_router.dart';

class ProfilePage extends StatelessWidget {
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

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';

import 'pages.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  /// The path for the more page.
  static const String path = '/more';

  /// The name for the more page.
  static const String name = 'More';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('More Page'),
            ElevatedButton(
              onPressed: () => context.goNamed(ProfilePage.name),
              child: const Text('Profile'),
            ),
            const SizedBox(height: kMaterialGutterValue),
            ElevatedButton(
              onPressed: () => context.goNamed(SettingsPage.name),
              child: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../app_router.dart';

class LoginPage extends StatelessWidget {
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

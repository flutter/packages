import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../global_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  static const String path = '/login';
  static const String name = 'Login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            const Text('Login Page'),
            TextButton(
              onPressed: () => <void>{
                GlobalRouter.authenticated = true,
                context.go('/'),
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

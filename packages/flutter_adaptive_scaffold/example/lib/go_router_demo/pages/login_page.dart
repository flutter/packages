import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  static const String path = '/login';
  static const String name = 'Login';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login Page'),
      ),
    );
  }
}

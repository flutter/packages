import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  static const String path = 'forgot_password';
  static const String name = 'ForgotPassword';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('ForgotPassword Page'),
      ),
    );
  }
}

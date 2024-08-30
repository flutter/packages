import 'package:flutter/material.dart';

/// The forgot password page.
class ForgotPasswordPage extends StatelessWidget {
  /// Construct the forgot password page.
  const ForgotPasswordPage({super.key});

  /// The path for the forgot password page.
  static const String path = 'forgot_password';

  /// The name for the forgot password page.
  static const String name = 'ForgotPassword';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: const Center(
        child: Text('ForgotPassword Page'),
      ),
    );
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

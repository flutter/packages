// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Credential data class.
class Credentials {
  /// Creates a credential data object.
  Credentials(this.username, this.password);

  /// The username of the credentials.
  final String username;

  /// The password of the credentials.
  final String password;
}

/// The sign-in screen.
class SignInScreen extends StatefulWidget {
  /// Creates a sign-in screen.
  const SignInScreen({
    required this.onSignIn,
    Key? key,
  }) : super(key: key);

  /// Called when users sign in with [Credentials].
  final ValueChanged<Credentials> onSignIn;

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Card(
            child: Container(
              constraints: BoxConstraints.loose(const Size(600, 600)),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Sign in', style: Theme.of(context).textTheme.headline4),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Username'),
                    controller: _usernameController,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passwordController,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: () async {
                        widget.onSignIn(Credentials(
                            _usernameController.value.text,
                            _passwordController.value.text));
                      },
                      child: const Text('Sign in'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

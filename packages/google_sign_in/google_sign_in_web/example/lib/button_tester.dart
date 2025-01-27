// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/web_only.dart';

import 'src/button_configuration_column.dart';

// Let's use the Platform Interface directly, no need to use anything web-specific
// from it. (In a normal app, we'd use the plugin interface!)
// All the web-specific imports come from the `web_only.dart` library.
final GoogleSignInPlatform _platform = GoogleSignInPlatform.instance;

Future<void> main() async {
  await _platform.initWithParams(const SignInInitParameters(
    clientId: 'your-client_id.apps.googleusercontent.com',
  ));
  runApp(
    const MaterialApp(
      title: 'Sign in with Google button Tester',
      home: ButtonConfiguratorDemo(),
    ),
  );
}

/// The home widget of this app.
class ButtonConfiguratorDemo extends StatefulWidget {
  /// A const constructor for the Widget.
  const ButtonConfiguratorDemo({super.key});

  @override
  State createState() => _ButtonConfiguratorState();
}

class _ButtonConfiguratorState extends State<ButtonConfiguratorDemo> {
  GoogleSignInUserData? _userData; // sign-in information?
  GSIButtonConfiguration? _buttonConfiguration; // button configuration

  @override
  void initState() {
    super.initState();
    _platform.userDataEvents?.listen((GoogleSignInUserData? userData) {
      setState(() {
        _userData = userData;
      });
    });
  }

  void _handleSignOut() {
    _platform.signOut();
    setState(() {
      // signOut does not broadcast through the userDataEvents, so we fake it.
      _userData = null;
    });
  }

  void _handleNewWebButtonConfiguration(GSIButtonConfiguration newConfig) {
    setState(() {
      _buttonConfiguration = newConfig;
    });
  }

  Widget _buildBody() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_userData == null)
                renderButton(configuration: _buttonConfiguration),
              if (_userData != null) ...<Widget>[
                Text('Hello, ${_userData!.displayName}!'),
                ElevatedButton(
                  onPressed: _handleSignOut,
                  child: const Text('SIGN OUT'),
                ),
              ]
            ],
          ),
        ),
        renderWebButtonConfiguration(
          _buttonConfiguration,
          onChange: _userData == null ? _handleNewWebButtonConfiguration : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign in with Google button Tester'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}

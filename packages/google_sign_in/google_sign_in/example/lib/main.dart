// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'src/sign_in_button.dart';

/// To run this example, replace this value with your client ID, and/or
/// update the relevant configuration files, as described in the README.
String? clientId;

/// To run this example, replace this value with your server client ID, and/or
/// update the relevant configuration files, as described in the README.
String? serverClientId;

/// The scopes required by this application.
const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

void main() {
  runApp(
    const MaterialApp(
      title: 'Google Sign In',
      home: SignInDemo(),
    ),
  );
}

/// The SignInDemo app.
class SignInDemo extends StatefulWidget {
  ///
  const SignInDemo({super.key});

  @override
  State createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false; // has granted permissions?
  String _contactText = '';
  String _errorMessage = '';
  String _serverAuthCode = '';

  @override
  void initState() {
    super.initState();

    final GoogleSignIn signIn = GoogleSignIn.instance;
    unawaited(signIn
        .initialize(clientId: clientId, serverClientId: serverClientId)
        .then((_) {
      GoogleSignIn.instance.authenticationEvents
          .listen(_handleAuthenticationEvent);

      /// This example always uses the stream-based approach to determining
      /// which UI state to show, rather than using the future returned here,
      /// if any, to conditionally skip directly to the signed-in state.
      signIn.attemptLightweightAuthentication();
    }));
  }

  Future<void> _handleAuthenticationEvent(
      GoogleSignInAuthenticationEvent event) async {
    GoogleSignInAccount? user;
    String error = '';
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn():
        user = event.user;
      case GoogleSignInAuthenticationEventSignOut():
        user = null;
      case GoogleSignInAuthenticationEventException():
        user = null;
        final GoogleSignInException e = event.exception;
        error = 'GoogleSignInException ${e.code}: ${e.description}';
    }

    // #docregion CanAccessScopes
    // Check for existing authorization.
    bool isAuthorized = false;
    if (user != null) {
      final GoogleSignInClientAuthorization? authorization =
          await user.authorizationClient.authorizationForScopes(scopes);
      isAuthorized = authorization != null;
    }
    // #enddocregion CanAccessScopes

    setState(() {
      _currentUser = user;
      _isAuthorized = isAuthorized;
      _errorMessage = error;
    });

    // Now that we know that the user can access the required scopes, the app
    // can call the REST API.
    if (user != null && isAuthorized) {
      unawaited(_handleGetContact(user));
    }
  }

  // Calls the People API REST endpoint for the signed-in user to retrieve information.
  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = 'Loading contact info...';
    });
    final Map<String, String>? headers =
        await user.authorizationClient.authorizationHeaders(scopes);
    if (headers == null) {
      setState(() {
        _contactText = 'Failed to construct authorization headers.';
      });
      return;
    }
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = 'People API gave a ${response.statusCode} '
            'response. Check logs for details.';
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = 'I see you know $namedContact!';
      } else {
        _contactText = 'No contacts to display.';
      }
    });
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => (contact as Map<Object?, dynamic>)['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final List<dynamic> names = contact['names'] as List<dynamic>;
      final Map<String, dynamic>? name = names.firstWhere(
        (dynamic name) =>
            (name as Map<Object?, dynamic>)['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  // This is the on-click handler for the Sign In button that is rendered by Flutter.
  //
  // On the web, the on-click handler of the Sign In button is owned by the JS
  // SDK, so this method can be considered mobile only.
  // #docregion SignIn
  Future<void> _handleSignIn() async {
    try {
      await GoogleSignIn.instance.authenticate();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }
  // #enddocregion SignIn

  // Prompts the user to authorize `scopes`.
  //
  // On the web, this must be called from an user interaction (button click).
  // #docregion RequestScopes
  Future<void> _handleAuthorizeScopes(GoogleSignInAccount user) async {
    try {
      // The returned tokens are ignored here since _handleGetContact uses the
      // authorizationHeaders method to re-read the token cached here.
      await user.authorizationClient.authorizeScopes(scopes);

      // #enddocregion RequestScopes
      setState(() {
        _isAuthorized = true;
        _errorMessage = '';
      });
      // #docregion RequestScopes
      unawaited(_handleGetContact(_currentUser!));
      // #enddocregion RequestScopes
    } on GoogleSignInException catch (e) {
      _errorMessage = 'GoogleSignInException ${e.code}: ${e.description}';
    }
  }

  // Requests a server auth code for the authorized scopes.
  //
  // On the web, this must be called from an user interaction (button click).
  // #docregion RequestScopes
  Future<void> _handleGetAuthCode(GoogleSignInAccount user) async {
    try {
      final GoogleSignInServerAuthorization? serverAuth =
          await user.authorizationClient.authorizeServer(scopes);

      // #enddocregion RequestScopes
      setState(() {
        _serverAuthCode = serverAuth == null ? '' : serverAuth.serverAuthCode;
      });
    } on GoogleSignInException catch (e) {
      _errorMessage = 'GoogleSignInException ${e.code}: ${e.description}';
    }
  }

  Future<void> _handleSignOut() async {
    // Disconnect instead of just signing out, to reset the example state as
    // much as possible.
    await GoogleSignIn.instance.disconnect();
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        if (user != null)
          ..._buildAuthenticatedWidgets(user)
        else
          ..._buildUnauthenticatedWidgets(),
        if (_errorMessage.isNotEmpty) Text(_errorMessage),
      ],
    );
  }

  /// Returns the list of widgets to include if the user is authenticated.
  List<Widget> _buildAuthenticatedWidgets(GoogleSignInAccount user) {
    return <Widget>[
      // The user is Authenticated.
      ListTile(
        leading: GoogleUserCircleAvatar(
          identity: user,
        ),
        title: Text(user.displayName ?? ''),
        subtitle: Text(user.email),
      ),
      const Text('Signed in successfully.'),
      if (_isAuthorized) ...<Widget>[
        // The user has Authorized all required scopes.
        if (_contactText.isNotEmpty) Text(_contactText),
        ElevatedButton(
          child: const Text('REFRESH'),
          onPressed: () => _handleGetContact(user),
        ),
        if (_serverAuthCode.isEmpty)
          ElevatedButton(
            child: const Text('REQUEST SERVER CODE'),
            onPressed: () => _handleGetAuthCode(user),
          )
        else
          Text('Server auth code:\n$_serverAuthCode'),
      ] else ...<Widget>[
        // The user has NOT Authorized all required scopes.
        const Text('Authorization needed to read your contacts.'),
        ElevatedButton(
          onPressed: () => _handleAuthorizeScopes(user),
          child: const Text('REQUEST PERMISSIONS'),
        ),
      ],
      ElevatedButton(
        onPressed: _handleSignOut,
        child: const Text('SIGN OUT'),
      ),
    ];
  }

  /// Returns the list of widgets to include if the user is not authenticated.
  List<Widget> _buildUnauthenticatedWidgets() {
    return <Widget>[
      const Text('You are not currently signed in.'),
      // This method is used to separate mobile from web code with conditional exports.
      // See: src/sign_in_button.dart
      buildSignInButton(
        onPressed: _handleSignIn,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Sign In'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}

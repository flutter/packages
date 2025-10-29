// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'src/web_wrapper.dart' as web;

/// To run this example, replace this value with your client ID, and/or
/// update the relevant configuration files, as described in the README.
String? clientId;

/// To run this example, replace this value with your server client ID, and/or
/// update the relevant configuration files, as described in the README.
String? serverClientId;

/// The scopes required by this application.
// #docregion CheckAuthorization
const List<String> scopes = <String>[
  'https://www.googleapis.com/auth/contacts.readonly',
];
// #enddocregion CheckAuthorization

void main() {
  runApp(const MaterialApp(title: 'Google Sign In', home: SignInDemo()));
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

    // #docregion Setup
    final GoogleSignIn signIn = GoogleSignIn.instance;
    unawaited(
      signIn.initialize(clientId: clientId, serverClientId: serverClientId).then((
        _,
      ) {
        signIn.authenticationEvents
            .listen(_handleAuthenticationEvent)
            .onError(_handleAuthenticationError);

        /// This example always uses the stream-based approach to determining
        /// which UI state to show, rather than using the future returned here,
        /// if any, to conditionally skip directly to the signed-in state.
        signIn.attemptLightweightAuthentication();
      }),
    );
    // #enddocregion Setup
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    // #docregion CheckAuthorization
    final GoogleSignInAccount? user = // ...
    // #enddocregion CheckAuthorization
    switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    // Check for existing authorization.
    // #docregion CheckAuthorization
    final GoogleSignInClientAuthorization? authorization = await user
        ?.authorizationClient
        .authorizationForScopes(scopes);
    // #enddocregion CheckAuthorization

    setState(() {
      _currentUser = user;
      _isAuthorized = authorization != null;
      _errorMessage = '';
    });

    // If the user has already granted access to the required scopes, call the
    // REST API.
    if (user != null && authorization != null) {
      unawaited(_handleGetContact(user));
    }
  }

  Future<void> _handleAuthenticationError(Object e) async {
    setState(() {
      _currentUser = null;
      _isAuthorized = false;
      _errorMessage =
          e is GoogleSignInException
              ? _errorMessageFromSignInException(e)
              : 'Unknown error: $e';
    });
  }

  // Calls the People API REST endpoint for the signed-in user to retrieve information.
  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = 'Loading contact info...';
    });
    final Map<String, String>? headers = await user.authorizationClient
        .authorizationHeaders(scopes);
    if (headers == null) {
      setState(() {
        _contactText = '';
        _errorMessage = 'Failed to construct authorization headers.';
      });
      return;
    }
    final http.Response response = await http.get(
      Uri.parse(
        'https://people.googleapis.com/v1/people/me/connections'
        '?requestMask.includeField=person.names',
      ),
      headers: headers,
    );
    if (response.statusCode != 200) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        setState(() {
          _isAuthorized = false;
          _errorMessage =
              'People API gave a ${response.statusCode} response. '
              'Please re-authorize access.';
        });
      } else {
        print('People API ${response.statusCode} response: ${response.body}');
        setState(() {
          _contactText =
              'People API gave a ${response.statusCode} '
              'response. Check logs for details.';
        });
      }
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
    final Map<String, dynamic>? contact =
        connections?.firstWhere(
              (dynamic contact) =>
                  (contact as Map<Object?, dynamic>)['names'] != null,
              orElse: () => null,
            )
            as Map<String, dynamic>?;
    if (contact != null) {
      final List<dynamic> names = contact['names'] as List<dynamic>;
      final Map<String, dynamic>? name =
          names.firstWhere(
                (dynamic name) =>
                    (name as Map<Object?, dynamic>)['displayName'] != null,
                orElse: () => null,
              )
              as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  // Prompts the user to authorize `scopes`.
  //
  // If authorizationRequiresUserInteraction() is true, this must be called from
  // a user interaction (button click). In this example app, a button is used
  // regardless, so authorizationRequiresUserInteraction() is not checked.
  Future<void> _handleAuthorizeScopes(GoogleSignInAccount user) async {
    try {
      // #docregion RequestScopes
      final GoogleSignInClientAuthorization authorization = await user
          .authorizationClient
          .authorizeScopes(scopes);
      // #enddocregion RequestScopes

      // The returned tokens are ignored since _handleGetContact uses the
      // authorizationHeaders method to re-read the token cached by
      // authorizeScopes. The code above is used as a README excerpt, so shows
      // the simpler pattern of getting the authorization for immediate use.
      // That results in an unused variable, which this statement suppresses
      // (without adding an ignore: directive to the README excerpt).
      // ignore: unnecessary_statements
      authorization;

      setState(() {
        _isAuthorized = true;
        _errorMessage = '';
      });
      unawaited(_handleGetContact(_currentUser!));
    } on GoogleSignInException catch (e) {
      _errorMessage = _errorMessageFromSignInException(e);
    }
  }

  // Requests a server auth code for the authorized scopes.
  //
  // If authorizationRequiresUserInteraction() is true, this must be called from
  // a user interaction (button click). In this example app, a button is used
  // regardless, so authorizationRequiresUserInteraction() is not checked.
  Future<void> _handleGetAuthCode(GoogleSignInAccount user) async {
    try {
      // #docregion RequestServerAuth
      final GoogleSignInServerAuthorization? serverAuth = await user
          .authorizationClient
          .authorizeServer(scopes);
      // #enddocregion RequestServerAuth

      setState(() {
        _serverAuthCode = serverAuth == null ? '' : serverAuth.serverAuthCode;
      });
    } on GoogleSignInException catch (e) {
      _errorMessage = _errorMessageFromSignInException(e);
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
        leading: GoogleUserCircleAvatar(identity: user),
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
      ElevatedButton(onPressed: _handleSignOut, child: const Text('SIGN OUT')),
    ];
  }

  /// Returns the list of widgets to include if the user is not authenticated.
  List<Widget> _buildUnauthenticatedWidgets() {
    return <Widget>[
      const Text('You are not currently signed in.'),
      // #docregion ExplicitSignIn
      if (GoogleSignIn.instance.supportsAuthenticate())
        ElevatedButton(
          onPressed: () async {
            try {
              await GoogleSignIn.instance.authenticate();
            } catch (e) {
              // #enddocregion ExplicitSignIn
              _errorMessage = e.toString();
              // #docregion ExplicitSignIn
            }
          },
          child: const Text('SIGN IN'),
        )
      else ...<Widget>[
        if (kIsWeb)
          web.renderButton()
        // #enddocregion ExplicitSignIn
        else
          const Text(
            'This platform does not have a known authentication method',
          ),
        // #docregion ExplicitSignIn
      ],
      // #enddocregion ExplicitSignIn
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign In')),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(),
      ),
    );
  }

  String _errorMessageFromSignInException(GoogleSignInException e) {
    // In practice, an application should likely have specific handling for most
    // or all of the, but for simplicity this just handles cancel, and reports
    // the rest as generic errors.
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Sign in canceled',
      _ => 'GoogleSignInException ${e.code}: ${e.description}',
    };
  }
}

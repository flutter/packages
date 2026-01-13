// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, avoid_print

import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:http/http.dart' as http;

const List<String> _scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

void main() {
  runApp(const MaterialApp(title: 'Google Sign In', home: SignInDemo()));
}

class SignInDemo extends StatefulWidget {
  const SignInDemo({super.key});

  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  GoogleSignInUserData? _currentUser;
  bool _isAuthorized = false;
  String _contactText = '';
  String _errorMessage = '';
  // Future that completes when `init` has completed on the sign in instance.
  Future<void>? _initialization;

  @override
  void initState() {
    super.initState();
    _signIn();
  }

  Future<void> _ensureInitialized() {
    return _initialization ??=
        GoogleSignInPlatform.instance.init(const InitParameters())
          ..catchError((dynamic _) {
            _initialization = null;
          });
  }

  void _setUser(GoogleSignInUserData? user) {
    setState(() {
      _currentUser = user;
    });
    if (user != null) {
      // Try getting contacts, in case authorization is already granted.
      _handleGetContact(user);
    }
  }

  Future<void> _signIn() async {
    await _ensureInitialized();
    try {
      final AuthenticationResults? result = await GoogleSignInPlatform.instance
          .attemptLightweightAuthentication(
            const AttemptLightweightAuthenticationParameters(),
          );
      _setUser(result?.user);
    } on GoogleSignInException catch (e) {
      setState(() {
        _errorMessage = e.code == GoogleSignInExceptionCode.canceled
            ? ''
            : 'GoogleSignInException ${e.code}: ${e.description}';
      });
    }
  }

  Future<void> _handleAuthorizeScopes(GoogleSignInUserData user) async {
    try {
      final ClientAuthorizationTokenData? tokens = await GoogleSignInPlatform
          .instance
          .clientAuthorizationTokensForScopes(
            ClientAuthorizationTokensForScopesParameters(
              request: AuthorizationRequestDetails(
                scopes: _scopes,
                userId: user.id,
                email: user.email,
                promptIfUnauthorized: true,
              ),
            ),
          );

      setState(() {
        _isAuthorized = tokens != null;
        _errorMessage = '';
      });
      if (_isAuthorized) {
        unawaited(_handleGetContact(user));
      }
    } on GoogleSignInException catch (e) {
      setState(() {
        _errorMessage = 'GoogleSignInException ${e.code}: ${e.description}';
      });
    }
  }

  Future<Map<String, String>?> _getAuthHeaders(
    GoogleSignInUserData user,
  ) async {
    final ClientAuthorizationTokenData? tokens = await GoogleSignInPlatform
        .instance
        .clientAuthorizationTokensForScopes(
          ClientAuthorizationTokensForScopesParameters(
            request: AuthorizationRequestDetails(
              scopes: _scopes,
              userId: user.id,
              email: user.email,
              promptIfUnauthorized: false,
            ),
          ),
        );
    if (tokens == null) {
      return null;
    }

    return <String, String>{
      'Authorization': 'Bearer ${tokens.accessToken}',
      // TODO(kevmoo): Use the correct value once it's available.
      // See https://github.com/flutter/flutter/issues/80905
      'X-Goog-AuthUser': '0',
    };
  }

  Future<void> _handleGetContact(GoogleSignInUserData user) async {
    setState(() {
      _contactText = 'Loading contact info...';
    });
    final Map<String, String>? headers = await _getAuthHeaders(user);
    setState(() {
      _isAuthorized = headers != null;
    });
    if (headers == null) {
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
      setState(() {
        _contactText =
            'People API gave a ${response.statusCode} '
            'response. Check logs for details.';
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final int contactCount =
        (data['connections'] as List<dynamic>?)?.length ?? 0;
    setState(() {
      _contactText = '$contactCount contacts found';
    });
  }

  Future<void> _handleSignIn() async {
    try {
      await _ensureInitialized();
      final AuthenticationResults result = await GoogleSignInPlatform.instance
          .authenticate(const AuthenticateParameters());
      _setUser(result.user);
    } on GoogleSignInException catch (e) {
      setState(() {
        _errorMessage = e.code == GoogleSignInExceptionCode.canceled
            ? ''
            : 'GoogleSignInException ${e.code}: ${e.description}';
      });
    }
  }

  Future<void> _handleSignOut() async {
    await _ensureInitialized();
    await GoogleSignInPlatform.instance.disconnect(const DisconnectParams());
  }

  Widget _buildBody() {
    final GoogleSignInUserData? user = _currentUser;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        if (user != null) ...<Widget>[
          ListTile(
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const Text('Signed in successfully.'),
          ElevatedButton(
            onPressed: _handleSignOut,
            child: const Text('SIGN OUT'),
          ),
          if (_isAuthorized) ...<Widget>[
            // The user has Authorized all required scopes.
            if (_contactText.isNotEmpty) Text(_contactText),
            ElevatedButton(
              child: const Text('REFRESH'),
              onPressed: () => _handleGetContact(user),
            ),
          ] else ...<Widget>[
            // The user has NOT Authorized all required scopes.
            const Text('Authorization needed to read your contacts.'),
            ElevatedButton(
              onPressed: () => _handleAuthorizeScopes(user),
              child: const Text('REQUEST PERMISSIONS'),
            ),
          ],
        ] else ...<Widget>[
          const Text('You are not currently signed in.'),
          ElevatedButton(
            onPressed: _handleSignIn,
            child: const Text('SIGN IN'),
          ),
        ],
        if (_errorMessage.isNotEmpty) Text(_errorMessage),
      ],
    );
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
}

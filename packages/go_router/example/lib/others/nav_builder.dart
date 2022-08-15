// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// The login information.
class LoginInfo extends ChangeNotifier {
  /// The username of login.
  String get userName => _userName;
  String _userName = '';

  /// Whether a user has logged in.
  bool get loggedIn => _userName.isNotEmpty;

  /// Logs in a user.
  void login(String userName) {
    _userName = userName;
    notifyListeners();
  }

  /// Logs out the current user.
  void logout() {
    _userName = '';
    notifyListeners();
  }
}

void main() => runApp(App());

/// The main app.
class App extends StatelessWidget {
  /// Creates an [App].
  App({Key? key}) : super(key: key);

  final LoginInfo _loginInfo = LoginInfo();

  /// The title of the app.
  static const String title = 'GoRouter Example: Navigator Builder';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationProvider: _router.routeInformationProvider,
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: title,
      );

  late final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    routes: <GoRoute>[
      GoRoute(
        name: 'home',
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreenNoLogout(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
    ],

    // changes on the listenable will cause the router to refresh it's route
    refreshListenable: _loginInfo,

    // redirect to the login page if the user is not logged in
    redirect: (GoRouterState state) {
      final bool loggedIn = _loginInfo.loggedIn;
      const String loginLocation = '/login';
      final bool loggingIn = state.subloc == loginLocation;

      if (!loggedIn) {
        return loggingIn ? null : loginLocation;
      }
      if (loggingIn) {
        return state.namedLocation('home');
      }
      return null;
    },

    // add a wrapper around the navigator to:
    // - put loginInfo into the widget tree, and to
    // - add an overlay to show a logout option
    navigatorBuilder:
        (BuildContext context, GoRouterState state, Widget child) =>
            ChangeNotifierProvider<LoginInfo>.value(
      value: _loginInfo,
      builder: (BuildContext context, Widget? _) {
        return _loginInfo.loggedIn ? AuthOverlay(child: child) : child;
      },
    ),
  );
}

/// A simple class for placing an exit button on top of all screens.
class AuthOverlay extends StatelessWidget {
  /// Creates an [AuthOverlay].
  const AuthOverlay({required this.child, Key? key}) : super(key: key);

  /// The child subtree.
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          child,
          Positioned(
            top: 90,
            right: 4,
            child: ElevatedButton(
              onPressed: () {
                context.read<LoginInfo>().logout();
                context.goNamed('home'); // clear out the `from` query param
              },
              child: const Icon(Icons.logout),
            ),
          ),
        ],
      );
}

/// The home screen without a logout button.
class HomeScreenNoLogout extends StatelessWidget {
  /// Creates a [HomeScreenNoLogout].
  const HomeScreenNoLogout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: const Center(
          child: Text('home screen'),
        ),
      );
}

/// The login screen.
class LoginScreen extends StatelessWidget {
  /// Creates a [LoginScreen].
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // log a user in, letting all the listeners know
                  context.read<LoginInfo>().login('test-user');
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
}

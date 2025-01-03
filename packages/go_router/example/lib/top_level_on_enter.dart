// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(const App());

/// The main application widget.
class App extends StatelessWidget {
  /// Constructs an [App].
  const App({super.key});

  /// The title of the app.
  static const String title = 'GoRouter Example: Top-level onEnter';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/home',

          /// A callback invoked for every route navigation attempt.
          ///
          /// If the callback returns `false`, the navigation is blocked.
          /// Use this to handle authentication, referrals, or other route-based logic.
          onEnter: (BuildContext context, GoRouterState state) {
            // Save the referral code (if provided) and block navigation to the /referral route.
            if (state.uri.path == '/referral') {
              saveReferralCode(context, state.uri.queryParameters['code']);
              return false;
            }

            return true; // Allow navigation for all other routes.
          },

          /// The list of application routes.
          routes: <GoRoute>[
            GoRoute(
              path: '/login',
              builder: (BuildContext context, GoRouterState state) =>
                  const LoginScreen(),
            ),
            GoRoute(
              path: '/home',
              builder: (BuildContext context, GoRouterState state) =>
                  const HomeScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (BuildContext context, GoRouterState state) =>
                  const SettingsScreen(),
            ),
          ],
        ),
        title: title,
      );
}

/// The login screen widget.
class LoginScreen extends StatelessWidget {
  /// Constructs a [LoginScreen].
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go to Home'),
              ),
              ElevatedButton(
                onPressed: () => context.go('/settings'),
                child: const Text('Go to Settings'),
              ),
            ],
          ),
        ),
      );
}

/// The home screen widget.
class HomeScreen extends StatelessWidget {
  /// Constructs a [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Go to Login'),
              ),
              ElevatedButton(
                onPressed: () => context.go('/settings'),
                child: const Text('Go to Settings'),
              ),
              ElevatedButton(
                // This would typically be triggered by an incoming deep link.
                onPressed: () => context.go('/referral?code=12345'),
                child: const Text('Save Referral Code'),
              ),
            ],
          ),
        ),
      );
}

/// The settings screen widget.
class SettingsScreen extends StatelessWidget {
  /// Constructs a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Go to Login'),
              ),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
}

/// Saves a referral code.
///
/// Displays a [SnackBar] with the referral code for demonstration purposes.
/// Replace this with real referral handling logic.
void saveReferralCode(BuildContext context, String? code) {
  if (code != null) {
    // Here you can implement logic to save the referral code as needed.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Referral code saved: $code')),
    );
  }
}

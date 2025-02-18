// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Simulated service for handling referrals and deep links
class ReferralService {
  /// processReferralCode
  static Future<bool> processReferralCode(String code) async {
    // Simulate network delay
    await Future<dynamic>.delayed(const Duration(seconds: 1));
    return true;
  }

  /// trackDeepLink
  static Future<void> trackDeepLink(Uri uri) async {
    // Simulate analytics tracking
    await Future<dynamic>.delayed(const Duration(milliseconds: 300));
    debugPrint('Deep link tracked: $uri');
  }
}

void main() => runApp(const App());

/// The main application widget.
class App extends StatelessWidget {
  /// The main application widget.
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

    return MaterialApp.router(
      routerConfig: _router(key),
      title: 'Top-level onEnter',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
    );
  }

  /// Configures the router with navigation handling and deep link support.
  GoRouter _router(GlobalKey<NavigatorState> key) {
    return GoRouter(
      navigatorKey: key,
      initialLocation: '/home',
      debugLogDiagnostics: true,

      /// Handles incoming routes before navigation occurs.
      /// This callback can:
      /// 1. Block navigation and perform actions (return false)
      /// 2. Allow navigation to proceed (return true)
      /// 3. Show loading states during async operations
      onEnter: (
        BuildContext context,
        GoRouterState currentState,
        GoRouterState nextState,
        GoRouter goRouter,
      ) async {
        // Track analytics for deep links
        if (nextState.uri.hasQuery || nextState.uri.hasFragment) {
          _handleDeepLinkTracking(nextState.uri);
        }

        // Handle special routes
        switch (nextState.uri.path) {
          case '/referral':
            _handleReferralDeepLink(context, nextState);
            return false; // Prevent navigation

          case '/auth':
            if (nextState.uri.queryParameters['token'] != null) {
              _handleAuthCallback(context, nextState);
              return false; // Prevent navigation
            }
            return true;

          default:
            return true; // Allow navigation for all other routes
        }
      },
      routes: <RouteBase>[
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
        // Add route for testing purposes, but it won't navigate
        GoRoute(
          path: '/referral',
          builder: (BuildContext context, GoRouterState state) =>
              const SizedBox(), // Never reached
        ),
      ],
    );
  }

  /// Handles tracking of deep links asynchronously
  void _handleDeepLinkTracking(Uri uri) {
    ReferralService.trackDeepLink(uri).catchError((dynamic error) {
      debugPrint('Failed to track deep link: $error');
    });
  }

  /// Processes referral deep links with loading state
  void _handleReferralDeepLink(BuildContext context, GoRouterState state) {
    final String? code = state.uri.queryParameters['code'];
    if (code == null) {
      return;
    }

    // Show loading immediately
    showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing referral...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Process referral asynchronously
    ReferralService.processReferralCode(code).then(
      (bool success) {
        if (!context.mounted) {
          return;
        }

        // Close loading dialog
        Navigator.of(context).pop();

        // Show result
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Referral code $code applied successfully!'
                  : 'Failed to apply referral code',
            ),
          ),
        );
      },
      onError: (dynamic error) {
        if (!context.mounted) {
          return;
        }

        // Close loading dialog
        Navigator.of(context).pop();

        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  /// Handles OAuth callback processing
  void _handleAuthCallback(BuildContext context, GoRouterState state) {
    final String token = state.uri.queryParameters['token']!;

    // Show processing state
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Processing authentication...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Process auth token asynchronously
    // Replace with your actual auth logic
    Future<void>(() async {
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Processed auth token: $token'),
        ),
      );
    }).catchError((dynamic error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auth error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }
}

/// Demonstrates various navigation scenarios and deep link handling.
class HomeScreen extends StatelessWidget {
  /// Demonstrates various navigation scenarios and deep link handling.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top-level onEnter'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Navigation examples
            ElevatedButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.login),
              label: const Text('Go to Login'),
            ),
            const SizedBox(height: 16),

            // Deep link examples
            Text('Deep Link Tests',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const _DeepLinkButton(
              label: 'Process Referral',
              path: '/referral?code=TEST123',
              description: 'Processes code without navigation',
            ),
            const SizedBox(height: 8),
            const _DeepLinkButton(
              label: 'Auth Callback',
              path: '/auth?token=abc123',
              description: 'Simulates OAuth callback',
            ),
          ],
        ),
      ),
    );
  }
}

/// A button that demonstrates a deep link scenario.
class _DeepLinkButton extends StatelessWidget {
  const _DeepLinkButton({
    required this.label,
    required this.path,
    required this.description,
  });

  final String label;
  final String path;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          OutlinedButton(
            onPressed: () => context.go(path),
            child: Text(label),
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Login screen implementation
class LoginScreen extends StatelessWidget {
  /// Login screen implementation

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.home),
                label: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
}

/// Settings screen implementation
class SettingsScreen extends StatelessWidget {
  /// Settings screen implementation
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            ListTile(
              title: const Text('Home'),
              leading: const Icon(Icons.home),
              onTap: () => context.go('/home'),
            ),
            ListTile(
              title: const Text('Login'),
              leading: const Icon(Icons.login),
              onTap: () => context.go('/login'),
            ),
          ],
        ),
      );
}

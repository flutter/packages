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
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
    );
  }

  /// Configures the router with navigation handling and deep link support.
  GoRouter _router(GlobalKey<NavigatorState> key) {
    return GoRouter(
      navigatorKey: key,
      initialLocation: '/home',
      debugLogDiagnostics: true,

      /// Exception handler to gracefully handle errors in navigation
      onException: (
        BuildContext context,
        GoRouterState state,
        GoRouter router,
      ) {
        // Show a user-friendly error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigation error: ${state.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Go Home',
                onPressed: () => router.go('/home'),
              ),
            ),
          );
        }
        // Log the error for debugging
        debugPrint('Router exception: ${state.error}');

        // Navigate to error screen if needed
        if (state.uri.path == '/crash-test') {
          router.go('/error');
        }
      },

      /// Handles incoming routes before navigation occurs.
      /// This callback can:
      /// 1. Block navigation and perform actions (return Block())
      /// 2. Allow navigation to proceed (return Allow())
      /// 3. Show loading states during async operations
      /// 4. Demonstrate exception handling
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
            final String? code = nextState.uri.queryParameters['code'];
            if (code != null) {
              // Use SnackBar for feedback instead of dialog
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Processing referral code...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }

              // Process code in background - don't block with complex UI
              await _processReferralCodeInBackground(context, code);
            }
            return const Block(); // Prevent navigation

          case '/auth':
            if (nextState.uri.queryParameters['token'] != null) {
              _handleAuthToken(
                context,
                nextState.uri.queryParameters['token']!,
              );
              return const Block(); // Prevent navigation
            }
            return const OnEnterResult.allow();

          case '/crash-test':
            // Deliberately throw an exception to demonstrate error handling
            throw Exception('Simulated error in onEnter callback!');

          case '/bad-route':
            // Runtime type error to test different error types
            // ignore: unnecessary_cast
            nextState.uri as int;
            return const OnEnterResult.allow();

          default:
            // Allow navigation for all other routes
            return const OnEnterResult.allow();
        }
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          redirect: (BuildContext context, GoRouterState state) => '/home',
        ),
        GoRoute(
          path: '/login',
          builder:
              (BuildContext context, GoRouterState state) =>
                  const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder:
              (BuildContext context, GoRouterState state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder:
              (BuildContext context, GoRouterState state) =>
                  const SettingsScreen(),
        ),
        // Add routes for demonstration purposes
        GoRoute(
          path: '/referral',
          builder:
              (BuildContext context, GoRouterState state) =>
                  const SizedBox(), // Never reached
        ),
        GoRoute(
          path: '/crash-test',
          builder:
              (BuildContext context, GoRouterState state) =>
                  const SizedBox(), // Never reached
        ),
        GoRoute(
          path: '/bad-route',
          builder:
              (BuildContext context, GoRouterState state) =>
                  const SizedBox(), // Never reached
        ),
        GoRoute(
          path: '/error',
          builder:
              (BuildContext context, GoRouterState state) =>
                  const ErrorScreen(),
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

  /// Processes referral code in the background without blocking navigation
  Future<void> _processReferralCodeInBackground(
    BuildContext context,
    String code,
  ) async {
    try {
      final bool success = await ReferralService.processReferralCode(code);

      if (!context.mounted) {
        return;
      }

      // Show result with a simple SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Referral code $code applied successfully!'
                : 'Failed to apply referral code',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
      );
    }
  }

  /// Handles OAuth tokens with minimal UI interaction
  void _handleAuthToken(BuildContext context, String token) {
    if (!context.mounted) {
      return;
    }

    // Just show feedback, avoid complex UI
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing auth token: $token'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Process in background
    Future<void>(() async {
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Auth token processed: $token')));
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
            Text(
              'Deep Link Tests',
              style: Theme.of(context).textTheme.titleMedium,
            ),
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

            // Exception Testing Section
            const SizedBox(height: 24),
            Text(
              'Exception Handling Tests',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const _DeepLinkButton(
              label: 'Trigger Exception',
              path: '/crash-test',
              description: 'Throws exception in onEnter callback',
            ),
            const SizedBox(height: 8),
            const _DeepLinkButton(
              label: 'Type Error Exception',
              path: '/bad-route',
              description: 'Triggers a runtime type error',
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
          OutlinedButton(onPressed: () => context.go(path), child: Text(label)),
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

/// Error screen implementation
class ErrorScreen extends StatelessWidget {
  /// Error screen implementation
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Error'), backgroundColor: Colors.red),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          const Text(
            'An error occurred during navigation',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home),
            label: const Text('Return to Home'),
          ),
        ],
      ),
    ),
  );
}

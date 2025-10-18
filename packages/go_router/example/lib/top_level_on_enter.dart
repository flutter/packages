// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

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
    );
  }

  /// Configures the router with navigation handling and deep link support.
  GoRouter _router(GlobalKey<NavigatorState> key) {
    return GoRouter(
      navigatorKey: key,
      initialLocation: '/home',
      debugLogDiagnostics: true,

      // If anything goes sideways during parsing/guards/redirects,
      // surface a friendly message and offer a one-tap “Go Home”.
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

      /// Top-level guard runs BEFORE legacy top-level redirects and route-level redirects.
      /// Return:
      ///  - `Allow()` to proceed (optionally with `then:` side-effects)
      ///  - `Block.stop()` to cancel navigation immediately
      ///  - `Block.then(() => ...)` to cancel navigation and run follow-up work
      onEnter: (
        BuildContext context,
        GoRouterState current,
        GoRouterState next,
        GoRouter router,
      ) async {
        // Example: fire-and-forget analytics for deep links; never block the nav
        if (next.uri.hasQuery || next.uri.hasFragment) {
          // Don't await: keep the guard non-blocking for best UX.
          unawaited(ReferralService.trackDeepLink(next.uri));
        }

        switch (next.uri.path) {
          // Block deep-link routes that should never render a page
          // (we stay on the current page and show a lightweight UI instead).
          case '/referral':
            {
              final String? code = next.uri.queryParameters['code'];
              if (code != null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Processing referral code...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                // Do the real work in the background; don’t keep the user waiting.
                await _processReferralCodeInBackground(context, code);
              }
              return const Block.stop(); // keep user where they are
            }

          // Simulate an OAuth callback: do background work + toast; never show a page at /auth
          case '/auth':
            {
              final String? token = next.uri.queryParameters['token'];
              if (token != null) {
                _handleAuthToken(context, token);
                return const Block.stop(); // cancel showing any /auth page
              }
              return const Allow();
            }

          // Demonstrate error reporting path
          case '/crash-test':
            throw Exception('Simulated error in onEnter callback!');

          case '/protected':
            {
              // ignore: prefer_final_locals
              bool isLoggedIn = false; // pretend we’re not authenticated
              if (!isLoggedIn) {
                // Chaining block: cancel the original nav, then redirect to /login.
                // This preserves redirection history to detect loops.
                final String from = Uri.encodeComponent(next.uri.toString());
                return Block.then(() => router.go('/login?from=$from'));
              }
              // ignore: dead_code
              return const Allow();
            }

          default:
            return const Allow();
        }
      },

      routes: <RouteBase>[
        // Simple “root → home”
        GoRoute(
          path: '/',
          redirect: (BuildContext _, GoRouterState __) => '/home',
        ),

        // Auth + simple pages
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),

        // The following routes will never render (we always Block in onEnter),
        // but they exist so deep-links resolve safely.
        GoRoute(path: '/referral', builder: (_, __) => const SizedBox.shrink()),
        GoRoute(path: '/auth', builder: (_, __) => const SizedBox.shrink()),
        GoRoute(
          path: '/crash-test',
          builder: (_, __) => const SizedBox.shrink(),
        ),

        // Route-level redirect happens AFTER top-level onEnter allows.
        GoRoute(
          path: '/old',
          builder: (_, __) => const SizedBox.shrink(),
          redirect: (_, __) => '/home?from=old',
        ),

        // A page that shows fragments (#hash) via state.uri.fragment
        GoRoute(
          path: '/article/:id',
          name: 'article',
          builder: (_, GoRouterState state) {
            return Scaffold(
              appBar: AppBar(title: const Text('Article')),
              body: Center(
                child: Text(
                  'id=${state.pathParameters['id']}; fragment=${state.uri.fragment}',
                ),
              ),
            );
          },
        ),

        GoRoute(path: '/error', builder: (_, __) => const ErrorScreen()),
      ],
    );
  }

  /// Processes referral code in the background without blocking navigation
  Future<void> _processReferralCodeInBackground(
    BuildContext context,
    String code,
  ) async {
    final bool ok = await ReferralService.processReferralCode(code);
    if (!context.mounted) {
      return;
    }

    // Show result with a simple SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Referral code $code applied successfully!'
              : 'Failed to apply referral code',
        ),
      ),
    );
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
    // background processing — keeps UI responsive and avoids re-entrancy
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
    void goArticleWithFragment() {
      context.goNamed(
        'article',
        pathParameters: <String, String>{'id': '42'},
        // demonstrate fragment support (e.g., for in-page anchors)
        fragment: 'section-2',
      );
    }

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // Navigation examples
          ElevatedButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.login),
            label: const Text('Go to Login'),
          ),
          const SizedBox(height: 16),

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

          const SizedBox(height: 24),
          Text(
            'Guards & Redirects',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const _DeepLinkButton(
            label: 'Protected Route (redirects to login)',
            path: '/protected',
            description: 'Top-level onEnter returns Block.then(() => go(...))',
          ),
          const SizedBox(height: 8),
          const _DeepLinkButton(
            label: 'Legacy Route-level Redirect',
            path: '/old',
            description: 'Route-level redirect to /home?from=old',
          ),

          const SizedBox(height: 24),
          Text(
            'Fragments (hash)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: goArticleWithFragment,
            child: const Text('Open Article #section-2'),
          ),
          Text(
            "Uses goNamed(..., fragment: 'section-2') and reads state.uri.fragment",
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        OutlinedButton(onPressed: () => context.go(path), child: Text(label)),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
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

---
name: go-router-setup-and-usage
description: Set up and use go_router for declarative, URL-based navigation, deep linking, redirection, and nested shell routes in Flutter applications.
---

# Setting Up and Using go_router

`go_router` is a declarative routing package for Flutter built on the Navigator 2.0 Router API. It provides a convenient URL-based API for navigating between screens, parsing path and query parameters, handling deep links, managing redirects, and displaying persistent shell UIs (such as bottom navigation bars).

## 1. Installation

Add `go_router` to your project's `pubspec.yaml`:

```bash
flutter pub add go_router
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  go_router: ^18.0.1
```

## 2. Router Configuration

Configure a `GoRouter` instance and pass it to `MaterialApp.router` (or `CupertinoApp.router`):

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'details/:itemId',
          builder: (BuildContext context, GoRouterState state) {
            final String itemId = state.pathParameters['itemId']!;
            final String? filter = state.uri.queryParameters['filter'];
            return DetailsScreen(itemId: itemId, filter: filter);
          },
        ),
      ],
    ),
  ],
);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'GoRouter Example',
    );
  }
}
```

## 3. Usage and API Examples

### Navigating Between Screens

Use the `BuildContext` extensions provided by `go_router` or call methods on `GoRouter.of(context)`:

```dart
// Navigate to a new location, replacing the current route stack if it's not a sub-route
context.go('/details/42?filter=active');

// Push a location onto the navigation stack (allows popping back)
context.push('/details/42');

// Pop the top-most route off the stack
if (context.canPop()) {
  context.pop();
}
```

### Redirection (Authentication Guard)

Use the top-level or route-level `redirect` callback to guard routes based on application state:

```dart
final GoRouter router = GoRouter(
  refreshListenable: authNotifier, // Re-evaluates redirect when auth state changes
  redirect: (BuildContext context, GoRouterState state) {
    final bool isLoggedIn = authNotifier.isLoggedIn;
    final bool isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoggingIn) {
      return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
    }
    if (isLoggedIn && isLoggingIn) {
      return '/';
    }
    return null; // No redirect needed
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
    ),
  ],
);
```

### Persistent Bottom Navigation with `StatefulShellRoute`

Use `StatefulShellRoute.indexedStack` to maintain independent navigation stacks for each tab in a `NavigationBar` or `BottomNavigationBar`:

```dart
final GoRouter shellRouter = GoRouter(
  initialLocation: '/feed',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/feed',
              builder: (BuildContext context, GoRouterState state) => const FeedScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/profile',
              builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.rss_feed), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

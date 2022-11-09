import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

/// App
class MyApp extends StatelessWidget {
  /// App ctor
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
              return const HomeScreen();
            },
            routes: <RouteBase>[
              ShellRoute(
                builder:
                    (BuildContext context, GoRouterState state, Widget child) {
                  return AppShell(
                    child: child,
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'details',
                    builder: (BuildContext context, GoRouterState state) {
                      return const DetailsScreen();
                    },
                  ),
                  GoRoute(
                    path: 'more-details',
                    builder: (BuildContext context, GoRouterState state) {
                      return const DetailsScreen();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The home screen
class HomeScreen extends StatelessWidget {
  /// Constructs the home screen
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Home'),
      ),
    );
  }
}

/// The app shell
class AppShell extends StatelessWidget {
  /// Constructs the app shell
  const AppShell({
    required this.child,
    Key? key,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (idx) {
          /* ... */
        },
        currentIndex: /* ... */,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Details'),
    );
  }
}

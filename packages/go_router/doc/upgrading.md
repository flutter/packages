You can upgrade an existing app to go_router gradually, by starting with the
home screen and creating a GoRoute for each screen you would like to be
deep-linkable.

# Upgrade an app that uses Navigator

To upgrade an app that is already using the Navigator for routing, start with
a single route for the home screen:

```dart
import 'package:go_router/go_router.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
```

GoRouter leverages the Router API to provide backward compatibility with the
Navigator, so any calls to `Navigator.of(context).push()` or
`Navigator.of(context).pop()` will continue to work, but these destinations
aren't deep-linkable. You can gradually add more routes to the GoRouter
configuration.

# Upgrade an app that uses named routes

An app that uses named routes can be migrated to go_router by changing each
entry in the map to a GoRoute object and changing any calls to
`Navigator.of(context).pushNamed` to `context.go()`.

For example, if you are starting with an app like this:

```dart
MaterialApp(
  initialRoute: '/details',
  routes: {
    '/': (context) => HomeScreen(),
    '/details': (context) => DetailsScreen(),
  },
);
```

Then the GoRouter configuration would look like this:

```dart
GoRouter(
  initialLocation: '/details',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/details',
      builder: (context, state) => const DetailsScreen(),
    ),
  ],
);
```

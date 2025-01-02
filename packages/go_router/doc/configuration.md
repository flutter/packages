Create a GoRouter configuration by calling the [GoRouter][] constructor and
providing list of [GoRoute][] objects:

```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Page1Screen(),
    ),
    GoRoute(
      path: '/page2',
      builder: (context, state) => const Page2Screen(),
    ),
  ],
);
```

# GoRoute
To configure a GoRoute, a path template and builder must be provided. Specify a
path template to handle by providing a `path` parameter, and a builder by
providing either the `builder` or `pageBuilder` parameter:

```dart
GoRoute(
  path: '/users/:userId',
  builder: (context, state) => const UserScreen(),
),
```

To navigate to this route, use
[go()](https://pub.dev/documentation/go_router/latest/go_router/GoRouter/go.html).
To learn more about how navigation works, visit the
[Navigation](https://pub.dev/documentation/go_router/latest/topics/Navigation-topic.html)
topic.

# Parameters
To specify a path parameter, prefix a path segment with a `:` character,
followed by a unique name, for example, `:userId`. You can access the value of
the parameter by accessing it through the [GoRouterState][] object provided to
the builder callback:

```dart
GoRoute(
  path: '/users/:userId',
  builder: (context, state) => const UserScreen(id: state.pathParameters['userId']),
),
```

Similarly, to access a [query
string](https://en.wikipedia.org/wiki/Query_string) parameter (the part of URL
after the `?`), use [GoRouterState][]. For example, a URL path such as
`/users?filter=admins` can read the `filter` parameter:

```dart
GoRoute(
  path: '/users',
  builder: (context, state) => const UsersScreen(filter: state.uri.queryParameters['filter']),
),
```

# Child routes
A matched route can result in more than one screen being displayed on a
Navigator. This is equivalent to calling `push()`, where a new screen is
displayed above the previous screen with a transition animation, and with an
in-app back button in the `AppBar` widget, if it is used.

To display a screen on top of another, add a child route by adding it to the
parent route's `routes` list:

```dart
GoRoute(
  path: '/',
  builder: (context, state) {
    return HomeScreen();
  },
  routes: [
    GoRoute(
      path: 'details',
      builder: (context, state) {
        return DetailsScreen();
      },
    ),
  ],
)
```

# Dynamic RoutingConfig
The [RoutingConfig][] provides a way to update the GoRoute\[s\] after 
the [GoRouter][] has already created. This can be done by creating a GoRouter
with special constructor [GoRouter.routingConfig][]

```dart
final ValueNotifier<RoutingConfig> myRoutingConfig = ValueNotifier<RoutingConfig>(
  RoutingConfig(
    routes: <RouteBase>[GoRoute(path: '/', builder: (_, __) => HomeScreen())],
  ),
);
final GoRouter router = GoRouter.routingConfig(routingConfig: myRoutingConfig);
```

To change the GoRoute later, modify the value of the [ValueNotifier][] directly.

```dart
myRoutingConfig.value = RoutingConfig(
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (_, __) => AlternativeHomeScreen()),
    GoRoute(path: '/a-new-route', builder: (_, __) => SomeScreen()),
  ],
);
```

The value change is automatically picked up by GoRouter and causes it to reparse
the current routes, i.e. RouteMatchList, stored in GoRouter. The RouteMatchList will
reflect the latest change of the `RoutingConfig`.

# Nested navigation
Some apps display destinations in a subsection of the screen, for example, an
app using a BottomNavigationBar that stays on-screen when navigating between
destinations.

To add an additional Navigator, use [ShellRoute][] and provide a builder that returns a widget:

```dart
ShellRoute(
  builder:
      (BuildContext context, GoRouterState state, Widget child) {
    return Scaffold(
      body: child,
      /* ... */
      bottomNavigationBar: BottomNavigationBar(
      /* ... */
      ),
    );
  },
  routes: <RouteBase>[
    GoRoute(
      path: 'details',
      builder: (BuildContext context, GoRouterState state) {
        return const DetailsScreen();
      },
    ),
  ],
),
```

The `child` widget is a Navigator configured to display the matching sub-routes.

For more details, see the [ShellRoute API
documentation](https://pub.dev/documentation/go_router/latest/go_router/ShellRoute-class.html).
For a complete example, see the [ShellRoute
sample](https://github.com/flutter/packages/tree/main/packages/go_router/example/lib/shell_route.dart)
in the example/ directory.

# Stateful nested navigation
In addition to using nested navigation with for instance a BottomNavigationBar,
many apps also require that state is maintained when navigating between 
destinations. To accomplish this, use [StatefulShellRoute][] instead of 
`ShellRoute`.

StatefulShellRoute creates separate `Navigator`s for each of its nested [branches](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellBranch-class.html)
(i.e. parallel navigation trees), making it possible to build an app with 
stateful nested navigation. The constructor [StatefulShellRoute.indexedStack](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute/StatefulShellRoute.indexedStack.html)
provides a default implementation for managing the branch navigators, using an 
`IndexedStack`. 

When using StatefulShellRoute, routes aren't configured on the shell route 
itself. Instead, they are configured for each of the branches. Example:

<?code-excerpt "../example/lib/stateful_shell_route.dart (configuration-branches)"?>
```dart
branches: <StatefulShellBranch>[
  // The route branch for the first tab of the bottom navigation bar.
  StatefulShellBranch(
    navigatorKey: _sectionANavigatorKey,
    routes: <RouteBase>[
      GoRoute(
        // The screen to display as the root in the first tab of the
        // bottom navigation bar.
        path: '/a',
        builder: (BuildContext context, GoRouterState state) =>
            const RootScreen(label: 'A', detailsPath: '/a/details'),
        routes: <RouteBase>[
          // The details screen to display stacked on navigator of the
          // first tab. This will cover screen A but not the application
          // shell (bottom navigation bar).
          GoRoute(
            path: 'details',
            builder: (BuildContext context, GoRouterState state) =>
                const DetailsScreen(label: 'A'),
          ),
        ],
      ),
    ],
    // To enable preloading of the initial locations of branches, pass
    // 'true' for the parameter `preload` (false is default).
  ),
```

Similar to ShellRoute, a builder must be provided to build the actual shell 
Widget that encapsulates the branch navigation container. The latter is 
implemented by the class [StatefulNavigationShell](https://pub.dev/documentation/go_router/latest/go_router/StatefulNavigationShell-class.html), 
which is passed as the last argument to the builder function. Example:

<?code-excerpt "../example/lib/stateful_shell_route.dart (configuration-builder)"?>
```dart
StatefulShellRoute.indexedStack(
  builder: (BuildContext context, GoRouterState state,
      StatefulNavigationShell navigationShell) {
    // Return the widget that implements the custom shell (in this case
    // using a BottomNavigationBar). The StatefulNavigationShell is passed
    // to be able access the state of the shell and to navigate to other
    // branches in a stateful way.
    return ScaffoldWithNavBar(navigationShell: navigationShell);
  },
```

Within the custom shell widget, the StatefulNavigationShell is first and 
foremost used as the child, or body, of the shell. Secondly, it is also used for   
handling stateful switching between branches, as well as providing the currently 
active branch index. Example:

<?code-excerpt "../example/lib/stateful_shell_route.dart (configuration-custom-shell)"?>
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    // The StatefulNavigationShell from the associated StatefulShellRoute is
    // directly passed as the body of the Scaffold.
    body: navigationShell,
    bottomNavigationBar: BottomNavigationBar(
      // Here, the items of BottomNavigationBar are hard coded. In a real
      // world scenario, the items would most likely be generated from the
      // branches of the shell route, which can be fetched using
      // `navigationShell.route.branches`.
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Section A'),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Section B'),
        BottomNavigationBarItem(icon: Icon(Icons.tab), label: 'Section C'),
      ],
      currentIndex: navigationShell.currentIndex,
      // Navigate to the current location of the branch at the provided index
      // when tapping an item in the BottomNavigationBar.
      onTap: (int index) => navigationShell.goBranch(index),
    ),
  );
}
```

For a complete example, see the [Stateful Nested 
Navigation](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart)
in the example/ directory. 
For further details, see the [StatefulShellRoute API
documentation](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html).

# Initial location

The initial location is shown when the app first opens and there is no deep link
provided by the platform. To specify the initial location, provide the
`initialLocation` parameter to the
GoRouter constructor:

```dart
GoRouter(
  initialLocation: '/details',
  /* ... */
);
```

# Logging

To enable log output, enable the `debugLogDiagnostics` parameter:

```dart
final _router = GoRouter(
  routes: [/* ... */],
  debugLogDiagnostics: true,
);
```

[GoRouter]: https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html
[GoRoute]: https://pub.dev/documentation/go_router/latest/go_router/GoRoute-class.html
[GoRouterState]: https://pub.dev/documentation/go_router/latest/go_router/GoRouterState-class.html
[ShellRoute]: https://pub.dev/documentation/go_router/latest/go_router/ShellRoute-class.html
[StatefulShellRoute]: https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html

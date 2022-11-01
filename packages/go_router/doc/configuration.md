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

# Parameters
To specify a path parameter, prefix a path segment with a `:` character,
followed by a unique name, for example, `:userId`. You can access the value of
the parameter by accessing it through the [GoRouterState][] object provided to
the builder callback:

```dart
GoRoute(
  path: '/users/:userId',
  builder: (context, state) => const UserScreen(id: state.params['userId']),
),
```

Similarly, to access a query parameter, use [GoRouterState][]:

```dart
GoRoute(
  path: '/users',
  builder: (context, state) => const UsersScreen(filter: state.queryParams['filter']),
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

[GoRouter]: https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html
[GoRoute]: https://pub.dev/documentation/go_router/latest/go_router/GoRoute-class.html
[GoRouterState]: https://pub.dev/documentation/go_router/latest/go_router/GoRouterState-class.html
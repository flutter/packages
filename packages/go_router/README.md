# go_router

A Declarative Routing Package for Flutter.

This package uses the Flutter framework's Router API to provide a
convenient, url-based API for navigating between different screens. You can
define URL patterns, navigate using a URL, handle deep links,
and a number of other navigation-related scenarios.

## Getting Started

Follow the [package install instructions](https://pub.dev/packages/go_router/install),
and you can start using go_router in your app:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'GoRouter Example',
    );
  }

  final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return ScreenA();
        },
      ),
      GoRoute(
        path: '/b',
        builder: (BuildContext context, GoRouterState state) {
          return ScreenB();
        },
      ),
    ],
  );
}
```

## Define Routes

go_router is governed by a set of routes which are specified as part of the
[GoRouter](https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html)
constructor:

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

In the above snippet, two routes are defined, `/` and `/page2`.
When the URL changes, it is matched against each route path.
The path is matched in a case-insensitive way, but the case for 
parameters is preserved. If there are multiple route matches, 
the **first match** in the list takes priority over the others.

The [builder](https://pub.dev/documentation/go_router/latest/go_router/GoRoute/builder.html)
is responsible for building the `Widget` to display on screen.
Alternatively, you can use `pageBuilder` to customize the transition 
animation when that route becomes active.
The default transition is used between pages
depending on the app at the top of its widget tree, e.g. the use of `MaterialApp`
will cause go_router to use the `MaterialPage` transitions. Consider using
[pageBuilder](https://pub.dev/documentation/go_router/latest/go_router/GoRoute/pageBuilder.html)
for custom `Page` class.

## Initialization

Create a [GoRouter](https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html)
object and initialize your `MaterialApp` or `CupertinoApp`:

```dart
final GoRouter _router = GoRouter(
  routes: <GoRoute>[
     // ...
  ]
);

MaterialApp.router(
  routerConfig: _router,
);
```

## Error handling

By default, go_router comes with default error screens for both `MaterialApp` and
`CupertinoApp` as well as a default error screen in the case that none is used.
Once can also replace the default error screen by using the [errorBuilder](https://pub.dev/documentation/go_router/latest/go_router/GoRouter/GoRouter.html):

```dart
GoRouter(
  ...
  errorBuilder: (context, state) => ErrorScreen(state.error),
);
```

## Redirection

You can use redirection to prevent the user from visiting a specific page. In
go_router, redirection can be asynchronous.

```dart
GoRouter(
  ...
  redirect: (context, state) async {
    if (await LoginService.of(context).isLoggedIn) {
      return state.location;
    }
    return '/login';
  },
);
```

If the code depends on [BuildContext](https://api.flutter.dev/flutter/widgets/BuildContext-class.html)
through the [dependOnInheritedWidgetOfExactType](https://api.flutter.dev/flutter/widgets/BuildContext/dependOnInheritedWidgetOfExactType.html)
(which is how `of` methods are usually implemented), the redirect will be called every time the [InheritedWidget](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)
updated.

### Top-level redirect

The [GoRouter.redirect](https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html)
is always called for every navigation regardless of which GoRoute was matched. The
top-level redirect always takes priority over route-level redirect.

### Route-level redirect

If the top-level redirect does not redirect to a different location,
the [GoRoute.redirect](https://pub.dev/documentation/go_router/latest/go_router/GoRoute/redirect.html)
is then called if the route has matched the GoRoute. If there are multiple
GoRoute matches, e.g. GoRoute with sub-routes, the parent route redirect takes
priority over sub-routes' redirect.

## Navigation

To navigate between routes, use the [GoRouter.go](https://pub.dev/documentation/go_router/latest/go_router/GoRouter/go.html) method:

```dart
onTap: () => GoRouter.of(context).go('/page2')
```

go_router also provides a more concise way to navigate using Dart extension
methods:

```dart
onTap: () => context.go('/page2')
```

## Nested Navigation

The `ShellRoute` route type provides a way to wrap all sub-routes with a UI shell.
Under the hood, GoRouter places a Navigator in the widget tree, which is used
to display matching sub-routes:

```dart
final  _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppScaffold(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/albums',
          builder: (context, state) {
            return HomeScreen();
          },
          routes: <RouteBase>[
            /// The details screen to display stacked on the inner Navigator.
            GoRoute(
              path: 'song/:songId',
              builder: (BuildContext context, GoRouterState state) {
                return const DetailsScreen(label: 'A');
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
```

For more details, see the
[ShellRoute](https://pub.dev/documentation/go_router/latest/go_router/ShellRoute-class.html)
API documentation. For a complete
example, see the 
[ShellRoute sample](https://github.com/flutter/packages/tree/main/packages/go_router/example/lib/shell_route.dart)
in the example/ directory.

### Still not sure how to proceed?
See [examples](https://github.com/flutter/packages/tree/main/packages/go_router/example) for complete runnable examples or visit [API documentation](https://pub.dev/documentation/go_router/latest/go_router/go_router-library.html)


## Migration guides

- [Migrating to 2.0](https://flutter.dev/go/go-router-v2-breaking-changes)
- [Migrating to 2.5](https://flutter.dev/go/go-router-v2-5-breaking-changes)
- [Migrating to 3.0](https://flutter.dev/go/go-router-v3-breaking-changes)
- [Migrating to 4.0](https://flutter.dev/go/go-router-v4-breaking-changes)
- [Migrating to 5.0](https://flutter.dev/go/go-router-v5-breaking-changes)

## Changelog

See the [Changelog](https://github.com/flutter/packages/blob/main/packages/go_router/CHANGELOG.md)
for a list of new features and breaking changes.




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
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
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

## Initalization

Create a [GoRouter](https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html)
object and initialize your `MaterialApp` or `CupertinoApp`:

```dart
final GoRouter _router = GoRouter(
  routes: <GoRoute>[
     // ...
  ]
);

MaterialApp.router(
  routeInformationProvider: _router.routeInformationProvider,
  routeInformationParser: _router.routeInformationParser,
  routerDelegate: _router.routerDelegate,
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

### Still not sure how to proceed?
See [examples](https://github.com/flutter/packages/tree/main/packages/go_router/example) for complete runnable examples or visit [API documentation](https://pub.dev/documentation/go_router/latest/go_router/go_router-library.html)


## Migration guides

- [Migrating to 2.0](https://flutter.dev/go/go-router-v2-breaking-changes)
- [Migrating to 2.5](https://flutter.dev/go/go-router-v2-5-breaking-changes)
- [Migrating to 3.0](https://flutter.dev/go/go-router-v3-breaking-changes)
- [Migrating to 4.0](https://flutter.dev/go/go-router-v4-breaking-changes)

## Changelog

See the [Changelog](https://github.com/flutter/packages/blob/main/packages/go_router/CHANGELOG.md)
for a list of new features and breaking changes.




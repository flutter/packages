# go_router, A Declarative Routing Package for Flutter

This package builds on top of the Flutter framework's Router API and provides
convenient url-based APIs to navigate between different screens. You can
define your own url patterns, navigating to different url, handle deep and
dynamic linking, and a number of other navigation-related scenarios.

## Getting Started

Follow the [package install instructions](https://pub.dev/packages/go_router/install),
and you can start using go_router in your code:

```dart
class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationProvider: _router.routeInformationProvider,
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: 'GoRouter Example',
      );

  final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const Page1Screen(),
      ),
      GoRoute(
        path: '/page2',
        builder: (BuildContext context, GoRouterState state) => const Page2Screen(),
      ),
    ],
  );
}
```

## Define Routes

go_router is governed by a set of routes which are specify as part of the
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

It defined two routes, `/` and `/page2`. Each route path will be matched against
the location to which the user is navigating. The path will be matched in a
case-insensitive way, although the case for parameters will be preserved. If
there are multiple route matches, the <b>first</b> match in the list takes priority
over the others.

In addition to the path, each route will typically have a [builder](https://pub.dev/documentation/go_router/latest/go_router/GoRoute/builder.html)
function that is responsible for building the `Widget` that is to take up the
entire screen of the app. The default transition is used between pages
depending on the app at the top of its widget tree, e.g. the use of `MaterialApp`
will cause go_router to use the `MaterialPage` transitions. Consider using
[pageBuilder](https://pub.dev/documentation/go_router/latest/go_router/GoRoute/pageBuilder.html)
for custom `Page` class.

## Initalization

Once a [GoRouter](https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html)
object is created, it can be used to initialize `MaterialApp` or `CupertinoApp`.

```dart
final GoRouter _router = GoRouter(..);

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

go_router also provides a simplified means of navigation using Dart extension
methods:

```dart
onTap: () => context.go('/page2')
```

<br>

### Still not sure how to proceed? See [examples](https://github.com/flutter/packages/tree/main/packages/go_router/example) for complete runnable examples or visit [API documentation](https://pub.dev/documentation/go_router/latest/go_router/go_router-library.html)


## Migration guides

- [Migrating to 2.0](https://flutter.dev/go/go-router-v2-breaking-changes)
- [Migrating to 2.5](https://flutter.dev/go/go-router-v2-5-breaking-changes)
- [Migrating to 3.0](https://flutter.dev/go/go-router-v3-breaking-changes)
- [Migrating to 4.0](https://flutter.dev/go/go-router-v4-breaking-changes)

## Changelog

See the [Changelog](https://github.com/flutter/packages/blob/main/packages/go_router/CHANGELOG.md)
for a list of new features and breaking changes.




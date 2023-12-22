## Usage

### Dependencies

To use `go_router_builder`, you need to have the following dependencies in
`pubspec.yaml`.

<?code-excerpt "example/readme_excerpts.yaml (Dependencies)"?>
```yaml
dependencies:
  # ...along with your other dependencies
  go_router: ^13.0.0

dev_dependencies:
  # ...along with your other dev-dependencies
  build_runner: ^2.4.0
  go_router_builder: ^2.4.0
```

### Source code

Instructions below explain how to create and annotate types to use this builder.
Along with importing the `go_router.dart` library, it's essential to also
include a `part` directive that references the generated Dart file. The
generated file will always have the name `[source_file].g.dart`.

<?code-excerpt "example/lib/readme_excerpts.dart (Import)"?>
```dart
import 'package:go_router/go_router.dart';

part 'readme_excerpts.g.dart';
```

### Running `build_runner`

To do a one-time build:

```console
flutter pub run build_runner build
```

Read more about using
[`build_runner` on pub.dev](https://pub.dev/packages/build_runner).

## Overview

`go_router` fundamentally relies on the ability to match a string-based location
in a URI format into one or more page builders, each that require zero or more
arguments that are passed as path and query parameters as part of the location.
`go_router` does a good job of making the path and query parameters available
via the `pathParameters` and `queryParameters` properties of the `GoRouterState` object, but
often the page builder must first parse the parameters into types that aren't
`String`s, e.g.

<?code-excerpt "example/lib/readme_excerpts.dart (ParsedParameter)"?>
```dart
routes: <RouteBase>[
  GoRoute(
    path: '/author/:authorId',
    builder: (BuildContext context, GoRouterState state) {
      // require the authorId to be present and be an integer
      final int authorId = int.parse(state.pathParameters['authorId']!);
      return AuthorDetailsScreen(authorId: authorId);
    },
  ),
],
```

In this example, the `authorId` parameter is a) required and b) must be an
`int`. However, neither of these requirements are checked until run-time, making
it easy to write code that is not type-safe, e.g.

<?code-excerpt "example/lib/readme_excerpts.dart (RoutePathTypeError)"?>
```dart
onPressed: () =>
    context.go('/author/a42'), // error: `a42` is not an `int`
```

Dart's type system allows mistakes to be caught at compile-time instead of
run-time. The goal of the routing is to provide a way to define the required and
optional parameters that a specific route consumes and to use code generation to
take out the drudgery of writing a bunch of `go`, `push` and `location`
boilerplate code implementations ourselves.

## Defining a route

Define each route as a class extending `GoRouteData` and overriding the `build`
method.

<?code-excerpt "example/lib/main.dart (DefineRoute)"?>
```dart
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}
```

## Route tree

The tree of routes is defined as an attribute on each of the top-level routes:

<?code-excerpt "example/lib/main.dart (RouteTree)"?>
```dart
@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<FamilyRoute>(
      path: 'family/:fid',
// ···
  ],
)
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

@TypedGoRoute<LoginRoute>(
  path: '/login',
)
class LoginRoute extends GoRouteData {
// ···
}
```

## `GoRouter` initialization

The code generator aggregates all top-level routes into a single list called
`$appRoutes` for use in initializing the `GoRouter` instance:

<?code-excerpt "example/lib/simple_example.dart (Initialization)"?>
```dart
final GoRouter _router = GoRouter(routes: $appRoutes);
```

## Error builder

One can use typed routes to provide an error builder as well:

<?code-excerpt "example/lib/readme_excerpts.dart (ErrorBuilder)"?>
```dart
class ErrorRoute extends GoRouteData {
  ErrorRoute({required this.error});
  final Exception error;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ErrorScreen(error: error);
}
```

With this in place, you can provide the `errorBuilder` parameter like so:

<?code-excerpt "example/lib/readme_excerpts.dart (ErrorBuilderParameter)"?>
```dart
  final GoRouter _router = GoRouter(
    errorBuilder: (BuildContext c, GoRouterState s) =>
        ErrorRoute(error: s.error!).build(c, s),
// ···
  );
```

## Navigation

Navigate using the `go` or `push` methods provided by the code generator:

<?code-excerpt "example/lib/main.dart (Navigation)"?>
```dart
onTap: () => PersonRoute(family.id, p.id).go(context),
```

If you get this wrong, the compiler will complain:

<?code-excerpt "example/lib/readme_excerpts.dart (NavigationError)"?>
```dart
// error: missing required parameter 'fid'
onPressed: () => const PersonRoute(pid: 'p1').go(context),
```

This is the point of typed routing: the error is found statically.

## Return value

Starting from `go_router` 6.5.0, pushing a route and subsequently popping it, can produce
a return value. The generated routes also follow this functionality.

<?code-excerpt "example/lib/readme_excerpts.dart (ReturnValue)"?>
```dart
Future<void> _tap(BuildContext context) async {
  final String result = await const PersonRoute(pid: 'p1').go(context);
}
```

## Query parameters

Parameters (named or positional) not listed in the path of `TypedGoRoute` indicate query parameters:

<?code-excerpt "example/lib/main.dart (QueryParameters)"?>
```dart
@TypedGoRoute<LoginRoute>(
  path: '/login',
)
class LoginRoute extends GoRouteData {
  const LoginRoute({this.fromPage});

  final String? fromPage;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      LoginScreen(from: fromPage);
}
```

### Default values

For query parameters with a **non-nullable** type, you can define a default value:

<?code-excerpt "example/lib/readme_excerpts.dart (DefaultValues)"?>
```dart
@TypedGoRoute<MyRoute>(path: '/my-route')
class MyRoute extends GoRouteData {
  MyRoute({this.queryParameter = 'defaultValue'});
  final String queryParameter;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      MyScreen(queryParameter: queryParameter);
}
```

A query parameter that equals to its default value is not included in the location.


## Extra parameter

A route can consume an extra parameter by taking it as a typed constructor
parameter with the special name `$extra`:

<?code-excerpt "example/lib/extra_example.dart (ExtraParameter)"?>
```dart
@TypedGoRoute<OptionalExtraRoute>(path: '/optionalExtra')
class OptionalExtraRoute extends GoRouteData {
  const OptionalExtraRoute({this.$extra});

  final Extra? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      OptionalExtraScreen(extra: $extra);
}
```

Pass the extra param as a typed object:

<?code-excerpt "example/lib/extra_example.dart (PassExtraParameter)"?>
```dart
onPressed: () =>
    const OptionalExtraRoute($extra: Extra(2)).go(context),
```

The `$extra` parameter is still passed outside the location, still defeats
dynamic and deep linking (including the browser back button) and is still not
recommended when targeting Flutter web.

## Mixed parameters

You can, of course, combine the use of path, query and $extra parameters:

<?code-excerpt "example/lib/readme_excerpts.dart (MixedParameters)"?>
```dart
@TypedGoRoute<HotdogRouteWithEverything>(path: '/:ketchup')
class HotdogRouteWithEverything extends GoRouteData {
  HotdogRouteWithEverything(this.ketchup, this.mustard, this.$extra);
  final bool ketchup; // required path parameter
  final String? mustard; // optional query parameter
  final Sauce $extra; // special $extra parameter

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      HotdogScreen(ketchup, mustard, $extra);
}
```

This seems kinda silly, but it works.

## Redirection

Redirect using the `location` property on a route provided by the code
generator:

<?code-excerpt "example/lib/main.dart (Redirection)"?>
```dart
// redirect to the login page if the user is not logged in
redirect: (BuildContext context, GoRouterState state) {
  final bool loggedIn = loginInfo.loggedIn;

  // check just the matchedLocation in case there are query parameters
  final String loginLoc = const LoginRoute().location;
  final bool goingToLogin = state.matchedLocation == loginLoc;

  // the user is not logged in and not headed to /login, they need to login
  if (!loggedIn && !goingToLogin) {
    return LoginRoute(fromPage: state.matchedLocation).location;
  }

  // the user is logged in and headed to /login, no need to login again
  if (loggedIn && goingToLogin) {
    return const HomeRoute().location;
  }

  // no need to redirect at all
  return null;
},
```

## Route-level redirection

Handle route-level redirects by implementing the `redirect` method on the route:

<?code-excerpt "example/lib/readme_excerpts.dart (RouteLevelRedirection)"?>
```dart
class HomeRoute extends GoRouteData {
  // no need to implement [build] when this [redirect] is unconditional
  @override
  String? redirect(BuildContext context, GoRouterState state) =>
      BooksRoute().location;
}
```

## Type conversions

The code generator can convert simple types like `int` and `enum` to/from the
`String` type of the underlying pathParameters:

<?code-excerpt "example/lib/readme_excerpts.dart (TypeConversions)"?>
```dart
enum BookKind { all, popular, recent }

@TypedGoRoute<BooksRoute>(path: '/books')
class BooksRoute extends GoRouteData {
  BooksRoute({this.kind = BookKind.popular});

  final BookKind kind;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BooksScreen(kind: kind);
}
```

## Transitions

By default, the `GoRouter` will use the app it finds in the widget tree, e.g.
`MaterialApp`, `CupertinoApp`, `WidgetApp`, etc. and use the corresponding page
type to create the page that wraps the `Widget` returned by the route's `build`
method, e.g. `MaterialPage`, `CupertinoPage`, `NoTransitionPage`, etc.
Furthermore, it will use the `state.pageKey` property to set the `key` property
of the page and the `restorationId` of the page.

### Transition override

If you'd like to change how the page is created, e.g. to use a different page
type, pass non-default parameters when creating the page (like a custom key) or
access the `GoRouteState` object, you can override the `buildPage`
method of the base class instead of the `build` method:

<?code-excerpt "example/lib/readme_excerpts.dart (TransitionOverride)"?>
```dart
class MyMaterialRoute extends GoRouteData {
  @override
  MaterialPage<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(
        key: state.pageKey,
        child: const MyPage(),
      );
}
```

### Custom transitions

Overriding the `buildPage` method is also useful for custom transitions:

<?code-excerpt "example/lib/readme_excerpts.dart (CustomTransitions)"?>
```dart
class FancyRoute extends GoRouteData {
  @override
  CustomTransitionPage<void> buildPage(
          BuildContext context, GoRouterState state) =>
      CustomTransitionPage<void>(
        key: state.pageKey,
        child: const FancyPage(),
        transitionsBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> animation2, Widget child) =>
            RotationTransition(turns: animation, child: child),
      );
}
```

## TypedShellRoute and navigator keys

There may be situations where a child route of a shell needs to be displayed on a
different navigator. This kind of scenarios can be achieved by declaring a
**static** navigator key named:

- `$navigatorKey` for ShellRoutes
- `$parentNavigatorKey` for GoRoutes

Example:

<?code-excerpt "example/lib/readme_excerpts.dart (NavigatorKey)"?>
```dart
// For ShellRoutes:
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

class MyShellRouteData extends ShellRouteData {
  const MyShellRouteData();

  static final GlobalKey<NavigatorState> $navigatorKey = shellNavigatorKey;

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
// ···
  }
}

// For GoRoutes:
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class MyGoRouteData extends GoRouteData {
  const MyGoRouteData();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // ···
  }
}
```

An example is available [here](https://github.com/flutter/packages/blob/main/packages/go_router_builder/example/lib/shell_route_with_keys_example.dart).

## Run tests

To run unit tests, run command `dart tool/run_tests.dart` from `packages/go_router_builder/`.

To run tests in examples, run `flutter test` from `packages/go_router_builder/example`.

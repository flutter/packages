## Usage

### Dependencies

To use `go_router_builder`, you need to have the following dependencies in
`pubspec.yaml`.

```yaml
dependencies:
  # ...along with your other dependencies
  go_router: ^7.0.0

dev_dependencies:
  # ...along with your other dev-dependencies
  build_runner: ^2.0.0
  go_router_builder: ^2.0.0
```

### Source code

Instructions below explain how to create and annotate types to use this builder.
Along with importing the `go_router.dart` library, it's essential to also
include a `part` directive that references the generated Dart file. The
generated file will always have the name `[source_file].g.dart`.

```dart
import 'package:go_router/go_router.dart';

part 'this_file.g.dart';
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

```dart
GoRoute(
  path: ':authorId',
  builder: (context, state) {
    // require the authorId to be present and be an integer
    final authorId = int.parse(state.pathParameters['authorId']!);
    return AuthorDetailsScreen(authorId: authorId);
  },
),
```

In this example, the `authorId` parameter is a) required and b) must be an
`int`. However, neither of these requirements are checked until run-time, making
it easy to write code that is not type-safe, e.g.

```dart
void _tap() => context.go('/author/a42'); // error: `a42` is not an `int`
```

Dart's type system allows mistakes to be caught at compile-time instead of
run-time. The goal of the routing is to provide a way to define the required and
optional parameters that a specific route consumes and to use code generation to
take out the drudgery of writing a bunch of `go`, `push` and `location`
boilerplate code implementations ourselves.

## Defining a route

Define each route as a class extending `GoRouteData` and overriding the `build`
method.

```dart
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}
```

## Route tree

The tree of routes is defined as an attribute on each of the top-level routes:

```dart
@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<FamilyRoute>(
      path: 'family/:familyId',
    )
  ],
)
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => HomeScreen(families: familyData);
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {...}
```

## `GoRouter` initialization

The code generator aggregates all top-level routes into a single list called
`$appRoutes` for use in initializing the `GoRouter` instance:

```dart
final _router = GoRouter(routes: $appRoutes);
```

## Error builder

One can use typed routes to provide an error builder as well:

```dart
class ErrorRoute extends GoRouteData {
  ErrorRoute({required this.error});
  final Exception error;

  @override
  Widget build(BuildContext context, GoRouterState state) => ErrorScreen(error: error);
}
```

With this in place, you can provide the `errorBuilder` parameter like so:

```dart
final _router = GoRouter(
  routes: $appRoutes,
  errorBuilder: (c, s) => ErrorRoute(s.error!).build(c),
);
```

## Navigation

Navigate using the `go` or `push` methods provided by the code generator:

```dart
void _tap() => PersonRoute(fid: 'f2', pid: 'p1').go(context);
```

If you get this wrong, the compiler will complain:

```dart
// error: missing required parameter 'fid'
void _tap() => PersonRoute(pid: 'p1').go(context);
```

This is the point of typed routing: the error is found statically.

## Return value

Starting from `go_router` 6.5.0, pushing a route and subsequently popping it, can produce
a return value. The generated routes also follow this functionality.

```dart
void _tap() async {
  final result = await PersonRoute(pid: 'p1').go(context);
}
```

## Query parameters

Parameters (named or positional) not listed in the path of `TypedGoRoute` indicate query parameters:

```dart
@TypedGoRoute(path: '/login')
class LoginRoute extends GoRouteData {
  LoginRoute({this.from});
  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) => LoginScreen(from: from);
}
```

### Default values

For query parameters with a **non-nullable** type, you can define a default value:

```dart
@TypedGoRoute(path: '/my-route')
class MyRoute extends GoRouteData {
  MyRoute({this.queryParameter = 'defaultValue'});
  final String queryParameter;

  @override
  Widget build(BuildContext context, GoRouterState state) => MyScreen(queryParameter: queryParameter);
}
```

A query parameter that equals to its default value is not included in the location.


## Extra parameter

A route can consume an extra parameter by taking it as a typed constructor
parameter with the special name `$extra`:

```dart
class PersonRouteWithExtra extends GoRouteData {
  PersonRouteWithExtra({this.$extra});
  final int? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) => PersonScreen(personId: $extra);
}
```

Pass the extra param as a typed object:

```dart
void _tap() => PersonRouteWithExtra(Person(name: 'Marvin', age: 42)).go(context);
```

The `$extra` parameter is still passed outside the location, still defeats
dynamic and deep linking (including the browser back button) and is still not
recommended when targeting Flutter web.

## Mixed parameters

You can, of course, combine the use of path, query and $extra parameters:

```dart
@TypedGoRoute<HotdogRouteWithEverything>(path: '/:ketchup')
class HotdogRouteWithEverything extends GoRouteData {
  HotdogRouteWithEverything(this.ketchup, this.mustard, this.$extra);
  final bool ketchup; // required path parameter
  final String? mustard; // optional query parameter
  final Sauce $extra; // special $extra parameter

  @override
  Widget build(BuildContext context, GoRouterState state) => HotdogScreen(ketchup, mustard, $extra);
}
```

This seems kinda silly, but it works.

## Redirection

Redirect using the `location` property on a route provided by the code
generator:

```dart
redirect: (state) {
  final loggedIn = loginInfo.loggedIn;
  final loggingIn = state.matchedLocation == LoginRoute().location;
  if( !loggedIn && !loggingIn ) return LoginRoute(from: state.matchedLocation).location;
  if( loggedIn && loggingIn ) return HomeRoute().location;
  return null;
}
```

## Route-level redirection

Handle route-level redirects by implementing the `redirect` method on the route:

```dart
class HomeRoute extends GoRouteData {
  // no need to implement [build] when this [redirect] is unconditional
  @override
  String? redirect(BuildContext context, GoRouterState state) => BooksRoute().location;
}
```

## Type conversions

The code generator can convert simple types like `int` and `enum` to/from the
`String` type of the underlying pathParameters:

```dart
enum BookKind { all, popular, recent }

class BooksRoute extends GoRouteData {
  BooksRoute({this.kind = BookKind.popular});
  final BookKind kind;

  @override
  Widget build(BuildContext context, GoRouterState state) => BooksScreen(kind: kind);
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

```dart
class MyMaterialRouteWithKey extends GoRouteData {
  static final _key = LocalKey('my-route-with-key');
  @override
  MaterialPage<void> buildPage(BuildContext context, GoRouterState state) =>
    MaterialPage<void>(
      key: _key,
      child: MyPage(),
    );
}
```

### Custom transitions

Overriding the `buildPage` method is also useful for custom transitions:

```dart
class FancyRoute extends GoRouteData {
  @override
  MaterialPage<void> buildPage(BuildContext context, GoRouterState state) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: FancyPage(),
      transitionsBuilder: (context, animation, animation2, child) =>
          RotationTransition(turns: animation, child: child),
    ),
}
```

## TypedShellRoute and navigator keys

There may be situations where a child route of a shell needs to be displayed on a
different navigator. This kind of scenarios can be achieved by declaring a
**static** navigator key named:

- `$navigatorKey` for ShellRoutes
- `$parentNavigatorKey` for GoRoutes

Example:

```dart
// For ShellRoutes:
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

class MyShellRouteData extends ShellRouteData {
  const MyShellRouteData();

  static final GlobalKey<NavigatorState> $navigatorKey = shellNavigatorKey;

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    // ...
  }
}

// For GoRoutes:
class MyGoRouteData extends GoRouteData {
  const MyGoRouteData();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // ...
  }
}
```

An example is available [here](https://github.com/flutter/packages/blob/main/packages/go_router_builder/example/lib/shell_route_with_keys_example.dart).

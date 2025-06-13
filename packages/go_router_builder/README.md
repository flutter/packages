## Usage

### Dependencies

To use `go_router_builder`, you need to have the following dependencies in
`pubspec.yaml`.

```yaml
dependencies:
  # ...along with your other dependencies
  go_router: ^9.0.3

dev_dependencies:
  # ...along with your other dev-dependencies
  build_runner: ^2.0.0
  go_router_builder: ^2.3.0
```

### Source code

Instructions below explain how to create and annotate types to use this builder.
Along with importing the `go_router.dart` library, it's essential to also
include a `part` directive that references the generated Dart file. The
generated file will always have the name `[source_file].g.dart`.

<?code-excerpt "example/lib/readme_excerpts.dart (import)"?>
```dart
import 'package:go_router/go_router.dart';

part 'readme_excerpts.g.dart';
```

### Running `build_runner`

To do a one-time build:

```console
dart run build_runner build
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

<?code-excerpt "example/lib/readme_excerpts.dart (GoRoute)"?>
```dart
GoRoute(
  path: ':familyId',
  builder: (BuildContext context, GoRouterState state) {
    // Require the familyId to be present and be an integer.
    final int familyId = int.parse(state.pathParameters['familyId']!);
    return FamilyScreen(familyId);
  },
);
```

In this example, the `familyId` parameter is a) required and b) must be an
`int`. However, neither of these requirements are checked until run-time, making
it easy to write code that is not type-safe, e.g.

<?code-excerpt "example/lib/readme_excerpts.dart (GoWrong)"?>
```dart
void tap() =>
    context.go('/familyId/a42'); // This is an error: `a42` is not an `int`.
```

Dart's type system allows mistakes to be caught at compile-time instead of
run-time. The goal of the routing is to provide a way to define the required and
optional parameters that a specific route consumes and to use code generation to
take out the drudgery of writing a bunch of `go`, `push` and `location`
boilerplate code implementations ourselves.

## Defining a route

Define each route as a class extending `GoRouteData` and overriding the `build`
method.

<?code-excerpt "example/lib/readme_excerpts.dart (HomeRoute)"?>
```dart
class HomeRoute extends GoRouteData with _$HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}
```

## Route tree

The tree of routes is defined as an attribute on each of the top-level routes:

<?code-excerpt "example/lib/readme_excerpts.dart (TypedGoRouteHomeRoute)"?>
```dart
@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<FamilyRoute>(
      path: 'family/:fid',
    ),
  ],
)
class HomeRoute extends GoRouteData with _$HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class RedirectRoute extends GoRouteData {
  // There is no need to implement [build] when this [redirect] is unconditional.
  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return const HomeRoute().location;
  }
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with _$LoginRoute {
  LoginRoute({this.from});
  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return LoginScreen(from: from);
  }
}
```

## `GoRouter` initialization

The code generator aggregates all top-level routes into a single list called
`$appRoutes` for use in initializing the `GoRouter` instance:

<?code-excerpt "example/lib/readme_excerpts.dart (GoRouter)"?>
```dart
final GoRouter router = GoRouter(routes: $appRoutes);
```

## Error builder

One can use typed routes to provide an error builder as well:

<?code-excerpt "example/lib/readme_excerpts.dart (ErrorRoute)"?>
```dart
class ErrorRoute extends GoRouteData {
  ErrorRoute({required this.error});
  final Exception error;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ErrorScreen(error: error);
  }
}
```

With this in place, you can provide the `errorBuilder` parameter like so:

<?code-excerpt "example/lib/readme_excerpts.dart (routerWithErrorBuilder)"?>
```dart
final GoRouter routerWithErrorBuilder = GoRouter(
  routes: $appRoutes,
  errorBuilder: (BuildContext context, GoRouterState state) {
    return ErrorRoute(error: state.error!).build(context, state);
  },
);
```

## Navigation

Navigate using the `go` or `push` methods provided by the code generator:

<?code-excerpt "example/lib/readme_excerpts.dart (go)"?>
```dart
void onTap() => const FamilyRoute(fid: 'f2').go(context);
```

If you get this wrong, the compiler will complain:

<?code-excerpt "example/lib/readme_excerpts.dart (goError)"?>
```dart
// This is an error: missing required parameter 'fid'.
void errorTap() => const FamilyRoute().go(context);
```

This is the point of typed routing: the error is found statically.

## Return value

Starting from `go_router` 6.5.0, pushing a route and subsequently popping it, can produce
a return value. The generated routes also follow this functionality.

<?code-excerpt "example/lib/readme_excerpts.dart (awaitPush)"?>
```dart
final bool? result =
    await const FamilyRoute(fid: 'John').push<bool>(context);
```

## Query parameters

Parameters (named or positional) not listed in the path of `TypedGoRoute` indicate query parameters:

<?code-excerpt "example/lib/readme_excerpts.dart (login)"?>
```dart
@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with _$LoginRoute {
  LoginRoute({this.from});
  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return LoginScreen(from: from);
  }
}
```

### Default values

For query parameters with a **non-nullable** type, you can define a default value:

<?code-excerpt "example/lib/readme_excerpts.dart (MyRoute)"?>
```dart
@TypedGoRoute<MyRoute>(path: '/my-route')
class MyRoute extends GoRouteData with _$MyRoute {
  MyRoute({this.queryParameter = 'defaultValue'});
  final String queryParameter;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MyScreen(queryParameter: queryParameter);
  }
}
```

A query parameter that equals to its default value is not included in the location.


## Extra parameter

A route can consume an extra parameter by taking it as a typed constructor
parameter with the special name `$extra`:

<?code-excerpt "example/lib/readme_excerpts.dart (PersonRouteWithExtra)"?>
```dart
class PersonRouteWithExtra extends GoRouteData with _$PersonRouteWithExtra {
  PersonRouteWithExtra(this.$extra);
  final Person? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PersonScreen($extra);
  }
}
```

Pass the extra param as a typed object:

<?code-excerpt "example/lib/readme_excerpts.dart (tapWithExtra)"?>
```dart
void tapWithExtra() {
  PersonRouteWithExtra(Person(id: 1, name: 'Marvin', age: 42)).go(context);
}
```

The `$extra` parameter is still passed outside the location, still defeats
dynamic and deep linking (including the browser back button) and is still not
recommended when targeting Flutter web.

## Mixed parameters

You can, of course, combine the use of path, query and $extra parameters:

<?code-excerpt "example/lib/readme_excerpts.dart (HotdogRouteWithEverything)"?>
```dart
@TypedGoRoute<HotdogRouteWithEverything>(path: '/:ketchup')
class HotdogRouteWithEverything extends GoRouteData
    with _$HotdogRouteWithEverything {
  HotdogRouteWithEverything(this.ketchup, this.mustard, this.$extra);
  final bool ketchup; // A required path parameter.
  final String? mustard; // An optional query parameter.
  final Sauce $extra; // A special $extra parameter.

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return HotdogScreen(ketchup, mustard, $extra);
  }
}
```

This seems kinda silly, but it works.

## Redirection

Redirect using the `location` property on a route provided by the code
generator:

<?code-excerpt "example/lib/readme_excerpts.dart (redirect)"?>
```dart
redirect: (BuildContext context, GoRouterState state) {
  final bool loggedIn = loginInfo.loggedIn;
  final bool loggingIn = state.matchedLocation == LoginRoute().location;
  if (!loggedIn && !loggingIn) {
    return LoginRoute(from: state.matchedLocation).location;
  }
  if (loggedIn && loggingIn) {
    return const HomeRoute().location;
  }
  return null;
},
```

## Route-level redirection

Handle route-level redirects by implementing the `redirect` method on the route:

<?code-excerpt "example/lib/readme_excerpts.dart (RedirectRoute)"?>
```dart
class RedirectRoute extends GoRouteData {
  // There is no need to implement [build] when this [redirect] is unconditional.
  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return const HomeRoute().location;
  }
}
```

## Type conversions

The code generator can convert simple types like `int` and `enum` to/from the
`String` type of the underlying pathParameters:

<?code-excerpt "example/lib/readme_excerpts.dart (BookKind)"?>
```dart
enum BookKind { all, popular, recent }

@TypedGoRoute<BooksRoute>(path: '/books')
class BooksRoute extends GoRouteData with _$BooksRoute {
  BooksRoute({this.kind = BookKind.popular});
  final BookKind kind;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BooksScreen(kind: kind);
  }
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

<?code-excerpt "example/lib/readme_excerpts.dart (MyMaterialRouteWithKey)"?>
```dart
class MyMaterialRouteWithKey extends GoRouteData with _$MyMaterialRouteWithKey {
  const MyMaterialRouteWithKey();
  static const LocalKey _key = ValueKey<String>('my-route-with-key');
  @override
  MaterialPage<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage<void>(
      key: _key,
      child: MyPage(),
    );
  }
}
```

### Custom transitions

Overriding the `buildPage` method is also useful for custom transitions:

<?code-excerpt "example/lib/readme_excerpts.dart (FancyRoute)"?>
```dart
class FancyRoute extends GoRouteData with _$FancyRoute {
  const FancyRoute();
  @override
  CustomTransitionPage<void> buildPage(
    BuildContext context,
    GoRouterState state,
  ) {
    return CustomTransitionPage<void>(
        key: state.pageKey,
        child: const MyPage(),
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return RotationTransition(turns: animation, child: child);
        });
  }
}
```

## TypedShellRoute and navigator keys

There may be situations where a child route of a shell needs to be displayed on a
different navigator. This kind of scenarios can be achieved by declaring a
**static** navigator key named:

- `$navigatorKey` for ShellRoutes
- `$parentNavigatorKey` for GoRoutes

Example:

<?code-excerpt "example/lib/readme_excerpts.dart (MyShellRouteData)"?>
```dart
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

@TypedShellRoute<MyShellRouteData>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<MyGoRouteData>(path: 'my-go-route'),
  ],
)
class MyShellRouteData extends ShellRouteData {
  const MyShellRouteData();

  static final GlobalKey<NavigatorState> $navigatorKey = shellNavigatorKey;

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MyShellRoutePage(navigator);
  }
}

// For GoRoutes:
class MyGoRouteData extends GoRouteData with _$MyGoRouteData {
  const MyGoRouteData();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => const MyPage();
}
```

An example is available [here](https://github.com/flutter/packages/blob/main/packages/go_router_builder/example/lib/shell_route_with_keys_example.dart).

## Run tests

To run unit tests, run command `dart tool/run_tests.dart` from `packages/go_router_builder/`.

To run tests in examples, run `flutter test` from `packages/go_router_builder/example`.

---
name: go-router-builder-setup-and-usage
description: Set up and use go_router_builder with build_runner to generate strongly-typed route classes and compile-time safe navigation helpers for go_router.
---

# Setting Up and Using go_router_builder

`go_router_builder` generates strongly-typed route helpers for [`go_router`](https://pub.dev/packages/go_router). It eliminates runtime string parsing errors for path and query parameters by generating type-safe `go`, `push`, and `location` methods at compile time.

## 1. Installation

Add `go_router` to `dependencies`, and `go_router_builder` + `build_runner` to `dev_dependencies` in your `pubspec.yaml`:

```bash
flutter pub add go_router
flutter pub add dev:go_router_builder dev:build_runner
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  go_router: ^18.0.1

dev_dependencies:
  build_runner: ^2.6.0
  go_router_builder: ^4.5.0
```

## 2. Build Configuration and Code Generation

### Add `part` Directive
In any Dart file where you define typed routes, include the `part` directive matching the filename with a `.g.dart` extension:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';
```

### Run `build_runner`
Generate the route helper code from the command line:

```bash
# One-time build
dart run build_runner build -d

# Continuous watch mode during development
dart run build_runner watch -d
```

### Optional Builder Configuration (`build.yaml`)
To treat duplicate route paths as compile-time errors instead of warnings, configure `build.yaml` at your package root:

```yaml
targets:
  $default:
    builders:
      go_router_builder:
        options:
          duplicate_route_paths: error
```

## 3. Usage and API Examples

### Defining Typed Routes and Route Trees

Annotate top-level route classes with `@TypedGoRoute<T>` and extend `GoRouteData` with the generated `$RouteName` mixin. Constructor parameters matching path segments become required path parameters; remaining parameters become query parameters:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'app_routes.g.dart';

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<UserDetailsRoute>(path: 'users/:userId'),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class UserDetailsRoute extends GoRouteData with $UserDetailsRoute {
  const UserDetailsRoute({
    required this.userId,
    this.tab = 'overview',
  });

  /// Extracted from path segment `:userId` and automatically converted to int.
  final int userId;

  /// Passed as query parameter `?tab=...` with a default value.
  final String tab;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return UserDetailsScreen(userId: userId, activeTab: tab);
  }
}
```

### Initializing `GoRouter` with Generated Routes

Pass the generated `$appRoutes` list directly to `GoRouter`:

```dart
final GoRouter router = GoRouter(
  routes: $appRoutes,
);
```

### Type-Safe Navigation and Return Values

Navigate using the generated `.go(context)` or `.push(context)` methods on your route instances:

```dart
// Navigate to /users/42?tab=activity
void openUserActivity(BuildContext context) {
  const UserDetailsRoute(userId: 42, tab: 'activity').go(context);
}

// Push a route and await a typed return value when popped
Future<void> pickUser(BuildContext context) async {
  final bool? confirmed = await const UserDetailsRoute(userId: 42).push<bool>(context);
  if (confirmed == true) {
    // Handle confirmation
  }
}
```

### Passing Complex Objects via `$extra`

To pass an in-memory object that is not serialized into the URL, declare a parameter named `$extra`:

```dart
@TypedGoRoute<CheckoutRoute>(path: '/checkout')
class CheckoutRoute extends GoRouteData with $CheckoutRoute {
  const CheckoutRoute({required this.$extra});

  final CartSummary $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CheckoutScreen(cart: $extra);
  }
}
```

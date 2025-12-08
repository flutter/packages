## What is state restoration?

State restoration refers to the process of persisting and restoring serialized state 
after the app has been killed by the operating system in the background.

For more information, see [Restore state on Android](https://docs.flutter.dev/platform-integration/android/restore-state-android)
and [Restore state on iOS](https://docs.flutter.dev/platform-integration/ios/restore-state-ios).

> [!NOTE]
> State restoration does not refer to general purpose state persistence.
> For keeping multiple navigation branches in memory at the same time, 
> see [StatefulShellRoute](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html).

## Support

GoRouter fully supports state restoration. 

To enable state restoration, a top-level configuration is needed
as well as additional configuration depending on the types of routes used.

## Top-level configuration

Add `restorationScopeId`s to `GoRouter` and `MaterialApp.router`:

```dart
final _router = GoRouter(
  restorationScopeId: 'router',
  routes: [
    ...
  ],
);
```

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      restorationScopeId: 'app',
      routerConfig: _router,
    );
  }
}
```

## Route-specific configuration

### GoRoute

For a `GoRoute` that uses `pageBuilder`, supply a `restorationId` to the page:

```dart
GoRoute(
  pageBuilder: (context, state) {
    return MaterialPage(
      restorationId: 'detailsPage',
      path: '/details',
      child: DetailsPage(),
    );
  },
)
```

For a `GoRoute` that does not use `pageBuilder`, no additional configuration
is needed.

For a runnable example with tests, see the [GoRoute state restoration example](https://github.com/flutter/packages/tree/main/packages/go_router/example/lib/state_restoration/go_route_state_restoration.dart).

### ShellRoute

Add a unique `restorationScopeId` to the `ShellRoute`. 
Additionally, add a `pageBuilder` and supply a `restorationId` to the page.

> [!IMPORTANT]
> A `pageBuilder` which returns a page with `restorationId` must be supplied for `ShellRoute` state restoration to work.

For a runnable example with tests, see the [ShellRoute state restoration example](https://github.com/flutter/packages/tree/main/packages/go_router/example/lib/state_restoration/shell_route_state_restoration.dart).

```dart
ShellRoute(
  restorationScopeId: 'onboardingShell',
  pageBuilder: (context, state, child) {
    return MaterialPage(
      restorationId: 'onboardingPage',
      child: OnboardingScaffold(child: child),
    );
  },
  routes: [
    ...
  ],
)
```

### StatefulShellRoute

Add a `restorationScopeId` to the `StatefulShellRoute` and a
`pageBuilder` which returns a page with a `restorationId`.

Additionally, add a `restorationScopeId` to each `StatefulShellBranch`.

> [!IMPORTANT]
> A `pageBuilder` which returns a page with `restorationId` must be supplied for `StatefulShellRoute` state restoration to work.

For a runnable example with tests, see the [StatefulShellRoute state restoration example](https://github.com/flutter/packages/tree/main/packages/go_router/example/lib/state_restoration/stateful_shell_route_state_restoration.dart).

```dart
StatefulShellRoute.indexedStack(
  restorationScopeId: 'appShell',
  pageBuilder: (context, state, navigationShell) {
    return MaterialPage(
      restorationId: 'appShellPage',
      child: AppShell(navigationShell: navigationShell),
    );
  },
  branches: [
    StatefulShellBranch(
      restorationScopeId: 'homeBranch',
      routes: [
        ...
      ],
    ),
    StatefulShellBranch(
      restorationScopeId: 'profileBranch',
      routes: [
        ...
      ],
    ),
  ],
)
```

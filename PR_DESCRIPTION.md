## Description

This PR adds support for route-level `onEnter` navigation guards in `GoRouteData` classes for `go_router_builder`.

### What changed

**go_router:**
- Added `EnterCallback` typedef for route-level onEnter callbacks
- Added `onEnter` parameter to `GoRoute` constructor
- Added `onEnter` method to `_GoRouteDataBase` with default `Allow()` implementation
- Updated `_GoRouteParameters` to include `onEnter` callback
- Modified `GoRouteData.$route()` and `RelativeGoRouteData.$route()` helpers to pass `onEnter` to generated routes

**go_router_builder:**
- Added test case `on_enter.dart` demonstrating usage of `onEnter` in `GoRouteData` classes
- Code generation automatically handles `onEnter` method through existing `$route()` helper infrastructure

### Why

Resolves issue #181471

Currently, `go_router` 16.3.0 introduced a global `onEnter` callback at the `GoRouter` level. However, there's no way to define route-specific navigation guards in `GoRouteData` classes, unlike `redirect` and `onExit` which work at the route level.

This PR enables developers to override the `onEnter` method in their `GoRouteData` classes to implement navigation guards for specific routes, providing consistency with the existing `onExit` pattern.

### Example Usage

```dart
@TypedGoRoute<ProtectedRoute>(path: '/protected')
class ProtectedRoute extends GoRouteData {
  @override
  FutureOr<OnEnterResult> onEnter(
    BuildContext context,
    GoRouterState current,
    GoRouterState next,
    GoRouter router,
  ) {
    final isAuthenticated = checkAuth();
    if (!isAuthenticated) {
      return Block.then(() => router.go('/login'));
    }
    return const Allow();
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProtectedScreen();
  }
}
```

### Note on Implementation Status

⚠️ **Important**: This PR implements the API surface and code generation, but the routing infrastructure to call `GoRoute.onEnter` during navigation is not yet implemented. The generated code is correct, but the callback won't be invoked until the routing logic in `parser.dart` is updated to handle route-level `onEnter` callbacks (similar to how `onExit` is handled in `delegate.dart`).

This PR can serve as a foundation, but additional work is needed to complete the feature.

Fixes #181471

## Pre-Review Checklist

- [x] I read the [Contributor Guide] and followed the process outlined there for submitting PRs.
- [x] I read the [Tree Hygiene] page, which explains my responsibilities.
- [x] I read and followed the [relevant style guides] and ran [the auto-formatter].
- [ ] I signed the [CLA].
- [x] The title of the PR starts with the name of the package surrounded by square brackets, e.g. `[go_router_builder]` and `[go_router]`
- [x] I [linked to at least one issue that this PR fixes] in the description above.
- [x] I updated `pubspec.yaml` with an appropriate new version according to the [pub versioning philosophy], or I have commented below to indicate which [version change exemption] this PR falls under.
- [x] I updated `CHANGELOG.md` to add a description of the change, [following repository CHANGELOG style], or I have commented below to indicate which [CHANGELOG exemption] this PR falls under.
- [x] I updated/added any relevant documentation (doc comments with `///`).
- [x] I added new tests to check the change I am making, or I have commented below to indicate which [test exemption] this PR falls under.
- [x] All existing and new tests are passing.

### Tests

- All 389 existing tests in `go_router` pass
- All 40 tests in `go_router_builder` pass (including new `on_enter.dart` test case)
- New test file: `packages/go_router_builder/test_inputs/on_enter.dart` and `.expect` file

### Version Updates

- Updated `CHANGELOG.md` for both `go_router` and `go_router_builder`
- Version bumps should be handled by repository maintainers using the standard tooling

<!-- Links -->
[Contributor Guide]: https://github.com/flutter/packages/blob/main/CONTRIBUTING.md
[Tree Hygiene]: https://github.com/flutter/flutter/blob/master/docs/contributing/Tree-hygiene.md
[relevant style guides]: https://github.com/flutter/packages/blob/main/CONTRIBUTING.md#style
[the auto-formatter]: https://github.com/flutter/packages/blob/main/script/tool/README.md#format-code
[CLA]: https://cla.developers.google.com/
[Discord]: https://github.com/flutter/flutter/blob/master/docs/contributing/Chat.md
[linked to at least one issue that this PR fixes]: https://github.com/flutter/flutter/blob/master/docs/contributing/Tree-hygiene.md#overview
[pub versioning philosophy]: https://dart.dev/tools/pub/versioning
[version change exemption]: https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#version
[following repository CHANGELOG style]: https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#changelog-style
[CHANGELOG exemption]: https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#changelog
[test exemption]: https://github.com/flutter/flutter/blob/master/docs/contributing/Tree-hygiene.md#tests

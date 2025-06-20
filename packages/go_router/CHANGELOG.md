## 15.2.3

- Updates Type-safe routes topic documentation to use the mixin from `go_router_builder` 3.0.0.

## 15.2.2

- Fixes calling `PopScope.onPopInvokedWithResult` in branch routes.

## 15.2.1

* Fixes Popping state and re-rendering scaffold at the same time doesn't update the URL on web.

## 15.2.0

* `GoRouteData` now defines `.location`, `.go(context)`, `.push(context)`, `.pushReplacement(context)`, and `replace(context)` to be used for [Type-safe routing](https://pub.dev/documentation/go_router/latest/topics/Type-safe%20routes-topic.html). **Requires go_router_builder >= 3.0.0**.

## 15.1.3

* Updates minimum supported SDK version to Flutter 3.27/Dart 3.6.
* Fixes typo in API docs.

## 15.1.2

- Fixes focus request propagation from `GoRouter` to `Navigator` by properly handling the `requestFocus` parameter.

## 15.1.1

- Adds missing `caseSensitive` to `GoRouteData.$route`.

## 15.1.0

- Adds `caseSensitive` to `TypedGoRoute`.

## 15.0.0

- **BREAKING CHANGE**
  - URLs are now case sensitive.
  - Adds `caseSensitive` parameter to `GoRouter` (default to `true`).
  - See [Migrating to 15.0.0](https://flutter.dev/go/go-router-v15-breaking-changes)

## 14.8.1

- Secured canPop method for the lack of matches in routerDelegate's configuration.
 
## 14.8.0

- Adds `preload` parameter to `StatefulShellBranchData.$branch`.

## 14.7.2

- Add missing `await` keyword to `onTap` callback in `navigation.md`.

## 14.7.1

- Fixes return type of current state getter on `GoRouter` and `GoRouterDelegate` to be non-nullable.

## 14.7.0

- Adds fragment support to GoRouter, enabling direct specification and automatic handling of fragments in routes.

## 14.6.4

- Rephrases readme.

## 14.6.3

- Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
- Updates readme.

## 14.6.2

- Replaces deprecated collection method usage.

## 14.6.1

- Fixed `PopScope`, and `WillPopScop` was not handled properly in the Root routes.

## 14.6.0

- Allows going to a path relatively by prefixing `./`

## 14.5.0

- Adds preload support to StatefulShellRoute, configurable via `preload` parameter on StatefulShellBranch.

## 14.4.1

- Adds `missing_code_block_language_in_doc_comment` lint.

## 14.4.0

- Adds current state getter on `GoRouter` that returns the current `GoRouterState`.

## 14.3.0

- Adds missing implementation for the routerNeglect parameter in GoRouter.

## 14.2.9

- Relaxes route path requirements. Both root and child routes can now start with or without '/'.

## 14.2.8

- Updated custom_stateful_shell_route example to better support swiping in TabView as well as demonstration of the use of PageView.

## 14.2.7

- Fixes issue so that the parseRouteInformationWithContext can handle non-http Uris.

## 14.2.6

- Fixes replace and pushReplacement uri when only one route match in current route match list.

## 14.2.5

- Fixes an issue where android back button pops pages in the wrong order.

## 14.2.4

- Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.
- Fix GoRouter configuration in `upgrading.md`

## 14.2.3

- Fixes redirect example's signature in `route.dart`.

## 14.2.2

- Adds section for "Stateful nested navigation" to configuration.md.

## 14.2.1

- Makes GoRouterState lookup more robust.

## 14.2.0

- Added proper `redirect` handling for `ShellRoute.$route` and `StatefulShellRoute.$route` for proper redirection handling in case of code generation.

## 14.1.4

- Fixes a URL in `navigation.md`.

## 14.1.3

- Improves the logging of routes when `debugLogDiagnostics` is enabled or `debugKnownRoutes() is called. Explains the position of shell routes in the route tree. Prints the widget name of the routes it is building.

## 14.1.2

- Fixes issue that path parameters are not set when using the `goBranch`.

## 14.1.1

- Fixes correctness of the state provided in the `onExit`.

## 14.1.0

- Adds route redirect to ShellRoutes

## 14.0.2

- Fixes unwanted logs when `hierarchicalLoggingEnabled` was set to `true`.

## 14.0.1

- Updates the redirection documentation for clarity

## 14.0.0

- **BREAKING CHANGE**
  - `GoRouteData`'s `onExit` now takes 2 parameters `BuildContext context, GoRouterState state`.

## 13.2.4

- Updates examples to use uri.path instead of uri.toString() for accessing the current location.

## 13.2.3

- Fixes an issue where deep links without path caused an exception

## 13.2.2

- Fixes restoreRouteInformation issue when GoRouter.optionURLReflectsImperativeAPIs is true and the last match is ShellRouteMatch

## 13.2.1

- Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.
- Fixes memory leaks.

## 13.2.0

- Exposes full `Uri` on `GoRouterState` in `GoRouterRedirect`

## 13.1.0

- Adds `topRoute` to `GoRouterState`
- Adds `lastOrNull` to `RouteMatchList`

## 13.0.1

- Fixes new lint warnings.

## 13.0.0

- Refactors `RouteMatchList` and imperative APIs.
- **BREAKING CHANGE**:
  - RouteMatchList structure changed.
  - Matching logic updated.

## 12.1.3

- Fixes a typo in `navigation.md`.

## 12.1.2

- Fixes an incorrect use of `extends` for Dart 3 compatibility.
- Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 12.1.1

- Retains query parameters during refresh and first redirect.

## 12.1.0

- Adds an ability to add a custom codec for serializing/deserializing extra.

## 12.0.3

- Fixes crashes when dynamically updates routing tables with named routes.

## 12.0.2

- Fixes the problem that pathParameters is null in redirect when the Router is recreated.

## 12.0.1

- Fixes deep-link with no path on cold start.

## 12.0.0

- Adds ability to dynamically update routing table.
- **BREAKING CHANGE**:
  - The function signature of constructor of `RouteConfiguration` is updated.
  - Adds a required `matchedPath` named parameter to `RouteMatch.match`.

## 11.1.4

- Fixes missing parameters in the type-safe routes topic documentation.

## 11.1.3

- Fixes missing state.extra in onException().

## 11.1.2

- Fixes a bug where the known routes and initial route were logged even when `debugLogDiagnostics` was set to `false`.

## 11.1.1

- Fixes a missing `{@end-tool}` doc directive tag for `GoRoute.name`.

## 11.1.0

- Adds optional parameter `overridePlatformDefaultLocation` to override initial route set by platform.

## 11.0.1

- Fixes the Android back button ignores top level route's onExit.

## 11.0.0

- Fixes the GoRouter.goBranch so that it doesn't reset extra to null if extra is not serializable.
- **BREAKING CHANGE**:
  - Updates the function signature of `GoRouteInformationProvider.restore`.
  - Adds `NavigationType.restore` to `NavigationType` enum.

## 10.2.0

- Adds `onExit` to GoRoute.

## 10.1.4

- Fixes RouteInformationParser that does not restore full RouteMatchList if
  the optionURLReflectsImperativeAPIs is set.

## 10.1.3

- Fixes an issue in the documentation that was using `state.queryParameters` instead of `state.uri.queryParameters`.

## 10.1.2

- Adds pub topics to package metadata.

## 10.1.1

- Fixes mapping from `Page` to `RouteMatch`s.
- Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 10.1.0

- Supports setting `requestFocus`.

## 10.0.0

- **BREAKING CHANGE**:
  - Replaces location, queryParameters, and queryParametersAll in GoRouterState with Uri.
  - See [Migrating to 10.0.0](https://flutter.dev/go/go-router-v10-breaking-changes) or
    run `dart fix --apply` to fix the breakages.

## 9.1.1

- Fixes a link in error handling documentation.

## 9.1.0

- Adds the parentNavigatorKey parameter to ShellRouteData and StatefulShellRouteData.
- Fixes a typo in docs for `StatefulShellRoute.indexedStack(...)`.
- Cleans some typos in the documentation and asserts.

## 9.0.3

- Adds helpers for go_router_builder for StatefulShellRoute support

## 9.0.2

- Exposes package-level privates.

## 9.0.1

- Allows redirect only GoRoute to be part of RouteMatchList.

## 9.0.0

- **BREAKING CHANGE**:
  - Removes GoRouter.location. Use GoRouterState.of().location instead.
  - GoRouter does not `extends` ChangeNotifier.
  - [Migration guide](https://flutter.dev/go/go-router-v9-breaking-changes)
- Reduces excessive rebuilds due to inherited look up.

## 8.2.0

- Adds onException to GoRouter constructor.

## 8.1.0

- Adds parent navigator key to ShellRoute and StatefulShellRoute.

## 8.0.5

- Fixes a bug that GoRouterState in top level redirect doesn't contain complete data.

## 8.0.4

- Updates documentations around `GoRouter.of`, `GoRouter.maybeOf`, and `BuildContext` extension.

## 8.0.3

- Makes namedLocation and route name related APIs case sensitive.

## 8.0.2

- Fixes a bug in `debugLogDiagnostics` to support StatefulShellRoute.

## 8.0.1

- Fixes a link for an example in `path` documentation.
  documentation.

## 8.0.0

- **BREAKING CHANGE**:
  - Imperatively pushed GoRoute no longer change URL.
  - Browser backward and forward button respects imperative route operations.
- Refactors the route parsing pipeline.

## 7.1.1

- Removes obsolete null checks on non-nullable values.

## 7.1.0

- Introduces `StatefulShellRoute` to support using separate navigators for child routes as well as preserving state in each navigation tree (flutter/flutter#99124).
- Updates documentation for `pageBuilder` and `builder` fields of `ShellRoute`, to more correctly
  describe the meaning of the child argument in the builder functions.
- Adds support for restorationId to ShellRoute (and StatefulShellRoute).

## 7.0.2

- Fixes `BuildContext` extension method `replaceNamed` to correctly pass `pathParameters` and `queryParameters`.

## 7.0.1

- Adds a workaround for the `dart fix --apply` issue, https://github.com/dart-lang/sdk/issues/52233.

## 7.0.0

- **BREAKING CHANGE**:
  - For the below changes, run `dart fix --apply` to automatically migrate your code.
    - `GoRouteState.subloc` has been renamed to `GoRouteState.matchedLocation`.
    - `GoRouteState.params` has been renamed to `GoRouteState.pathParameters`.
    - `GoRouteState.fullpath` has been renamed to `GoRouteState.fullPath`.
    - `GoRouteState.queryParams` has been renamed to `GoRouteState.queryParameters`.
    - `params` and `queryParams` in `GoRouteState.namedLocation` have been renamed to `pathParameters` and `queryParameters`.
    - `params` and `queryParams` in `GoRouter`'s `namedLocation`, `pushNamed`, `pushReplacementNamed`
      `replaceNamed` have been renamed to `pathParameters` and `queryParameters`.
  - For the below changes, please follow the [migration guide](https://docs.google.com/document/d/10Xbpifbs4E-zh6YE5akIO8raJq_m3FIXs6nUGdOspOg).
    - `params` and `queryParams` in `BuildContext`'s `namedLocation`, `pushNamed`, `pushReplacementNamed`
      `replaceNamed` have been renamed to `pathParameters` and `queryParameters`.
- Cleans up API and makes RouteMatchList immutable.

## 6.5.9

- Removes navigator keys from `GoRouteData` and `ShellRouteData`.

## 6.5.8

- Adds name parameter to `TypedGoRoute`

## 6.5.7

- Fixes a bug that go_router would crash if `GoRoute.pageBuilder` depends on `InheritedWidget`s.

## 6.5.6

- Fixes an issue where ShellRoute routes were not logged when debugLogDiagnostic was enabled.

## 6.5.5

- Fixes an issue when popping pageless route would accidentally complete imperative page.

## 6.5.4

- Removes navigator keys from `TypedGoRoute` and `TypedShellRoute`.

## 6.5.3

- Fixes redirect being called with an empty location for unknown routes.

## 6.5.2

- NoTransitionPage now has an instant reverse transition.

## 6.5.1

- Fixes an issue where the params are removed after popping.

## 6.5.0

- Supports returning values on pop.

## 6.4.1

- Adds `initialExtra` to **GoRouter** to pass extra data alongside `initialRoute`.

## 6.4.0

- Adds `replace` method to that replaces the current route with a new one and keeps the same page key. This is useful for when you want to update the query params without changing the page key ([#115902](https://github.com/flutter/flutter/issues/115902)).

## 6.3.0

- Aligns Dart and Flutter SDK constraints.
- Updates compileSdkVersion to 33.
- Updates example app to iOS 11.
- Adds `navigatorKey` to `TypedShellRoute`
- Adds `parentNavigatorKey` to `TypedGoRoute`
- Updates documentation in matching methods.

## 6.2.0

- Exports supertypes in route_data.dart library.

## 6.1.0

- Adds `GoRouter.maybeOf` to get the closest `GoRouter` from the context, if there is any.

## 6.0.10

- Adds helpers for go_router_builder for ShellRoute support

## 6.0.9

- Fixes deprecation message for `GoRouterState.namedLocation`

## 6.0.8

- Adds support for Iterables, Lists and Sets in query params for TypedGoRoute. [#108437](https://github.com/flutter/flutter/issues/108437).

## 6.0.7

- Add observers parameter to the ShellRoute that will be passed to the nested Navigator.
- Use `HeroControllerScope` for nested Navigator that fixes Hero Widgets not animating in Nested Navigator.

## 6.0.6

- Adds `reverseTransitionDuration` to `CustomTransitionPage`

## 6.0.5

- Fixes [unnecessary_null_comparison](https://dart.dev/lints/unnecessary_null_checks) lint warnings.

## 6.0.4

- Fixes redirection info log.

## 6.0.3

- Makes `CustomTransitionPage.barrierDismissible` work

## 6.0.2

- Fixes missing result on pop in go_router extension.

## 6.0.1

- Fixes crashes when popping navigators manually.
- Fixes trailing slashes after pops.

## 6.0.0

- **BREAKING CHANGE**
  - `GoRouteData`'s `redirect` now takes 2 parameters `BuildContext context, GoRouterState state`.
  - `GoRouteData`'s `build` now takes 2 parameters `BuildContext context, GoRouterState state`.
  - `GoRouteData`'s `buildPageWithState` has been removed and replaced by `buildPage` with now takes 2 parameters `BuildContext context, GoRouterState state`.
  - `replace` from `GoRouter`, `GoRouterDelegate` and `GoRouterHelper` has been renamed into `pushReplacement`.
  - `replaceNamed` from `GoRouter`, `GoRouterDelegate` and `GoRouterHelper` has been renamed into `pushReplacementNamed`.
  - [go_router v6 migration guide](https://flutter.dev/go/go-router-v6-breaking-changes)

## 5.2.4

- Fixes crashes when using async redirect.

## 5.2.3

- Fixes link for router configuration and sub-routes

## 5.2.2

- Fixes `pop` and `push` to update urls correctly.

## 5.2.1

- Refactors `GoRouter.pop` to be able to pop individual pageless route with result.

## 5.2.0

- Fixes `GoRouterState.location` and `GoRouterState.param` to return correct value.
- Cleans up `RouteMatch` and `RouteMatchList` API.

## 5.1.10

- Fixes link of ShellRoute in README.

## 5.1.9

- Fixes broken links in documentation.

## 5.1.8

- Fixes a bug with `replace` where it was not generated a new `pageKey`.

## 5.1.7

- Adds documentation using dartdoc topics.

## 5.1.6

- Fixes crashes when multiple `GoRoute`s use the same `parentNavigatorKey` in a route subtree.

## 5.1.5

- Adds migration guide for 5.1.2 to readme.

## 5.1.4

- Fixes the documentation by removing the `ShellRoute`'s non-existing `path` parameter from it.

## 5.1.3

- Allows redirection to return same location.

## 5.1.2

- Adds GoRouterState to context.
- Fixes GoRouter notification.
- Updates README.
- Removes dynamic calls in examples.
- **BREAKING CHANGE**
  - Remove NavigatorObserver mixin from GoRouter

## 5.1.1

- Removes DebugGoRouteInformation.

## 5.1.0

- Removes urlPathStrategy completely, which should have been done in v5.0.0 but some code remained mistakenly.

## 5.0.5

- Fixes issue where asserts in popRoute were preventing the app from
  exiting on Android.

## 5.0.4

- Fixes a bug in ShellRoute example where NavigationBar might lose current index in a nested routes.

## 5.0.3

- Changes examples to use the routerConfig API

## 5.0.2

- Fixes missing code example in ShellRoute documentation.

## 5.0.1

- Allows ShellRoute to have child ShellRoutes (flutter/flutter#111981)

## 5.0.0

- Fixes a bug where intermediate route redirect methods are not called.
- GoRouter implements the RouterConfig interface, allowing you to call
  MaterialApp.router(routerConfig: \_myGoRouter) instead of passing
  the RouterDelegate, RouteInformationParser, and RouteInformationProvider
  fields.
- **BREAKING CHANGE**
  - Redesigns redirection API, adds asynchronous feature, and adds build context to redirect.
  - Removes GoRouterRefreshStream
  - Removes navigatorBuilder
  - Removes urlPathStrategy
- [go_router v5 migration guide](https://flutter.dev/go/go-router-v5-breaking-changes)

## 4.5.1

- Fixes an issue where GoRoutes with only a redirect were disallowed
  (flutter/flutter#111763)

## 4.5.0

- Adds ShellRoute for nested navigation support (flutter/flutter#99126)
- Adds `parentNavigatorKey` to GoRoute, which specifies the Navigator to place that
  route's Page onto.

## 4.4.1

- Fix an issue where disabling logging clears the root logger's listeners

## 4.4.0

- Adds `buildPageWithState` to `GoRouteData`.
- `GoRouteData.buildPage` is now deprecated in favor of `GoRouteData.buildPageWithState`.

## 4.3.0

- Allows `Map<String, dynamic>` maps as `queryParams` of `goNamed`, `replacedName`, `pushNamed` and `namedLocation`.

## 4.2.9

- Updates text theme parameters to avoid deprecation issues.
- Fixes lint warnings.

## 4.2.8

- Fixes namedLocation to return URIs without trailing question marks if there are no query parameters.
- Cleans up examples.

## 4.2.7

- Updates README.

## 4.2.6

- Fixes rendering issues in the README.

## 4.2.5

- Fixes a bug where calling extra parameter is always null in route level redirect callback

## 4.2.4

- Rewrites Readme and examples.

## 4.2.3

- Fixes a bug where the ValueKey to be the same when a page was pushed multiple times.

## 4.2.2

- Fixes a bug where go_router_builder wasn't detecting annotations.

## 4.2.1

- Refactors internal classes and methods

## 4.2.0

- Adds `void replace()` and `replaceNamed` to `GoRouterDelegate`, `GoRouter` and `GoRouterHelper`.

## 4.1.1

- Fixes a bug where calling namedLocation does not support case-insensitive way.

## 4.1.0

- Adds `bool canPop()` to `GoRouterDelegate`, `GoRouter` and `GoRouterHelper`.

## 4.0.3

- Adds missed popping log.

## 4.0.2

- Fixes a bug where initialLocation took precedence over deep-links

## 4.0.1

- Fixes a bug where calling setLogging(false) does not clear listeners.

## 4.0.0

- Refactors go_router and introduces `GoRouteInformationProvider`. [Migration Doc](https://flutter.dev/go/go-router-v4-breaking-changes)
- Fixes a bug where top-level routes are skipped if another contains child routes.

## 3.1.1

- Uses first match if there are more than one route to match. [ [#99833](https://github.com/flutter/flutter/issues/99833)

## 3.1.0

- Adds `GoRouteData` and `TypedGoRoute` to support `package:go_router_builder`.

## 3.0.7

- Refactors runtime checks to assertions.

## 3.0.6

- Exports inherited_go_router.dart file.

## 3.0.5

- Add `dispatchNotification` method to `DummyBuildContext` in tests. (This
  should be revisited when Flutter `2.11.0` becomes stable.)
- Improves code coverage.
- `GoRoute` now warns about requiring either `pageBuilder`, `builder` or `redirect` at instantiation.

## 3.0.4

- Updates code for stricter analysis options.

## 3.0.3

- Fixes a bug where params disappear when pushing a nested route.

## 3.0.2

- Moves source to flutter/packages.
- Removes all_lint_rules_community and path_to_regexp dependencies.

## 3.0.1

- pass along the error to the `navigatorBuilder` to allow for different
  implementations based on the presence of an error

## 3.0.0

- breaking change: added `GoRouterState` to `navigatorBuilder` function
- breaking change: removed `BuildContext` from `GoRouter.pop()` to remove the
  need to use `context` parameter when calling the `GoRouter` API; this changes
  the behavior of `GoRouter.pop()` to only pop what's on the `GoRouter` page
  stack and no longer calls `Navigator.pop()`
- new [Migrating to 3.0 section](https://gorouter.dev/migrating-to-30) in the
  docs to describe the details of the breaking changes and how to update your
  code
- added a new [shared
  scaffold](https://github.com/csells/go_router/blob/main/go_router/example/lib/shared_scaffold.dart)
  sample to show how to use the `navigatorBuilder` function to build a custom
  shared scaffold outside of the animations provided by go_router

## 2.5.7

- [PR 262](https://github.com/csells/go_router/pull/262): add support for
  `Router.neglect`; thanks to [nullrocket](https://github.com/nullrocket)!
- [PR 265](https://github.com/csells/go_router/pull/265): add Japanese
  translation of the docs; thanks to
  [toshi-kuji](https://github.com/toshi-kuji)! Unfortunately I don't yet know
  how to properly display them via docs.page, but [I'm working on
  it](https://github.com/csells/go_router/issues/266)
- updated the examples using the `from` query parameter to be completely
  self-contained in the `redirect` function, simplifying usage
- updated the async data example to be simpler
- added a new example to show how to implement a loading page
- renamed the navigator_integration example to user_input and added an example
  of `WillPopScope` for go_router apps

## 2.5.6

- [PR 259](https://github.com/csells/go_router/pull/259): remove a hack for
  notifying the router of a route change that was no longer needed; thanks to
  [nullrocket](https://github.com/nullrocket)!
- improved async example to handle the case that the data has been returned but
  the page is no longer there by checking the `mounted` property of the screen

## 2.5.5

- updated implementation to use logging package for debug diagnostics; thanks
  to [johnpryan](https://github.com/johnpryan)

## 2.5.4

- fixed up the `GoRouterRefreshStream` implementation with an export, an example
  and some docs

## 2.5.3

- added `GoRouterRefreshStream` from
  [jopmiddelkamp](https://github.com/jopmiddelkamp) to easily map from a
  `Stream` to a `Listenable` for use with `refreshListenable`; very useful when
  combined with stream-based state management like
  [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- dartdocs fixups from [mehade369](https://github.com/mehade369)
- example link fixes from [ben-milanko](https://github.com/ben-milanko)

## 2.5.2

- pass additional information to the `NavigatorObserver` via default args to
  `MaterialPage`, etc.

## 2.5.1

- [fix 205](https://github.com/csells/go_router/issues/205): hack around a
  failed assertion in Flutter when using `Duration.zero` in the
  `NoTransitionPage`

## 2.5.0

- provide default implementation of `GoRoute.pageBuilder` to provide a simpler
  way to build pages via the `GoRouter.build` method
- provide default implementation of `GoRouter.errorPageBuilder` to provide a
  simpler way to build error pages via the `GoRouter.errorBuilder` method
- provide default implementation of `GoRouter.errorBuilder` to provide an error
  page without the need to implement a custom error page builder
- new [Migrating to 2.5 section](https://gorouter.dev/migrating-to-25) in
  the docs to show how to take advantage of the new `builder` and default error
  page builder
- removed `launch.json` as VSCode-centric and unnecessary for discovery or easy
  launching
- added a [new custom error screen
  sample](https://github.com/csells/go_router/blob/master/example/lib/error_screen.dart)
- added a [new WidgetsApp
  sample](https://github.com/csells/go_router/blob/master/example/lib/widgets_app.dart)
- added a new `NoTransitionPage` class
- updated docs to explain why the browser's Back button doesn't work
  with the `extra` param
- updated README to point to new docs site: [gorouter.dev](https://gorouter.dev)

## 2.3.1

- [fix 191](https://github.com/csells/go_router/issues/191): handle several
  kinds of trailing / in the location, e.g. `/foo/` should be the same as `/foo`

## 2.3.0

- fix a misleading error message when using redirect functions with sub-routes

## 2.2.9

- [fix 182](https://github.com/csells/go_router/issues/182): fixes a regression
  in the nested navigation caused by the fix for
  [#163](https://github.com/csells/go_router/issues/163); thanks to
  [lulupointu](https://github.com/lulupointu) for the fix!

## 2.2.8

- reformatted CHANGELOG file; lets see if pub.dev is still ok with it...
- staged an in-progress doc site at https://docs.page/csells/go_router
- tightened up a test that was silently failing
- fixed a bug that dropped parent params in sub-route redirects

## 2.2.7

- [fix 163](https://github.com/csells/go_router/issues/163): avoids unnecessary
  page rebuilds
- [fix 139](https://github.com/csells/go_router/issues/139): avoids unnecessary
  page flashes on deep linking
- [fix 158](https://github.com/csells/go_router/issues/158): shows exception
  info in the debug output even during a top-level redirect coded w/ an
  anonymous function, i.e. what the samples all use
- [fix 151](https://github.com/csells/go_router/issues/151): exposes
  `Navigator.pop()` via `GoRouter.pop()` to make it easy to find

## 2.2.6

- [fix 127](https://github.com/csells/go_router/issues/127): updated the docs
  to add a video overview of the project for people that prefer that media style
  over long-form text when approaching a new topic
- [fix 108](https://github.com/csells/go_router/issues/108): updated the
  description of the `state` parameter to clarfy that not all properties will be
  set at every usage

## 2.2.5

- [fix 120 again](https://github.com/csells/go_router/issues/120): found the bug
  in my tests that was masking the real bug; changed two characters to implement
  the actual fix (sigh)

## 2.2.4

- [fix 116](https://github.com/csells/go_router/issues/116): work-around for
  auto-import of the `context.go` family of extension methods

## 2.2.3

- [fix 132](https://github.com/csells/go_router/issues/132): route names are
  stored as case insensitive and are now matched in a case insensitive manner

## 2.2.2

- [fix 120](https://github.com/csells/go_router/issues/120): encoding and
  decoding of params and query params

## 2.2.1

- [fix 114](https://github.com/csells/go_router/issues/114): give a better error
  message when the `GoRouter` isn't found in the widget tree via
  `GoRouter.of(context)`; thanks [aoatmon](https://github.com/aoatmon) for the
  [excellent bug report](https://github.com/csells/go_router/issues/114)!

## 2.2.0

- added a new [`navigatorBuilder`](https://gorouter.dev/navigator-builder) argument to the
  `GoRouter` constructor; thanks to [andyduke](https://github.com/andyduke)!
- also from [andyduke](https://github.com/andyduke) is an update to
  improve state restoration
- refactor from [kevmoo](https://github.com/kevmoo) for easier maintenance
- added a new [Navigator Integration section of the
  docs](https://gorouter.dev/navigator-integration)

## 2.1.2

- [fix 61 again](https://github.com/csells/go_router/issues/61): enable images
  and file links to work on pub.dev/documentation
- [fix 62](https://github.com/csells/go_router/issues/62) re-tested; fixed w/
  earlier Android system Back button fix (using navigation key)
- [fix 91](https://github.com/csells/go_router/issues/91): fix a regression w/
  the `errorPageBuilder`
- [fix 92](https://github.com/csells/go_router/issues/92): fix an edge case w/
  named sub-routes
- [fix 89](https://github.com/csells/go_router/issues/89): enable queryParams
  and extra object param w/ `push`
- refactored tests for greater coverage and fewer methods `@visibleForTesting`

## 2.1.1

- [fix 86](https://github.com/csells/go_router/issues/86): add `name` to
  `GoRouterState` to complete support for URI-free navigation knowledge in your
  code
- [fix 83](https://github.com/csells/go_router/issues/83): fix for `null`
  `extra` object

## 2.1.0

- [fix 80](https://github.com/csells/go_router/issues/80): adding a redirect
  limit to catch too many redirects error
- [fix 81](https://github.com/csells/go_router/issues/81): allow an `extra`
  object to pass through for navigation

## 2.0.1

- add badges to the README and codecov to the GitHub commit action; thanks to
  [rydmike](https://github.com/rydmike) for both

## 2.0.0

- BREAKING CHANGE and [fix #50](https://github.com/csells/go_router/issues/50):
  split `params` into `params` and `queryParams`; see the [Migrating to 2.0
  section of the docs](https://gorouter.dev/migrating-to-20)
  for instructions on how to migrate your code from 1.x to 2.0
- [fix 69](https://github.com/csells/go_router/issues/69): exposed named
  location lookup for redirection
- [fix 57](https://github.com/csells/go_router/issues/57): enable the Android
  system Back button to behave exactly like the `AppBar` Back button; thanks to
  [SunlightBro](https://github.com/SunlightBro) for the one-line fix that I had
  no idea about until he pointed it out
- [fix 59](https://github.com/csells/go_router/issues/59): add query params to
  top-level redirect
- [fix 44](https://github.com/csells/go_router/issues/44): show how to use the
  `AutomaticKeepAliveClientMixin` with nested navigation to keep widget state
  between navigations; thanks to [rydmike](https://github.com/rydmike) for this
  update

## 1.1.3

- enable case-insensitive path matching while still preserving path and query
  parameter cases
- change a lifetime of habit to sort constructors first as per
  [sort_constructors_first](https://dart.dev/lints/sort_constructors_first).
  Thanks for the PR, [Abhishek01039](https://github.com/Abhishek01039)!
- set the initial transition example route to `/none` to make pushing the 'fade
  transition' button on the first run through more fun
- fixed an error in the async data example

## 1.1.2

- Thanks, Mikes!
  - updated dartdocs from [rydmike](https://github.com/rydmike)
  - also shoutout to [https://github.com/Salakar](https://github.com/Salakar)
    for the CI action on GitHub
  - this is turning into a real community effort...

## 1.1.1

- now showing routing exceptions in the debug log
- updated the docs to make it clear that it will be called until it returns
  `null`

## 1.1.0

- added support `NavigatorObserver` objects to receive change notifications

## 1.0.1

- docs updates based on user feedback for clarity
- fix for setting URL path strategy in `main()`
- fix for `push()` disables `AppBar` Back button

## 1.0.0

- updated version for initial release
- some renaming for clarify and consistency with transitions
  - `GoRoute.builder` => `GoRoute.pageBuilder`
  - `GoRoute.error` => `GoRoute.errorPageBuilder`
- added diagnostic logging for `push` and `pushNamed`

## 0.9.6

- added support for `push` as well as `go`
- added 'none' to transitions example app
- updated animation example to use no transition and added an animated gif to
  the docs

## 0.9.5

- added support for custom transitions between routes

## 0.9.4

- updated API docs
- updated docs for `GoRouterState`

## 0.9.3

- updated API docs

## 0.9.2

- updated named route lookup to O(1)
- updated diagnostics output to show known named routes

## 0.9.1

- updated diagnostics output to show named route lookup
- docs updates

## 0.9.0

- added support for named routes

## 0.8.8

- fix to make `GoRouter` notify on pop

## 0.8.7

- made `GoRouter` a `ChangeNotifier` so you can listen for `location` changes

## 0.8.6

- books sample bug fix

## 0.8.5

- added Cupertino sample
- added example of async data lookup

## 0.8.4

- added state restoration sample

## 0.8.3

- changed `debugOutputFullPaths` to `debugLogDiagnostics` and added add'l
  debugging logging
- parameterized redirect

## 0.8.2

- updated docs for `Link` widget support

## 0.8.1

- added Books sample; fixed some issues it revealed

## 0.8.0

- breaking build to refactor the API for simplicity and capability
- move to fixed routing from conditional routing; simplies API, allows for
  redirection at the route level and there scenario was sketchy anyway
- add redirection at the route level
- replace guard objects w/ redirect functions
- add `refresh` method and `refreshListener`
- removed `.builder` ctor from `GoRouter` (not reasonable to implement)
- add Dynamic linking section to the docs
- replaced Books sample with Nested Navigation sample
- add ability to dump the known full paths to your routes to debug output

## 0.7.1

- update to pageKey to take sub-routes into account

## 0.7.0

- BREAK: rename `pattern` to `path` for consistency w/ other routers in the
  world
- added the `GoRouterLoginGuard` for the common redirect-to-login-page pattern

## 0.6.2

- fixed issue showing home page for a second before redirecting (if needed)

## 0.6.1

- added `GoRouterState.pageKey`
- removed `cupertino_icons` from main `pubspec.yaml`

## 0.6.0

- refactor to support sub-routes to build a stack of pages instead of matching
  multiple routes
- added unit tests for building the stack of pages
- some renaming of the types, e.g. `Four04Page` and `FamiliesPage` to
  `ErrorPage` and `HomePage` respectively
- fix a redirection error shown in the debug output

## 0.5.2

- add `urlPathStrategy` argument to `GoRouter` ctor

## 0.5.1

- docs and description updates

## 0.5.0

- moved redirect to top-level instead of per route for simplicity

## 0.4.1

- fixed CHANGELOG formatting

## 0.4.0

- bundled various useful route handling variables into the `GoRouterState` for
  use when building pages and error pages
- updated URL Strategy section of docs to reference `flutter run`

## 0.3.2

- formatting update to appease the pub.dev gods...

## 0.3.1

- updated the CHANGELOG

## 0.3.0

- moved redirection into a `GoRoute` ctor arg
- forgot to update the CHANGELOG

## 0.2.3

- move outstanding issues to [issue
  tracker](https://github.com/csells/go_router/issues)
- added explanation of Deep Linking to docs
- reformatting to meet pub.dev scoring guidelines

## 0.2.2

- docs updates

## 0.2.1

- messing with the CHANGELOG formatting

## 0.2.0

- initial useful release
- added support for declarative routes via `GoRoute` instances
- added support for imperative routing via `GoRoute.builder`
- added support for setting the URL path strategy
- added support for conditional routing
- added support for redirection
- added support for optional query parameters as well as positional parameters
  in route names

## 0.1.0

- squatting on the package name (I'm not too proud to admit it)


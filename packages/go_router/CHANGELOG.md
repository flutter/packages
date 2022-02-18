## 3.0.2

- Integrated to flutter first party.
- Remove all_lint_rules_community and path_to_regexp dependencies

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
  [sort_constructors_first](https://dart-lang.github.io/linter/lints/sort_constructors_first.html).
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

# go_router
A declarative routing package for Flutter that uses the Router API to provide a
convenient, url-based API for navigating between different screens. You can
define URL patterns, navigate using a URL, handle deep links, and a number of
other navigation-related scenarios.

## Features
GoRouter has a number of features to make navigation straightforward:

- Parsing path and query parameters using a template syntax (for example, "user/:id')
- Displaying multiple screens for a destination (sub-routes)
- Redirection support - you can re-route the user to a different URL based on
  application state, for example to a sign-in when the user is not
  authenticated
- Support for multiple Navigators via
  [ShellRoute](https://pub.dev/documentation/go_router/latest/go_router/ShellRoute-class.html) -
  you can display an inner Navigator that displays its own pages based on the
  matched route. For example, to display a BottomNavigationBar that stays
  visible at the bottom of the
  screen
- Support for both Material and Cupertino apps
- Backwards-compatibility with Navigator API

## Documentation
See the API documentation for details on the following topics:

- [Getting started](https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic.html)
- [Upgrade an existing app](https://pub.dev/documentation/go_router/latest/topics/Upgrading-topic.html)
- [Configuration](https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html)
- [Navigation](https://pub.dev/documentation/go_router/latest/topics/Navigation-topic.html)
- [Redirection](https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html)
- [Web](https://pub.dev/documentation/go_router/latest/topics/Web-topic.html)
- [Deep linking](https://pub.dev/documentation/go_router/latest/topics/Deep%20linking-topic.html)
- [Transition animations](https://pub.dev/documentation/go_router/latest/topics/Transition%20animations-topic.html)
- [Type-safe routes](https://pub.dev/documentation/go_router/latest/topics/Type-safe%20routes-topic.html)
- [Named routes](https://pub.dev/documentation/go_router/latest/topics/Named%20routes-topic.html)
- [Error handling](https://pub.dev/documentation/go_router/latest/topics/Error%20handling-topic.html)

## Migration Guides
- [Migrating to 14.0.0](https://flutter.dev/go/go-router-v14-breaking-changes).
- [Migrating to 13.0.0](https://flutter.dev/go/go-router-v13-breaking-changes).
- [Migrating to 12.0.0](https://flutter.dev/go/go-router-v12-breaking-changes).
- [Migrating to 11.0.0](https://flutter.dev/go/go-router-v11-breaking-changes).
- [Migrating to 10.0.0](https://flutter.dev/go/go-router-v10-breaking-changes).
- [Migrating to 9.0.0](https://flutter.dev/go/go-router-v9-breaking-changes).
- [Migrating to 8.0.0](https://flutter.dev/go/go-router-v8-breaking-changes).
- [Migrating to 7.0.0](https://flutter.dev/go/go-router-v7-breaking-changes).
- [Migrating to 6.0.0](https://flutter.dev/go/go-router-v6-breaking-changes)
- [Migrating to 5.1.2](https://flutter.dev/go/go-router-v5-1-2-breaking-changes)
- [Migrating to 5.0](https://flutter.dev/go/go-router-v5-breaking-changes)
- [Migrating to 4.0](https://flutter.dev/go/go-router-v4-breaking-changes)
- [Migrating to 3.0](https://flutter.dev/go/go-router-v3-breaking-changes)
- [Migrating to 2.5](https://flutter.dev/go/go-router-v2-5-breaking-changes)
- [Migrating to 2.0](https://flutter.dev/go/go-router-v2-breaking-changes)

## Changelog
See the
[Changelog](https://github.com/flutter/packages/blob/main/packages/go_router/CHANGELOG.md)
for a list of new features and breaking changes.

## Triage
See the [GitHub issues](https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-asc+label%3Ateam-go_router+)
for all Go Router issues.

The project follows the same priority system as flutter framework.
[P0](https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-asc+label%3Ateam-go_router+label%3AP0+)
[P1](https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-asc+label%3Ateam-go_router+label%3AP1+)
[P2](https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-asc+label%3Ateam-go_router+label%3AP2+)
[P3](https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-asc+label%3Ateam-go_router+label%3AP3+)

[Package PRs](https://github.com/flutter/packages/pulls?q=is%3Apr+is%3Aopen+label%3A%22p%3A+go_router%22%2C%22p%3A+go_router_builder%22)

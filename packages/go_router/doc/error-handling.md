There are several kinds of errors or exceptions in go_router.

* GoError and AssertionError 

This kind of errors are thrown when go_router is used incorrectly, for example, if the root
[GoRoute.path](https://pub.dev/documentation/go_router/latest/go_router/GoRoute/path.html) does
not start with `/` or a builder in GoRoute is not provided. These errors should not be caught and
must be fixed in code in order to use go_router.

* GoException

This kind of exception are thrown when the configuration of go_router cannot handle incoming requests
from users or other part of the code. For example, an GoException is thrown when user enter url that
can't be parsed according to pattern specified in the `GoRouter.routes`. These exceptions can be
handled in various callbacks.

Once can provide a callback to `GoRouter.onException` to handle this exception. In this callback,
one can choose to ignore, redirect, or push different pages depending on the situation.
See [Exception Handling](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/exception_handling.dart)
on a runnable example.

The `GoRouter.errorBuilder` and `GoRouter.errorPageBuilder` can also be used to handle exceptions.
```dart
GoRouter(
  /* ... */
  errorBuilder: (context, state) => ErrorScreen(state.error),
);
```

By default, go_router comes with default error screens for both `MaterialApp`
and `CupertinoApp` as well as a default error screen in the case that none is
used.

**Note** the `GoRouter.onException` supersedes other exception handling APIs.
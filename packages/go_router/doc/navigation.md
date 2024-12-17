There are many ways to navigate between destinations in your app.

## Go directly to a destination
Navigating to a destination in GoRouter will replace the current stack of screens with the screens configured to be displayed
for the destination route. To change to a new screen, call `context.go()` with a URL:

```
build(BuildContext context) {
  return TextButton(
    onPressed: () => context.go('/users/123'),
  );
}
```

This is shorthand for calling `GoRouter.of(context).go('/users/123)`.

To build a URI with query parameters, you can use the `Uri` class from the Dart standard library:

```
context.go(Uri(path: '/users/123', queryParameters: {'filter': 'abc'}).toString());
```

## Imperative navigation
GoRouter can push a screen onto the Navigator's history
stack using `context.push()`, and can pop the current screen via
`context.pop()`. However, imperative navigation is known to cause issues with
the browser history.

To learn more, see [issue
#99112](https://github.com/flutter/flutter/issues/99112).

## Using the Link widget
You can use a Link widget from the url_launcher package to create a link to destinations in
your app. This is equivalent to calling `context.go()`, but renders a real link
on the web.

To add a Link to your app, follow the [Link API
documentation](https://pub.dev/documentation/url_launcher/latest/link/Link-class.html)
from the url_launcher package.

## Using named routes
You can also use [Named routes] to navigate instead of using URLs.

## Prevent navigation
GoRouter and other Router-based APIs are not compatible with the
[WillPopScope](https://api.flutter.dev/flutter/widgets/WillPopScope-class.html)
widget.

See [issue #102408](https://github.com/flutter/flutter/issues/102408)
for details on what such an API might look like in go_router.

## Disable browser history tracking when navigating 

To disable browser history tracking when navigating, use the `neglect` method 
of the `Router` class:

```dart
ElevatedButton(
  onPressed: () => Router.neglect(
    context,
    () => context.go('/destination'),
  ),
  child: ...
),
```

To disable browser history tracking for the **entire** application, set the 
`routerNeglect` property of the `GoRouter` widget to `true`:
```dart
final _router = GoRouter(
  routerNeglect: true,
  routes: [
    ...
  ],
);
```

## Imperative navigation with Navigator
You can continue using the Navigator to push and pop pages. Pages displayed in
this way are not deep-linkable and will be replaced if any parent page that is
associated with a GoRoute is removed, for example when a new call to `go()`
occurs.

To push a screen using the imperative Navigator API, call
[`NavigatorState.push()`](https://api.flutter.dev/flutter/widgets/NavigatorState/push.html):

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (BuildContext context) {
      return const DetailsScreen();
    },
  ),
);
```

The behavior may change depends on the shell route in current screen and the new screen.

If pushing a new screen without any shell route onto the current screen with shell route, the new
screen is placed entirely on top of the current screen.

![An animation shows a new screen push on top of current screen](https://flutter.github.io/assets-for-api-docs/assets/go_router/push_regular_route.gif)

If pushing a new screen with the same shell route as the current screen, the new
screen is placed inside of the shell.

![An animation shows pushing a new screen with the same shell as current screen](https://flutter.github.io/assets-for-api-docs/assets/go_router/push_same_shell.gif)

If pushing a new screen with the different shell route as the current screen, the new
screen along with the shell is placed entirely on top of the current screen.

![An animation shows pushing a new screen with the different shell as current screen](https://flutter.github.io/assets-for-api-docs/assets/go_router/push_different_shell.gif)

To try out the behavior yourself, see
[push_with_shell_route.dart](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/push_with_shell_route.dart).

## Returning values
Waiting for a value to be returned:

```dart
onTap: () {
  final bool? result = await context.push<bool>('/page2');
  if(result ?? false)...
}
```

Returning a value:

```dart
onTap: () => context.pop(true)
```

## Using extra
You can provide additional data along with navigation.

```dart
context.go('/123', extra: 'abc');
```

and retrieve the data from GoRouterState

```dart
final String extraString = GoRouterState.of(context).extra! as String;
```

The extra data will go through serialization when it is stored in the browser.
If you plan to use complex data as extra, consider also providing a codec
to GoRouter so that it won't get dropped during serialization.

For an example on how to use complex data in extra with a codec, see
[extra_codec.dart](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/extra_codec.dart).


[Named routes]: https://pub.dev/documentation/go_router/latest/topics/Named%20routes-topic.html

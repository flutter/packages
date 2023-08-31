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


[Named routes]: https://pub.dev/documentation/go_router/latest/topics/Named%20routes-topic.html

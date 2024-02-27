Redirection changes the location to a new one based on application state. For
example, redirection can be used to display a sign-in screen if the user is not
logged in.

A redirect is a callback of the type
[GoRouterRedirect](https://pub.dev/documentation/go_router/latest/go_router/GoRouterRedirect.html).
To change incoming location based on some application state, add a callback to
either the GoRouter or GoRoute constructor:


```dart
redirect: (BuildContext context, GoRouterState state) {
  if (!AuthState.of(context).isSignedIn) {
    return '/signin';
  } else {
    return null;
  }   
},
```

To display the intended route without redirecting, return `null` or the original
route path.

## Top-level vs route-level redirection
There are two types of redirection:

- Top-level redirection: Defined on the `GoRouter` constructor. Called before
  any navigation event.
- Route-level redirection: Defined on the `GoRoute`
  constructor. Called when a navigation event is about to display the route.

## Named routes
You can also redirect using [Named routes].

## Considerations
- You can specify a `redirectLimit` to configure the maximum number of redirects
  that are expected to occur in your app. By default, this value is set to 5.
  GoRouter will display the error screen if this redirect limit is exceeded (See
  the [Error handling][] topic for more information on the error screen.)

[Named routes]: https://pub.dev/documentation/go_router/latest/topics/Named%20routes-topic.html
[Error handling]: https://pub.dev/documentation/go_router/topics/Error%20handling-topic.html

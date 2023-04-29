Instead of navigating to a route based on the URL, a GoRoute can be given a unique
name. To configure a named route, use the `name` parameter:

```dart
GoRoute(
   name: 'song',
   path: 'songs/:songId',
   builder: /* ... */,
 ),
```

To navigate to a route using its name, call [`goNamed`](https://pub.dev/documentation/go_router/latest/go_router/GoRouter/goNamed.html):

```dart
TextButton(
  onPressed: () {
    context.goNamed('song', pathParameters: {'songId': 123});
  },
  child: const Text('Go to song 2'),
),
```

Alternatively, you can look up the location for a name using `namedLocation`:

```dart
TextButton(
  onPressed: () {
    final String location = context.namedLocation('song', pathParameters: {'songId': 123});
    context.go(location);
  },
  child: const Text('Go to song 2'),
),
```

To learn more about navigation, see the [Navigation][] topic.

## Redirecting to a named route
To redirect to a named route, use the `namedLocation` API:

```dart
redirect: (BuildContext context, GoRouterState state) {
  if (AuthState.of(context).isSignedIn) {
    return context.namedLocation('signIn');
  } else {
    return null;
  }   
},
```

To learn more about redirection, see the [Redirection][] topic.

[Navigation]: https://pub.dev/documentation/go_router/latest/topics/Navigation-topic.html
[Redirection]: https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html

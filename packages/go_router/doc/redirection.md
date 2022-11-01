Redirection changes the location to a new one based on application state. Redirection can
be used to display a sign-in screen if the user is not logged in, for example.

A redirect is a callback of the type
[GoRouterRedirect](go_router/GoRouterRedirect.html). To change incoming location
based on some application state, add a callback to either the GoRouter or
GoRoute constructor:


```dart
redirect: (BuildContext context, GoRouterState state) {
  if (AuthState.of(context).isSignedIn) {
    return '/signin';
  } else {
    return null;
  }   
},
```

## Top-level vs route-level redirection
There are two types of redirection:

- Top-level redirection: Defined on the `GoRouter` constructor. Called before
  any navigation event
- Route-level redirection: Defined on the `GoRoute`
  constructor. Called when a navigation event is about to display the route.

## Considerations
- You can specify a `redirectLimit` to configure the maximum number of redirects
  that are expected to occur in your app, By default, this value is set to 5.
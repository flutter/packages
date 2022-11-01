To get started, follow the [package installation
instructions](https://pub.dev/packages/go_router/install) and add a GoRouter
configuration to your app:

```dart
import 'package:go_router/go_router.dart';

// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
  ],
);
```

To use this configuration in your app, use either the `MaterialApp.router` or
`CupertinoApp.router` constructor and set the `routerConfig` parameter to your
GoRouter configuration object:

```
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
```

For a complete sample, see the [simple example app][] in the example directory.

[simple example app]: https://github.com/flutter/packages/tree/main/packages/go_router/example/lib/simple.dart

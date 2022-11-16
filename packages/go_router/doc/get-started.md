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

For a complete sample, see the [Getting started sample][] in the example directory.
For more on how to configure GoRouter, see [Configuration].

[Getting started sample]: https://github.com/flutter/packages/tree/main/packages/go_router/example/lib/main.dart
[Configuration]: https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html 

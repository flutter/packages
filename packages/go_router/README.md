# Welcome to go_router!

The purpose of [the go_router package](https://pub.dev/packages/go_router) is to
use declarative routes to reduce complexity, regardless of the platform you're
targeting (mobile, web, desktop), handle deep and dynamic linking from
Android, iOS and the web, along with a number of other navigation-related
scenarios, while still (hopefully) providing an easy-to-use developer
experience.

You can get started with go_router with code as simple as this:

```dart
class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: 'GoRouter Example',
      );

  final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const Page1Screen(),
      ),
      GoRoute(
        path: '/page2',
        builder: (BuildContext context, GoRouterState state) => const Page2Screen(),
      ),
    ],
  );
}

class Page1Screen extends StatelessWidget {...}

class Page2Screen extends StatelessWidget {...}
```

But go_router can do oh so much more!

# See [gorouter.dev](https://gorouter.dev) for go_router docs & samples

[![Pub
Version](https://img.shields.io/pub/v/go_router?label=go_router&labelColor=333940&logo=dart)](https://pub.dev/packages/go_router)
![Test](https://github.com/csells/go_router/workflows/validate/badge.svg)
[![codecov](https://codecov.io/gh/csells/go_router/branch/master/graph/badge.svg?token=4XJU30IGO3)](https://codecov.io/gh/csells/go_router)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

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

  final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Page1Screen(),
      ),
      GoRoute(
        path: '/page2',
        builder: (context, state) => const Page2Screen(),
      ),
    ],
  );
}

class Page1Screen extends StatelessWidget {...}

class Page2Screen extends StatelessWidget {...}
```

But go_router can do oh so much more!

# See [gorouter.dev](https://gorouter.dev) for go_router docs & samples

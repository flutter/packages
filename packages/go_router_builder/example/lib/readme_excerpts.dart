// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, unreachable_from_main, avoid_print, unused_element, unused_local_variable, directives_ordering

import 'package:flutter/material.dart';
import 'shared/data.dart';
// #docregion import
import 'package:go_router/go_router.dart';

part 'readme_excerpts.g.dart';
// #enddocregion import

void otherDoc(BuildContext context) {
  // #docregion GoRoute
  GoRoute(
    path: ':familyId',
    builder: (BuildContext context, GoRouterState state) {
      // Require the familyId to be present and be an integer.
      final int familyId = int.parse(state.pathParameters['familyId']!);
      return FamilyScreen(familyId);
    },
  );
  // #enddocregion GoRoute

  // #docregion GoWrong
  void tap() =>
      context.go('/familyId/a42'); // This is an error: `a42` is not an `int`.
  // #enddocregion GoWrong

  // #docregion GoRouter
  final GoRouter router = GoRouter(routes: $appRoutes);
  // #enddocregion GoRouter

  // #docregion routerWithErrorBuilder
  final GoRouter routerWithErrorBuilder = GoRouter(
    routes: $appRoutes,
    errorBuilder: (BuildContext context, GoRouterState state) {
      return ErrorRoute(error: state.error!).build(context, state);
    },
  );
  // #enddocregion routerWithErrorBuilder

  // #docregion go
  void onTap() => const FamilyRoute(fid: 'f2').go(context);
  // #enddocregion go

  // #docregion goError
  // This is an error: missing required parameter 'fid'.
  void errorTap() => const FamilyRoute().go(context);
  // #enddocregion goError

  // #docregion tapWithExtra
  void tapWithExtra() {
    PersonRouteWithExtra(Person(id: 1, name: 'Marvin', age: 42)).go(context);
  }
  // #enddocregion tapWithExtra

  final LoginInfo loginInfo = LoginInfo();

  final GoRouter routerWithRedirect = GoRouter(
    routes: $appRoutes,
    // #docregion redirect
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = loginInfo.loggedIn;
      final bool loggingIn = state.matchedLocation == LoginRoute().location;
      if (!loggedIn && !loggingIn) {
        return LoginRoute(from: state.matchedLocation).location;
      }
      if (loggedIn && loggingIn) {
        return const HomeRoute().location;
      }
      return null;
    },
    // #enddocregion redirect
  );
}

// #docregion TypedGoRouteHomeRoute
@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<FamilyRoute>(
      path: 'family/:fid',
    ),
  ],
)
// #docregion HomeRoute
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}
// #enddocregion HomeRoute

// #docregion RedirectRoute
class RedirectRoute extends GoRouteData {
  // There is no need to implement [build] when this [redirect] is unconditional.
  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return const HomeRoute().location;
  }
}
// #enddocregion RedirectRoute

// #docregion login
@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {
  LoginRoute({this.from});
  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return LoginScreen(from: from);
  }
}
// #enddocregion login
// #enddocregion TypedGoRouteHomeRoute

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('home'),
      ),
      body: TextButton(
        onPressed: () async {
          // #docregion awaitPush
          final bool? result =
              await const FamilyRoute(fid: 'John').push<bool>(context);
          // #enddocregion awaitPush
          print('result is $result');
        },
        child: const Text('push'),
      ),
    );
  }
}

class FamilyRoute extends GoRouteData {
  const FamilyRoute({this.fid});

  final String? fid;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FamilyScreen(int.parse(fid!));
  }
}

class FamilyScreen extends StatelessWidget {
  const FamilyScreen(this.fid, {super.key});

  final int fid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('family'),
      ),
      body: TextButton(
        onPressed: () {
          context.pop(true);
        },
        child: const Text('pop with true'),
      ),
    );
  }
}

// #docregion ErrorRoute
class ErrorRoute extends GoRouteData {
  ErrorRoute({required this.error});
  final Exception error;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ErrorScreen(error: error);
  }
}
// #enddocregion ErrorRoute

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({required this.error, super.key});

  final Exception error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Text(error.toString()),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({required this.from, super.key});
  final String? from;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
    );
  }
}

// #docregion MyRoute
@TypedGoRoute<MyRoute>(path: '/my-route')
class MyRoute extends GoRouteData {
  MyRoute({this.queryParameter = 'defaultValue'});
  final String queryParameter;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MyScreen(queryParameter: queryParameter);
  }
}
// #enddocregion MyRoute

class MyScreen extends StatelessWidget {
  const MyScreen({required this.queryParameter, super.key});
  final String queryParameter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyScreen'),
      ),
    );
  }
}

@TypedGoRoute<PersonRouteWithExtra>(path: '/person')
// #docregion PersonRouteWithExtra
class PersonRouteWithExtra extends GoRouteData {
  PersonRouteWithExtra(this.$extra);
  final Person? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PersonScreen($extra);
  }
}
// #enddocregion PersonRouteWithExtra

class PersonScreen extends StatelessWidget {
  const PersonScreen(this.person, {super.key});
  final Person? person;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PersonScreen'),
      ),
    );
  }
}

// #docregion HotdogRouteWithEverything
@TypedGoRoute<HotdogRouteWithEverything>(path: '/:ketchup')
class HotdogRouteWithEverything extends GoRouteData {
  HotdogRouteWithEverything(this.ketchup, this.mustard, this.$extra);
  final bool ketchup; // A required path parameter.
  final String? mustard; // An optional query parameter.
  final Sauce $extra; // A special $extra parameter.

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return HotdogScreen(ketchup, mustard, $extra);
  }
}
// #enddocregion HotdogRouteWithEverything

class Sauce {}

class HotdogScreen extends StatelessWidget {
  const HotdogScreen(this.ketchup, this.mustard, this.extra, {super.key});
  final bool ketchup;
  final String? mustard;
  final Sauce extra;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotdog'),
      ),
    );
  }
}

// #docregion BookKind
enum BookKind { all, popular, recent }

class BooksRoute extends GoRouteData {
  BooksRoute({this.kind = BookKind.popular});
  final BookKind kind;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BooksScreen(kind: kind);
  }
}
// #enddocregion BookKind

class BooksScreen extends StatelessWidget {
  const BooksScreen({required this.kind, super.key});
  final BookKind kind;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BooksScreen'),
      ),
    );
  }
}

// #docregion MyMaterialRouteWithKey
class MyMaterialRouteWithKey extends GoRouteData {
  static const LocalKey _key = ValueKey<String>('my-route-with-key');
  @override
  MaterialPage<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage<void>(
      key: _key,
      child: MyPage(),
    );
  }
}
// #enddocregion MyMaterialRouteWithKey

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPage'),
      ),
    );
  }
}

class MyShellRoutePage extends StatelessWidget {
  const MyShellRoutePage(this.child, {super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShellRoutePage'),
      ),
      body: child,
    );
  }
}

// #docregion FancyRoute
class FancyRoute extends GoRouteData {
  @override
  CustomTransitionPage<void> buildPage(
    BuildContext context,
    GoRouterState state,
  ) {
    return CustomTransitionPage<void>(
        key: state.pageKey,
        child: const MyPage(),
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return RotationTransition(turns: animation, child: child);
        });
  }
}
// #enddocregion FancyRoute

// #docregion MyShellRouteData
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class MyShellRouteData extends ShellRouteData {
  const MyShellRouteData();

  static final GlobalKey<NavigatorState> $navigatorKey = shellNavigatorKey;

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MyShellRoutePage(navigator);
  }
}

// For GoRoutes:
class MyGoRouteData extends GoRouteData {
  const MyGoRouteData();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => const MyPage();
}
// #enddocregion MyShellRouteData

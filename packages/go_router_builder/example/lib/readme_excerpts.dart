// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: unused_local_variable, unused_field, public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'readme_excerpts.g.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('In App Purchase Examples'),
        ),
      ),
    );
  }

  // #docregion ErrorBuilderParameter
  final GoRouter _router = GoRouter(
    errorBuilder: (BuildContext c, GoRouterState s) =>
        ErrorRoute(error: s.error!).build(c, s),
// #enddocregion ErrorBuilderParameter
// #docregion ParsedParameter
    routes: <RouteBase>[
      GoRoute(
        path: '/author/:authorId',
        builder: (BuildContext context, GoRouterState state) {
          // require the authorId to be present and be an integer
          final int authorId = int.parse(state.pathParameters['authorId']!);
          return AuthorDetailsScreen(authorId: authorId);
        },
      ),
    ],
// #enddocregion ParsedParameter
    // #docregion ErrorBuilderParameter
  );
  // #enddocregion ErrorBuilderParameter
}

class PersonRoute extends GoRouteData {
  const PersonRoute({required this.pid});

  final String pid;

  Future<String> go(BuildContext context) async {
    return 'Result from PersonRoute';
  }
}

// #docregion ErrorBuilder
class ErrorRoute extends GoRouteData {
  ErrorRoute({required this.error});
  final Exception error;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ErrorScreen(error: error);
}
// #enddocregion ErrorBuilder

// #docregion DefaultValues
@TypedGoRoute<MyRoute>(path: '/my-route')
class MyRoute extends GoRouteData {
  MyRoute({this.queryParameter = 'defaultValue'});
  final String queryParameter;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      MyScreen(queryParameter: queryParameter);
}
// #enddocregion DefaultValues

// #docregion MixedParameters
@TypedGoRoute<HotdogRouteWithEverything>(path: '/:ketchup')
class HotdogRouteWithEverything extends GoRouteData {
  HotdogRouteWithEverything(this.ketchup, this.mustard, this.$extra);
  final bool ketchup; // required path parameter
  final String? mustard; // optional query parameter
  final Sauce $extra; // special $extra parameter

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      HotdogScreen(ketchup, mustard, $extra);
}
// #enddocregion MixedParameters

class ReturnValueExample extends StatelessWidget {
  const ReturnValueExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tap Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _tap(context),
          child: const Text('Tap Me'),
        ),
      ),
    );
  }

  // #docregion ReturnValue
  Future<void> _tap(BuildContext context) async {
    final String result = await const PersonRoute(pid: 'p1').go(context);
  }
// #enddocregion ReturnValue
}

class RoutePathTypeErrorExample extends StatelessWidget {
  const RoutePathTypeErrorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Path Type Error Example')),
      body: Center(
        child: ElevatedButton(
          // #docregion RoutePathTypeError
          onPressed: () =>
              context.go('/author/a42'), // error: `a42` is not an `int`
// #enddocregion RoutePathTypeError
          child: const Text('Tap Me'),
        ),
      ),
    );
  }
}

class NavigationErrorExample extends StatelessWidget {
  const NavigationErrorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error Example')),
      body: Center(
        child: ElevatedButton(
          // #docregion NavigationError
          // error: missing required parameter 'fid'
          onPressed: () => const PersonRoute(pid: 'p1').go(context),
          // #enddocregion NavigationError
          child: const Text('Tap Me'),
        ),
      ),
    );
  }
}

// #docregion RouteLevelRedirection
class HomeRoute extends GoRouteData {
  // no need to implement [build] when this [redirect] is unconditional
  @override
  String? redirect(BuildContext context, GoRouterState state) =>
      BooksRoute().location;
}
// #enddocregion RouteLevelRedirection

// #docregion TypeConversions
enum BookKind { all, popular, recent }

@TypedGoRoute<BooksRoute>(path: '/books')
class BooksRoute extends GoRouteData {
  BooksRoute({this.kind = BookKind.popular});

  final BookKind kind;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BooksScreen(kind: kind);
}
// #enddocregion TypeConversions

// #docregion CustomTransitions
class FancyRoute extends GoRouteData {
  @override
  CustomTransitionPage<void> buildPage(
          BuildContext context, GoRouterState state) =>
      CustomTransitionPage<void>(
        key: state.pageKey,
        child: const FancyPage(),
        transitionsBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> animation2, Widget child) =>
            RotationTransition(turns: animation, child: child),
      );
}
// #enddocregion CustomTransitions

// #docregion TransitionOverride
class MyMaterialRoute extends GoRouteData {
  @override
  MaterialPage<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(
        key: state.pageKey,
        child: const MyPage(),
      );
}
// #enddocregion TransitionOverride

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('My Page')));
  }
}

// #docregion NavigatorKey
// For ShellRoutes:
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

class MyShellRouteData extends ShellRouteData {
  const MyShellRouteData();

  static final GlobalKey<NavigatorState> $navigatorKey = shellNavigatorKey;

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
// #enddocregion NavigatorKey
    return Container();
// #docregion NavigatorKey
  }
}

// For GoRoutes:
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class MyGoRouteData extends GoRouteData {
  const MyGoRouteData();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // #enddocregion NavigatorKey
    return Container();
// #docregion NavigatorKey
  }
}
// #enddocregion NavigatorKey

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({required this.error, super.key});

  final Exception error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Error: $error')));
  }
}

class AuthorDetailsScreen extends StatelessWidget {
  const AuthorDetailsScreen({required this.authorId, super.key});

  final int authorId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Author ID: $authorId')));
  }
}

class HotdogScreen extends StatelessWidget {
  const HotdogScreen(this.ketchup, this.mustard, this.$extra, {super.key});

  final bool ketchup;
  final String? mustard;
  final Sauce $extra;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Hot dog screen')));
  }
}

class Sauce {}

class MyScreen extends StatelessWidget {
  const MyScreen({required this.queryParameter, super.key});

  final String queryParameter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Query: $queryParameter')));
  }
}

class BooksScreen extends StatelessWidget {
  const BooksScreen({required this.kind, super.key});

  final BookKind kind;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Book Kind: $kind')));
  }
}

class FancyPage extends StatelessWidget {
  const FancyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Fancy Page')));
  }
}

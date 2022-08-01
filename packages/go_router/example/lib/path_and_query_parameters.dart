// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/data.dart';

// This scenario demonstrates how to use path parameters and query parameters.
//
// The route segments that start with ':' are treated as path parameters when
// defining GoRoute[s]. The parameter values can be accessed through
// GoRouterState.params.
//
// The query parameters are automatically stored in GoRouterState.queryParams.

void main() => runApp(App());

/// The main app.
class App extends StatelessWidget {
  /// Creates an [App].
  App({Key? key}) : super(key: key);

  /// The title of the app.
  static const String title = 'GoRouter Example: Query Parameters';

  // add the login info into the tree as app state that can change over time
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationProvider: _router.routeInformationProvider,
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: title,
        debugShowCheckedModeBanner: false,
      );

  late final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            HomeScreen(families: Families.data),
        routes: <GoRoute>[
          GoRoute(
              path: 'family/:id',
              builder: (BuildContext context, GoRouterState state) {
                return FamilyScreen(
                  family: Families.family(state.params['id']!),
                  asc: state.queryParams['sort'] == 'asc',
                );
              }),
        ],
      ),
    ],
  );
}

/// The home screen that shows a list of families.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({required this.families, Key? key}) : super(key: key);

  /// The list of families.
  final List<Family> families;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(App.title),
      ),
      body: ListView(
        children: <Widget>[
          for (final Family f in families)
            ListTile(
              title: Text(f.name),
              onTap: () => context.go('/family/${f.id}'),
            )
        ],
      ),
    );
  }
}

/// The screen that shows a list of persons in a family.
class FamilyScreen extends StatelessWidget {
  /// Creates a [FamilyScreen].
  const FamilyScreen({required this.family, required this.asc, Key? key})
      : super(key: key);

  /// The family to display.
  final Family family;

  /// Whether to sort the name in ascending order.
  final bool asc;

  @override
  Widget build(BuildContext context) {
    final String curentPath = Uri.parse(GoRouter.of(context).location).path;
    final Map<String, String> newQueries;
    final List<String> names =
        family.people.map<String>((Person p) => p.name).toList();
    names.sort();
    if (asc) {
      newQueries = const <String, String>{'sort': 'desc'};
    } else {
      newQueries = const <String, String>{'sort': 'asc'};
    }
    final Uri iconLink = Uri(path: curentPath, queryParameters: newQueries);
    return Scaffold(
      appBar: AppBar(
        title: Text(family.name),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.go(iconLink.toString()),
            tooltip: 'sort ascending or descending',
            icon: const Icon(Icons.sort),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          for (final String name in asc ? names : names.reversed)
            ListTile(
              title: Text(name),
            ),
        ],
      ),
    );
  }
}

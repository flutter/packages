// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// This scenario demonstrates how to use path parameters and query parameters.
//
// The route segments that start with ':' are treated as path parameters when
// defining GoRoute[s]. The parameter values can be accessed through
// GoRouterState.pathParameters.
//
// The query parameters are automatically stored in GoRouterState.queryParameters.

/// Family data class.
class Family {
  /// Create a family.
  const Family({required this.name, required this.people});

  /// The last name of the family.
  final String name;

  /// The people in the family.
  final Map<String, Person> people;
}

/// Person data class.
class Person {
  /// Creates a person.
  const Person({required this.name, required this.age});

  /// The first name of the person.
  final String name;

  /// The age of the person.
  final int age;
}

const Map<String, Family> _families = <String, Family>{
  'f1': Family(
    name: 'Doe',
    people: <String, Person>{
      'p1': Person(name: 'Jane', age: 23),
      'p2': Person(name: 'John', age: 6),
    },
  ),
  'f2': Family(
    name: 'Wong',
    people: <String, Person>{
      'p1': Person(name: 'June', age: 51),
      'p2': Person(name: 'Xin', age: 44),
    },
  ),
};

void main() => runApp(App());

/// The main app.
class App extends StatelessWidget {
  /// Creates an [App].
  App({super.key});

  /// The title of the app.
  static const String title = 'GoRouter Example: Query Parameters';

  // add the login info into the tree as app state that can change over time
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: _router,
        title: title,
        debugShowCheckedModeBanner: false,
      );

  late final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
        routes: <GoRoute>[
          GoRoute(
              name: 'family',
              path: 'family/:fid',
              builder: (BuildContext context, GoRouterState state) {
                return FamilyScreen(
                  fid: state.pathParameters['fid']!,
                  asc: state.queryParameters['sort'] == 'asc',
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
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(App.title),
      ),
      body: ListView(
        children: <Widget>[
          for (final MapEntry<String, Family> entry in _families.entries)
            ListTile(
              title: Text(entry.value.name),
              onTap: () => context.go('/family/${entry.key}'),
            )
        ],
      ),
    );
  }
}

/// The screen that shows a list of persons in a family.
class FamilyScreen extends StatelessWidget {
  /// Creates a [FamilyScreen].
  const FamilyScreen({required this.fid, required this.asc, super.key});

  /// The family to display.
  final String fid;

  /// Whether to sort the name in ascending order.
  final bool asc;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> newQueries;
    final List<String> names = _families[fid]!
        .people
        .values
        .map<String>((Person p) => p.name)
        .toList();
    names.sort();
    if (asc) {
      newQueries = const <String, String>{'sort': 'desc'};
    } else {
      newQueries = const <String, String>{'sort': 'asc'};
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_families[fid]!.name),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.goNamed('family',
                pathParameters: <String, String>{'fid': fid},
                queryParameters: newQueries),
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

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(goderbauer): Refactor the examples to remove this ignore, https://github.com/flutter/flutter/issues/110210
// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// This scenario demonstrates how to use path parameters and query parameters.
//
// The route segments that start with ':' are treated as path parameters when
// defining GoRoute[s]. The parameter values can be accessed through
// GoRouterState.params.
//
// The query parameters are automatically stored in GoRouterState.queryParams.

final Map<String, dynamic> _families = const JsonDecoder().convert('''
{
  "f1": {
    "name": "Doe",
    "people": {
      "p1": {
        "name": "Jane",
        "age": 23
      },
      "p2": {
        "name": "John",
        "age": 6
      }
    }
  },
  "f2": {
    "name": "Wong",
    "people": {
      "p1": {
        "name": "June",
        "age": 51
      },
      "p2": {
        "name": "Xin",
        "age": 44
      }
    }
  }
}
''');

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
                  fid: state.params['fid']!,
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
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(App.title),
      ),
      body: ListView(
        children: <Widget>[
          for (final String fid in _families.keys)
            ListTile(
              title: Text(_families[fid]['name']),
              onTap: () => context.go('/family/$fid'),
            )
        ],
      ),
    );
  }
}

/// The screen that shows a list of persons in a family.
class FamilyScreen extends StatelessWidget {
  /// Creates a [FamilyScreen].
  const FamilyScreen({required this.fid, required this.asc, Key? key})
      : super(key: key);

  /// The family to display.
  final String fid;

  /// Whether to sort the name in ascending order.
  final bool asc;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> newQueries;
    final List<String> names = _families[fid]['people']
        .values
        .map<String>((dynamic p) => p['name'] as String)
        .toList();
    names.sort();
    if (asc) {
      newQueries = const <String, String>{'sort': 'desc'};
    } else {
      newQueries = const <String, String>{'sort': 'asc'};
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_families[fid]['name']),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.goNamed('family',
                params: <String, String>{'fid': fid}, queryParams: newQueries),
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

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(goderbauer): Refactor the examples to remove this ignore, https://github.com/flutter/flutter/issues/110210
// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// This scenario demonstrates how to navigate using named locations instead of
// URLs.
//
// Instead of hardcoding the URI locations , you can also use the named
// locations. To use this API, give a unique name to each GoRoute. The name can
// then be used in context.namedLocation to be translate back to the actual URL
// location.

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
  static const String title = 'GoRouter Example: Named Routes';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: _router,
        title: title,
        debugShowCheckedModeBanner: false,
      );

  late final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    routes: <GoRoute>[
      GoRoute(
        name: 'home',
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
        routes: <GoRoute>[
          GoRoute(
            name: 'family',
            path: 'family/:fid',
            builder: (BuildContext context, GoRouterState state) =>
                FamilyScreen(fid: state.params['fid']!),
            routes: <GoRoute>[
              GoRoute(
                name: 'person',
                path: 'person/:pid',
                builder: (BuildContext context, GoRouterState state) {
                  return PersonScreen(
                      fid: state.params['fid']!, pid: state.params['pid']!);
                },
              ),
            ],
          ),
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
              onTap: () => context.go(context.namedLocation('family',
                  params: <String, String>{'fid': fid})),
            )
        ],
      ),
    );
  }
}

/// The screen that shows a list of persons in a family.
class FamilyScreen extends StatelessWidget {
  /// Creates a [FamilyScreen].
  const FamilyScreen({required this.fid, Key? key}) : super(key: key);

  /// The id family to display.
  final String fid;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> people =
        _families[fid]['people'] as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: Text(_families[fid]['name'])),
      body: ListView(
        children: <Widget>[
          for (final String pid in people.keys)
            ListTile(
              title: Text(people[pid]['name']),
              onTap: () => context.go(context.namedLocation(
                'person',
                params: <String, String>{'fid': fid, 'pid': pid},
                queryParams: <String, String>{'qid': 'quid'},
              )),
            ),
        ],
      ),
    );
  }
}

/// The person screen.
class PersonScreen extends StatelessWidget {
  /// Creates a [PersonScreen].
  const PersonScreen({required this.fid, required this.pid, Key? key})
      : super(key: key);

  /// The id of family this person belong to.
  final String fid;

  /// The id of the person to be displayed.
  final String pid;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> family = _families[fid];
    final Map<String, dynamic> person = family['people'][pid];
    return Scaffold(
      appBar: AppBar(title: Text(person['name'])),
      body: Text(
          '${person['name']} ${family['name']} is ${person['age']} years old'),
    );
  }
}

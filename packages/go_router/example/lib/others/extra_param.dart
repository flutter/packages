// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(goderbauer): Refactor the examples to remove this ignore, https://github.com/flutter/flutter/issues/110210
// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  static const String title = 'GoRouter Example: Extra Parameter';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: _router,
        title: title,
      );

  late final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        name: 'home',
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
        routes: <GoRoute>[
          GoRoute(
            name: 'family',
            path: 'family',
            builder: (BuildContext context, GoRouterState state) {
              final Map<String, Object> params =
                  state.extra! as Map<String, String>;
              final String fid = params['fid']! as String;
              return FamilyScreen(fid: fid);
            },
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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: ListView(
          children: <Widget>[
            for (final String fid in _families.keys)
              ListTile(
                title: Text(_families[fid]['name']),
                onTap: () => context
                    .goNamed('family', extra: <String, String>{'fid': fid}),
              )
          ],
        ),
      );
}

/// The screen that shows a list of persons in a family.
class FamilyScreen extends StatelessWidget {
  /// Creates a [FamilyScreen].
  const FamilyScreen({required this.fid, Key? key}) : super(key: key);

  /// The family to display.
  final String fid;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> people =
        _families[fid]['people'] as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: Text(_families[fid]['name'])),
      body: ListView(
        children: <Widget>[
          for (final dynamic p in people.values)
            ListTile(
              title: Text(p['name']),
            ),
        ],
      ),
    );
  }
}

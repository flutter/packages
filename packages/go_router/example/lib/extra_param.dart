// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// This scenario demonstrates how to use the extra parameter.
//
// The example uses the extra parameter to send addition `fid` along with the
// URL. The BrowserState is used for supporting web platform.

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
        routeInformationProvider: _router.routeInformationProvider,
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
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
              final dynamic params = const JsonDecoder()
                  .convert((state.extra! as BrowserState).jsonString);
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
                onTap: () {
                  final BrowserState state = BrowserState(
                      jsonString: const JsonEncoder()
                          .convert(<String, String>{'fid': fid}));
                  context.goNamed('family', extra: state);
                },
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

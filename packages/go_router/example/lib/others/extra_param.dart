// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: ListView(
          children: <Widget>[
            for (final MapEntry<String, Family> entry in _families.entries)
              ListTile(
                title: Text(entry.value.name),
                onTap: () => context.goNamed('family',
                    extra: <String, String>{'fid': entry.key}),
              )
          ],
        ),
      );
}

/// The screen that shows a list of persons in a family.
class FamilyScreen extends StatelessWidget {
  /// Creates a [FamilyScreen].
  const FamilyScreen({required this.fid, super.key});

  /// The family to display.
  final String fid;

  @override
  Widget build(BuildContext context) {
    final Map<String, Person> people = _families[fid]!.people;
    return Scaffold(
      appBar: AppBar(title: Text(_families[fid]!.name)),
      body: ListView(
        children: <Widget>[
          for (final Person p in people.values)
            ListTile(
              title: Text(p.name),
            ),
        ],
      ),
    );
  }
}

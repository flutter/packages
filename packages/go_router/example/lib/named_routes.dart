// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// This scenario demonstrates how to navigate using named locations instead of
// URLs.
//
// Instead of hardcoding the URI locations , you can also use the named
// locations. To use this API, give a unique name to each GoRoute. The name can
// then be used in context.namedLocation to be translate back to the actual URL
// location.

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
                FamilyScreen(fid: state.pathParameters['fid']!),
            routes: <GoRoute>[
              GoRoute(
                name: 'person',
                path: 'person/:pid',
                builder: (BuildContext context, GoRouterState state) {
                  return PersonScreen(
                      fid: state.pathParameters['fid']!,
                      pid: state.pathParameters['pid']!);
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
              onTap: () => context.go(context.namedLocation('family',
                  pathParameters: <String, String>{'fid': entry.key})),
            )
        ],
      ),
    );
  }
}

/// The screen that shows a list of persons in a family.
class FamilyScreen extends StatelessWidget {
  /// Creates a [FamilyScreen].
  const FamilyScreen({required this.fid, super.key});

  /// The id family to display.
  final String fid;

  @override
  Widget build(BuildContext context) {
    final Map<String, Person> people = _families[fid]!.people;
    return Scaffold(
      appBar: AppBar(title: Text(_families[fid]!.name)),
      body: ListView(
        children: <Widget>[
          for (final MapEntry<String, Person> entry in people.entries)
            ListTile(
              title: Text(entry.value.name),
              onTap: () => context.go(context.namedLocation(
                'person',
                pathParameters: <String, String>{'fid': fid, 'pid': entry.key},
                queryParameters: <String, String>{'qid': 'quid'},
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
  const PersonScreen({required this.fid, required this.pid, super.key});

  /// The id of family this person belong to.
  final String fid;

  /// The id of the person to be displayed.
  final String pid;

  @override
  Widget build(BuildContext context) {
    final Family family = _families[fid]!;
    final Person person = family.people[pid]!;
    return Scaffold(
      appBar: AppBar(title: Text(person.name)),
      body: Text('${person.name} ${family.name} is ${person.age} years old'),
    );
  }
}

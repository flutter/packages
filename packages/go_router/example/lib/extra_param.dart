// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/data.dart';

void main() => runApp(App());

/// The main app.
class App extends StatelessWidget {
  /// Creates an [App].
  App({Key? key}) : super(key: key);

  /// The title of the app.
  static const String title = 'GoRouter Example: Extra Parameter';

  static const bool _alertOnWeb = true;

  @override
  Widget build(BuildContext context) => _alertOnWeb && kIsWeb
      ? const MaterialApp(
          title: title,
          home: NoExtraParamOnWebScreen(),
        )
      : MaterialApp.router(
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
            HomeScreen(families: Families.data),
        routes: <GoRoute>[
          GoRoute(
            name: 'family',
            path: 'family',
            builder: (BuildContext context, GoRouterState state) {
              final Map<String, Object> params =
                  state.extra! as Map<String, Object>;
              final Family family = params['family']! as Family;
              return FamilyScreen(family: family);
            },
            routes: <GoRoute>[
              GoRoute(
                name: 'person',
                path: 'person',
                builder: (BuildContext context, GoRouterState state) {
                  final Map<String, Object> params =
                      state.extra! as Map<String, Object>;
                  final Family family = params['family']! as Family;
                  final Person person = params['person']! as Person;
                  return PersonScreen(family: family, person: person);
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
  const HomeScreen({required this.families, Key? key}) : super(key: key);

  /// The list of families.
  final List<Family> families;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: ListView(
          children: <Widget>[
            for (final Family f in families)
              ListTile(
                title: Text(f.name),
                onTap: () => context
                    .goNamed('family', extra: <String, Object?>{'family': f}),
              )
          ],
        ),
      );
}

/// The screen that shows a list of persons in a family.
class FamilyScreen extends StatelessWidget {
  /// Creates a [FamilyScreen].
  const FamilyScreen({required this.family, Key? key}) : super(key: key);

  /// The family to display.
  final Family family;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(family.name)),
        body: ListView(
          children: <Widget>[
            for (final Person p in family.people)
              ListTile(
                title: Text(p.name),
                onTap: () => context.go(
                  context.namedLocation('person'),
                  extra: <String, Object>{'family': family, 'person': p},
                ),
              ),
          ],
        ),
      );
}

/// The person screen.
class PersonScreen extends StatelessWidget {
  /// Creates a [PersonScreen].
  const PersonScreen({required this.family, required this.person, Key? key})
      : super(key: key);

  /// The family this person belong to.
  final Family family;

  /// The person to be displayed.
  final Person person;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(person.name)),
        body: Text('${person.name} ${family.name} is ${person.age} years old'),
      );
}

/// A screen that explains this example does not work on web platform.
class NoExtraParamOnWebScreen extends StatelessWidget {
  /// Creates a [NoExtraParamOnWebScreen].
  const NoExtraParamOnWebScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text("The `extra` param doesn't mix with the web:"),
              Text("There's no support for the brower's Back button or"
                  ' deep linking'),
            ],
          ),
        ),
      );
}

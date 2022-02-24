// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/data.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  static const title = 'GoRouter Example: Extra Parameter';
  static const alertOnWeb = true;

  @override
  Widget build(BuildContext context) => alertOnWeb && kIsWeb
      ? const MaterialApp(
          title: title,
          home: NoExtraParamOnWebScreen(),
        )
      : MaterialApp.router(
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
          title: title,
        );

  late final _router = GoRouter(
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => HomeScreen(families: Families.data),
        routes: [
          GoRoute(
            name: 'family',
            path: 'family',
            builder: (context, state) {
              final params = state.extra! as Map<String, Object>;
              final family = params['family']! as Family;
              return FamilyScreen(family: family);
            },
            routes: [
              GoRoute(
                name: 'person',
                path: 'person',
                builder: (context, state) {
                  final params = state.extra! as Map<String, Object>;
                  final family = params['family']! as Family;
                  final person = params['person']! as Person;
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.families, Key? key}) : super(key: key);
  final List<Family> families;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: ListView(
          children: [
            for (final f in families)
              ListTile(
                title: Text(f.name),
                onTap: () => context.goNamed('family', extra: {'family': f}),
              )
          ],
        ),
      );
}

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({required this.family, Key? key}) : super(key: key);
  final Family family;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(family.name)),
        body: ListView(
          children: [
            for (final p in family.people)
              ListTile(
                title: Text(p.name),
                onTap: () => context.go(
                  context.namedLocation('person'),
                  extra: {'family': family, 'person': p},
                ),
              ),
          ],
        ),
      );
}

class PersonScreen extends StatelessWidget {
  const PersonScreen({required this.family, required this.person, Key? key})
      : super(key: key);

  final Family family;
  final Person person;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(person.name)),
        body: Text('${person.name} ${family.name} is ${person.age} years old'),
      );
}

class NoExtraParamOnWebScreen extends StatelessWidget {
  const NoExtraParamOnWebScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("The `extra` param doesn't mix with the web:"),
              Text("There's no support for the brower's Back button or"
                  ' deep linking'),
            ],
          ),
        ),
      );
}

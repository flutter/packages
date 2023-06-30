// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/data.dart';

part 'simple_example.g.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: _appTitle,
      );

  final GoRouter _router = GoRouter(routes: $appRoutes);
}

@TypedGoRoute<HomeRoute>(
  path: '/',
  name: 'Home',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<FamilyRoute>(path: 'family/:familyId')
  ],
)
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class FamilyRoute extends GoRouteData {
  const FamilyRoute(this.familyId);

  final String familyId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      FamilyScreen(family: familyById(familyId));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(_appTitle)),
        body: ListView(
          children: <Widget>[
            for (final Family family in familyData)
              ListTile(
                title: Text(family.name),
                onTap: () => FamilyRoute(family.id).go(context),
              )
          ],
        ),
      );
}

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({required this.family, super.key});
  final Family family;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(family.name)),
        body: ListView(
          children: <Widget>[
            for (final Person p in family.people)
              ListTile(
                title: Text(p.name),
              ),
          ],
        ),
      );
}

const String _appTitle = 'GoRouter Example: builder';

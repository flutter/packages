// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: use_late_for_private_fields_and_variables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/data.dart';

void main() => runApp(App());

/// The main app.
class App extends StatelessWidget {
  /// Creates a [App].
  App({Key? key}) : super(key: key);

  /// The title of the app.
  static const String title = 'GoRouter Example: Async Data';

  /// Repository to query data from.
  static final Repository repo = Repository();

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: title,
      );

  late final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
        routes: <GoRoute>[
          GoRoute(
            path: 'family/:fid',
            builder: (BuildContext context, GoRouterState state) =>
                FamilyScreen(
              fid: state.params['fid']!,
            ),
            routes: <GoRoute>[
              GoRoute(
                path: 'person/:pid',
                builder: (BuildContext context, GoRouterState state) =>
                    PersonScreen(
                  fid: state.params['fid']!,
                  pid: state.params['pid']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// The home screen.
class HomeScreen extends StatefulWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Family>>? _future;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // refresh cached data
    _fetch();
  }

  void _fetch() => _future = App.repo.getFamilies();

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Family>>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<List<Family>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: const Text('${App.title}: Loading...')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('${App.title}: Error')),
              body: SnapshotError(snapshot.error!),
            );
          }

          assert(snapshot.hasData);
          final List<Family> families = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('${App.title}: ${families.length} families'),
            ),
            body: ListView(
              children: <Widget>[
                for (final Family f in families)
                  ListTile(
                    title: Text(f.name),
                    onTap: () => context.go('/family/${f.id}'),
                  )
              ],
            ),
          );
        },
      );
}

/// The family screen.
class FamilyScreen extends StatefulWidget {
  /// Creates a [FamilyScreen].
  const FamilyScreen({required this.fid, Key? key}) : super(key: key);

  /// The id of the family.
  final String fid;

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  Future<Family>? _future;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant FamilyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // refresh cached data
    if (oldWidget.fid != widget.fid) {
      _fetch();
    }
  }

  void _fetch() => _future = App.repo.getFamily(widget.fid);

  @override
  Widget build(BuildContext context) => FutureBuilder<Family>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<Family> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: const Text('Loading...')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: SnapshotError(snapshot.error!),
            );
          }

          assert(snapshot.hasData);
          final Family family = snapshot.data!;
          return Scaffold(
            appBar: AppBar(title: Text(family.name)),
            body: ListView(
              children: <Widget>[
                for (final Person p in family.people)
                  ListTile(
                    title: Text(p.name),
                    onTap: () => context.go(
                      '/family/${family.id}/person/${p.id}',
                    ),
                  ),
              ],
            ),
          );
        },
      );
}

/// The person screen.
class PersonScreen extends StatefulWidget {
  /// Creates a [PersonScreen].
  const PersonScreen({required this.fid, required this.pid, Key? key})
      : super(key: key);

  /// The id of family the person is in.
  final String fid;

  /// The id of the person.
  final String pid;

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  Future<FamilyPerson>? _future;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant PersonScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // refresh cached data
    if (oldWidget.fid != widget.fid || oldWidget.pid != widget.pid) {
      _fetch();
    }
  }

  void _fetch() => _future = App.repo.getPerson(widget.fid, widget.pid);

  @override
  Widget build(BuildContext context) => FutureBuilder<FamilyPerson>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<FamilyPerson> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: const Text('Loading...')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: SnapshotError(snapshot.error!),
            );
          }

          assert(snapshot.hasData);
          final FamilyPerson famper = snapshot.data!;
          return Scaffold(
            appBar: AppBar(title: Text(famper.person.name)),
            body: Text(
              '${famper.person.name} ${famper.family.name} is '
              '${famper.person.age} years old',
            ),
          );
        },
      );
}

/// The Error page.
class SnapshotError extends StatelessWidget {
  /// Creates an error page.
  SnapshotError(Object error, {Key? key})
      : error = error is Exception ? error : Exception(error),
        super(key: key);

  /// The error.
  final Exception error;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SelectableText(error.toString()),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Home'),
            ),
          ],
        ),
      );
}

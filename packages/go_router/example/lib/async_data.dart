// ignore_for_file: use_late_for_private_fields_and_variables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/data.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  static const title = 'GoRouter Example: Async Data';
  static final repo = Repository();

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: title,
      );

  late final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'family/:fid',
            builder: (context, state) => FamilyScreen(
              fid: state.params['fid']!,
            ),
            routes: [
              GoRoute(
                path: 'person/:pid',
                builder: (context, state) => PersonScreen(
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

class HomeScreen extends StatefulWidget {
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
        builder: (context, snapshot) {
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
          final families = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('${App.title}: ${families.length} families'),
            ),
            body: ListView(
              children: [
                for (final f in families)
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

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({required this.fid, Key? key}) : super(key: key);
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
    if (oldWidget.fid != widget.fid) _fetch();
  }

  void _fetch() => _future = App.repo.getFamily(widget.fid);

  @override
  Widget build(BuildContext context) => FutureBuilder<Family>(
        future: _future,
        builder: (context, snapshot) {
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
          final family = snapshot.data!;
          return Scaffold(
            appBar: AppBar(title: Text(family.name)),
            body: ListView(
              children: [
                for (final p in family.people)
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

class PersonScreen extends StatefulWidget {
  const PersonScreen({required this.fid, required this.pid, Key? key})
      : super(key: key);

  final String fid;
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
    if (oldWidget.fid != widget.fid || oldWidget.pid != widget.pid) _fetch();
  }

  void _fetch() => _future = App.repo.getPerson(widget.fid, widget.pid);

  @override
  Widget build(BuildContext context) => FutureBuilder<FamilyPerson>(
        future: _future,
        builder: (context, snapshot) {
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
          final famper = snapshot.data!;
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

class SnapshotError extends StatelessWidget {
  SnapshotError(Object error, {Key? key})
      : error = error is Exception ? error : Exception(error),
        super(key: key);
  final Exception error;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectableText(error.toString()),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Home'),
            ),
          ],
        ),
      );
}

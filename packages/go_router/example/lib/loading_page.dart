// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'shared/data.dart';

void main() => runApp(App());

class AppState extends ChangeNotifier {
  AppState() {
    loginInfo.addListener(loginChange);
    repo.addListener(notifyListeners);
  }

  final loginInfo = LoginInfo2();
  final repo = ValueNotifier<Repository2?>(null);

  Future<void> loginChange() async {
    notifyListeners();

    // this will call notifyListeners(), too
    repo.value =
        loginInfo.loggedIn ? await Repository2.get(loginInfo.userName) : null;
  }

  @override
  void dispose() {
    loginInfo.removeListener(loginChange);
    repo.removeListener(notifyListeners);
    super.dispose();
  }
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  static const title = 'GoRouter Example: Loading Page';
  final appState = AppState();

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: MaterialApp.router(
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
          title: title,
          debugShowCheckedModeBanner: false,
        ),
      );

  late final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
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
    redirect: (state) {
      // if the user is not logged in, they need to login
      final loggedIn = appState.loginInfo.loggedIn;
      final loggingIn = state.subloc == '/login';
      final subloc = state.subloc;
      final fromp1 = subloc == '/' ? '' : '?from=$subloc';
      if (!loggedIn) return loggingIn ? null : '/login$fromp1';

      // if the user is logged in but the repository is not loaded, they need to
      // wait while it's loaded
      final loaded = appState.repo.value != null;
      final loading = state.subloc == '/loading';
      final from = state.queryParams['from'];
      final fromp2 = from == null ? '' : '?from=$from';
      if (!loaded) return loading ? null : '/loading$fromp2';

      // if the user is logged in and the repository is loaded, send them where
      // they were going before (or home if they weren't going anywhere)
      if (loggingIn || loading) return from ?? '/';

      // no need to redirect at all
      return null;
    },
    refreshListenable: appState,
    navigatorBuilder: (context, state, child) =>
        appState.loginInfo.loggedIn ? AuthOverlay(child: child) : child,
  );
}

class AuthOverlay extends StatelessWidget {
  const AuthOverlay({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          child,
          Positioned(
            top: 90,
            right: 4,
            child: ElevatedButton(
              onPressed: () async {
                // ignore: unawaited_futures
                context.read<AppState>().loginInfo.logout();
                // ignore: use_build_context_synchronously
                context.go('/'); // clear query parameters
              },
              child: const Icon(Icons.logout),
            ),
          ),
        ],
      );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // ignore: unawaited_futures
                  context.read<AppState>().loginInfo.login('test-user');
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({this.from, Key? key}) : super(key: key);
  final String? from;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              Text('loading repository...'),
            ],
          ),
        ),
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

  void _fetch() => _future = _repo.getFamilies();
  Repository2 get _repo => context.read<AppState>().repo.value!;

  @override
  Widget build(BuildContext context) => MyFutureBuilder<List<Family>>(
        future: _future,
        builder: (context, families) => Scaffold(
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
        ),
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

  void _fetch() => _future = _repo.getFamily(widget.fid);
  Repository2 get _repo => context.read<AppState>().repo.value!;

  @override
  Widget build(BuildContext context) => MyFutureBuilder<Family>(
        future: _future,
        builder: (context, family) => Scaffold(
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
        ),
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

  void _fetch() => _future = _repo.getPerson(widget.fid, widget.pid);
  Repository2 get _repo => context.read<AppState>().repo.value!;

  @override
  Widget build(BuildContext context) => MyFutureBuilder<FamilyPerson>(
        future: _future,
        builder: (context, famper) => Scaffold(
          appBar: AppBar(title: Text(famper.person.name)),
          body: Text(
            '${famper.person.name} ${famper.family.name} is '
            '${famper.person.age} years old',
          ),
        ),
      );
}

class MyFutureBuilder<T extends Object> extends StatelessWidget {
  const MyFutureBuilder({required this.future, required this.builder, Key? key})
      : super(key: key);

  final Future<T>? future;
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
        future: future,
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
          return builder(context, snapshot.data!);
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

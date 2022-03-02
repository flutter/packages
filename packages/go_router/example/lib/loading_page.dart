// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'shared/data.dart';

void main() => runApp(App());

/// The app state data class.
class AppState extends ChangeNotifier {
  /// Creates an [AppState].
  AppState() {
    loginInfo.addListener(loginChange);
    repo.addListener(notifyListeners);
  }

  /// The login status.
  final LoginInfo2 loginInfo = LoginInfo2();

  /// The repository to query data from.
  final ValueNotifier<Repository2?> repo = ValueNotifier<Repository2?>(null);

  /// Called when login status changed.
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

/// The main app.
class App extends StatelessWidget {
  /// Creates an [App].
  App({Key? key}) : super(key: key);

  /// The title of the app.
  static const String title = 'GoRouter Example: Loading Page';

  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<AppState>.value(
        value: _appState,
        child: MaterialApp.router(
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
          title: title,
          debugShowCheckedModeBanner: false,
        ),
      );

  late final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: '/loading',
        builder: (BuildContext context, GoRouterState state) =>
            const LoadingScreen(),
      ),
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
    redirect: (GoRouterState state) {
      // if the user is not logged in, they need to login
      final bool loggedIn = _appState.loginInfo.loggedIn;
      final bool loggingIn = state.subloc == '/login';
      final String subloc = state.subloc;
      final String fromp1 = subloc == '/' ? '' : '?from=$subloc';
      if (!loggedIn) {
        return loggingIn ? null : '/login$fromp1';
      }

      // if the user is logged in but the repository is not loaded, they need to
      // wait while it's loaded
      final bool loaded = _appState.repo.value != null;
      final bool loading = state.subloc == '/loading';
      final String? from = state.queryParams['from'];
      final String fromp2 = from == null ? '' : '?from=$from';
      if (!loaded) {
        return loading ? null : '/loading$fromp2';
      }

      // if the user is logged in and the repository is loaded, send them where
      // they were going before (or home if they weren't going anywhere)
      if (loggingIn || loading) {
        return from ?? '/';
      }

      // no need to redirect at all
      return null;
    },
    refreshListenable: _appState,
    navigatorBuilder:
        (BuildContext context, GoRouterState state, Widget child) =>
            _appState.loginInfo.loggedIn ? AuthOverlay(child: child) : child,
  );
}

/// A simple class for placing an exit button on top of all screens.
class AuthOverlay extends StatelessWidget {
  /// Creates an [AuthOverlay].
  const AuthOverlay({
    required this.child,
    Key? key,
  }) : super(key: key);

  /// The child subtree.
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
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

/// The login screen.
class LoginScreen extends StatefulWidget {
  /// Creates a [LoginScreen].
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
            children: <Widget>[
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

/// The loading screen.
class LoadingScreen extends StatelessWidget {
  /// Creates a [LoadingScreen].
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              CircularProgressIndicator(),
              Text('loading repository...'),
            ],
          ),
        ),
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

  void _fetch() => _future = _repo.getFamilies();
  Repository2 get _repo => context.read<AppState>().repo.value!;

  @override
  Widget build(BuildContext context) => MyFutureBuilder<List<Family>>(
        future: _future,
        builder: (BuildContext context, List<Family> families) => Scaffold(
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
        ),
      );
}

/// The family screen.
class FamilyScreen extends StatefulWidget {
  /// Creates a [FamilyScreen].
  const FamilyScreen({required this.fid, Key? key}) : super(key: key);

  /// The family id.
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

  void _fetch() => _future = _repo.getFamily(widget.fid);
  Repository2 get _repo => context.read<AppState>().repo.value!;

  @override
  Widget build(BuildContext context) => MyFutureBuilder<Family>(
        future: _future,
        builder: (BuildContext context, Family family) => Scaffold(
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
        ),
      );
}

/// The person screen.
class PersonScreen extends StatefulWidget {
  /// Creates a [PersonScreen].
  const PersonScreen({required this.fid, required this.pid, Key? key})
      : super(key: key);

  /// The id of family the person belongs to.
  final String fid;

  /// The person id.
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

  void _fetch() => _future = _repo.getPerson(widget.fid, widget.pid);
  Repository2 get _repo => context.read<AppState>().repo.value!;

  @override
  Widget build(BuildContext context) => MyFutureBuilder<FamilyPerson>(
        future: _future,
        builder: (BuildContext context, FamilyPerson famper) => Scaffold(
          appBar: AppBar(title: Text(famper.person.name)),
          body: Text(
            '${famper.person.name} ${famper.family.name} is '
            '${famper.person.age} years old',
          ),
        ),
      );
}

/// A custom [Future] builder.
class MyFutureBuilder<T extends Object> extends StatelessWidget {
  /// Creates a [MyFutureBuilder].
  const MyFutureBuilder({required this.future, required this.builder, Key? key})
      : super(key: key);

  /// The [Future] to depend on.
  final Future<T>? future;

  /// The builder that builds the widget subtree.
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
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

/// The error widget.
class SnapshotError extends StatelessWidget {
  /// Creates a [SnapshotError].
  SnapshotError(Object error, {Key? key})
      : error = error is Exception ? error : Exception(error),
        super(key: key);

  /// The error to display.
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

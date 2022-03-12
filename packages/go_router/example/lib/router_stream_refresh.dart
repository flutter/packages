// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'shared/data.dart';

void main() => runApp(const App());

/// The main app.
class App extends StatefulWidget {
  /// Creates an [App].
  const App({Key? key}) : super(key: key);

  /// The title of the app.
  static const String title = 'GoRouter Example: Stream Refresh';

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late LoggedInState loggedInState;
  late GoRouter router;

  @override
  void initState() {
    loggedInState = LoggedInState.seeded(false);
    router = GoRouter(
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              HomeScreen(families: Families.data),
          routes: <GoRoute>[
            GoRoute(
              path: 'family/:fid',
              builder: (BuildContext context, GoRouterState state) =>
                  FamilyScreen(
                family: Families.family(state.params['fid']!),
              ),
              routes: <GoRoute>[
                GoRoute(
                  path: 'person/:pid',
                  builder: (BuildContext context, GoRouterState state) {
                    final Family family = Families.family(state.params['fid']!);
                    final Person person = family.person(state.params['pid']!);
                    return PersonScreen(family: family, person: person);
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) =>
              const LoginScreen(),
        ),
      ],

      // redirect to the login page if the user is not logged in
      redirect: (GoRouterState state) {
        // if the user is not logged in, they need to login
        final bool loggedIn = loggedInState.state;
        final bool loggingIn = state.subloc == '/login';

        // bundle the location the user is coming from into a query parameter
        final String fromp = state.subloc == '/' ? '' : '?from=${state.subloc}';
        if (!loggedIn) {
          return loggingIn ? null : '/login$fromp';
        }

        // if the user is logged in, send them where they were going before (or
        // home if they weren't going anywhere)
        if (loggingIn) {
          return state.queryParams['from'] ?? '/';
        }

        // no need to redirect at all
        return null;
      },
      // changes on the listenable will cause the router to refresh it's route
      refreshListenable: GoRouterRefreshStream(loggedInState.stream),
    );
    super.initState();
  }

  // add the login info into the tree as app state that can change over time
  @override
  Widget build(BuildContext context) => Provider<LoggedInState>.value(
        value: loggedInState,
        child: MaterialApp.router(
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          title: App.title,
          debugShowCheckedModeBanner: false,
        ),
      );

  @override
  void dispose() {
    loggedInState.dispose();
    super.dispose();
  }
}

/// The home screen that shows a list of families.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({
    required this.families,
    Key? key,
  }) : super(key: key);

  /// The list of families.
  final List<Family> families;

  @override
  Widget build(BuildContext context) {
    final LoggedInState info = context.read<LoggedInState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(App.title),
        actions: <Widget>[
          IconButton(
            onPressed: () => info.emit(false),
            icon: const Icon(Icons.logout),
          )
        ],
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
  }
}

/// The screen that shows a list of persons in a family.
class FamilyScreen extends StatelessWidget {
  /// Creates a [FamilyScreen].
  const FamilyScreen({
    required this.family,
    Key? key,
  }) : super(key: key);

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
                onTap: () => context.go('/family/${family.id}/person/${p.id}'),
              ),
          ],
        ),
      );
}

/// The person screen.
class PersonScreen extends StatelessWidget {
  /// Creates a [PersonScreen].
  const PersonScreen({
    required this.family,
    required this.person,
    Key? key,
  }) : super(key: key);

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

/// The login screen.
class LoginScreen extends StatelessWidget {
  /// Creates a [LoginScreen].
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // log a user in, letting all the listeners know
                  context.read<LoggedInState>().emit(true);
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
}

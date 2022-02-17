import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'shared/data.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  final loginInfo = LoginInfo();
  static const title = 'GoRouter Example: Navigator Builder';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: title,
      );

  late final _router = GoRouter(
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) =>
            HomeScreenNoLogout(families: Families.data),
        routes: [
          GoRoute(
            name: 'family',
            path: 'family/:fid',
            builder: (context, state) {
              final family = Families.family(state.params['fid']!);
              return FamilyScreen(family: family);
            },
            routes: [
              GoRoute(
                name: 'person',
                path: 'person/:pid',
                builder: (context, state) {
                  final family = Families.family(state.params['fid']!);
                  final person = family.person(state.params['pid']!);
                  return PersonScreen(family: family, person: person);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],

    // redirect to the login page if the user is not logged in
    redirect: (state) {
      // if the user is not logged in, they need to login
      final loggedIn = loginInfo.loggedIn;
      final loginloc = state.namedLocation('login');
      final loggingIn = state.subloc == loginloc;

      // bundle the location the user is coming from into a query parameter
      final homeloc = state.namedLocation('home');
      final fromloc = state.subloc == homeloc ? '' : state.subloc;
      if (!loggedIn) {
        return loggingIn
            ? null
            : state.namedLocation(
                'login',
                queryParams: {if (fromloc.isNotEmpty) 'from': fromloc},
              );
      }

      // if the user is logged in, send them where they were going before (or
      // home if they weren't going anywhere)
      if (loggingIn) return state.queryParams['from'] ?? homeloc;

      // no need to redirect at all
      return null;
    },

    // changes on the listenable will cause the router to refresh it's route
    refreshListenable: loginInfo,

    // add a wrapper around the navigator to:
    // - put loginInfo into the widget tree, and to
    // - add an overlay to show a logout option
    navigatorBuilder: (context, state, child) =>
        ChangeNotifierProvider<LoginInfo>.value(
      value: loginInfo,
      builder: (context, _) {
        debugPrint('navigatorBuilder: ${state.subloc}');
        return loginInfo.loggedIn ? AuthOverlay(child: child) : child;
      },
    ),
  );
}

// A simple class for placing an exit button on top of all screens
class AuthOverlay extends StatelessWidget {
  const AuthOverlay({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          child,
          Positioned(
            top: 90,
            right: 4,
            child: ElevatedButton(
              onPressed: () {
                context.read<LoginInfo>().logout();
                context.goNamed('home'); // clear out the `from` query param
              },
              child: const Icon(Icons.logout),
            ),
          ),
        ],
      );
}

class HomeScreenNoLogout extends StatelessWidget {
  const HomeScreenNoLogout({required this.families, Key? key})
      : super(key: key);
  final List<Family> families;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: ListView(
          children: [
            for (final f in families)
              ListTile(
                title: Text(f.name),
                onTap: () => context.goNamed('family', params: {'fid': f.id}),
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
                onTap: () => context.go('/family/${family.id}/person/${p.id}'),
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

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // log a user in, letting all the listeners know
                  context.read<LoginInfo>().login('test-user');
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
}

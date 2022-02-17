import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(
      const RootRestorationScope(restorationId: 'root', child: App()),
    );

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  static const title = 'GoRouter Example: State Restoration';

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with RestorationMixin {
  @override
  String get restorationId => 'wrapper';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    // todo: implement restoreState for you app
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: App.title,
        restorationScopeId: 'app',
      );

  final _router = GoRouter(
    routes: [
      // restorationId set for the route automatically
      GoRoute(
        path: '/',
        builder: (context, state) => const Page1Screen(),
      ),

      // restorationId set for the route automatically
      GoRoute(
        path: '/page2',
        builder: (context, state) => const Page2Screen(),
      ),
    ],
    restorationScopeId: 'router',
  );
}

class Page1Screen extends StatelessWidget {
  const Page1Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.go('/page2'),
                child: const Text('Go to page 2'),
              ),
            ],
          ),
        ),
      );
}

class Page2Screen extends StatelessWidget {
  const Page2Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to home page'),
              ),
            ],
          ),
        ),
      );
}

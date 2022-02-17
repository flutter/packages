import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  static const title = 'GoRouter Example: Push';

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
        builder: (context, state) => const Page1ScreenWithPush(),
      ),
      GoRoute(
        path: '/page2',
        builder: (context, state) => Page2ScreenWithPush(
          int.parse(state.queryParams['push-count']!),
        ),
      ),
    ],
  );
}

class Page1ScreenWithPush extends StatelessWidget {
  const Page1ScreenWithPush({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('${App.title}: page 1')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.push('/page2?push-count=1'),
                child: const Text('Push page 2'),
              ),
            ],
          ),
        ),
      );
}

class Page2ScreenWithPush extends StatelessWidget {
  const Page2ScreenWithPush(this.pushCount, {Key? key}) : super(key: key);
  final int pushCount;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('${App.title}: page 2 w/ push count $pushCount'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go to home page'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () => context.push(
                    '/page2?push-count=${pushCount + 1}',
                  ),
                  child: const Text('Push page 2 (again)'),
                ),
              ),
            ],
          ),
        ),
      );
}

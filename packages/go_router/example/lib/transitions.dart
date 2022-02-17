import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  static const title = 'GoRouter Example: Custom Transitions';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: title,
      );

  final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        redirect: (_) => '/none',
      ),
      GoRoute(
        path: '/fade',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ExampleTransitionsScreen(
            kind: 'fade',
            color: Colors.red,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/scale',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ExampleTransitionsScreen(
            kind: 'scale',
            color: Colors.green,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              ScaleTransition(scale: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/slide',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ExampleTransitionsScreen(
            kind: 'slide',
            color: Colors.yellow,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                  position: animation.drive(
                    Tween<Offset>(
                      begin: const Offset(0.25, 0.25),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeIn)),
                  ),
                  child: child),
        ),
      ),
      GoRoute(
        path: '/rotation',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ExampleTransitionsScreen(
            kind: 'rotation',
            color: Colors.purple,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              RotationTransition(turns: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/none',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ExampleTransitionsScreen(
            kind: 'none',
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}

class ExampleTransitionsScreen extends StatelessWidget {
  const ExampleTransitionsScreen({
    required this.color,
    required this.kind,
    Key? key,
  }) : super(key: key);

  static final kinds = ['fade', 'scale', 'slide', 'rotation', 'none'];
  final Color color;
  final String kind;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('${App.title}: $kind')),
        body: Container(
          color: color,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final kind in kinds)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () => context.go('/$kind'),
                      child: Text('$kind transition'),
                    ),
                  )
              ],
            ),
          ),
        ),
      );
}

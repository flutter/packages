import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/go_router_error_page.dart';
import 'package:go_router/src/typedefs.dart';

import '../go_router_test.dart';

GoRouter createGoRouter({
  GoRouterNavigatorBuilder? navigatorBuilder,
}) =>
    GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
        GoRoute(
          path: '/error',
          builder: (_, __) => const GoRouterErrorScreen(null),
        ),
      ],
      navigatorBuilder: navigatorBuilder,
    );

void main() {
  test('pop triggers pop on routerDelegate', () {
    final router = createGoRouter()..push('/error');
    router.routerDelegate.addListener(expectAsync0(() {}));
    router.pop();
  });

  test('refresh triggers refresh on routerDelegate', () {
    final router = createGoRouter();
    router.routerDelegate.addListener(expectAsync0(() {}));
    router.refresh();
  });

  test('didPush notifies listeners', () {
    createGoRouter()
      ..addListener(expectAsync0(() {}))
      ..didPush(
        MaterialPageRoute<void>(builder: (_) => const Text('Current route')),
        MaterialPageRoute<void>(builder: (_) => const Text('Previous route')),
      );
  });

  test('didPop notifies listeners', () {
    createGoRouter()
      ..addListener(expectAsync0(() {}))
      ..didPop(
        MaterialPageRoute<void>(builder: (_) => const Text('Current route')),
        MaterialPageRoute<void>(builder: (_) => const Text('Previous route')),
      );
  });

  test('didRemove notifies listeners', () {
    createGoRouter()
      ..addListener(expectAsync0(() {}))
      ..didRemove(
        MaterialPageRoute<void>(builder: (_) => const Text('Current route')),
        MaterialPageRoute<void>(builder: (_) => const Text('Previous route')),
      );
  });

  test('didReplace notifies listeners', () {
    createGoRouter()
      ..addListener(expectAsync0(() {}))
      ..didReplace(
        newRoute: MaterialPageRoute<void>(
          builder: (_) => const Text('Current route'),
        ),
        oldRoute: MaterialPageRoute<void>(
          builder: (_) => const Text('Previous route'),
        ),
      );
  });

  test('uses navigatorBuilder when provided', () {
    final navigationBuilder = expectAsync3(fakeNavigationBuilder);
    final router = createGoRouter(navigatorBuilder: navigationBuilder);
    final delegate = router.routerDelegate;
    delegate.builderWithNav(
      DummyBuildContext(),
      GoRouterState(delegate, location: '/foo', subloc: '/bar', name: 'baz'),
      const Navigator(),
    );
  });
}

Widget fakeNavigationBuilder(
  BuildContext context,
  GoRouterState state,
  Widget child,
) =>
    child;

class DummyStatefulWidget extends StatefulWidget {
  const DummyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<DummyStatefulWidget> createState() => _DummyStatefulWidgetState();
}

class _DummyStatefulWidgetState extends State<DummyStatefulWidget> {
  @override
  Widget build(BuildContext context) => Container();
}

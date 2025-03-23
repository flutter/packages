import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
    'PopScope onPopInvokedWithResult should be called only once',
    (WidgetTester tester) async {
      int counter = 0;

      final GoRouter goRouter = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
          GoRoute(
            path: '/page-1',
            onExit: (_, __) => true,
            builder: (_, __) => PopScope(
              onPopInvokedWithResult: (bool didPop, __) {
                if (didPop) {
                  counter++;
                  return;
                }
              },
              child: const Text('Page 1'),
            ),
          ),
        ],
      );

      addTearDown(goRouter.dispose);

      await tester.pumpWidget(MaterialApp.router(
        routeInformationProvider: goRouter.routeInformationProvider,
        routeInformationParser: goRouter.routeInformationParser,
        routerDelegate: goRouter.routerDelegate,
      ));

      goRouter.push('/page-1');

      await tester.pumpAndSettle();

      expect(find.text('Page 1'), findsOneWidget);
      expect(
        goRouter.routerDelegate.currentConfiguration.matches.length,
        equals(2),
      );
      expect(goRouter.routerDelegate.canPop(), true);

      goRouter.routerDelegate.pop();

      await tester.pumpAndSettle();

      expect(counter, equals(1));
    },
  );

  testWidgets(
    r'PopScope onPopInvokedWithResult should be called only once with GoRouteData.$route',
    (WidgetTester tester) async {
      int counter = 0;

      final GoRouter goRouter = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
          GoRouteData.$route(
            path: '/page-1',
            factory: (GoRouterState state) => _Page1(
              onPop: () {
                counter++;
              },
            ),
          ),
        ],
      );

      addTearDown(goRouter.dispose);

      await tester.pumpWidget(MaterialApp.router(
        routeInformationProvider: goRouter.routeInformationProvider,
        routeInformationParser: goRouter.routeInformationParser,
        routerDelegate: goRouter.routerDelegate,
      ));

      goRouter.push('/page-1');

      await tester.pumpAndSettle();

      expect(find.text('Page 1'), findsOneWidget);
      expect(
        goRouter.routerDelegate.currentConfiguration.matches.length,
        equals(2),
      );
      expect(goRouter.routerDelegate.canPop(), true);

      goRouter.routerDelegate.pop();

      await tester.pumpAndSettle();

      expect(counter, equals(1));
    },
  );
}

class _Page1 extends GoRouteData {
  const _Page1({
    required this.onPop,
  });

  final VoidCallback onPop;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(
        child: PopScope(
          onPopInvokedWithResult: (bool didPop, __) {
            if (didPop) {
              onPop();
              return;
            }
          },
          child: const Text('Page 1'),
        ),
      );
}

class DummyStatefulWidget extends StatefulWidget {
  const DummyStatefulWidget({super.key});

  @override
  State<DummyStatefulWidget> createState() => _DummyStatefulWidgetState();
}

class _DummyStatefulWidgetState extends State<DummyStatefulWidget> {
  @override
  Widget build(BuildContext context) => Container();
}

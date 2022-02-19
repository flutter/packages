import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/go_router_cupertino.dart';

void main() {
  group('isCupertinoApp', () {
    testWidgets('returns [true] when CupertinoApp is present', (tester) async {
      final key = GlobalKey<_DummyStatefulWidgetState>();
      await tester.pumpWidget(
        CupertinoApp(
          home: DummyStatefulWidget(key: key),
        ),
      );
      final isCupertino = isCupertinoApp(key.currentContext! as Element);
      expect(isCupertino, true);
    });

    testWidgets('returns [false] when MaterialApp is present', (tester) async {
      final key = GlobalKey<_DummyStatefulWidgetState>();
      await tester.pumpWidget(
        MaterialApp(
          home: DummyStatefulWidget(key: key),
        ),
      );
      final isCupertino = isCupertinoApp(key.currentContext! as Element);
      expect(isCupertino, false);
    });
  });

  test('pageBuilderForCupertinoApp creates a [CupertinoPage] accordingly', () {
    final key = UniqueKey();
    const name = 'name';
    const arguments = 'arguments';
    const restorationId = 'restorationId';
    const child = DummyStatefulWidget();
    final page = pageBuilderForCupertinoApp(
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
    );
    expect(page.key, key);
    expect(page.name, name);
    expect(page.arguments, arguments);
    expect(page.restorationId, restorationId);
    expect(page.child, child);
  });

  group('GoRouterCupertinoErrorScreen', () {
    testWidgets('shows "page not found" by default', (tester) async {
      await tester.pumpWidget(const CupertinoApp(
        home: GoRouterCupertinoErrorScreen(null),
      ));
      expect(find.text('page not found'), findsOneWidget);
    });

    testWidgets('shows the exception message when provided', (tester) async {
      final error = Exception('Something went wrong!');
      await tester.pumpWidget(CupertinoApp(
        home: GoRouterCupertinoErrorScreen(error),
      ));
      expect(find.text('$error'), findsOneWidget);
    });

    testWidgets('clicking the CupertinoButton should redirect to /',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/error',
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
          GoRoute(
            path: '/error',
            builder: (_, __) => const GoRouterCupertinoErrorScreen(null),
          ),
        ],
      );
      await tester.pumpWidget(
        CupertinoApp.router(
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          title: 'GoRouter Example',
        ),
      );
      final cupertinoButton = find.byType(CupertinoButton);
      await tester.tap(cupertinoButton);
      await tester.pumpAndSettle();
      expect(find.byType(DummyStatefulWidget), findsOneWidget);
    });
  });
}

class DummyStatefulWidget extends StatefulWidget {
  const DummyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<DummyStatefulWidget> createState() => _DummyStatefulWidgetState();
}

class _DummyStatefulWidgetState extends State<DummyStatefulWidget> {
  @override
  Widget build(BuildContext context) => Container();
}

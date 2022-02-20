import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../go_router_test.dart';

void main() {
  testWidgets('CustomTransitionPage builds its child using transitionsBuilder',
      (tester) async {
    const child = HomeScreen();
    final transition = CustomTransitionPage<void>(
      transitionsBuilder: expectAsync4((_, __, ___, child) => child),
      child: child,
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (_, __) => transition,
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        title: 'GoRouter Example',
      ),
    );
    expect(find.byWidget(child), findsOneWidget);
  });

  test('NoTransitionPage does not apply any transition', () {
    const homeScreen = HomeScreen();
    const page = NoTransitionPage<void>(child: homeScreen);
    const primaryAnimation = AlwaysStoppedAnimation<double>(0);
    const secondaryAnimation = AlwaysStoppedAnimation<double>(1);
    final widget = page.transitionsBuilder(
      DummyBuildContext(),
      primaryAnimation,
      secondaryAnimation,
      homeScreen,
    );
    expect(widget, homeScreen);
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container();
}

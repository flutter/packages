import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_examples/web-side-nav-example.dart.dart';

void main() {
  group('Navigation tests', () {
    testWidgets('Initial route is /a/d', (WidgetTester tester) async {
      await tester.pumpWidget(ShellRouteExampleAppForWeb());
      
      final state = GoRouterState.of(tester.element(find.byType(ScaffoldWithNavBar)));
      expect(state.uri.path, '/a/d');
    });

    testWidgets('Navigation to /b', (WidgetTester tester) async {
      await tester.pumpWidget(ShellRouteExampleAppForWeb());
      await tester.tap(find.text('Menu B'));

      await tester.pumpAndSettle();

      final state = GoRouterState.of(tester.element(find.byType(ScaffoldWithNavBar)));
      expect(state.uri.path, '/b');
    });

    // Add more tests for navigation to /c, /a/e, /a/f, /a/d/details, etc.
  });

  group('UI rendering tests', () {
    testWidgets('Check if all menu items are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(ShellRouteExampleAppForWeb());

      expect(find.text('Menu A'), findsOneWidget);
      expect(find.text('Menu B'), findsOneWidget);
      expect(find.text('Menu C'), findsOneWidget);
    });

    // Add more tests to check UI rendering for different screens and components.
  });
}

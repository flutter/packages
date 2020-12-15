// Imports the Flutter Driver API.
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:web_pointer_interceptor_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Widget', () {
    // First, define the Finders and use them to locate widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.
    final Finder resultKeyFinder = find.byKey(const Key('last-clicked'));
    final Finder resultTextFinderNone = find.text('Last click on: none');
    final Finder resultTextFinderHtml = find.text('Last click on: html-element');
    final Finder resultTextFinderButton = find.text('Last click on: clickable-button');
    final Finder resultTextFinderTransparentButton = find.text('Last click on: transparent-button');

    final Finder nonClickableButtonFinder = find.byKey(const Key('transparent-button'));
    final Finder clickableButtonFinder = find.byKey(const Key('clickable-button'));

    testWidgets('starts at "none"', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(resultKeyFinder, findsOneWidget);
      expect(resultTextFinderNone, findsOneWidget);

      expect(tester.widget(resultTextFinderNone), tester.widget(resultKeyFinder));
    });

    testWidgets('clicking on the clickable button works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(clickableButtonFinder);

      await tester.pumpAndSettle();

      expect(resultKeyFinder, findsOneWidget);
      expect(resultTextFinderButton, findsOneWidget);

      expect(tester.widget(resultTextFinderButton), tester.widget(resultKeyFinder));
    });

    testWidgets('clicks on the transparent button go through', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(nonClickableButtonFinder);

      await tester.pumpAndSettle();

      expect(resultKeyFinder, findsOneWidget);
      expect(resultTextFinderTransparentButton, findsNothing);
      expect(resultTextFinderHtml, findsOneWidget);

      expect(tester.widget(resultTextFinderHtml), tester.widget(resultKeyFinder));
    }, skip: true); // This test should pass, but does not. It finds a "transparent-button" result.
  });
}

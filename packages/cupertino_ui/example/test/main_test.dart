import 'package:flutter_test/flutter_test.dart';

import 'package:cupertino_ui_examples/main.dart';

import 'package:cupertino_ui_examples/activity_indicator/cupertino_activity_indicator.0.dart'
    as activity_indicator;

void main() {
  testWidgets('cupertino_activity_indicator.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text(
      'activity_indicator/cupertino_activity_indicator.0.dart',
    );
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.byType(activity_indicator.CupertinoIndicatorApp),
      findsOneWidget,
    );
  });
}

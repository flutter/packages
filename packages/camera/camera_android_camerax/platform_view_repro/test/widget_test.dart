import 'package:flutter_test/flutter_test.dart';
import 'package:platform_view_repro/main.dart';

void main() {
  testWidgets('MinimalPlatformViewReproApp builds cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const MinimalPlatformViewReproApp());
    expect(find.text('Platform View Jank Repro'), findsOneWidget);
  });
}


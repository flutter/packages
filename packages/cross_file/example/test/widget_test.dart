import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cross_file_example/main.dart';

void main() {
  testWidgets('Displays created file text', (WidgetTester tester) async {
    // Build our app and wait for any async build work to complete.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the text is shown.
    expect(find.text('Created file: demo.txt'), findsOneWidget);
  });
}

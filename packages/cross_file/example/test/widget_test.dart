import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cross_file_example/main.dart';

void main() {
  testWidgets('Displays created file text', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the text is shown.
    expect(find.text('Created file: demo.txt'), findsOneWidget);
  });
}

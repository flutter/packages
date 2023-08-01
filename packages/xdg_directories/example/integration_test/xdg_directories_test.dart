// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:xdg_directories_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('xdg_directories_demo', (WidgetTester _) async {
    // Build our app and trigger a frame.
    await _.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('XDG Directories Demo'), findsOneWidget);
    expect(find.text('Data Home:'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    // await _.tap(find.byIcon(Icons.add));
    // await _.pump();

    // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);

    // await _.tap(find.byIcon(Icons.add));
    // await _.pump();

    // expect(find.text('0'), findsNothing);
  });
}

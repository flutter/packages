// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Android Local Network example smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the initial status is 'Unknown'.
    expect(find.text('Unknown'), findsOneWidget);

    // Verify that the 'Deep Scan LAN' button is present.
    expect(find.text('Deep Scan LAN'), findsOneWidget);

    // Verify that the 'Check Status' button is present.
    expect(find.text('Check Status'), findsOneWidget);

    // Verify that 'Request Permission' is NOT present.
    expect(find.text('Request Permission'), findsNothing);
  });
}

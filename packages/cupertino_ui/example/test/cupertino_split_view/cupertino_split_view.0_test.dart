// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:cupertino_ui_examples/cupertino_split_view/cupertino_split_view.0.dart'
    as example;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CupertinoSplitView updates the detail column from the sidebar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.CupertinoSplitViewApp());
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoSplitView<String>), findsOneWidget);
    expect(find.text('Mailboxes'), findsOneWidget);
    expect(find.text('Select a mailbox'), findsOneWidget);

    await tester.tap(find.text('Inbox'));
    await tester.pumpAndSettle();

    expect(find.text('Messages in Inbox'), findsOneWidget);
    expect(find.byType(CupertinoNavigationBarBackButton), findsNothing);
  });
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:cupertino_ui_examples/tab_scaffold/cupertino_tab_scaffold.0.dart'
    as example;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Can use CupertinoTabView as the root widget', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.TabScaffoldApp());

    expect(find.text('Page 1 of tab 0'), findsOneWidget);
    await tester.tap(find.byIcon(CupertinoIcons.search_circle_fill));
    await tester.pumpAndSettle();
    expect(find.text('Page 1 of tab 1'), findsOneWidget);

    await tester.tap(find.text('Next page'));
    await tester.pumpAndSettle();
    expect(find.text('Page 2 of tab 1'), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Page 1 of tab 1'), findsOneWidget);
  });
}

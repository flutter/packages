// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/main.dart';

void main() {
  testWidgets('Validate extra logic walkthrough', (WidgetTester tester) async {
    await tester.pumpWidget(App());

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    await _openPopupMenu(tester);

    await tester.tap(find.text('Push w/o return value'));
    await tester.pumpAndSettle();
    expect(find.text('Chris'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await _openPopupMenu(tester);

    await tester.tap(find.text('Push w/ return value'));
    await tester.pumpAndSettle();
    expect(find.text('Family Count'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sells'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chris'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('hobbies - coding'));
    await tester.pumpAndSettle();

    expect(find.text('No extra click!'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('With extra...').first);
    await tester.pumpAndSettle();

    expect(find.text('Extra click count: 1'), findsOneWidget);
  });
}

Future<void> _openPopupMenu(WidgetTester tester) async {
  final Finder moreButton = find.byIcon(Icons.more_vert);
  expect(moreButton, findsOneWidget);

  await tester.tap(moreButton);
  await tester.pumpAndSettle();
}

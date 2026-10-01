// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:a11y_assessments/use_cases/bottom_app_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_utils.dart';

void main() {
  testWidgets('bottom app bar test', (WidgetTester tester) async {
    await pumpsUseCase(tester, BottomAppBarUseCase());
    expect(find.byType(BottomAppBar), findsOneWidget);
    expect(find.text('Selected: None'), findsOneWidget);

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();

    expect(find.text('Selected: Menu'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

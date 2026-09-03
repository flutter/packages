// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:a11y_assessments/use_cases/back_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_utils.dart';

void main() {
  testWidgets('back button can run', (WidgetTester tester) async {
    await pumpsUseCase(tester, BackButtonUseCase());
    expect(find.byType(BackButton), findsOneWidget);
  });
}

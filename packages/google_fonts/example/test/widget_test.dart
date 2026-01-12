// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

// Consider `flutter test --no-test-assets` if assets are not required.
void main() {
  testWidgets('Can specify text style', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Text('Hello', style: GoogleFonts.aBeeZee())),
    );
  });

  testWidgets('Can specify text theme', (WidgetTester tester) async {
    final ThemeData baseTheme = ThemeData.dark();

    await tester.pumpWidget(
      MaterialApp(
        theme: baseTheme.copyWith(
          textTheme: GoogleFonts.aBeeZeeTextTheme(baseTheme.textTheme),
        ),
      ),
    );
  });
}

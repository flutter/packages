// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/chip/chip.snippet.1.dart' as example;

void main() {
  testWidgets('Blacksmith InputChip calls startHammering when tapped', (
    WidgetTester tester,
  ) async {
    final List<String> log = <String>[];
    await runZoned(
      () async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: example.Blacksmith())),
        );

        expect(find.text('Apply Hammer'), findsOneWidget);
        await tester.tap(find.byType(InputChip));
        await tester.pump();
      },
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          log.add(line);
        },
      ),
    );

    expect(log, <String>['bang bang bang']);
  });
}

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/expansion_panel/expansion_panel_list.2.dart'
    as example;

void main() {
  testWidgets(
    'Flat ExpansionPanelList preserves dividers with no MaterialGap',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.FlatExpansionPanelListExampleApp());

      await tester.tap(find.text('Panel A'));
      await tester.pumpAndSettle();

      final MergeableMaterial mergeableMaterial = tester.widget(
        find.byType(MergeableMaterial),
      );
      expect(mergeableMaterial.children.whereType<MaterialGap>().length, 0);
      expect(mergeableMaterial.hasDividers, true);
    },
  );
}

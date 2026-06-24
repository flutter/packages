// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:cupertino_ui_examples/list_section/list_section_base.0.dart'
    as example;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Has exactly 1 CupertinoListSection base widget', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.CupertinoListSectionBaseApp());

    final Finder listSectionFinder = find.byType(CupertinoListSection);
    expect(listSectionFinder, findsOneWidget);

    final CupertinoListSection listSectionWidget = tester
        .widget<CupertinoListSection>(listSectionFinder);
    expect(listSectionWidget.type, equals(CupertinoListSectionType.base));
  });

  testWidgets('CupertinoListSection has 3 CupertinoListTile children', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.CupertinoListSectionBaseApp());

    expect(find.byType(CupertinoListTile), findsNWidgets(3));
  });
}

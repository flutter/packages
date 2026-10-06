// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:pointer_interceptor_example/readme_excerpts.dart';

void main() {
  testWidgets('wrapButtonSnippet wraps a button in a PointerInterceptor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: wrapButtonSnippet()));

    expect(find.byType(PointerInterceptor), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Button'), findsOneWidget);
  });

  testWidgets('wrapSubtreeSnippet wraps a Drawer in a PointerInterceptor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: wrapSubtreeSnippet()));
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();

    expect(find.byType(PointerInterceptor), findsOneWidget);
    expect(find.widgetWithText(Drawer, 'Drawer contents'), findsOneWidget);
  });

  testWidgets('interceptingBeforeSnippet returns a PointerInterceptor when true', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: interceptingBeforeSnippet(true)));

    expect(find.byType(PointerInterceptor), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Button'), findsOneWidget);
  });

  testWidgets('interceptingBeforeSnippet returns a plain button when false', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: interceptingBeforeSnippet(false)));

    expect(find.byType(PointerInterceptor), findsNothing);
    expect(find.widgetWithText(ElevatedButton, 'Button'), findsOneWidget);
  });

  testWidgets('interceptingAfterSnippet sets intercepting from its argument', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: interceptingAfterSnippet(true)));

    final PointerInterceptor interceptor = tester.widget(find.byType(PointerInterceptor));
    expect(interceptor.intercepting, isTrue);
    expect(find.widgetWithText(ElevatedButton, 'Button'), findsOneWidget);
  });
}

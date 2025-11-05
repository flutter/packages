// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../lib/refresh_example.dart';

void main() {
  group('Refresh Function Tests', () {
    // Helper to get router from tester
    GoRouter getRouter(WidgetTester tester) {
      final BuildContext context = tester.element(find.byType(Scaffold).first);
      return GoRouter.of(context);
    }

    testWidgets('refresh() creates new configuration', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      final GoRouter router = getRouter(tester);
      final dynamic matchesBefore = router.routerDelegate.currentConfiguration;

      await tester.pump(const Duration(milliseconds: 10));
      router.refresh();
      await tester.pump();

      final dynamic matchesAfter = router.routerDelegate.currentConfiguration;

      // Verify that configuration changed
      expect(matchesAfter, isNot(same(matchesBefore)));
    });

    testWidgets('refresh() on simple route triggers data reload', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      getRouter(tester).go('/simple');
      await tester.pumpAndSettle();

      final Finder dataFinder = find.textContaining('Data #');
      expect(dataFinder, findsOneWidget);
      final String initialData = tester.widget<Text>(dataFinder).data!;

      await tester.pump(const Duration(milliseconds: 10));
      getRouter(tester).refresh();
      await tester.pump();

      final String updatedData = tester.widget<Text>(dataFinder).data!;
      expect(updatedData, isNot(equals(initialData)));
    });

    testWidgets('refresh() preserves path parameters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      getRouter(tester).go('/nested/456');
      await tester.pumpAndSettle();

      expect(find.text('Nested 456'), findsOneWidget);

      final dynamic matchesBefore =
          getRouter(tester).routerDelegate.currentConfiguration;

      getRouter(tester).refresh();
      await tester.pump();

      final dynamic matchesAfter =
          getRouter(tester).routerDelegate.currentConfiguration;

      expect(matchesAfter.pathParameters['id'], equals('456'));
      expect(matchesBefore.uri.path, equals(matchesAfter.uri.path));
    });

    testWidgets('refresh() on nested detail route', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      getRouter(tester).go('/nested/789/detail');
      await tester.pumpAndSettle();

      expect(find.text('Detail'), findsOneWidget);

      final Finder dataFinder = find.textContaining('Detail for 789:');
      final String initialData = tester.widget<Text>(dataFinder).data!;

      await tester.pump(const Duration(milliseconds: 10));
      getRouter(tester).refresh();
      await tester.pump();

      final String updatedData = tester.widget<Text>(dataFinder).data!;
      expect(updatedData, isNot(equals(initialData)));
    });

    testWidgets('refresh() preserves query parameters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      getRouter(tester).go('/simple?test=value&count=5');
      await tester.pumpAndSettle();

      final dynamic matchesBefore =
          getRouter(tester).routerDelegate.currentConfiguration;

      getRouter(tester).refresh();
      await tester.pump();

      final dynamic matchesAfter =
          getRouter(tester).routerDelegate.currentConfiguration;

      expect(matchesAfter.uri.queryParameters['test'], equals('value'));
      expect(matchesAfter.uri.queryParameters['count'], equals('5'));
      expect(matchesBefore.uri.toString(), equals(matchesAfter.uri.toString()));
    });

    testWidgets('multiple refresh() calls create different configurations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      getRouter(tester).go('/simple');
      await tester.pumpAndSettle();

      final List<dynamic> configurations = <dynamic>[];

      for (int i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 10));
        getRouter(tester).refresh();
        await tester.pump();

        configurations.add(
          getRouter(tester).routerDelegate.currentConfiguration,
        );
      }

      // All configurations should be different objects
      expect(configurations[0], isNot(same(configurations[1])));
      expect(configurations[1], isNot(same(configurations[2])));
      expect(configurations[0], isNot(same(configurations[2])));
    });

    testWidgets('refresh() on ShellRoute', (WidgetTester tester) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      getRouter(tester).go('/shell/page1');
      await tester.pumpAndSettle();

      expect(find.text('Shell Page 1'), findsOneWidget);

      getRouter(tester).refresh();
      await tester.pump();

      expect(find.text('Shell Page 1'), findsOneWidget);
    });

    testWidgets('refresh() on StatefulShellRoute', (WidgetTester tester) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      getRouter(tester).go('/stateful/tab1');
      await tester.pumpAndSettle();

      expect(find.text('Stateful Tab 1'), findsOneWidget);

      getRouter(tester).refresh();
      await tester.pump();

      expect(find.text('Stateful Tab 1'), findsOneWidget);
    });

    testWidgets('refresh() maintains navigation stack depth', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      getRouter(tester).go('/nested/111/detail');
      await tester.pumpAndSettle();

      expect(find.text('Detail'), findsOneWidget);

      final dynamic matchesBefore =
          getRouter(tester).routerDelegate.currentConfiguration;

      getRouter(tester).refresh();
      await tester.pump();

      final dynamic matchesAfter =
          getRouter(tester).routerDelegate.currentConfiguration;

      expect(matchesAfter.matches.length, equals(matchesBefore.matches.length));
      expect(matchesAfter.uri.path, equals('/nested/111/detail'));
    });

    testWidgets('refresh() works with push navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      getRouter(tester).go('/simple');
      await tester.pumpAndSettle();

      getRouter(tester).push('/nested/222');
      await tester.pumpAndSettle();

      expect(find.text('Nested 222'), findsOneWidget);

      getRouter(tester).refresh();
      await tester.pump();

      expect(find.text('Nested 222'), findsOneWidget);
    });

    testWidgets('refresh() preserves extra data', (WidgetTester tester) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      const Map<String, String> extraData = <String, String>{'key': 'value'};
      getRouter(tester).go('/simple', extra: extraData);
      await tester.pumpAndSettle();

      final dynamic matchesBefore =
          getRouter(tester).routerDelegate.currentConfiguration;
      expect(matchesBefore.extra, equals(extraData));

      getRouter(tester).refresh();
      await tester.pump();

      final dynamic matchesAfter =
          getRouter(tester).routerDelegate.currentConfiguration;
      expect(matchesAfter.extra, equals(extraData));
    });

    testWidgets('refresh() can be called rapidly', (WidgetTester tester) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      getRouter(tester).go('/simple');
      await tester.pumpAndSettle();

      // Call refresh multiple times rapidly
      for (int i = 0; i < 5; i++) {
        getRouter(tester).refresh();
        await tester.pump(const Duration(milliseconds: 1));
      }

      expect(find.text('Simple Refresh'), findsOneWidget);
    });

    testWidgets('refresh() on different route types', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      // Home route
      getRouter(tester).refresh();
      await tester.pump();
      expect(find.byType(MaterialApp), findsOneWidget);

      // Simple route
      getRouter(tester).go('/simple');
      await tester.pumpAndSettle();
      getRouter(tester).refresh();
      await tester.pump();
      expect(find.text('Simple Refresh'), findsOneWidget);

      // Nested route
      getRouter(tester).go('/nested/333');
      await tester.pumpAndSettle();
      getRouter(tester).refresh();
      await tester.pump();
      expect(find.text('Nested 333'), findsOneWidget);

      // Shell route
      getRouter(tester).go('/shell/page2');
      await tester.pumpAndSettle();
      getRouter(tester).refresh();
      await tester.pump();
      expect(find.text('Shell Page 2'), findsOneWidget);

      // Stateful shell route
      getRouter(tester).go('/stateful/tab2');
      await tester.pumpAndSettle();
      getRouter(tester).refresh();
      await tester.pump();
      expect(find.text('Stateful Tab 2'), findsOneWidget);
    });

    testWidgets('refresh() updates data timestamp', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      getRouter(tester).go('/simple');
      await tester.pumpAndSettle();

      final Finder dataFinder = find.textContaining('Data #');
      final String data1 = tester.widget<Text>(dataFinder).data!;

      final RegExp timestampRegex = RegExp(r'- (\d+)');
      final int timestamp1 = int.parse(
        timestampRegex.firstMatch(data1)!.group(1)!,
      );

      await tester.pump(const Duration(milliseconds: 100));
      getRouter(tester).refresh();
      await tester.pump();

      final String data2 = tester.widget<Text>(dataFinder).data!;
      final int timestamp2 = int.parse(
        timestampRegex.firstMatch(data2)!.group(1)!,
      );

      expect(timestamp2, greaterThan(timestamp1));
    });

    testWidgets('refresh() after navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      getRouter(tester).go('/simple');
      await tester.pumpAndSettle();
      expect(find.text('Simple Refresh'), findsOneWidget);

      getRouter(tester).go('/');
      await tester.pumpAndSettle();

      getRouter(tester).refresh();
      await tester.pump();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('refresh() maintains URI structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RefreshExampleApp());
      await tester.pumpAndSettle();

      getRouter(tester).go('/nested/555?query=test#fragment');
      await tester.pumpAndSettle();

      final dynamic matchesBefore =
          getRouter(tester).routerDelegate.currentConfiguration;

      getRouter(tester).refresh();
      await tester.pump();

      final dynamic matchesAfter =
          getRouter(tester).routerDelegate.currentConfiguration;

      expect(matchesAfter.uri.path, equals(matchesBefore.uri.path));
      expect(matchesAfter.uri.query, equals(matchesBefore.uri.query));
      expect(matchesAfter.uri.fragment, equals(matchesBefore.uri.fragment));
    });
  });
}

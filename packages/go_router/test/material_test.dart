// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/pages/material.dart';

import 'helpers/error_screen_helpers.dart';

void main() {
  group('isMaterialApp', () {
    testWidgets('returns [true] when MaterialApp is present', (
      WidgetTester tester,
    ) async {
      final GlobalKey<_DummyStatefulWidgetState> key =
          GlobalKey<_DummyStatefulWidgetState>();
      await tester.pumpWidget(MaterialApp(home: DummyStatefulWidget(key: key)));
      final bool isMaterial = isMaterialApp(key.currentContext! as Element);
      expect(isMaterial, true);
    });

    testWidgets('returns [false] when CupertinoApp is present', (
      WidgetTester tester,
    ) async {
      final GlobalKey<_DummyStatefulWidgetState> key =
          GlobalKey<_DummyStatefulWidgetState>();
      await tester.pumpWidget(
        CupertinoApp(home: DummyStatefulWidget(key: key)),
      );
      final bool isMaterial = isMaterialApp(key.currentContext! as Element);
      expect(isMaterial, false);
    });
  });

  test('pageBuilderForMaterialApp creates a [MaterialPage] accordingly', () {
    final UniqueKey key = UniqueKey();
    const String name = 'name';
    const String arguments = 'arguments';
    const String restorationId = 'restorationId';
    const DummyStatefulWidget child = DummyStatefulWidget();
    final MaterialPage<void> page = pageBuilderForMaterialApp(
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
    );
    expect(page.key, key);
    expect(page.name, name);
    expect(page.arguments, arguments);
    expect(page.restorationId, restorationId);
    expect(page.child, child);
  });

  group('GoRouterMaterialErrorScreen', () {
    testWidgets(
      'shows "page not found" by default',
      testPageNotFound(
        widget: const MaterialApp(home: MaterialErrorScreen(null)),
      ),
    );

    final Exception exception = Exception('Something went wrong!');
    testWidgets(
      'shows the exception message when provided',
      testPageShowsExceptionMessage(
        exception: exception,
        widget: MaterialApp(home: MaterialErrorScreen(exception)),
      ),
    );

    testWidgets(
      'clicking the TextButton should redirect to /',
      testClickingTheButtonRedirectsToRoot(
        buttonFinder: find.byType(TextButton),
        widget: const MaterialApp(home: MaterialErrorScreen(null)),
      ),
    );
  });
}

class DummyStatefulWidget extends StatefulWidget {
  const DummyStatefulWidget({super.key});

  @override
  State<DummyStatefulWidget> createState() => _DummyStatefulWidgetState();
}

class _DummyStatefulWidgetState extends State<DummyStatefulWidget> {
  @override
  Widget build(BuildContext context) => Container();
}

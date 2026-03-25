// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/pages/cupertino.dart';

import 'helpers/error_screen_helpers.dart';

void main() {
  group('isCupertinoApp', () {
    testWidgets('returns [true] when CupertinoApp is present', (
      WidgetTester tester,
    ) async {
      final key = GlobalKey<_DummyStatefulWidgetState>();
      await tester.pumpWidget(
        CupertinoApp(home: DummyStatefulWidget(key: key)),
      );
      final bool isCupertino = isCupertinoApp(key.currentContext! as Element);
      expect(isCupertino, true);
    });

    testWidgets('returns [false] when MaterialApp is present', (
      WidgetTester tester,
    ) async {
      final key = GlobalKey<_DummyStatefulWidgetState>();
      await tester.pumpWidget(MaterialApp(home: DummyStatefulWidget(key: key)));
      final bool isCupertino = isCupertinoApp(key.currentContext! as Element);
      expect(isCupertino, false);
    });
  });

  test('pageBuilderForCupertinoApp creates a [CupertinoPage] accordingly', () {
    final key = UniqueKey();
    const name = 'name';
    const arguments = 'arguments';
    const restorationId = 'restorationId';
    const child = DummyStatefulWidget();
    final CupertinoPage<void> page = pageBuilderForCupertinoApp(
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

  group('GoRouterCupertinoErrorScreen', () {
    testWidgets(
      'shows "page not found" by default',
      testPageNotFound(
        widget: const CupertinoApp(home: CupertinoErrorScreen(null)),
      ),
    );

    final exception = Exception('Something went wrong!');
    testWidgets(
      'shows the exception message when provided',
      testPageShowsExceptionMessage(
        exception: exception,
        widget: CupertinoApp(home: CupertinoErrorScreen(exception)),
      ),
    );

    testWidgets(
      'clicking the CupertinoButton should redirect to /',
      testClickingTheButtonRedirectsToRoot(
        buttonFinder: find.byType(CupertinoButton),
        appRouterBuilder: cupertinoAppRouterBuilder,
        widget: const CupertinoApp(home: CupertinoErrorScreen(null)),
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

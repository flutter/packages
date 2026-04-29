// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('OpenContainer can be opened via onOpen hook', (WidgetTester tester) async {
    var onOpenCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OpenContainer(
            onOpen: () {
              onOpenCalled = true;
              return Future<void>.value();
            },
            closedBuilder: (BuildContext context, VoidCallback openContainer) {
              return ElevatedButton(
                onPressed: openContainer,
                child: const Text('Open'),
              );
            },
            openBuilder: (BuildContext context, VoidCallback closeContainer) {
              return const Text('Opened');
            },
          ),
        ),
      ),
    );

    expect(onOpenCalled, isFalse);
    await tester.tap(find.text('Open'));
    await tester.pump();
    expect(onOpenCalled, isTrue);
  });

  testWidgets('OpenContainer registers itself in OpenContainerRegistry', (WidgetTester tester) async {
    const tag = 'test-tag';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OpenContainer(
            transitionTag: tag,
            closedBuilder: (BuildContext context, VoidCallback openContainer) {
              return const Text('Closed');
            },
            openBuilder: (BuildContext context, VoidCallback closeContainer) {
              return const Text('Opened');
            },
          ),
        ),
      ),
    );

    final OpenContainerState<dynamic>? state = OpenContainerRegistry.instance.get(tag);
    expect(state, isNotNull);
    expect(state!.widget.transitionTag, tag);

    await tester.pumpWidget(Container());
    expect(OpenContainerRegistry.instance.get(tag), isNull);
  });

  testWidgets('OpenContainerPage performs coordinated transition', (WidgetTester tester) async {
    const tag = 'coordinated-tag';
    final navKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        home: Scaffold(
          body: OpenContainer(
            transitionTag: tag,
            closedBuilder: (BuildContext context, VoidCallback openContainer) {
              return const SizedBox(
                width: 100,
                height: 100,
                child: Text('Closed Content'),
              );
            },
            openBuilder: (BuildContext context, VoidCallback closeContainer) {
              return const Text('Opened Content');
            },
          ),
        ),
      ),
    );

    expect(find.text('Closed Content'), findsOneWidget);
    expect(find.text('Opened Content'), findsNothing);

    navKey.currentState!.push(
      OpenContainerPage<void>(
        transitionTag: tag,
        openBuilder: (BuildContext context, VoidCallback closeContainer) {
          return const Scaffold(body: Text('Opened Content'));
        },
      ).createRoute(tester.element(find.byType(OpenContainer))),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // During transition, both should be present (though one might be fading out)
    expect(find.text('Closed Content'), findsOneWidget);
    expect(find.text('Opened Content'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Closed Content'), findsNothing);
    expect(find.text('Opened Content'), findsOneWidget);
  });

  testWidgets('OpenContainerPage falls back to fade when tag not found', (WidgetTester tester) async {
    final navKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        home: const Scaffold(
          body: Text('Home'),
        ),
      ),
    );

    navKey.currentState!.push(
      OpenContainerPage<void>(
        transitionTag: 'non-existent',
        openBuilder: (BuildContext context, VoidCallback closeContainer) {
          return const Scaffold(body: Text('Opened Content'));
        },
      ).createRoute(tester.element(find.text('Home'))),
    );

    await tester.pump();
    // It should just work without crashing
    expect(find.text('Opened Content'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Opened Content'), findsOneWidget);
  });
}

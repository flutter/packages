// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_adaptive_scaffold/src/breakpoints.dart';
import 'package:flutter_adaptive_scaffold/src/slot_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'SlotLayout displays correct widget based on screen width',
    (WidgetTester tester) async {
      MediaQuery slot(double width) {
        return MediaQuery(
          data: MediaQueryData(size: Size(width, 2000)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SlotLayout(
              config: <Breakpoint, SlotLayoutConfig>{
                Breakpoints.smallAndUp: SlotLayout.from(
                    key: const Key('0'), builder: (_) => const Text('Small')),
                Breakpoints.mediumAndUp: SlotLayout.from(
                    key: const Key('400'),
                    builder: (_) => const Text('Medium')),
                Breakpoints.largeAndUp: SlotLayout.from(
                    key: const Key('800'), builder: (_) => const Text('Large')),
              },
            ),
          ),
        );
      }

      await tester.pumpWidget(slot(300));
      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Medium'), findsNothing);
      expect(find.text('Large'), findsNothing);

      await tester.pumpWidget(slot(600));
      expect(find.text('Small'), findsNothing);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Large'), findsNothing);

      await tester.pumpWidget(slot(1200));
      expect(find.text('Small'), findsNothing);
      expect(find.text('Medium'), findsNothing);
      expect(find.text('Large'), findsOneWidget);
    },
  );

  testWidgets(
    'SlotLayout handles null configurations gracefully',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData.fromView(tester.view)
              .copyWith(size: const Size(500, 2000)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SlotLayout(
              config: <Breakpoint, SlotLayoutConfig?>{
                Breakpoints.smallAndUp: SlotLayout.from(
                  key: const Key('0'),
                  builder: (BuildContext context) => Container(),
                ),
                Breakpoints.mediumAndUp: null,
                Breakpoints.largeAndUp: SlotLayout.from(
                  key: const Key('800'),
                  builder: (BuildContext context) => Container(),
                ),
              },
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('0')), findsOneWidget);
      expect(find.byKey(const Key('400')), findsNothing);
      expect(find.byKey(const Key('800')), findsNothing);
    },
  );

  testWidgets(
    'SlotLayout builder generates widgets correctly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(600, 2000)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SlotLayout(
              config: <Breakpoint, SlotLayoutConfig>{
                Breakpoints.mediumAndUp: SlotLayout.from(
                    key: const Key('0'),
                    builder: (_) => const Text('Builder Test')),
              },
            ),
          ),
        ),
      );

      expect(find.text('Builder Test'), findsOneWidget);
    },
  );

  testWidgets(
    'SlotLayout applies inAnimation and outAnimation correctly when changing breakpoints',
    (WidgetTester tester) async {
      // Define a SlotLayout with custom animations.
      Widget buildSlotLayout(double width) {
        return MediaQuery(
          data: MediaQueryData(size: Size(width, 2000)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SlotLayout(
              config: <Breakpoint, SlotLayoutConfig>{
                Breakpoints.smallAndUp: SlotLayout.from(
                  key: const Key('small'),
                  builder: (_) => const SizedBox(
                      key: Key('smallBox'), width: 100, height: 100),
                  inAnimation: (Widget widget, Animation<double> animation) =>
                      ScaleTransition(
                    scale: animation,
                    child: widget,
                  ),
                  outAnimation: (Widget widget, Animation<double> animation) =>
                      FadeTransition(
                    opacity: animation,
                    child: widget,
                  ),
                  inDuration: const Duration(seconds: 1),
                  outDuration: const Duration(seconds: 2),
                  inCurve: Curves.easeIn,
                  outCurve: Curves.easeOut,
                ),
                Breakpoints.mediumAndUp: SlotLayout.from(
                  key: const Key('medium'),
                  builder: (_) => const SizedBox(
                      key: Key('mediumBox'), width: 200, height: 200),
                  inAnimation: (Widget widget, Animation<double> animation) =>
                      ScaleTransition(
                    scale: animation,
                    child: widget,
                  ),
                  outAnimation: (Widget widget, Animation<double> animation) =>
                      FadeTransition(
                    opacity: animation,
                    child: widget,
                  ),
                  inDuration: const Duration(seconds: 1),
                  outDuration: const Duration(seconds: 2),
                  inCurve: Curves.easeIn,
                  outCurve: Curves.easeOut,
                ),
              },
            ),
          ),
        );
      }

      // Pump the widget with the SlotLayout at small breakpoint.
      await tester.pumpWidget(buildSlotLayout(300));
      expect(find.byKey(const Key('smallBox')), findsOneWidget);
      expect(find.byKey(const Key('mediumBox')), findsNothing);

      // Change to medium breakpoint to trigger outAnimation for small and inAnimation for medium.
      await tester.pumpWidget(buildSlotLayout(600));
      await tester.pump(); // Start the animation.
      await tester.pump(const Duration(
          milliseconds: 1000)); // Halfway through the outDuration.

      // Verify that the outAnimation is in progress for smallBox.
      final FadeTransition fadeTransitionMid =
          tester.widget(find.byType(FadeTransition));
      expect(fadeTransitionMid.opacity.value, lessThan(1.0));
      expect(fadeTransitionMid.opacity.value, greaterThan(0.0));

      // Complete the animation.
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('smallBox')), findsNothing);
      expect(find.byKey(const Key('mediumBox')), findsOneWidget);
    },
  );
}

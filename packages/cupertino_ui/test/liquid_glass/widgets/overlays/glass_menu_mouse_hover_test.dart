// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

const _pill = Color(0xFF123456);

/// The sliding selection pill, found by the colour it is painted in.
Finder _pillFinder() => find.byWidgetPredicate((w) =>
    w is Container &&
    w.decoration is BoxDecoration &&
    (w.decoration! as BoxDecoration).color == _pill);

void main() {
  testWidgets('a resting mouse moves the selection pill onto the row',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassMenu(
              selectionColor: _pill,
              trigger: const SizedBox(
                width: 100,
                height: 44,
                child: Text('Open Menu'),
              ),
              items: [
                GlassMenuItem(title: 'First Item', onTap: () {}),
                GlassMenuItem(title: 'Second Item', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Menu'));
    await tester.pumpAndSettle();
    expect(_pillFinder(), findsNothing);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);

    await mouse.moveTo(tester.getCenter(find.text('Second Item')));
    await tester.pumpAndSettle();
    expect(_pillFinder(), findsOneWidget);
    final second = tester.getRect(find.text('Second Item'));
    final pill = tester.getRect(_pillFinder());
    expect(pill.top, lessThanOrEqualTo(second.top));
    expect(pill.bottom, greaterThanOrEqualTo(second.bottom));

    await mouse.moveTo(tester.getCenter(find.text('First Item')));
    await tester.pumpAndSettle();
    final first = tester.getRect(find.text('First Item'));
    expect(tester.getRect(_pillFinder()).top, lessThanOrEqualTo(first.top));
    expect(tester.getRect(_pillFinder()).bottom, lessThan(second.top));

    // Leaving the menu takes the pill away again.
    await mouse.moveTo(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(_pillFinder(), findsNothing);
  });
}

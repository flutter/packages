// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart' show RendererBinding;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'dropdown_button_tester.dart';

void main() {
  testWidgets('DropdownMenuItem does not crash at zero area', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox.shrink(
              child: DropdownMenuItem<String>(value: 'a', child: Text('a')),
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(DropdownMenuItem<String>)), Size.zero);
  });

  testWidgets('DropdownMenuItem has expected mouse cursor when explicitly configured', (
    WidgetTester tester,
  ) async {
    const menuKey = Key('testDropdownButton');
    const itemKey = Key('testDropdownMenuItem');
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DropdownButton<String>(
            key: menuKey,
            dropdownMenuItemMouseCursor: SystemMouseCursors.grab,
            onChanged: (String? newValue) {},
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(key: itemKey, value: 'One', child: Text('One')),
            ],
          ),
        ),
      ),
    );

    final TestGesture gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      pointer: 1,
    );

    // Open DropdownButton.
    await tester.tap(find.byKey(menuKey));
    await tester.pumpAndSettle();

    // Find DropdownMenuItem.
    final Finder menuItemFinder = find.byKey(itemKey);
    final Offset onMenuItem = tester.getCenter(menuItemFinder);

    await gesture.addPointer(location: onMenuItem);
    await tester.pump();

    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.grab,
    );
  });

  testWidgets('DropdownMenuItem onTap callback is called when defined', (
    WidgetTester tester,
  ) async {
    String? value = 'one';
    final menuItemTapCounters = <int>[0, 0, 0, 0];
    void onChanged(String? newValue) {
      value = newValue;
    }

    final onTapCallbacks = <VoidCallback>[
      () {
        menuItemTapCounters[0] += 1;
      },
      () {
        menuItemTapCounters[1] += 1;
      },
      () {
        menuItemTapCounters[2] += 1;
      },
      () {
        menuItemTapCounters[3] += 1;
      },
    ];

    var currentIndex = -1;
    await tester.pumpWidget(
      TestApp(
        textDirection: TextDirection.ltr,
        child: Material(
          child: RepaintBoundary(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              items: menuItems.map<DropdownMenuItem<String>>((String item) {
                currentIndex += 1;
                return DropdownMenuItem<String>(
                  value: item,
                  onTap: onTapCallbacks[currentIndex],
                  child: Text(item),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    // Tap dropdown button.
    await tester.tap(find.text('one'));
    await tester.pumpAndSettle();

    expect(value, equals('one'));
    // Counters should still be zero.
    expect(menuItemTapCounters, <int>[0, 0, 0, 0]);

    // Tap dropdown menu item.
    await tester.tap(find.text('three').last);
    await tester.pumpAndSettle();

    // Should update the counter for the third item (second index).
    expect(value, equals('three'));
    expect(menuItemTapCounters, <int>[0, 0, 1, 0]);

    // Tap dropdown button again.
    await tester.tap(find.text('three', skipOffstage: false), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Should not change.
    expect(value, equals('three'));
    expect(menuItemTapCounters, <int>[0, 0, 1, 0]);

    // Tap dropdown menu item.
    await tester.tap(find.text('two').last);
    await tester.pumpAndSettle();

    // Should update the counter for the second item (first index).
    expect(value, equals('two'));
    expect(menuItemTapCounters, <int>[0, 1, 1, 0]);

    // Tap dropdown button again.
    await tester.tap(find.text('two', skipOffstage: false), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Should not change.
    expect(value, equals('two'));
    expect(menuItemTapCounters, <int>[0, 1, 1, 0]);

    // Tap the already selected menu item
    await tester.tap(find.text('two').last);
    await tester.pumpAndSettle();

    // Should update the counter for the second item (first index), even
    // though it was already selected.
    expect(value, equals('two'));
    expect(menuItemTapCounters, <int>[0, 2, 1, 0]);
  });

  testWidgets('DropdownMenuItem has expected default mouse cursor on hover', (
    WidgetTester tester,
  ) async {
    const menuKey = Key('testDropdownMenuButton');
    const itemKey = Key('testDropdownMenuItem');
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DropdownButton<String>(
            key: menuKey,
            onChanged: (String? value) {},
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                key: itemKey,
                value: 'testDropdownMenuItem',
                child: Text('TestDropdownMenuItem'),
              ),
            ],
          ),
        ),
      ),
    );

    // Open DropdownButton.
    await tester.tap(find.byKey(menuKey));
    await tester.pump();

    // Find DropdownMenuItem.
    final Finder menuItemFinder = find.byKey(itemKey);
    final Offset onMenuItem = tester.getCenter(menuItemFinder);
    final Offset offMenuItem = tester.getBottomRight(menuItemFinder) + const Offset(1, 1);
    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);

    await gesture.addPointer(location: onMenuItem);
    await tester.pump();

    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      kIsWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
    );

    await gesture.moveTo(offMenuItem);

    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.basic,
    );
  });
}

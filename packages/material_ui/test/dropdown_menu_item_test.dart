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

  testWidgets('Disabled DropdownMenuItem should not be focusable', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropdownButton<String>(
            value: 'enabled',
            onChanged: (_) {},
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(enabled: false, child: Text('disabled')),
              DropdownMenuItem<String>(value: 'enabled', child: Text('enabled')),
            ],
          ),
        ),
      ),
    );

    // Open dropdown.
    await tester.tap(find.text('enabled').hitTestable());
    await tester.pumpAndSettle();

    // The `FocusNode` of [disabledItem] should be `null` as enabled is false.
    final Element disabledItem = tester.element(find.text('disabled').hitTestable());
    expect(
      Focus.maybeOf(disabledItem),
      null,
      reason: 'Disabled menu item should not be able to request focus',
    );
  });

  testWidgets('Tapping a disabled DropdownMenuItem should not close DropdownButton', (
    WidgetTester tester,
  ) async {
    String? value = 'first';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => DropdownButton<String>(
              value: value,
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(enabled: false, child: Text('disabled')),
                DropdownMenuItem<String>(value: 'first', child: Text('first')),
                DropdownMenuItem<String>(value: 'second', child: Text('second')),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  value = newValue;
                });
              },
            ),
          ),
        ),
      ),
    );

    // Open dropdown.
    await tester.tap(find.text('first').hitTestable());
    await tester.pumpAndSettle();

    // Tap on a disabled item.
    await tester.tap(find.text('disabled').hitTestable());
    await tester.pumpAndSettle();

    // The dropdown should still be open, i.e., there should be one widget with 'second' text.
    expect(find.text('second').hitTestable(), findsOneWidget);
  });

  testWidgets('DropdownMenuItem alignment test', (WidgetTester tester) async {
    final Key buttonKey = UniqueKey();
    Widget buildFrame({AlignmentGeometry? buttonAlignment, AlignmentGeometry? menuAlignment}) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: DropdownButton<String>(
              key: buttonKey,
              alignment: buttonAlignment ?? AlignmentDirectional.centerStart,
              value: 'enabled',
              onChanged: (_) {},
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  alignment: buttonAlignment ?? AlignmentDirectional.centerStart,
                  enabled: false,
                  child: const Text('disabled'),
                ),
                DropdownMenuItem<String>(
                  alignment: buttonAlignment ?? AlignmentDirectional.centerStart,
                  value: 'enabled',
                  child: const Text('enabled'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildFrame());

    final RenderBox buttonBox = tester.renderObject(find.byKey(buttonKey));
    RenderBox selectedItemBox = tester.renderObject(find.text('enabled'));
    // Default to center-start aligned.
    expect(
      buttonBox.localToGlobal(Offset(0.0, buttonBox.size.height / 2.0)),
      selectedItemBox.localToGlobal(Offset(0.0, selectedItemBox.size.height / 2.0)),
    );

    await tester.pumpWidget(
      buildFrame(
        buttonAlignment: AlignmentDirectional.center,
        menuAlignment: AlignmentDirectional.center,
      ),
    );

    selectedItemBox = tester.renderObject(find.text('enabled'));
    // Should be center-center aligned, the icon size is 24.0 pixels.
    expect(
      buttonBox.localToGlobal(
        Offset((buttonBox.size.width - 24.0) / 2.0, buttonBox.size.height / 2.0),
      ),
      offsetMoreOrLessEquals(
        selectedItemBox.localToGlobal(
          Offset(selectedItemBox.size.width / 2.0, selectedItemBox.size.height / 2.0),
        ),
      ),
    );

    // Open dropdown.
    await tester.tap(find.text('enabled').hitTestable());
    await tester.pumpAndSettle();

    final RenderBox selectedItemBoxInMenu = tester
        .renderObjectList<RenderBox>(find.text('enabled'))
        .toList()[1];
    final Finder menu = find.byWidgetPredicate((Widget widget) {
      return widget.runtimeType.toString().startsWith('_DropdownMenu<');
    });
    final Rect menuRect = tester.getRect(menu);
    final Offset center = selectedItemBoxInMenu.localToGlobal(
      Offset(selectedItemBoxInMenu.size.width / 2.0, selectedItemBoxInMenu.size.height / 2.0),
    );

    expect(center.dx, moreOrLessEquals(menuRect.topCenter.dx));
    expect(
      center.dy,
      moreOrLessEquals(
        selectedItemBox
            .localToGlobal(
              Offset(selectedItemBox.size.width / 2.0, selectedItemBox.size.height / 2.0),
            )
            .dy,
      ),
    );
  });
}

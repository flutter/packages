// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'dropdown_button_tester.dart';

// TODO(navaronbracke): port tests from dropdown_button_form_field_test.dart to plain DropdownButton tests as well

void main() {
  Widget buildDropdownWithHint({
    required AlignmentDirectional alignment,
    required bool isExpanded,
    bool enableSelectedItemBuilder = false,
  }) {
    return buildFrame(
      useMaterial3: false,
      mediaSize: const Size(800, 600),
      child: buildDropdownButton(
        hint: const Text('hint'),
        itemHeight: 100.0,
        isExpanded: isExpanded,
        alignment: alignment,
        selectedItemBuilder: enableSelectedItemBuilder
            ? (BuildContext context) {
                return menuItems.map<Widget>((String item) {
                  return ColoredBox(color: const Color(0xFF00FF00), child: Text(item));
                }).toList();
              }
            : null,
      ),
    );
  }

  Future<void> checkDropdownButtonColor(WidgetTester tester, {Color? color}) async {
    const text = 'foo';
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: Material(
          child: DropdownButton<String>(
            dropdownColor: color,
            value: text,
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(value: text, child: Text(text)),
            ],
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.tap(find.text(text));
    await tester.pump();

    expect(
      find.ancestor(of: find.text(text).last, matching: find.byType(CustomPaint)).at(2),
      paints
        ..save()
        ..rrect()
        ..rrect()
        ..rrect()
        ..rrect(color: color ?? Colors.grey[50], hasMaskFilter: false),
    );
  }

  testWidgets('DropdownButton value should only appear in one menu item', (
    WidgetTester tester,
  ) async {
    final List<DropdownMenuItem<String>> itemsWithDuplicateValues = <String>['a', 'b', 'c', 'd']
        .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        })
        .toList();

    await expectLater(
      () => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownButton<String>(
              value: 'e',
              onChanged: (String? newValue) {},
              items: itemsWithDuplicateValues,
            ),
          ),
        ),
      ),
      throwsA(
        isAssertionError.having(
          (AssertionError error) => error.toString(),
          '.toString()',
          contains("There should be exactly one item with [DropdownButton]'s value"),
        ),
      ),
    );
  });

  testWidgets('DropdownButton - selectedItemBuilder builds custom buttons', (
    WidgetTester tester,
  ) async {
    const items = <String>['One', 'Two', 'Three'];
    String? selectedItem = items[0];

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return MaterialApp(
            home: Scaffold(
              body: DropdownButton<String>(
                value: selectedItem,
                onChanged: (String? string) => setState(() => selectedItem = string),
                selectedItemBuilder: (BuildContext context) {
                  var index = 0;
                  return items.map((String string) {
                    index += 1;
                    return Text('$string as an Arabic numeral: $index');
                  }).toList();
                },
                items: items.map((String string) {
                  return DropdownMenuItem<String>(value: string, child: Text(string));
                }).toList(),
              ),
            ),
          );
        },
      ),
    );

    expect(find.text('One as an Arabic numeral: 1'), findsOneWidget);
    await tester.tap(find.text('One as an Arabic numeral: 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();
    expect(find.text('Two as an Arabic numeral: 2'), findsOneWidget);
  });

  testWidgets('DropdownButton selectedItemBuilder length must match items length', (
    WidgetTester tester,
  ) async {
    // Regression test for https://github.com/flutter/flutter/issues/92773
    final List<DropdownMenuItem<String>> items = <String>['a', 'b']
        .map<DropdownMenuItem<String>>(
          (String value) => DropdownMenuItem<String>(value: value, child: Text(value)),
        )
        .toList();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox.shrink(
              child: DropdownButton<String>(
                onChanged: (_) {},
                items: items,
                selectedItemBuilder: (BuildContext context) {
                  return <Widget>[const Text('a')];
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      (tester.takeException() as AssertionError).message,
      'The selectedItemBuilder must return a list of widgets with the same length as the items list.\n'
      'Currently, selectedItemBuilder returns a list of length 1, but items has length 2.',
    );
  });

  testWidgets('BorderRadius property works properly for DropdownButton', (
    WidgetTester tester,
  ) async {
    const radius = 20.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: DropdownButton(
              isExpanded: true,
              borderRadius: const BorderRadius.all(Radius.circular(radius)),
              value: 'One',
              items: <String>['One', 'Two', 'Three', 'Four'].map<DropdownMenuItem<String>>((
                String value,
              ) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();

    expect(
      find.ancestor(of: find.text('One').last, matching: find.byType(CustomPaint)).at(2),
      paints
        ..save()
        ..rrect()
        ..rrect()
        ..rrect()
        ..rrect(rrect: const RRect.fromLTRBXY(0.0, 0.0, 800.0, 208.0, radius, radius)),
    );
  });

  testWidgets('BorderRadius property clips DropdownButton', (WidgetTester tester) async {
    const radius = 20.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: DropdownButton<String>(
              borderRadius: const BorderRadius.all(Radius.circular(radius)),
              value: 'One',
              items: <String>['One', 'Two', 'Three', 'Four'].map<DropdownMenuItem<String>>((
                String value,
              ) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();

    final RenderClipRRect renderClip = tester.allRenderObjects.whereType<RenderClipRRect>().first;
    expect(renderClip.borderRadius, const BorderRadius.all(Radius.circular(radius)));
  });

  testWidgets('DropdownButton in ListView', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/12053
    // Positions a DropdownButton at the left and right edges of the screen,
    // forcing it to be sized down to the viewport width
    const value = 'foo';
    final itemKey = UniqueKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ListView(
            children: <Widget>[
              DropdownButton<String>(
                value: value,
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(key: itemKey, value: value, child: const Text(value)),
                ],
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text(value));
    await tester.pump();
    final List<RenderBox> itemBoxes = tester
        .renderObjectList<RenderBox>(find.byKey(itemKey))
        .toList();
    expect(itemBoxes[0].localToGlobal(Offset.zero).dx, equals(0.0));
    expect(itemBoxes[1].localToGlobal(Offset.zero).dx, equals(16.0));
    expect(itemBoxes[1].size.width, equals(800.0 - 16.0 * 2));
  });

  testWidgets('DropdownButton does not allow duplicate item values', (WidgetTester tester) async {
    final List<DropdownMenuItem<String>> itemsWithDuplicateValues = <String>['a', 'b', 'c', 'c']
        .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        })
        .toList();

    await expectLater(
      () => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownButton<String>(
              value: 'c',
              onChanged: (String? newValue) {},
              items: itemsWithDuplicateValues,
            ),
          ),
        ),
      ),
      throwsA(
        isAssertionError.having(
          (AssertionError error) => error.toString(),
          '.toString()',
          contains("There should be exactly one item with [DropdownButton]'s value"),
        ),
      ),
    );
  });

  testWidgets('DropdownButton selected item color test', (WidgetTester tester) async {
    Widget build({
      ValueChanged<String?>? onChanged,
      String? value,
      Widget? hint,
      Widget? disabledHint,
    }) {
      return MaterialApp(
        theme: ThemeData(disabledColor: Colors.pink),
        home: Scaffold(
          body: Center(
            child: Column(
              children: <Widget>[
                DropdownButton<String>(
                  style: const TextStyle(color: Colors.yellow),
                  disabledHint: disabledHint,
                  hint: hint,
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(value: 'one', child: Text('one')),
                    DropdownMenuItem<String>(value: 'two', child: Text('two')),
                  ],
                  value: value,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      );
    }

    Color textColor(String text) {
      return tester.renderObject<RenderParagraph>(find.text(text)).text.style!.color!;
    }

    // The selected value should be displayed when the button is enabled.
    await tester.pumpWidget(build(onChanged: (_) {}, value: 'two'));
    // The dropdown icon and the selected menu item are vertically aligned.
    expect(tester.getCenter(find.text('two')).dy, tester.getCenter(find.byType(Icon)).dy);
    // Selected item has a normal color from [DropdownButton.style]
    // when the button is enabled.
    expect(textColor('two'), Colors.yellow);

    // The selected value should be displayed when the button is disabled.
    await tester.pumpWidget(build(value: 'two'));
    expect(tester.getCenter(find.text('two')).dy, tester.getCenter(find.byType(Icon)).dy);
    // Selected item has a disabled color from [theme.disabledColor]
    // when the button is disable.
    expect(textColor('two'), Colors.pink);
  });

  testWidgets('DropdownButton uses default color when expanded', (WidgetTester tester) async {
    await checkDropdownButtonColor(tester);
  });

  testWidgets('DropdownButton uses dropdownColor when expanded', (WidgetTester tester) async {
    await checkDropdownButtonColor(tester, color: const Color.fromRGBO(120, 220, 70, 0.8));
  });

  testWidgets('DropdownButton can be focused, and has focusColor', (WidgetTester tester) async {
    tester.binding.focusManager.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    final buttonKey = UniqueKey();
    final focusNode = FocusNode(debugLabel: 'DropdownButton');
    addTearDown(focusNode.dispose);

    void onChanged<T>(T _) {}

    await tester.pumpWidget(
      buildFrame(
        useMaterial3: false,
        child: buildDropdownButton(
          buttonKey: buttonKey,
          onChanged: onChanged,
          focusNode: focusNode,
          autofocus: true,
        ),
      ),
    );
    await tester.pumpAndSettle(); // Pump a frame for autofocus to take effect.
    expect(focusNode.hasPrimaryFocus, isTrue);
    expect(
      find.byType(Material),
      paints..rect(
        rect: const Rect.fromLTRB(348.0, 276.0, 452.0, 324.0),
        color: const Color(0x1F000000),
      ),
    );

    await tester.pumpWidget(
      buildFrame(
        useMaterial3: false,
        child: buildDropdownButton(
          buttonKey: buttonKey,
          onChanged: onChanged,
          focusNode: focusNode,
          focusColor: const Color(0xFF00FF00),
        ),
      ),
    );
    await tester.pumpAndSettle(); // Pump a frame for autofocus to take effect.
    expect(
      find.byType(Material),
      paints..rect(
        rect: const Rect.fromLTRB(348.0, 276.0, 452.0, 324.0),
        color: const Color(0x1F00FF00),
      ),
    );
  });

  testWidgets('DropdownButton does not crash at zero area', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox.shrink(
              child: DropdownButton<String>(
                value: 'a',
                onChanged: (_) {},
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(value: 'a', child: Text('a')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(DropdownButton<String>)), Size.zero);
  });

  testWidgets('DropdownButton does not close when barrier dismissible set to false', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropdownButton<String>(
            value: 'first',
            barrierDismissible: false,
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(enabled: false, child: Text('disabled')),
              DropdownMenuItem<String>(value: 'first', child: Text('first')),
              DropdownMenuItem<String>(value: 'second', child: Text('second')),
            ],
            onChanged: (_) {},
          ),
        ),
      ),
    );

    // Open dropdown.
    await tester.tap(find.text('first').hitTestable());
    await tester.pumpAndSettle();

    // Tap on the barrier.
    await tester.tapAt(const Offset(400, 400));
    await tester.pumpAndSettle();

    // The dropdown should still be open, i.e., there should be one widget with 'second' text.
    expect(find.text('second'), findsOneWidget);
  });

  // This is a regression test for https://github.com/flutter/flutter/issues/70294.
  testWidgets('DropdownButton should highlight previous selected item when reopening on mobile', (
    WidgetTester tester,
  ) async {
    final Color selectedColor = Colors.black.withValues(alpha: 0.12);
    var currentValue = 'one';
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(focusColor: selectedColor),
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return DropdownButton<String>(
                  value: currentValue,
                  items: menuItems
                      .map(
                        (String item) => DropdownMenuItem<String>(value: item, child: Text(item)),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      currentValue = newValue!;
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    // Make sure the current value of dropdown is the first one of items list menuItems.
    expect(find.text('one'), findsOne);

    // Tap to open the dropdown.
    await tester.tap(find.text('one'));
    await tester.pumpAndSettle();

    // Select the second item from the dropdown list.
    await tester.tap(find.text('two'));
    await tester.pumpAndSettle();

    // Make sure the current item of dropdown is the second item of items list menuItems.
    expect(find.text('two'), findsOneWidget);

    // Tap to reopen the dropdown.
    await tester.tap(find.text('two'));
    await tester.pumpAndSettle();

    // Make sure the current selected item is highlighted with selectedColor.
    final Ink selectedItemInk = tester.widget<Ink>(
      find.ancestor(of: find.text('two'), matching: find.byType(Ink)).first,
    );
    final decoration = selectedItemInk.decoration! as BoxDecoration;
    expect(decoration.color, selectedColor);
  }, variant: TargetPlatformVariant.mobile());

  testWidgets('DropdownButton closes when barrier is tapped by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DropdownButton<String>(
            value: 'first',
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(enabled: false, child: Text('disabled')),
              DropdownMenuItem<String>(value: 'first', child: Text('first')),
              DropdownMenuItem<String>(value: 'second', child: Text('second')),
            ],
            onChanged: (_) {},
          ),
        ),
      ),
    );

    // Open dropdown.
    await tester.tap(find.text('first').hitTestable());
    await tester.pumpAndSettle();

    // Tap on the barrier.
    await tester.tapAt(const Offset(400, 400));
    await tester.pumpAndSettle();

    // The dropdown should be closed, i.e., there should be no widget with 'second' text.
    expect(find.text('second'), findsNothing);
  });

  testWidgets('Size of DropdownButton with padding', (WidgetTester tester) async {
    const double padVertical = 5;
    const double padHorizontal = 10;
    final Key buttonKey = UniqueKey();
    EdgeInsets? padding;

    Widget build() => buildFrame(
      child: buildDropdownButton(buttonKey: buttonKey, onChanged: (_) {}, padding: padding),
    );

    await tester.pumpWidget(build());
    final RenderBox buttonBoxNoPadding = tester.renderObject<RenderBox>(find.byKey(buttonKey));
    assert(buttonBoxNoPadding.attached);
    final noPaddingSize = Size.copy(buttonBoxNoPadding.size);

    padding = const EdgeInsets.symmetric(vertical: padVertical, horizontal: padHorizontal);
    await tester.pumpWidget(build());
    final RenderBox buttonBoxPadded = tester.renderObject<RenderBox>(find.byKey(buttonKey));
    assert(buttonBoxPadded.attached);
    final paddedSize = Size.copy(buttonBoxPadded.size);

    // dropdowns with padding should be that much larger than with no padding
    expect(noPaddingSize.height, equals(paddedSize.height - padVertical * 2));
    expect(noPaddingSize.width, equals(paddedSize.width - padHorizontal * 2));
  });

  testWidgets('DropdownButton hint alignment', (WidgetTester tester) async {
    const hintText = 'hint';

    // AlignmentDirectional.centerStart (default)
    await tester.pumpWidget(
      buildDropdownWithHint(alignment: AlignmentDirectional.centerStart, isExpanded: false),
    );
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dx, 348.0);
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dy, 292.0);
    // AlignmentDirectional.topStart
    await tester.pumpWidget(
      buildDropdownWithHint(alignment: AlignmentDirectional.topStart, isExpanded: false),
    );
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dx, 348.0);
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dy, 250.0);
    // AlignmentDirectional.bottomStart
    await tester.pumpWidget(
      buildDropdownWithHint(alignment: AlignmentDirectional.bottomStart, isExpanded: false),
    );
    expect(tester.getBottomLeft(find.text(hintText, skipOffstage: false)).dx, 348.0);
    expect(tester.getBottomLeft(find.text(hintText, skipOffstage: false)).dy, 350.0);
    // AlignmentDirectional.center
    await tester.pumpWidget(
      buildDropdownWithHint(alignment: AlignmentDirectional.center, isExpanded: false),
    );
    expect(tester.getCenter(find.text(hintText, skipOffstage: false)).dx, 388.0);
    expect(tester.getCenter(find.text(hintText, skipOffstage: false)).dy, 300.0);
    // AlignmentDirectional.topEnd
    await tester.pumpWidget(
      buildDropdownWithHint(alignment: AlignmentDirectional.topEnd, isExpanded: false),
    );
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dx, 428.0);
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dy, 250.0);
    // AlignmentDirectional.centerEnd
    await tester.pumpWidget(
      buildDropdownWithHint(alignment: AlignmentDirectional.centerEnd, isExpanded: false),
    );
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dx, 428.0);
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dy, 292.0);
    // AlignmentDirectional.bottomEnd
    await tester.pumpWidget(
      buildDropdownWithHint(alignment: AlignmentDirectional.bottomEnd, isExpanded: false),
    );
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dx, 428.0);
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dy, 334.0);

    // DropdownButton with `isExpanded: true`
    // AlignmentDirectional.centerStart (default)
    await tester.pumpWidget(
      buildDropdownWithHint(alignment: AlignmentDirectional.centerStart, isExpanded: true),
    );
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dx, 0.0);
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dy, 292.0);
    // AlignmentDirectional.topStart
    await tester.pumpWidget(
      buildDropdownWithHint(alignment: AlignmentDirectional.topStart, isExpanded: true),
    );
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dx, 0.0);
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dy, 250.0);
    // AlignmentDirectional.bottomStart
    await tester.pumpWidget(
      buildDropdownWithHint(alignment: AlignmentDirectional.bottomStart, isExpanded: true),
    );
    expect(tester.getBottomLeft(find.text(hintText, skipOffstage: false)).dx, 0.0);
    expect(tester.getBottomLeft(find.text(hintText, skipOffstage: false)).dy, 350.0);
    // AlignmentDirectional.center
    await tester.pumpWidget(
      buildDropdownWithHint(alignment: AlignmentDirectional.center, isExpanded: true),
    );
    expect(tester.getCenter(find.text(hintText, skipOffstage: false)).dx, 388.0);
    expect(tester.getCenter(find.text(hintText, skipOffstage: false)).dy, 300.0);
    // AlignmentDirectional.topEnd
    await tester.pumpWidget(
      buildDropdownWithHint(alignment: AlignmentDirectional.topEnd, isExpanded: true),
    );
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dx, 776.0);
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dy, 250.0);
    // AlignmentDirectional.centerEnd
    await tester.pumpWidget(
      buildDropdownWithHint(alignment: AlignmentDirectional.centerEnd, isExpanded: true),
    );
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dx, 776.0);
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dy, 292.0);
    // AlignmentDirectional.bottomEnd
    await tester.pumpWidget(
      buildDropdownWithHint(alignment: AlignmentDirectional.bottomEnd, isExpanded: true),
    );
    expect(tester.getBottomRight(find.text(hintText, skipOffstage: false)).dx, 776.0);
    expect(tester.getBottomRight(find.text(hintText, skipOffstage: false)).dy, 350.0);
  });

  testWidgets('DropdownButton hint alignment with selectedItemBuilder', (
    WidgetTester tester,
  ) async {
    const hintText = 'hint';

    // AlignmentDirectional.centerStart (default)
    await tester.pumpWidget(
      buildDropdownWithHint(
        alignment: AlignmentDirectional.centerStart,
        isExpanded: false,
        enableSelectedItemBuilder: true,
      ),
    );
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dx, 348.0);
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dy, 292.0);
    // AlignmentDirectional.topStart
    await tester.pumpWidget(
      buildDropdownWithHint(
        alignment: AlignmentDirectional.topStart,
        isExpanded: false,
        enableSelectedItemBuilder: true,
      ),
    );
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dx, 348.0);
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dy, 250.0);
    // AlignmentDirectional.bottomStart
    await tester.pumpWidget(
      buildDropdownWithHint(
        alignment: AlignmentDirectional.bottomStart,
        isExpanded: false,
        enableSelectedItemBuilder: true,
      ),
    );
    expect(tester.getBottomLeft(find.text(hintText, skipOffstage: false)).dx, 348.0);
    expect(tester.getBottomLeft(find.text(hintText, skipOffstage: false)).dy, 350.0);
    // AlignmentDirectional.center
    await tester.pumpWidget(
      buildDropdownWithHint(
        alignment: AlignmentDirectional.center,
        isExpanded: false,
        enableSelectedItemBuilder: true,
      ),
    );
    expect(tester.getCenter(find.text(hintText, skipOffstage: false)).dx, 388.0);
    expect(tester.getCenter(find.text(hintText, skipOffstage: false)).dy, 300.0);
    // AlignmentDirectional.topEnd
    await tester.pumpWidget(
      buildDropdownWithHint(
        alignment: AlignmentDirectional.topEnd,
        isExpanded: false,
        enableSelectedItemBuilder: true,
      ),
    );
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dx, 428.0);
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dy, 250.0);
    // AlignmentDirectional.centerEnd
    await tester.pumpWidget(
      buildDropdownWithHint(
        alignment: AlignmentDirectional.centerEnd,
        isExpanded: false,
        enableSelectedItemBuilder: true,
      ),
    );
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dx, 428.0);
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dy, 292.0);
    // AlignmentDirectional.bottomEnd
    await tester.pumpWidget(
      buildDropdownWithHint(
        alignment: AlignmentDirectional.bottomEnd,
        isExpanded: false,
        enableSelectedItemBuilder: true,
      ),
    );
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dx, 428.0);
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dy, 334.0);

    // DropdownButton with `isExpanded: true`
    // AlignmentDirectional.centerStart (default)
    await tester.pumpWidget(
      buildDropdownWithHint(
        alignment: AlignmentDirectional.centerStart,
        isExpanded: true,
        enableSelectedItemBuilder: true,
      ),
    );
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dx, 0.0);
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dy, 292.0);
    // AlignmentDirectional.topStart
    await tester.pumpWidget(
      buildDropdownWithHint(
        alignment: AlignmentDirectional.topStart,
        isExpanded: true,
        enableSelectedItemBuilder: true,
      ),
    );
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dx, 0.0);
    expect(tester.getTopLeft(find.text(hintText, skipOffstage: false)).dy, 250.0);
    // AlignmentDirectional.bottomStart
    await tester.pumpWidget(
      buildDropdownWithHint(
        alignment: AlignmentDirectional.bottomStart,
        isExpanded: true,
        enableSelectedItemBuilder: true,
      ),
    );
    expect(tester.getBottomLeft(find.text(hintText, skipOffstage: false)).dx, 0.0);
    expect(tester.getBottomLeft(find.text(hintText, skipOffstage: false)).dy, 350.0);
    // AlignmentDirectional.center
    await tester.pumpWidget(
      buildDropdownWithHint(
        alignment: AlignmentDirectional.center,
        isExpanded: true,
        enableSelectedItemBuilder: true,
      ),
    );
    expect(tester.getCenter(find.text(hintText, skipOffstage: false)).dx, 388.0);
    expect(tester.getCenter(find.text(hintText, skipOffstage: false)).dy, 300.0);
    // AlignmentDirectional.topEnd
    await tester.pumpWidget(
      buildDropdownWithHint(
        alignment: AlignmentDirectional.topEnd,
        isExpanded: true,
        enableSelectedItemBuilder: true,
      ),
    );
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dx, 776.0);
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dy, 250.0);
    // AlignmentDirectional.centerEnd
    await tester.pumpWidget(
      buildDropdownWithHint(
        alignment: AlignmentDirectional.centerEnd,
        isExpanded: true,
        enableSelectedItemBuilder: true,
      ),
    );
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dx, 776.0);
    expect(tester.getTopRight(find.text(hintText, skipOffstage: false)).dy, 292.0);
    // AlignmentDirectional.bottomEnd
    await tester.pumpWidget(
      buildDropdownWithHint(
        alignment: AlignmentDirectional.bottomEnd,
        isExpanded: true,
        enableSelectedItemBuilder: true,
      ),
    );
    expect(tester.getBottomRight(find.text(hintText, skipOffstage: false)).dx, 776.0);
    expect(tester.getBottomRight(find.text(hintText, skipOffstage: false)).dy, 350.0);
  });

  // Regression test for https://github.com/flutter/flutter/issues/92438
  testWidgets('DropdownButton does not throw due to the double precision', (
    WidgetTester tester,
  ) async {
    const value = 'One';
    const itemHeight = 77.701;
    final List<DropdownMenuItem<String>> menuItems = <String>[value, 'Two', 'Free']
        .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        })
        .toList();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: DropdownButton<String>(
              value: value,
              itemHeight: itemHeight,
              onChanged: (_) {},
              items: menuItems,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text(value));
    await tester.pumpAndSettle();

    expect(tester.takeException(), null);
  });

  // Regression test for https://github.com/flutter/flutter/issues/88574
  testWidgets("DropdownButton specifying itemHeight affects popup menu items' height", (
    WidgetTester tester,
  ) async {
    const value = 'One';
    const double itemHeight = 80;
    final List<DropdownMenuItem<String>> menuItems = <String>[value, 'Two', 'Free', 'Four']
        .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        })
        .toList();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: DropdownButton<String>(
              value: value,
              itemHeight: itemHeight,
              onChanged: (_) {},
              items: menuItems,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text(value));
    await tester.pumpAndSettle();

    for (final item in menuItems) {
      final Iterable<Element> elements = tester.elementList(find.byWidget(item));
      for (final element in elements) {
        expect(element.size!.height, itemHeight);
      }
    }
  });
}

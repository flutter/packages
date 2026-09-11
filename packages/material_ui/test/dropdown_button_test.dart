// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// TODO(navaronbracke): port tests from dropdown_button_form_field_test.dart to plain DropdownButton tests as well

void main() {
  const menuItems = <String>['one', 'two', 'three', 'four'];

  Widget buildDropdownButton({
    Key? buttonKey,
    String? initialValue = 'two',
    ValueChanged<String?>? onChanged,
    VoidCallback? onTap,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 24.0,
    bool isDense = false,
    bool isExpanded = false,
    Widget? hint,
    Widget? disabledHint,
    Widget? underline,
    List<String>? items = menuItems,
    List<Widget> Function(BuildContext)? selectedItemBuilder,
    double? itemHeight = kMinInteractiveDimension,
    double? menuWidth,
    AlignmentDirectional alignment = AlignmentDirectional.centerStart,
    FocusNode? focusNode,
    bool autofocus = false,
    Color? focusColor,
    Color? dropdownColor,
    double? menuMaxHeight,
    EdgeInsetsGeometry? padding,
  }) {
    final List<DropdownMenuItem<String>>? listItems = items?.map<DropdownMenuItem<String>>((
      String item,
    ) {
      return DropdownMenuItem<String>(
        key: ValueKey<String>(item),
        value: item,
        child: Text(item, key: ValueKey<String>('${item}Text')),
      );
    }).toList();

    return DropdownButton<String>(
      key: buttonKey,
      value: initialValue,
      hint: hint,
      disabledHint: disabledHint,
      onChanged: onChanged,
      onTap: onTap,
      icon: icon,
      iconSize: iconSize,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor: iconEnabledColor,
      isDense: isDense,
      isExpanded: isExpanded,
      underline: underline,
      focusNode: focusNode,
      autofocus: autofocus,
      focusColor: focusColor,
      dropdownColor: dropdownColor,
      items: listItems,
      selectedItemBuilder: selectedItemBuilder,
      itemHeight: itemHeight,
      menuWidth: menuWidth,
      alignment: alignment,
      menuMaxHeight: menuMaxHeight,
      padding: padding,
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
    // Selected item has a normal color from [DropdownButtonFormField.style]
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
}

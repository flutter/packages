// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dynamic_layouts/dynamic_layouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'DynamicGridView generates children and checks if they are layed out',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      10,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 95 : 180,
        child: Text('Item $index'),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView(
            gridDelegate: const SliverGridDelegateWithWrapping(),
            children: children,
          ),
        ),
      ),
    );

    // Check that the children are in the tree
    for (int i = 0; i < 10; i++) {
      expect(find.text('Item $i'), findsOneWidget);
    }
    // Check that the children are in the right position
    expect(tester.getTopLeft(find.text('Item 0')), Offset.zero);
    expect(tester.getTopLeft(find.text('Item 1')), const Offset(95.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 2')), const Offset(275.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 3')), const Offset(370.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 4')), const Offset(550.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 5')), const Offset(0.0, 100.0));
    expect(tester.getTopLeft(find.text('Item 6')), const Offset(180.0, 100.0));
    expect(tester.getTopLeft(find.text('Item 7')), const Offset(275.0, 100.0));
    expect(tester.getTopLeft(find.text('Item 8')), const Offset(455.0, 100.0));
    expect(tester.getTopLeft(find.text('Item 9')), const Offset(550.0, 100.0));
  });

  testWidgets(
      'Test for wrap that generates children and checks if they are layed out',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      10,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 95 : 180,
        child: Text('Item $index'),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.wrap(
            children: children,
          ),
        ),
      ),
    );
    for (int i = 0; i < 10; i++) {
      expect(find.text('Item $i'), findsOneWidget);
    }
    // Check that the children are in the right position
    expect(tester.getTopLeft(find.text('Item 0')), Offset.zero);
    expect(tester.getTopLeft(find.text('Item 1')), const Offset(95.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 2')), const Offset(275.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 3')), const Offset(370.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 4')), const Offset(550.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 5')), const Offset(0.0, 100.0));
    expect(tester.getTopLeft(find.text('Item 6')), const Offset(180.0, 100.0));
    expect(tester.getTopLeft(find.text('Item 7')), const Offset(275.0, 100.0));
    expect(tester.getTopLeft(find.text('Item 8')), const Offset(455.0, 100.0));
    expect(tester.getTopLeft(find.text('Item 9')), const Offset(550.0, 100.0));
  });

  testWidgets('Test for wrap to be laying child dynamically',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      20,
      (int index) => SizedBox(
        height: index.isEven ? 1000 : 50,
        width: index.isEven ? 95 : 180,
        child: Text('Item $index'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.builder(
            itemCount: children.length,
            gridDelegate: const SliverGridDelegateWithWrapping(),
            itemBuilder: (BuildContext context, int index) => children[index],
          ),
        ),
      ),
    );
    for (int i = 0; i < 5; i++) {
      expect(find.text('Item $i'), findsOneWidget);
    }
    // Check that the children are in the right position
    expect(tester.getTopLeft(find.text('Item 0')), Offset.zero);
    expect(tester.getTopLeft(find.text('Item 1')), const Offset(95.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 2')), const Offset(275.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 3')), const Offset(370.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 4')), const Offset(550.0, 0.0));
    expect(find.text('Item 5'), findsNothing);
    await tester.scrollUntilVisible(find.text('Item 19'), 500.0);
    await tester.pumpAndSettle();

    expect(find.text('Item 18'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Item 18')), const Offset(455.0, 0.0));

    expect(find.text('Item 0'), findsNothing);
    expect(find.text('Item 1'), findsNothing);
    expect(find.text('Item 2'), findsNothing);
    expect(find.text('Item 3'), findsNothing);
  });

  testWidgets(
      'Test for DynamicGridView.wrap to scrollDirection Axis.horizontal',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      20,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 100 : 180,
        child: Text('Item $index'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.wrap(
            scrollDirection: Axis.horizontal,
            children: children,
          ),
        ),
      ),
    );
    for (int i = 0; i < 20; i++) {
      expect(find.text('Item $i'), findsOneWidget);
    }
    // Check that the children are in the right position
    double dy = 0, dx = 0;
    for (int i = 0; i < 20; i++) {
      if (dy >= 600.0) {
        dy = 0.0;
        dx += 180.0;
      }
      expect(tester.getTopLeft(find.text('Item $i')), Offset(dx, dy));
      dy += i.isEven ? 100 : 50;
    }
  });

  testWidgets('Test DynamicGridView.builder for GridView.reverse to true',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      10,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 100 : 180,
        child: Text('Item $index'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.builder(
            reverse: true,
            itemCount: children.length,
            gridDelegate: const SliverGridDelegateWithWrapping(),
            itemBuilder: (BuildContext context, int index) => children[index],
          ),
        ),
      ),
    );
    for (int i = 0; i < 10; i++) {
      expect(find.text('Item $i'), findsOneWidget);
    }
    double dx = 0.0, dy = 600.0;
    for (int i = 0; i < 10; i++) {
      if (dx >= 600.0) {
        dx = 0.0;
        dy -= 100.0;
      }
      expect(tester.getBottomLeft(find.text('Item $i')), Offset(dx, dy));
      dx += i.isEven ? 100 : 180;
    }
  });

  testWidgets('DynamicGridView.wrap for GridView.reverse to true',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      20,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 100 : 180,
        child: Text('Item $index'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.wrap(
            reverse: true,
            children: children,
          ),
        ),
      ),
    );
    for (int i = 0; i < 20; i++) {
      expect(find.text('Item $i'), findsOneWidget);
    }
    // Check that the children are in the right position
    double dx = 0.0, dy = 600.0;
    for (int i = 0; i < 20; i++) {
      if (dx >= 600.0) {
        dx = 0.0;
        dy -= 100.0;
      }
      expect(tester.getBottomLeft(find.text('Item $i')), Offset(dx, dy));
      dx += i.isEven ? 100 : 180;
    }
  });

  testWidgets('DynamicGridView.wrap dismiss keyboard onDrag test',
      (WidgetTester tester) async {
    final List<FocusNode> focusNodes =
        List<FocusNode>.generate(50, (int i) => FocusNode());

    await tester.pumpWidget(
      textFieldBoilerplate(
        child: GridView.extent(
          padding: EdgeInsets.zero,
          maxCrossAxisExtent: 300,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: focusNodes.map((FocusNode focusNode) {
            return Container(
              height: 50,
              color: Colors.green,
              child: TextField(
                focusNode: focusNode,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    final Finder finder = find.byType(TextField).first;
    final TextField textField = tester.widget(finder);
    await tester.showKeyboard(finder);
    expect(textField.focusNode!.hasFocus, isTrue);

    await tester.drag(finder, const Offset(0.0, -40.0));
    await tester.pumpAndSettle();
    expect(textField.focusNode!.hasFocus, isFalse);
  });

  testWidgets('ChildMainAxisExtent & childCrossAxisExtent are respected',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      10,
      (int index) => SizedBox(
        key: Key(index.toString()),
        child: Text('Item $index'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.builder(
            gridDelegate: const SliverGridDelegateWithWrapping(
              childMainAxisExtent: 150,
              childCrossAxisExtent: 200,
            ),
            itemCount: children.length,
            itemBuilder: (BuildContext context, int index) => children[index],
          ),
        ),
      ),
    );

    for (int i = 0; i < 10; i++) {
      final Size sizeOfCurrent = tester.getSize(find.byKey(Key('$i')));
      expect(sizeOfCurrent.width, equals(200));
      expect(sizeOfCurrent.height, equals(150));
    }
    // Check that the children are in the right position
    double dy = 0, dx = 0;
    for (int i = 0; i < 10; i++) {
      if (dx > 600.0) {
        dx = 0.0;
        dy += 150.0;
      }
      expect(tester.getTopLeft(find.text('Item $i')), Offset(dx, dy));
      dx += 200;
    }
  });

  testWidgets('ChildMainAxisExtent is respected', (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      10,
      (int index) => SizedBox(
        key: Key(index.toString()),
        width: index.isEven ? 100 : 180,
        child: Text('Item $index'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.builder(
            gridDelegate: const SliverGridDelegateWithWrapping(
              childMainAxisExtent: 200,
            ),
            itemCount: children.length,
            itemBuilder: (BuildContext context, int index) => children[index],
          ),
        ),
      ),
    );

    for (int i = 0; i < 10; i++) {
      final Size sizeOfCurrent = tester.getSize(find.byKey(Key('$i')));
      expect(sizeOfCurrent.height, equals(200));
    }
    // Check that the children are in the right position
    double dy = 0, dx = 0;
    for (int i = 0; i < 10; i++) {
      if (dx >= 600.0) {
        dx = 0.0;
        dy += 200.0;
      }
      expect(tester.getTopLeft(find.text('Item $i')), Offset(dx, dy));
      dx += i.isEven ? 100 : 180;
    }
  });

  testWidgets('ChildCrossAxisExtent is respected', (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      10,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        key: Key(index.toString()),
        child: Text('Item $index'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.builder(
            gridDelegate: const SliverGridDelegateWithWrapping(
              childCrossAxisExtent: 150,
            ),
            itemCount: children.length,
            itemBuilder: (BuildContext context, int index) => children[index],
          ),
        ),
      ),
    );

    for (int i = 0; i < 10; i++) {
      final Size sizeOfCurrent = tester.getSize(find.byKey(Key('$i')));
      expect(sizeOfCurrent.width, equals(150));
    }
    // Check that the children are in the right position
    double dy = 0, dx = 0;
    for (int i = 0; i < 10; i++) {
      if (dx >= 750.0) {
        dx = 0.0;
        dy += 100.0;
      }
      expect(tester.getTopLeft(find.text('Item $i')), Offset(dx, dy));
      dx += 150;
    }
  });

  testWidgets('Test wrap to see nothing affected if elements are deleted.',
      (WidgetTester tester) async {
    late StateSetter stateSetter;
    final List<Widget> children = List<Widget>.generate(
      10,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 100 : 180,
        child: Text('Item $index'),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            stateSetter = setState;
            return DynamicGridView.builder(
              gridDelegate: const SliverGridDelegateWithWrapping(),
              itemCount: children.length,
              itemBuilder: (BuildContext context, int index) => children[index],
            );
          }),
        ),
      ),
    );
    // See if the children are in the tree.
    for (int i = 0; i < 10; i++) {
      expect(find.text('Item $i'), findsOneWidget);
    }
    // See if they are layed properly.
    double dx = 0.0, dy = 0.0;
    for (int i = 0; i < 10; i++) {
      if (dx >= 600) {
        dx = 0.0;
        dy += 100;
      }
      expect(tester.getTopLeft(find.text('Item $i')), Offset(dx, dy));
      dx += i.isEven ? 100 : 180;
    }
    stateSetter(() {
      // Remove children
      children.removeAt(0);
      children.removeAt(8);
      children.removeAt(5);
    });

    await tester.pump();

    // See if the proper widgets are in the tree.
    expect(find.text('Item 0'), findsNothing);
    expect(find.text('Item 6'), findsNothing);
    expect(find.text('Item 9'), findsNothing);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
    expect(find.text('Item 4'), findsOneWidget);
    expect(find.text('Item 5'), findsOneWidget);
    expect(find.text('Item 7'), findsOneWidget);
    expect(find.text('Item 8'), findsOneWidget);

    // See if the proper widgets are in the tree.
    expect(tester.getTopLeft(find.text('Item 1')), Offset.zero);
    expect(tester.getTopLeft(find.text('Item 2')), const Offset(180.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 3')), const Offset(280.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 4')), const Offset(460.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 5')), const Offset(560.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 7')), const Offset(0.0, 100.0));
    expect(tester.getTopLeft(find.text('Item 8')), const Offset(180.0, 100.0));
  });

  testWidgets('Test wrap in Axis.vertical direction',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      5,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 100 : 180,
        child: Text('Item $index'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.builder(
            itemCount: children.length,
            gridDelegate: const SliverGridDelegateWithWrapping(),
            itemBuilder: (BuildContext context, int index) => children[index],
          ),
        ),
      ),
    );

    // Change the size of the screen
    await tester.binding.setSurfaceSize(const Size(500, 100));
    await tester.pumpAndSettle();
    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Item 0')), Offset.zero);
    expect(tester.getTopLeft(find.text('Item 1')), const Offset(100.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 2')), const Offset(280.0, 0.0));
    expect(find.text('Item 3'), findsNothing);
    expect(find.text('Item 4'), findsNothing);
    await tester.binding.setSurfaceSize(const Size(560, 100));
    await tester.pumpAndSettle();
    expect(find.text('Item 3'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Item 3')), const Offset(380.0, 0.0));
    expect(find.text('Item 4'), findsNothing);
    await tester.binding.setSurfaceSize(const Size(280, 100));
    // resets the screen to its original size after the test end
    // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
    // ignore: deprecated_member_use
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    await tester.pumpAndSettle();
    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Item 0')), Offset.zero);
    expect(tester.getTopLeft(find.text('Item 1')), const Offset(100.0, 0.0));
    expect(find.text('Item 2'), findsNothing);
    expect(find.text('Item 3'), findsNothing);
    expect(find.text('Item 4'), findsNothing);
  });

  testWidgets('Test wrap in Axis.horizontal direction',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      5,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 100 : 180,
        child: Text('Item $index'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.wrap(
            scrollDirection: Axis.horizontal,
            children: children,
          ),
        ),
      ),
    );

    // Change the size of the screen
    await tester.binding.setSurfaceSize(const Size(180, 150));
    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Item 0')), Offset.zero);
    expect(tester.getTopLeft(find.text('Item 1')), const Offset(0.0, 100.0));

    expect(find.text('Item 2'), findsNothing);
    expect(find.text('Item 3'), findsNothing);

    await tester.binding.setSurfaceSize(const Size(180, 400));
    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
    expect(find.text('Item 4'), findsOneWidget);

    expect(tester.getTopLeft(find.text('Item 0')), Offset.zero);
    expect(tester.getTopLeft(find.text('Item 1')), const Offset(0.0, 100.0));
    expect(tester.getTopLeft(find.text('Item 2')), const Offset(0.0, 150.0));
    expect(tester.getTopLeft(find.text('Item 3')), const Offset(0.0, 250.0));
    expect(tester.getTopLeft(find.text('Item 4')), const Offset(0.0, 300.0));

    await tester.binding.setSurfaceSize(const Size(560, 100));
    // resets the screen to its original size after the test end
    // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
    // ignore: deprecated_member_use
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
    expect(find.text('Item 4'), findsNothing);

    expect(tester.getTopLeft(find.text('Item 0')), Offset.zero);
    expect(tester.getTopLeft(find.text('Item 1')), const Offset(100.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 2')), const Offset(280.0, 0.0));
    expect(tester.getTopLeft(find.text('Item 3')), const Offset(380.0, 0.0));
  });
}

Widget textFieldBoilerplate({required Widget child}) {
  return MaterialApp(
    home: Localizations(
      locale: const Locale('en', 'US'),
      delegates: <LocalizationsDelegate<dynamic>>[
        WidgetsLocalizationsDelegate(),
        MaterialLocalizationsDelegate(),
      ],
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(800.0, 600.0)),
          child: Center(
            child: Material(
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

class MaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      DefaultMaterialLocalizations.load(locale);

  @override
  bool shouldReload(MaterialLocalizationsDelegate old) => false;
}

class WidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      DefaultWidgetsLocalizations.load(locale);

  @override
  bool shouldReload(WidgetsLocalizationsDelegate old) => false;
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dynamic_layouts/dynamic_layouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'DynamicGridViw generates children and checks if they are layed out',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      10,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 95 : 180,
        child: Center(child: Text('Item $index')),
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
    expect(find.text('Item 0'), findsOneWidget);
    for (int i = 0; i < 10; i++) {
      expect(find.text('Item $i'), findsOneWidget);
    }
  });

  testWidgets(
      'Test for wrap that generates children and checks if they are layed out',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      10,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 95 : 180,
        child: Center(child: Text('Item $index')),
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
  });

  testWidgets('Test for wrap to be laying child dynamically',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      20,
      (int index) => SizedBox(
        height: index.isEven ? 1000 : 50,
        width: index.isEven ? 95 : 180,
        child: Center(child: Text('Item $index')),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.builder(
              itemCount: children.length,
              gridDelegate: const SliverGridDelegateWithWrapping(),
              itemBuilder: (
                BuildContext context,
                int index,
              ) =>
                  children[index]),
        ),
      ),
    );
    for (int i = 0; i < 5; i++) {
      expect(find.text('Item $i'), findsOneWidget);
    }

    expect(find.text('Item 5'), findsNothing);
    await tester.scrollUntilVisible(find.text('Item 19'), 500.0);
    await tester.pumpAndSettle();
    expect(find.text('Item 18'), findsOneWidget);
    expect(find.text('Item 0'), findsNothing);
    expect(find.text('Item 1'), findsNothing);
    expect(find.text('Item 2'), findsNothing);
    expect(find.text('Item 3'), findsNothing);
  });

  testWidgets('Test for DynamicGridView.wrap to scrollDirection Axis.horizontal',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      20,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 100 : 180,
        child: Center(child: Text('Item $index')),
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
  });

  testWidgets('Test DynamicGridView.builder for GridView.reverse to true',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      20,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 100 : 180,
        child: Center(child: Text('Item $index')),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.builder(
            reverse: true,
            itemCount: children.length,
            gridDelegate: const SliverGridDelegateWithWrapping(),
            itemBuilder: (
              BuildContext context,
              int index,
            ) =>
                children[index],
          ),
        ),
      ),
    );
    for (int i = 0; i < 20; i++) {
      expect(find.text('Item 0'), findsOneWidget);
    }
  });

  testWidgets('DynamicGridView.wrap for GridView.reverse to true',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      20,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 100 : 180,
        child: Center(child: Text('Item $index')),
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
      expect(find.text('Item 0'), findsOneWidget);
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

  testWidgets('Test wrap in Axis.vertical direction',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      5,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 100 : 180,
        child: Center(child: Text('Item $index')),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.builder(
              itemCount: children.length,
              gridDelegate: const SliverGridDelegateWithWrapping(),
              itemBuilder: (BuildContext context, int index) =>
                  children[index]),
        ),
      ),
    );

    // Change the size of the screen
    await tester.binding.setSurfaceSize(const Size(500, 100));
    await tester.pumpAndSettle();
    for (int i = 0; i < 3; i++) {
      expect(find.text('Item $i'), findsOneWidget);
    }
    expect(find.text('Item 3'), findsNothing);
    expect(find.text('Item 4'), findsNothing);
    await tester.binding.setSurfaceSize(const Size(560, 100));
    await tester.pumpAndSettle();
    expect(find.text('Item 3'), findsOneWidget);
    expect(find.text('Item 4'), findsNothing);
    await tester.binding.setSurfaceSize(const Size(280, 100));
    await tester.pumpAndSettle();
    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsNothing);
    expect(find.text('Item 3'), findsNothing);
    expect(find.text('Item 4'), findsNothing);
    // resets the screen to its original size after the test end
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });

  testWidgets('Test wrap in Axis.horizontal direction',
      (WidgetTester tester) async {
    final List<Widget> children = List<Widget>.generate(
      5,
      (int index) => SizedBox(
        height: index.isEven ? 100 : 50,
        width: index.isEven ? 100 : 180,
        child: Center(child: Text('Item $index')),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.wrap(
              scrollDirection: Axis.horizontal, children: children),
        ),
      ),
    );

    // Change the size of the screen
    await tester.binding.setSurfaceSize(const Size(180, 150));
    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsNothing);
    expect(find.text('Item 3'), findsNothing);

    await tester.binding.setSurfaceSize(const Size(180, 400));
    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
    expect(find.text('Item 4'), findsOneWidget);

    await tester.binding.setSurfaceSize(const Size(560, 100));
    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
    expect(find.text('Item 4'), findsNothing);

    // resets the screen to its original size after the test end
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });
  // FIXIT(snat-s)
  // testWidgets(
  //     'Test if childMainAxisExtent is respected',
  //     (WidgetTester tester) async {
  //   final List<Widget> children = List<Widget>.generate(
  //     10,
  //     (int index) => Container(
  //       height: index.isEven ? 50 : 150,
  //       width: index.isEven ? 95 : 180,
  //       child: Center(child: Text('Item $index')),
  //     ),
  //   );
  //   await tester.pumpWidget(
  //     MaterialApp(
  //       home: Scaffold(
  //         body: DynamicGridView.wrap(
  //           childMainAxisExtent: 100,
  //           children: children,
  //         ),
  //       ),
  //     ),
  //   );
  //   expect(find.text('Item 0'), findsOneWidget);
  //   expect(tester.getSize(find.text('Item 0')), const Size(100, 95));
  //   expect(find.text('Item 1'), findsOneWidget);
  //   // expect(tester.getSize(find.text('Item 1')), const Size(100, 180));
  //   // for (int i = 0; i < 10; i++) {
  //   //   expect(find.text('Item $i'), findsOneWidget);
  //   // }
  // });
  // TODO(snat-s): 'Test wrap to see nothing affected if random elements are deleted'.
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

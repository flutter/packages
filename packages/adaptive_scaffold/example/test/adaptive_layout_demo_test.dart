// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_scaffold/src/adaptive_layout.dart';
import 'package:adaptive_scaffold/src/slot_layout.dart';
import 'package:adaptive_scaffold/src/breakpoints.dart';
import 'package:adaptive_scaffold/adaptive_scaffold.dart';
import 'package:adaptive_scaffold_example/adaptive_layout_demo.dart' as example;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<MaterialApp> layout({
  required double width,
  required WidgetTester tester,
  Axis orientation = Axis.horizontal,
  TextDirection directionality = TextDirection.ltr,
  double? bodyRatio,
  bool animations = true,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 800));
  final List<Widget> children = List<Widget>.generate(10, (int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: const Color.fromARGB(255, 255, 201, 197),
        height: 400,
      ),
    );
  });

  // Define the list of destinations to be used within the app.
  const List<NavigationDestination> destinations = <NavigationDestination>[
    NavigationDestination(
        label: 'Inbox', icon: Icon(Icons.inbox, color: Colors.black)),
    NavigationDestination(
        label: 'Articles',
        icon: Icon(Icons.article_outlined, color: Colors.black)),
    NavigationDestination(
        label: 'Chat',
        icon: Icon(Icons.chat_bubble_outline, color: Colors.black)),
    NavigationDestination(
        label: 'Video',
        icon: Icon(Icons.video_call_outlined, color: Colors.black)),
  ];

  Widget trailingNavRail = Column(
    children: [
      const Divider(
        color: Colors.black,
      ),
      const SizedBox(
        height: 10,
      ),
      Row(
        children: const [
          SizedBox(
            width: 27,
          ),
          Text(
            "Folders",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Row(
        children: [
          const SizedBox(
            width: 16,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.folder_copy_outlined),
            iconSize: 21,
          ),
          const SizedBox(
            width: 21,
          ),
          const Text("Freelance"),
        ],
      ),
      const SizedBox(
        height: 12,
      ),
      Row(
        children: [
          const SizedBox(
            width: 16,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.folder_copy_outlined),
            iconSize: 21,
          ),
          const SizedBox(
            width: 21,
          ),
          const Text("Mortage"),
        ],
      ),
      const SizedBox(
        height: 12,
      ),
      Row(
        children: [
          const SizedBox(
            width: 16,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.folder_copy_outlined),
            iconSize: 21,
          ),
          const SizedBox(
            width: 21,
          ),
          const Flexible(
              child: Text(
            "Taxes",
            overflow: TextOverflow.ellipsis,
          )),
        ],
      ),
      const SizedBox(
        height: 12,
      ),
      Row(
        children: [
          const SizedBox(
            width: 16,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.folder_copy_outlined),
            iconSize: 21,
          ),
          const SizedBox(
            width: 21,
          ),
          const Flexible(
              child: Text(
            "Receipts",
            overflow: TextOverflow.ellipsis,
          )),
        ],
      ),
    ],
  );
  return MaterialApp(
      home: MediaQuery(
    data: MediaQueryData(size: Size(width, 800)),
    child: Directionality(
      textDirection: directionality,
      child: AdaptiveLayout(
        bodyOrientation: orientation,
        bodyRatio: bodyRatio,
        internalAnimations: animations,
        primaryNavigation: SlotLayout(
          config: {
            Breakpoints.small: SlotLayout.from(
                key: const Key('pnav'),
                builder: (_) => const SizedBox.shrink()),
            Breakpoints.medium: SlotLayout.from(
              inAnimation: AdaptiveScaffold.leftOutIn,
              key: const Key('pnav1'),
              builder: (_) => AdaptiveScaffold.toRailFromDestinations(
                  leading: const Icon(Icons.menu), destinations: destinations),
            ),
            Breakpoints.large: SlotLayout.from(
              key: const Key('pn1'),
              inAnimation: AdaptiveScaffold.leftOutIn,
              builder: (_) => AdaptiveScaffold.toRailFromDestinations(
                extended: true,
                leading: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Text(
                      "REPLY",
                      style:
                          TextStyle(color: Color.fromARGB(255, 255, 201, 197)),
                    ),
                    Icon(Icons.menu_open)
                  ],
                ),
                destinations: destinations,
                trailing: trailingNavRail,
              ),
            ),
          },
        ),
        body: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            Breakpoints.small: SlotLayout.from(
              key: const Key('body'),
              builder: (_) => ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: const Color.fromARGB(255, 255, 201, 197),
                    height: 400,
                  ),
                ),
              ),
            ),
            Breakpoints.medium: SlotLayout.from(
              key: const Key('body1'),
              builder: (_) =>
                  GridView.count(crossAxisCount: 2, children: <Widget>[
                for (int i = 0; i < 10; i++)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: const Color.fromARGB(255, 255, 201, 197),
                      height: 400,
                    ),
                  )
              ]),
            ),
            Breakpoints.large: SlotLayout.from(
              key: const Key('body1'),
              builder: (_) =>
                  GridView.count(crossAxisCount: 2, children: <Widget>[
                for (int i = 0; i < 10; i++)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: const Color.fromARGB(255, 255, 201, 197),
                      height: 400,
                    ),
                  )
              ]),
            ),
          },
        ),
        bottomNavigation: SlotLayout(
          config: {
            Breakpoints.small: SlotLayout.from(
              key: const Key('bn'),
              inAnimation: AdaptiveScaffold.bottomToTop,
              outAnimation: AdaptiveScaffold.topToBottom,
              builder: (_) => AdaptiveScaffold.toBottomNavigationBar(
                  destinations: destinations),
            ),
            Breakpoints.medium: SlotLayoutConfig.empty(),
            Breakpoints.large: SlotLayoutConfig.empty()
          },
        ),
      ),
    ),
  ));
}

void main() {
  final Finder body = find.byKey(const Key('body'));
  final Finder body1 = find.byKey(const Key('body1'));
  final Finder pnav = find.byKey(const Key('pnav'));
  final Finder pnav1 = find.byKey(const Key('pnav1'));
  final Finder pn1 = find.byKey(const Key('pn1'));
  final Finder bn = find.byKey(const Key('bn'));

  Future<void> updateScreen(double width, WidgetTester tester) async {
    await tester.binding.setSurfaceSize(Size(width, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
            data: MediaQueryData(size: Size(width, 800)),
            child: const example.MyHomePage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dislays correct item of config based on screen width',
      (WidgetTester tester) async {
    await updateScreen(300, tester);
    expect(find.byKey(const Key('body')), findsOneWidget);
    expect(find.byKey(const Key('pnav')), findsOneWidget);
    expect(find.byKey(const Key('bn')), findsOneWidget);
    expect(find.byKey(const Key('body1')), findsNothing);
    expect(find.byKey(const Key('pn1')), findsNothing);

    await updateScreen(700, tester);
    expect(find.byKey(const Key('body')), findsNothing);
    expect(find.byKey(const Key('bn')), findsNothing);
    expect(find.byKey(const Key('body1')), findsOneWidget);
    expect(find.byKey(const Key('pnav1')), findsOneWidget);
    expect(find.byKey(const Key('pn1')), findsNothing);
  });

  testWidgets(
      'adaptive layout bottom navigation displays with correct properties',
      (WidgetTester tester) async {
    await updateScreen(400, tester);
    final BuildContext context = tester.element(find.byType(MaterialApp));

    // Bottom Navigation Bar
    final findKey = find.byKey(const Key('bn'));
    SlotLayoutConfig slotLayoutConfig =
        tester.firstWidget<SlotLayoutConfig>(findKey);
    WidgetBuilder? widgetBuilder = slotLayoutConfig.builder;
    Widget Function(BuildContext) widgetFunction =
        widgetBuilder as Widget Function(BuildContext);

    BottomNavigationBar bottomNavigationBar =
        ((widgetFunction(context) as Builder).builder(context) as Theme).child
            as BottomNavigationBar;
    expect(bottomNavigationBar.backgroundColor, Colors.white);
    expect(bottomNavigationBar.selectedItemColor, Colors.black);
    expect(bottomNavigationBar.iconSize, 24);
  });

  testWidgets(
      'adaptive layout navigation rail displays with correct properties',
      (WidgetTester tester) async {
    await updateScreen(620, tester);
    final BuildContext context = tester.element(find.byType(AdaptiveLayout));

    final findKey = find.byKey(const Key('pnav1'));
    SlotLayoutConfig slotLayoutConfig =
        tester.firstWidget<SlotLayoutConfig>(findKey);
    WidgetBuilder? widgetBuilder = slotLayoutConfig.builder;
    Widget Function(BuildContext) widgetFunction =
        widgetBuilder as Widget Function(BuildContext);
    SizedBox sizedBox =
        ((widgetFunction(context) as Builder).builder(context) as Padding).child
            as SizedBox;
    expect(sizedBox.width, 72);
  });

  testWidgets('adaptive layout displays children in correct places',
      (WidgetTester tester) async {
    await updateScreen(400, tester);
    expect(tester.getTopLeft(pnav), Offset.zero);
    expect(tester.getTopRight(pnav), Offset.zero);
    expect(tester.getBottomLeft(bn), const Offset(0, 800));
    expect(tester.getBottomRight(bn), const Offset(400, 800));
    expect(tester.getTopRight(body), const Offset(400, 0));
    expect(tester.getTopLeft(body), const Offset(0, 0));
  });

  testWidgets('adaptive layout does not animate when animations off',
      (WidgetTester tester) async {
    final Finder b = find.byKey(const Key('body1'));

    await tester.pumpWidget(
        await layout(width: 690, tester: tester, animations: false));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getTopLeft(b), const Offset(88, 0));
    expect(tester.getBottomRight(b), const Offset(690, 800));
  });
}

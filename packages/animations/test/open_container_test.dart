// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/src/open_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Container opens', (WidgetTester tester) async {
    const ShapeBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    );
    bool closedBuilderCalled = false;
    bool openBuilderCalled = false;

    await tester.pumpWidget(_boilerplate(
      child: Center(
        child: OpenContainer(
          closedColor: Colors.green,
          openColor: Colors.blue,
          closedElevation: 4.0,
          openElevation: 8.0,
          closedShape: shape,
          closedBuilder: (BuildContext context, VoidCallback _) {
            closedBuilderCalled = true;
            return const Text('Closed');
          },
          openBuilder: (BuildContext context, VoidCallback _) {
            openBuilderCalled = true;
            return const Text('Open');
          },
        ),
      ),
    ));

    // Closed container has the expected properties.
    final StatefulElement srcMaterialElement = tester.firstElement(
      find.ancestor(
        of: find.text('Closed'),
        matching: find.byType(Material),
      ),
    );
    final Material srcMaterial = srcMaterialElement.widget;
    expect(srcMaterial.color, Colors.green);
    expect(srcMaterial.elevation, 4.0);
    expect(srcMaterial.shape, shape);
    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Open'), findsNothing);
    expect(closedBuilderCalled, isTrue);
    expect(openBuilderCalled, isFalse);
    final Rect srcMaterialRect = tester.getRect(
      find.byElementPredicate((Element e) => e == srcMaterialElement),
    );

    // Open the container.
    await tester.tap(find.text('Closed'));
    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Open'), findsNothing);
    await tester.pump();

    // On the first frame of the animation everything still looks like before.
    final StatefulElement destMaterialElement = tester.firstElement(
      find.ancestor(
        of: find.text('Closed'),
        matching: find.byType(Material),
      ),
    );
    final Material closedMaterial = destMaterialElement.widget;
    expect(closedMaterial.color, Colors.green);
    expect(closedMaterial.elevation, 4.0);
    expect(closedMaterial.shape, shape);
    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    final Rect closedMaterialRect = tester.getRect(
      find.byElementPredicate((Element e) => e == destMaterialElement),
    );
    expect(closedMaterialRect, srcMaterialRect);
    expect(_getOpacity(tester, 'Open'), 0.0);
    expect(_getOpacity(tester, 'Closed'), 1.0);

    final _TrackedData dataClosed = _TrackedData(
      closedMaterial,
      closedMaterialRect,
    );

    // The fade-out takes 4/12 of 300ms. Let's jump to the midpoint of that.
    await tester.pump(const Duration(milliseconds: 50)); // 300 * 2/12 = 50
    final _TrackedData dataMidFadeOut = _TrackedData(
      destMaterialElement.widget,
      tester.getRect(
        find.byElementPredicate((Element e) => e == destMaterialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataClosed,
      biggerMaterial: dataMidFadeOut,
      tester: tester,
    );
    expect(_getOpacity(tester, 'Open'), 0.0);
    expect(_getOpacity(tester, 'Closed'), lessThan(1.0));
    expect(_getOpacity(tester, 'Closed'), greaterThan(0.0));

    // Let's jump to the crossover point at 4/12 of 300ms.
    await tester.pump(const Duration(milliseconds: 50)); // 300 * 2/12 = 50
    final _TrackedData dataMidpoint = _TrackedData(
      destMaterialElement.widget,
      tester.getRect(
        find.byElementPredicate((Element e) => e == destMaterialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataMidFadeOut,
      biggerMaterial: dataMidpoint,
      tester: tester,
    );
    expect(_getOpacity(tester, 'Open'), moreOrLessEquals(0.0));
    expect(_getOpacity(tester, 'Closed'), moreOrLessEquals(0.0));

    // Let's jump to the middle of the fade-in at 8/12 of 300ms
    await tester.pump(const Duration(milliseconds: 100)); // 300 * 4/12 = 100
    final _TrackedData dataMidFadeIn = _TrackedData(
      destMaterialElement.widget,
      tester.getRect(
        find.byElementPredicate((Element e) => e == destMaterialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataMidpoint,
      biggerMaterial: dataMidFadeIn,
      tester: tester,
    );
    expect(_getOpacity(tester, 'Open'), lessThan(1.0));
    expect(_getOpacity(tester, 'Open'), greaterThan(0.0));
    expect(_getOpacity(tester, 'Closed'), 0.0);

    // Let's jump almost to the end of the transition.
    await tester.pump(const Duration(milliseconds: 100));
    final _TrackedData dataTransitionDone = _TrackedData(
      destMaterialElement.widget,
      tester.getRect(
        find.byElementPredicate((Element e) => e == destMaterialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataMidFadeIn,
      biggerMaterial: dataTransitionDone,
      tester: tester,
    );
    expect(_getOpacity(tester, 'Open'), 1.0);
    expect(_getOpacity(tester, 'Closed'), 0.0);
    expect(dataTransitionDone.material.color, Colors.blue);
    expect(dataTransitionDone.material.elevation, 8.0);
    expect(dataTransitionDone.radius, 0.0);
    expect(dataTransitionDone.rect, const Rect.fromLTRB(0, 0, 800, 600));

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Closed'), findsNothing); // No longer in the tree.
    expect(find.text('Open'), findsOneWidget);
    final StatefulElement finalMaterialElement = tester.firstElement(
      find.ancestor(
        of: find.text('Open'),
        matching: find.byType(Material),
      ),
    );
    final _TrackedData dataOpen = _TrackedData(
      finalMaterialElement.widget,
      tester.getRect(
        find.byElementPredicate((Element e) => e == finalMaterialElement),
      ),
    );
    expect(dataOpen.material.color, dataTransitionDone.material.color);
    expect(dataOpen.material.elevation, dataTransitionDone.material.elevation);
    expect(dataOpen.radius, dataTransitionDone.radius);
    expect(dataOpen.rect, dataTransitionDone.rect);
  });

  testWidgets('Container closes', (WidgetTester tester) async {
    const ShapeBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    );

    await tester.pumpWidget(_boilerplate(
      child: Center(
        child: OpenContainer(
          closedColor: Colors.green,
          openColor: Colors.blue,
          closedElevation: 4.0,
          openElevation: 8.0,
          closedShape: shape,
          closedBuilder: (BuildContext context, VoidCallback _) {
            return const Text('Closed');
          },
          openBuilder: (BuildContext context, VoidCallback _) {
            return const Text('Open');
          },
        ),
      ),
    ));

    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();

    // Open container has the expected properties.
    expect(find.text('Closed'), findsNothing);
    expect(find.text('Open'), findsOneWidget);
    final StatefulElement initialMaterialElement = tester.firstElement(
      find.ancestor(
        of: find.text('Open'),
        matching: find.byType(Material),
      ),
    );
    final _TrackedData dataOpen = _TrackedData(
      initialMaterialElement.widget,
      tester.getRect(
        find.byElementPredicate((Element e) => e == initialMaterialElement),
      ),
    );
    expect(dataOpen.material.color, Colors.blue);
    expect(dataOpen.material.elevation, 8.0);
    expect(dataOpen.radius, 0.0);
    expect(dataOpen.rect, const Rect.fromLTRB(0, 0, 800, 600));

    // Close the container.
    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pump();

    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    final StatefulElement materialElement = tester.firstElement(
      find.ancestor(
        of: find.text('Open'),
        matching: find.byType(Material),
      ),
    );
    final _TrackedData dataTransitionStart = _TrackedData(
      materialElement.widget,
      tester.getRect(
        find.byElementPredicate((Element e) => e == materialElement),
      ),
    );
    expect(dataTransitionStart.material.color, dataOpen.material.color);
    expect(dataTransitionStart.material.elevation, dataOpen.material.elevation);
    expect(dataTransitionStart.radius, dataOpen.radius);
    expect(dataTransitionStart.rect, dataOpen.rect);
    expect(_getOpacity(tester, 'Open'), 1.0);
    expect(_getOpacity(tester, 'Closed'), 0.0);

    // Jump to mid-point of fade-out: 2/12 of 300.
    await tester.pump(const Duration(milliseconds: 50)); // 300 * 2/12 = 50
    final _TrackedData dataMidFadeOut = _TrackedData(
      materialElement.widget,
      tester.getRect(
        find.byElementPredicate((Element e) => e == materialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataMidFadeOut,
      biggerMaterial: dataTransitionStart,
      tester: tester,
    );
    expect(_getOpacity(tester, 'Closed'), 0.0);
    expect(_getOpacity(tester, 'Open'), lessThan(1.0));
    expect(_getOpacity(tester, 'Open'), greaterThan(0.0));

    // Let's jump to the crossover point at 4/12 of 300ms.
    await tester.pump(const Duration(milliseconds: 50)); // 300 * 2/12 = 50
    final _TrackedData dataMidpoint = _TrackedData(
      materialElement.widget,
      tester.getRect(
        find.byElementPredicate((Element e) => e == materialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataMidpoint,
      biggerMaterial: dataMidFadeOut,
      tester: tester,
    );
    expect(_getOpacity(tester, 'Open'), moreOrLessEquals(0.0));
    expect(_getOpacity(tester, 'Closed'), moreOrLessEquals(0.0));

    // Let's jump to the middle of the fade-in at 8/12 of 300ms
    await tester.pump(const Duration(milliseconds: 100)); // 300 * 4/12 = 100
    final _TrackedData dataMidFadeIn = _TrackedData(
      materialElement.widget,
      tester.getRect(
        find.byElementPredicate((Element e) => e == materialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataMidFadeIn,
      biggerMaterial: dataMidpoint,
      tester: tester,
    );
    expect(_getOpacity(tester, 'Closed'), lessThan(1.0));
    expect(_getOpacity(tester, 'Closed'), greaterThan(0.0));
    expect(_getOpacity(tester, 'Open'), 0.0);

    // Let's jump almost to the end of the transition.
    await tester.pump(const Duration(milliseconds: 100));
    final _TrackedData dataTransitionDone = _TrackedData(
      materialElement.widget,
      tester.getRect(
        find.byElementPredicate((Element e) => e == materialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataTransitionDone,
      biggerMaterial: dataMidFadeIn,
      tester: tester,
    );
    expect(_getOpacity(tester, 'Closed'), 1.0);
    expect(_getOpacity(tester, 'Open'), 0.0);
    expect(dataTransitionDone.material.color, Colors.green);
    expect(dataTransitionDone.material.elevation, 4.0);
    expect(dataTransitionDone.radius, 8.0);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Open'), findsNothing); // No longer in the tree.
    expect(find.text('Closed'), findsOneWidget);
    final StatefulElement finalMaterialElement = tester.firstElement(
      find.ancestor(
        of: find.text('Closed'),
        matching: find.byType(Material),
      ),
    );
    final _TrackedData dataClosed = _TrackedData(
      finalMaterialElement.widget,
      tester.getRect(
        find.byElementPredicate((Element e) => e == finalMaterialElement),
      ),
    );
    expect(dataClosed.material.color, dataTransitionDone.material.color);
    expect(
      dataClosed.material.elevation,
      dataTransitionDone.material.elevation,
    );
    expect(dataClosed.radius, dataTransitionDone.radius);
    expect(dataClosed.rect, dataTransitionDone.rect);
  });

  testWidgets('Cannot tap container if tappable=false',
      (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(
      child: Center(
        child: OpenContainer(
          tappable: false,
          closedBuilder: (BuildContext context, VoidCallback _) {
            return const Text('Closed');
          },
          openBuilder: (BuildContext context, VoidCallback _) {
            return const Text('Open');
          },
        ),
      ),
    ));

    expect(find.text('Open'), findsNothing);
    expect(find.text('Closed'), findsOneWidget);
    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsNothing);
    expect(find.text('Closed'), findsOneWidget);
  });

  testWidgets('Action callbacks work', (WidgetTester tester) async {
    VoidCallback open, close;
    await tester.pumpWidget(_boilerplate(
      child: Center(
        child: OpenContainer(
          tappable: false,
          closedBuilder: (BuildContext context, VoidCallback action) {
            open = action;
            return const Text('Closed');
          },
          openBuilder: (BuildContext context, VoidCallback action) {
            close = action;
            return const Text('Open');
          },
        ),
      ),
    ));

    expect(find.text('Open'), findsNothing);
    expect(find.text('Closed'), findsOneWidget);

    expect(open, isNotNull);
    open();
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsNothing);

    expect(close, isNotNull);
    close();
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsNothing);
    expect(find.text('Closed'), findsOneWidget);
  });

  testWidgets('open widget keeps state', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(
      child: Center(
        child: OpenContainer(
          closedBuilder: (BuildContext context, VoidCallback action) {
            return const Text('Closed');
          },
          openBuilder: (BuildContext context, VoidCallback action) {
            return Switch(
              value: true,
              onChanged: (bool v) {},
            );
          },
        ),
      ),
    ));

    await tester.tap(find.text('Closed'));
    await tester.pump(const Duration(milliseconds: 200));

    final State stateOpening = tester.state(find.byType(Switch));
    expect(stateOpening, isNotNull);

    await tester.pumpAndSettle();
    expect(find.text('Closed'), findsNothing);
    final State stateOpen = tester.state(find.byType(Switch));
    expect(stateOpen, isNotNull);
    expect(stateOpen, same(stateOpening));

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Closed'), findsOneWidget);
    final State stateClosing = tester.state(find.byType(Switch));
    expect(stateClosing, isNotNull);
    expect(stateClosing, same(stateOpen));
  });

  testWidgets('closed widget keeps state', (WidgetTester tester) async {
    VoidCallback open;
    await tester.pumpWidget(_boilerplate(
      child: Center(
        child: OpenContainer(
          closedBuilder: (BuildContext context, VoidCallback action) {
            open = action;
            return Switch(
              value: true,
              onChanged: (bool v) {},
            );
          },
          openBuilder: (BuildContext context, VoidCallback action) {
            return const Text('Open');
          },
        ),
      ),
    ));

    final State stateClosed = tester.state(find.byType(Switch));
    expect(stateClosed, isNotNull);

    open();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Open'), findsOneWidget);

    final State stateOpening = tester.state(find.byType(Switch));
    expect(stateOpening, same(stateClosed));

    await tester.pumpAndSettle();
    expect(find.byType(Switch), findsNothing);
    expect(find.text('Open'), findsOneWidget);
    final State stateOpen = tester.state(find.byType(
      Switch,
      skipOffstage: false,
    ));
    expect(stateOpen, same(stateOpening));

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Open'), findsOneWidget);
    final State stateClosing = tester.state(find.byType(Switch));
    expect(stateClosing, same(stateOpen));

    await tester.pumpAndSettle();
    expect(find.text('Open'), findsNothing);
    final State stateClosedAgain = tester.state(find.byType(Switch));
    expect(stateClosedAgain, same(stateClosing));
  });

  testWidgets('closes to the right location when src position has changed',
      (WidgetTester tester) async {
    final Widget openContainer = OpenContainer(
      closedBuilder: (BuildContext context, VoidCallback action) {
        return Container(
          height: 100,
          width: 100,
          child: const Text('Closed'),
        );
      },
      openBuilder: (BuildContext context, VoidCallback action) {
        return GestureDetector(
          onTap: action,
          child: const Text('Open'),
        );
      },
    );

    await tester.pumpWidget(_boilerplate(
      child: Align(
        alignment: Alignment.topLeft,
        child: openContainer,
      ),
    ));

    final Rect originTextRect = tester.getRect(find.text('Closed'));
    expect(originTextRect.topLeft, Offset.zero);

    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsNothing);

    await tester.pumpWidget(_boilerplate(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: openContainer,
      ),
    ));

    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsNothing);

    await tester.tap(find.text('Open'));
    await tester.pump(); // Need one frame to measure things in the old route.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);

    final Rect transitionEndTextRect = tester.getRect(find.text('Open'));
    expect(transitionEndTextRect.topLeft, const Offset(0.0, 600.0 - 100.0));

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Open'), findsNothing);
    expect(find.text('Closed'), findsOneWidget);

    final Rect finalTextRect = tester.getRect(find.text('Closed'));
    expect(finalTextRect.topLeft, transitionEndTextRect.topLeft);
  });

  testWidgets('src changes size while open', (WidgetTester tester) async {
    double closedSize = 100;

    final Widget openContainer = _boilerplate(
      child: Center(
        child: OpenContainer(
          closedBuilder: (BuildContext context, VoidCallback action) {
            return Container(
              height: closedSize,
              width: closedSize,
              child: const Text('Closed'),
            );
          },
          openBuilder: (BuildContext context, VoidCallback action) {
            return GestureDetector(
              onTap: action,
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.pumpWidget(openContainer);

    final Size orignalClosedRect = tester.getSize(find
        .ancestor(
          of: find.text('Closed'),
          matching: find.byType(Material),
        )
        .first);
    expect(orignalClosedRect, const Size(100, 100));

    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsNothing);

    closedSize = 200;
    await tester.pumpWidget(openContainer);

    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsNothing);

    await tester.tap(find.text('Open'));
    await tester.pump(); // Need one frame to measure things in the old route.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);

    final Size transitionEndSize = tester.getSize(find
        .ancestor(
          of: find.text('Open'),
          matching: find.byType(Material),
        )
        .first);
    expect(transitionEndSize, const Size(200, 200));

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Open'), findsNothing);
    expect(find.text('Closed'), findsOneWidget);

    final Size finalSize = tester.getSize(find
        .ancestor(
          of: find.text('Closed'),
          matching: find.byType(Material),
        )
        .first);
    expect(finalSize, const Size(200, 200));
  });

  testWidgets('transition is interrupted and should not jump',
      (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(
      child: Center(
        child: OpenContainer(
          closedBuilder: (BuildContext context, VoidCallback action) {
            return const Text('Closed');
          },
          openBuilder: (BuildContext context, VoidCallback action) {
            return const Text('Open');
          },
        ),
      ),
    ));

    await tester.tap(find.text('Closed'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);

    final Material openingMaterial = tester.firstWidget(find.ancestor(
      of: find.text('Closed'),
      matching: find.byType(Material),
    ));
    final Rect openingRect = tester.getRect(
      find.byWidgetPredicate((Widget w) => w == openingMaterial),
    );

    // Close the container while it is half way to open.
    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pump();

    final Material closingMaterial = tester.firstWidget(find.ancestor(
      of: find.text('Open'),
      matching: find.byType(Material),
    ));
    final Rect closingRect = tester.getRect(
      find.byWidgetPredicate((Widget w) => w == closingMaterial),
    );

    expect(closingMaterial.elevation, openingMaterial.elevation);
    expect(closingMaterial.color, openingMaterial.color);
    expect(closingMaterial.shape, openingMaterial.shape);
    expect(closingRect, openingRect);
  });

  testWidgets('navigator is not full size', (WidgetTester tester) async {
    await tester.pumpWidget(Center(
      child: SizedBox(
        width: 300,
        height: 400,
        child: _boilerplate(
          child: Center(
            child: OpenContainer(
              closedBuilder: (BuildContext context, VoidCallback action) {
                return const Text('Closed');
              },
              openBuilder: (BuildContext context, VoidCallback action) {
                return const Text('Open');
              },
            ),
          ),
        ),
      ),
    ));
    const Rect fullNavigator = Rect.fromLTWH(250, 100, 300, 400);

    expect(tester.getRect(find.byType(Navigator)), fullNavigator);
    final Rect materialRectClosed = tester.getRect(find
        .ancestor(
          of: find.text('Closed'),
          matching: find.byType(Material),
        )
        .first);

    await tester.tap(find.text('Closed'));
    await tester.pump();
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);
    final Rect materialRectTransitionStart = tester.getRect(find.ancestor(
      of: find.text('Closed'),
      matching: find.byType(Material),
    ));
    expect(materialRectTransitionStart, materialRectClosed);

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);
    final Rect materialRectTransitionEnd = tester.getRect(find.ancestor(
      of: find.text('Open'),
      matching: find.byType(Material),
    ));
    expect(materialRectTransitionEnd, fullNavigator);
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsNothing);
    final Rect materialRectOpen = tester.getRect(find.ancestor(
      of: find.text('Open'),
      matching: find.byType(Material),
    ));
    expect(materialRectOpen, fullNavigator);
  });

  testWidgets('does not crash when disposed right after pop', (WidgetTester tester) async {
    await tester.pumpWidget(Center(
      child: SizedBox(
        width: 300,
        height: 400,
        child: _boilerplate(
          child: Center(
            child: OpenContainer(
              closedBuilder: (BuildContext context, VoidCallback action) {
                return const Text('Closed');
              },
              openBuilder: (BuildContext context, VoidCallback action) {
                return const Text('Open');
              },
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();

    await tester.pumpWidget(const Placeholder());
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('can specify a duration', (WidgetTester tester) async {
    await tester.pumpWidget(Center(
      child: SizedBox(
        width: 300,
        height: 400,
        child: _boilerplate(
          child: Center(
            child: OpenContainer(
              transitionDuration: const Duration(seconds: 2),
              closedBuilder: (BuildContext context, VoidCallback action) {
                return const Text('Closed');
              },
              openBuilder: (BuildContext context, VoidCallback action) {
                return const Text('Open');
              },
            ),
          ),
        ),
      ),
    ));

    expect(find.text('Open'), findsNothing);
    expect(find.text('Closed'), findsOneWidget);

    await tester.tap(find.text('Closed'));
    await tester.pump();

    // Jump to the end of the transition.
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Open'), findsOneWidget); // faded in
    expect(find.text('Closed'), findsOneWidget); // faded out
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsNothing);

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pump();

    // Jump to the end of the transition.
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Open'), findsOneWidget); // faded out
    expect(find.text('Closed'), findsOneWidget); // faded in
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Open'), findsNothing);
    expect(find.text('Closed'), findsOneWidget);
  });

  testWidgets('can specify an open shape', (WidgetTester tester) async {
    await tester.pumpWidget(Center(
      child: SizedBox(
        width: 300,
        height: 400,
        child: _boilerplate(
          child: Center(
            child: OpenContainer(
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              openShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              closedBuilder: (BuildContext context, VoidCallback action) {
                return const Text('Closed');
              },
              openBuilder: (BuildContext context, VoidCallback action) {
                return const Text('Open');
              },
            ),
          ),
        ),
      ),
    ));

    expect(find.text('Open'), findsNothing);
    expect(find.text('Closed'), findsOneWidget);
    final double closedRadius = _getRadius(tester.firstWidget(find.ancestor(
      of: find.text('Closed'),
      matching: find.byType(Material),
    )));
    expect(closedRadius, 10.0);

    await tester.tap(find.text('Closed'));
    await tester.pump();
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);
    final double openingRadius = _getRadius(tester.firstWidget(find.ancestor(
      of: find.text('Open'),
      matching: find.byType(Material),
    )));
    expect(openingRadius, 10.0);

    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);
    final double halfwayRadius = _getRadius(tester.firstWidget(find.ancestor(
      of: find.text('Open'),
      matching: find.byType(Material),
    )));
    expect(halfwayRadius, greaterThan(10.0));
    expect(halfwayRadius, lessThan(40.0));

    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);
    final double openRadius = _getRadius(tester.firstWidget(find.ancestor(
      of: find.text('Open'),
      matching: find.byType(Material),
    )));
    expect(openRadius, 40.0);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Closed'), findsNothing);
    expect(find.text('Open'), findsOneWidget);
    final double finalRadius = _getRadius(tester.firstWidget(find.ancestor(
      of: find.text('Open'),
      matching: find.byType(Material),
    )));
    expect(finalRadius, 40.0);
  });
}

void _expectMaterialPropertiesHaveAdvanced({
  @required _TrackedData biggerMaterial,
  @required _TrackedData smallerMaterial,
  @required WidgetTester tester,
}) {
  expect(biggerMaterial.material.color, isNot(smallerMaterial.material.color));
  expect(
    biggerMaterial.material.elevation,
    greaterThan(smallerMaterial.material.elevation),
  );
  expect(biggerMaterial.radius, lessThan(smallerMaterial.radius));
  expect(biggerMaterial.rect.height, greaterThan(smallerMaterial.rect.height));
  expect(biggerMaterial.rect.width, greaterThan(smallerMaterial.rect.width));
  expect(biggerMaterial.rect.top, lessThan(smallerMaterial.rect.top));
  expect(biggerMaterial.rect.left, lessThan(smallerMaterial.rect.left));
}

double _getOpacity(WidgetTester tester, String label) {
  final Opacity widget = tester.firstWidget(find.ancestor(
    of: find.text(label),
    matching: find.byType(Opacity),
  ));
  return widget.opacity;
}

class _TrackedData {
  _TrackedData(this.material, this.rect);

  final Material material;
  final Rect rect;

  double get radius => _getRadius(material);
}

double _getRadius(Material material) {
  final RoundedRectangleBorder shape = material.shape;
  if (shape == null) {
    return 0.0;
  }
  final BorderRadius radius = shape.borderRadius;
  return radius.topRight.x;
}

Widget _boilerplate({@required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/src/open_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Container opens - Fade (by default)',
    (WidgetTester tester) async {
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
      final Element srcMaterialElement = tester.firstElement(
        find.ancestor(
          of: find.text('Closed'),
          matching: find.byType(Material),
        ),
      );
      final Material srcMaterial = srcMaterialElement.widget as Material;
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
      final Element destMaterialElement = tester.firstElement(
        find.ancestor(
          of: find.text('Closed'),
          matching: find.byType(Material),
        ),
      );
      final Material closedMaterial = destMaterialElement.widget as Material;
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

      // Jump to the start of the fade in.
      await tester.pump(const Duration(milliseconds: 60)); // 300ms * 1/5 = 60ms
      final _TrackedData dataPreFade = _TrackedData(
        destMaterialElement.widget as Material,
        tester.getRect(
          find.byElementPredicate((Element e) => e == destMaterialElement),
        ),
      );
      _expectMaterialPropertiesHaveAdvanced(
        smallerMaterial: dataClosed,
        biggerMaterial: dataPreFade,
        tester: tester,
      );
      expect(_getOpacity(tester, 'Open'), moreOrLessEquals(0.0));
      expect(_getOpacity(tester, 'Closed'), 1.0);

      // Jump to the middle of the fade in.
      await tester
          .pump(const Duration(milliseconds: 30)); // 300ms * 3/10 = 90ms
      final _TrackedData dataMidFadeIn = _TrackedData(
        destMaterialElement.widget as Material,
        tester.getRect(
          find.byElementPredicate((Element e) => e == destMaterialElement),
        ),
      );
      _expectMaterialPropertiesHaveAdvanced(
        smallerMaterial: dataPreFade,
        biggerMaterial: dataMidFadeIn,
        tester: tester,
      );
      expect(dataMidFadeIn.material.color, isNot(dataPreFade.material.color));
      expect(_getOpacity(tester, 'Open'), lessThan(1.0));
      expect(_getOpacity(tester, 'Open'), greaterThan(0.0));
      expect(_getOpacity(tester, 'Closed'), 1.0);

      // Jump to the end of the fade in at 2/5 of 300ms.
      await tester.pump(
        const Duration(milliseconds: 30),
      ); // 300ms * 2/5 = 120ms

      final _TrackedData dataPostFadeIn = _TrackedData(
        destMaterialElement.widget as Material,
        tester.getRect(
          find.byElementPredicate((Element e) => e == destMaterialElement),
        ),
      );
      _expectMaterialPropertiesHaveAdvanced(
        smallerMaterial: dataMidFadeIn,
        biggerMaterial: dataPostFadeIn,
        tester: tester,
      );
      expect(_getOpacity(tester, 'Open'), moreOrLessEquals(1.0));
      expect(_getOpacity(tester, 'Closed'), 1.0);

      // Jump almost to the end of the transition.
      await tester.pump(const Duration(milliseconds: 180));
      final _TrackedData dataTransitionDone = _TrackedData(
        destMaterialElement.widget as Material,
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
      expect(dataTransitionDone.material.color, Colors.blue);
      expect(dataTransitionDone.material.elevation, 8.0);
      expect(dataTransitionDone.radius, 0.0);
      expect(dataTransitionDone.rect, const Rect.fromLTRB(0, 0, 800, 600));

      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text('Closed'), findsNothing); // No longer in the tree.
      expect(find.text('Open'), findsOneWidget);
      final Element finalMaterialElement = tester.firstElement(
        find.ancestor(
          of: find.text('Open'),
          matching: find.byType(Material),
        ),
      );
      final _TrackedData dataOpen = _TrackedData(
        finalMaterialElement.widget as Material,
        tester.getRect(
          find.byElementPredicate((Element e) => e == finalMaterialElement),
        ),
      );
      expect(dataOpen.material.color, dataTransitionDone.material.color);
      expect(
          dataOpen.material.elevation, dataTransitionDone.material.elevation);
      expect(dataOpen.radius, dataTransitionDone.radius);
      expect(dataOpen.rect, dataTransitionDone.rect);
    },
  );

  testWidgets(
    'Container closes - Fade (by default)',
    (WidgetTester tester) async {
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
      final Element initialMaterialElement = tester.firstElement(
        find.ancestor(
          of: find.text('Open'),
          matching: find.byType(Material),
        ),
      );
      final _TrackedData dataOpen = _TrackedData(
        initialMaterialElement.widget as Material,
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
      final Element materialElement = tester.firstElement(
        find.ancestor(
          of: find.text('Open'),
          matching: find.byType(Material),
        ),
      );
      final _TrackedData dataTransitionStart = _TrackedData(
        materialElement.widget as Material,
        tester.getRect(
          find.byElementPredicate((Element e) => e == materialElement),
        ),
      );
      expect(dataTransitionStart.material.color, dataOpen.material.color);
      expect(
          dataTransitionStart.material.elevation, dataOpen.material.elevation);
      expect(dataTransitionStart.radius, dataOpen.radius);
      expect(dataTransitionStart.rect, dataOpen.rect);
      expect(_getOpacity(tester, 'Open'), 1.0);

      // Jump to start of fade out: 1/5 of 300.
      await tester.pump(const Duration(milliseconds: 60)); // 300 * 1/5 = 60
      final _TrackedData dataPreFadeOut = _TrackedData(
        materialElement.widget as Material,
        tester.getRect(
          find.byElementPredicate((Element e) => e == materialElement),
        ),
      );
      _expectMaterialPropertiesHaveAdvanced(
        smallerMaterial: dataPreFadeOut,
        biggerMaterial: dataTransitionStart,
        tester: tester,
      );
      expect(_getOpacity(tester, 'Open'), moreOrLessEquals(1.0));
      expect(_getOpacity(tester, 'Closed'), 1.0);

      // Jump to the middle of the fade out.
      await tester.pump(const Duration(milliseconds: 30)); // 300 * 3/10 = 90
      final _TrackedData dataMidpoint = _TrackedData(
        materialElement.widget as Material,
        tester.getRect(
          find.byElementPredicate((Element e) => e == materialElement),
        ),
      );
      _expectMaterialPropertiesHaveAdvanced(
        smallerMaterial: dataMidpoint,
        biggerMaterial: dataPreFadeOut,
        tester: tester,
      );
      expect(dataMidpoint.material.color, isNot(dataPreFadeOut.material.color));
      expect(_getOpacity(tester, 'Open'), lessThan(1.0));
      expect(_getOpacity(tester, 'Open'), greaterThan(0.0));
      expect(_getOpacity(tester, 'Closed'), 1.0);

      // Jump to the end of the fade out.
      await tester.pump(const Duration(milliseconds: 30)); // 300 * 2/5 = 120
      final _TrackedData dataPostFadeOut = _TrackedData(
        materialElement.widget as Material,
        tester.getRect(
          find.byElementPredicate((Element e) => e == materialElement),
        ),
      );
      _expectMaterialPropertiesHaveAdvanced(
        smallerMaterial: dataPostFadeOut,
        biggerMaterial: dataMidpoint,
        tester: tester,
      );
      expect(_getOpacity(tester, 'Open'), moreOrLessEquals(0.0));
      expect(_getOpacity(tester, 'Closed'), 1.0);

      // Jump almost to the end of the transition.
      await tester.pump(const Duration(milliseconds: 180));
      final _TrackedData dataTransitionDone = _TrackedData(
        materialElement.widget as Material,
        tester.getRect(
          find.byElementPredicate((Element e) => e == materialElement),
        ),
      );
      _expectMaterialPropertiesHaveAdvanced(
        smallerMaterial: dataTransitionDone,
        biggerMaterial: dataPostFadeOut,
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
      final Element finalMaterialElement = tester.firstElement(
        find.ancestor(
          of: find.text('Closed'),
          matching: find.byType(Material),
        ),
      );
      final _TrackedData dataClosed = _TrackedData(
        finalMaterialElement.widget as Material,
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
    },
  );

  testWidgets('Container opens - Fade through', (WidgetTester tester) async {
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
          middleColor: Colors.red,
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
          transitionType: ContainerTransitionType.fadeThrough,
        ),
      ),
    ));

    // Closed container has the expected properties.
    final Element srcMaterialElement = tester.firstElement(
      find.ancestor(
        of: find.text('Closed'),
        matching: find.byType(Material),
      ),
    );
    final Material srcMaterial = srcMaterialElement.widget as Material;
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
    final Element destMaterialElement = tester.firstElement(
      find.ancestor(
        of: find.text('Closed'),
        matching: find.byType(Material),
      ),
    );
    final Material closedMaterial = destMaterialElement.widget as Material;
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

    // The fade-out takes 1/5 of 300ms. Let's jump to the midpoint of that.
    await tester.pump(const Duration(milliseconds: 30)); // 300ms * 1/10 = 30ms
    final _TrackedData dataMidFadeOut = _TrackedData(
      destMaterialElement.widget as Material,
      tester.getRect(
        find.byElementPredicate((Element e) => e == destMaterialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataClosed,
      biggerMaterial: dataMidFadeOut,
      tester: tester,
    );
    expect(dataMidFadeOut.material.color, isNot(dataClosed.material.color));
    expect(_getOpacity(tester, 'Open'), 0.0);
    expect(_getOpacity(tester, 'Closed'), lessThan(1.0));
    expect(_getOpacity(tester, 'Closed'), greaterThan(0.0));

    // Let's jump to the crossover point at 1/5 of 300ms.
    await tester.pump(const Duration(milliseconds: 30)); // 300ms * 1/5 = 60ms
    final _TrackedData dataMidpoint = _TrackedData(
      destMaterialElement.widget as Material,
      tester.getRect(
        find.byElementPredicate((Element e) => e == destMaterialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataMidFadeOut,
      biggerMaterial: dataMidpoint,
      tester: tester,
    );
    expect(dataMidpoint.material.color, Colors.red);
    expect(_getOpacity(tester, 'Open'), moreOrLessEquals(0.0));
    expect(_getOpacity(tester, 'Closed'), moreOrLessEquals(0.0));

    // Let's jump to the middle of the fade-in at 3/5 of 300ms
    await tester.pump(const Duration(milliseconds: 120)); // 300ms * 3/5 = 180ms
    final _TrackedData dataMidFadeIn = _TrackedData(
      destMaterialElement.widget as Material,
      tester.getRect(
        find.byElementPredicate((Element e) => e == destMaterialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataMidpoint,
      biggerMaterial: dataMidFadeIn,
      tester: tester,
    );
    expect(dataMidFadeIn.material.color, isNot(dataMidpoint.material.color));
    expect(_getOpacity(tester, 'Open'), lessThan(1.0));
    expect(_getOpacity(tester, 'Open'), greaterThan(0.0));
    expect(_getOpacity(tester, 'Closed'), 0.0);

    // Let's jump almost to the end of the transition.
    await tester.pump(const Duration(milliseconds: 120));
    final _TrackedData dataTransitionDone = _TrackedData(
      destMaterialElement.widget as Material,
      tester.getRect(
        find.byElementPredicate((Element e) => e == destMaterialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataMidFadeIn,
      biggerMaterial: dataTransitionDone,
      tester: tester,
    );
    expect(
      dataTransitionDone.material.color,
      isNot(dataMidFadeIn.material.color),
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
    final Element finalMaterialElement = tester.firstElement(
      find.ancestor(
        of: find.text('Open'),
        matching: find.byType(Material),
      ),
    );
    final _TrackedData dataOpen = _TrackedData(
      finalMaterialElement.widget as Material,
      tester.getRect(
        find.byElementPredicate((Element e) => e == finalMaterialElement),
      ),
    );
    expect(dataOpen.material.color, dataTransitionDone.material.color);
    expect(dataOpen.material.elevation, dataTransitionDone.material.elevation);
    expect(dataOpen.radius, dataTransitionDone.radius);
    expect(dataOpen.rect, dataTransitionDone.rect);
  });

  testWidgets('Container closes - Fade through', (WidgetTester tester) async {
    const ShapeBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    );

    await tester.pumpWidget(_boilerplate(
      child: Center(
        child: OpenContainer(
          closedColor: Colors.green,
          openColor: Colors.blue,
          middleColor: Colors.red,
          closedElevation: 4.0,
          openElevation: 8.0,
          closedShape: shape,
          closedBuilder: (BuildContext context, VoidCallback _) {
            return const Text('Closed');
          },
          openBuilder: (BuildContext context, VoidCallback _) {
            return const Text('Open');
          },
          transitionType: ContainerTransitionType.fadeThrough,
        ),
      ),
    ));

    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();

    // Open container has the expected properties.
    expect(find.text('Closed'), findsNothing);
    expect(find.text('Open'), findsOneWidget);
    final Element initialMaterialElement = tester.firstElement(
      find.ancestor(
        of: find.text('Open'),
        matching: find.byType(Material),
      ),
    );
    final _TrackedData dataOpen = _TrackedData(
      initialMaterialElement.widget as Material,
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
    await tester.pump();

    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    final Element materialElement = tester.firstElement(
      find.ancestor(
        of: find.text('Open'),
        matching: find.byType(Material),
      ),
    );
    final _TrackedData dataTransitionStart = _TrackedData(
      materialElement.widget as Material,
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

    // Jump to mid-point of fade-out: 1/10 of 300ms.
    await tester.pump(const Duration(milliseconds: 30)); // 300ms * 1/10 = 30ms
    final _TrackedData dataMidFadeOut = _TrackedData(
      materialElement.widget as Material,
      tester.getRect(
        find.byElementPredicate((Element e) => e == materialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataMidFadeOut,
      biggerMaterial: dataTransitionStart,
      tester: tester,
    );
    expect(
      dataMidFadeOut.material.color,
      isNot(dataTransitionStart.material.color),
    );
    expect(_getOpacity(tester, 'Closed'), 0.0);
    expect(_getOpacity(tester, 'Open'), lessThan(1.0));
    expect(_getOpacity(tester, 'Open'), greaterThan(0.0));

    // Let's jump to the crossover point at 1/5 of 300ms.
    await tester.pump(const Duration(milliseconds: 30)); // 300ms * 1/5 = 60ms
    final _TrackedData dataMidpoint = _TrackedData(
      materialElement.widget as Material,
      tester.getRect(
        find.byElementPredicate((Element e) => e == materialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataMidpoint,
      biggerMaterial: dataMidFadeOut,
      tester: tester,
    );
    expect(dataMidpoint.material.color, Colors.red);
    expect(_getOpacity(tester, 'Open'), moreOrLessEquals(0.0));
    expect(_getOpacity(tester, 'Closed'), moreOrLessEquals(0.0));

    // Let's jump to the middle of the fade-in at 3/5 of 300ms
    await tester.pump(const Duration(milliseconds: 120)); // 300ms * 3/5 = 180ms
    final _TrackedData dataMidFadeIn = _TrackedData(
      materialElement.widget as Material,
      tester.getRect(
        find.byElementPredicate((Element e) => e == materialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataMidFadeIn,
      biggerMaterial: dataMidpoint,
      tester: tester,
    );
    expect(dataMidFadeIn.material.color, isNot(dataMidpoint.material.color));
    expect(_getOpacity(tester, 'Closed'), lessThan(1.0));
    expect(_getOpacity(tester, 'Closed'), greaterThan(0.0));
    expect(_getOpacity(tester, 'Open'), 0.0);

    // Let's jump almost to the end of the transition.
    await tester.pump(const Duration(milliseconds: 120));
    final _TrackedData dataTransitionDone = _TrackedData(
      materialElement.widget as Material,
      tester.getRect(
        find.byElementPredicate((Element e) => e == materialElement),
      ),
    );
    _expectMaterialPropertiesHaveAdvanced(
      smallerMaterial: dataTransitionDone,
      biggerMaterial: dataMidFadeIn,
      tester: tester,
    );
    expect(
      dataTransitionDone.material.color,
      isNot(dataMidFadeIn.material.color),
    );
    expect(_getOpacity(tester, 'Closed'), 1.0);
    expect(_getOpacity(tester, 'Open'), 0.0);
    expect(dataTransitionDone.material.color, Colors.green);
    expect(dataTransitionDone.material.elevation, 4.0);
    expect(dataTransitionDone.radius, 8.0);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Open'), findsNothing); // No longer in the tree.
    expect(find.text('Closed'), findsOneWidget);
    final Element finalMaterialElement = tester.firstElement(
      find.ancestor(
        of: find.text('Closed'),
        matching: find.byType(Material),
      ),
    );
    final _TrackedData dataClosed = _TrackedData(
      finalMaterialElement.widget as Material,
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
    late VoidCallback open, close;
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
            return const DummyStatefulWidget();
          },
        ),
      ),
    ));

    await tester.tap(find.text('Closed'));
    await tester.pump(const Duration(milliseconds: 200));

    final State stateOpening = tester.state(find.byType(DummyStatefulWidget));
    expect(stateOpening, isNotNull);

    await tester.pumpAndSettle();
    expect(find.text('Closed'), findsNothing);
    final State stateOpen = tester.state(find.byType(DummyStatefulWidget));
    expect(stateOpen, isNotNull);
    expect(stateOpen, same(stateOpening));

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Closed'), findsOneWidget);
    final State stateClosing = tester.state(find.byType(DummyStatefulWidget));
    expect(stateClosing, isNotNull);
    expect(stateClosing, same(stateOpen));
  });

  testWidgets('closed widget keeps state', (WidgetTester tester) async {
    late VoidCallback open;
    await tester.pumpWidget(_boilerplate(
      child: Center(
        child: OpenContainer(
          closedBuilder: (BuildContext context, VoidCallback action) {
            open = action;
            return const DummyStatefulWidget();
          },
          openBuilder: (BuildContext context, VoidCallback action) {
            return const Text('Open');
          },
        ),
      ),
    ));

    final State stateClosed = tester.state(find.byType(DummyStatefulWidget));
    expect(stateClosed, isNotNull);

    open();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Open'), findsOneWidget);

    final State stateOpening = tester.state(find.byType(DummyStatefulWidget));
    expect(stateOpening, same(stateClosed));

    await tester.pumpAndSettle();
    expect(find.byType(DummyStatefulWidget), findsNothing);
    expect(find.text('Open'), findsOneWidget);
    final State stateOpen = tester.state(find.byType(
      DummyStatefulWidget,
      skipOffstage: false,
    ));
    expect(stateOpen, same(stateOpening));

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Open'), findsOneWidget);
    final State stateClosing = tester.state(find.byType(DummyStatefulWidget));
    expect(stateClosing, same(stateOpen));

    await tester.pumpAndSettle();
    expect(find.text('Open'), findsNothing);
    final State stateClosedAgain =
        tester.state(find.byType(DummyStatefulWidget));
    expect(stateClosedAgain, same(stateClosing));
  });

  testWidgets('closes to the right location when src position has changed',
      (WidgetTester tester) async {
    final Widget openContainer = OpenContainer(
      closedBuilder: (BuildContext context, VoidCallback action) {
        return const SizedBox(
          height: 100,
          width: 100,
          child: Text('Closed'),
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
    final Widget openContainer = _boilerplate(
      child: Center(
        child: OpenContainer(
          closedBuilder: (BuildContext context, VoidCallback action) {
            return const _SizableContainer(
              initialSize: 100,
              child: Text('Closed'),
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

    final _SizableContainerState containerState = tester.state(find.byType(
      _SizableContainer,
      skipOffstage: false,
    ));
    containerState.size = 200;

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

  testWidgets('does not crash when disposed right after pop',
      (WidgetTester tester) async {
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

  testWidgets('Scrim', (WidgetTester tester) async {
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

    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Open'), findsNothing);
    await tester.tap(find.text('Closed'));
    await tester.pump();

    expect(_getScrimColor(tester), Colors.transparent);

    await tester.pump(const Duration(milliseconds: 50));
    final Color halfwayFadeInColor = _getScrimColor(tester);
    expect(halfwayFadeInColor, isNot(Colors.transparent));
    expect(halfwayFadeInColor, isNot(Colors.black54));

    // Scrim is done fading in early.
    await tester.pump(const Duration(milliseconds: 50));
    expect(_getScrimColor(tester), Colors.black54);

    await tester.pump(const Duration(milliseconds: 200));
    expect(_getScrimColor(tester), Colors.black54);

    await tester.pumpAndSettle();

    // Close the container
    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pump();

    expect(_getScrimColor(tester), Colors.black54);

    // Scrim takes longer to fade out (vs. fade in).
    await tester.pump(const Duration(milliseconds: 200));
    final Color halfwayFadeOutColor = _getScrimColor(tester);
    expect(halfwayFadeOutColor, isNot(Colors.transparent));
    expect(halfwayFadeOutColor, isNot(Colors.black54));

    await tester.pump(const Duration(milliseconds: 100));
    expect(_getScrimColor(tester), Colors.transparent);
  });

  testWidgets(
      'Container partly offscreen can be opened without crash - vertical',
      (WidgetTester tester) async {
    final ScrollController controller =
        ScrollController(initialScrollOffset: 50);
    await tester.pumpWidget(Center(
      child: SizedBox(
        height: 200,
        width: 200,
        child: _boilerplate(
          child: ListView.builder(
            cacheExtent: 0,
            controller: controller,
            itemBuilder: (BuildContext context, int index) {
              return OpenContainer(
                closedBuilder: (BuildContext context, VoidCallback _) {
                  return SizedBox(
                    height: 100,
                    width: 100,
                    child: Text('Closed $index'),
                  );
                },
                openBuilder: (BuildContext context, VoidCallback _) {
                  return Text('Open $index');
                },
              );
            },
          ),
        ),
      ),
    ));

    void expectClosedState() {
      expect(find.text('Closed 0'), findsOneWidget);
      expect(find.text('Closed 1'), findsOneWidget);
      expect(find.text('Closed 2'), findsOneWidget);
      expect(find.text('Closed 3'), findsNothing);

      expect(find.text('Open 0'), findsNothing);
      expect(find.text('Open 1'), findsNothing);
      expect(find.text('Open 2'), findsNothing);
      expect(find.text('Open 3'), findsNothing);
    }

    expectClosedState();

    // Open container that's partly visible at top.
    await tester.tapAt(
      tester.getBottomRight(find.text('Closed 0')) - const Offset(20, 20),
    );
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Closed 0'), findsNothing);
    expect(find.text('Open 0'), findsOneWidget);

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pump();
    await tester.pumpAndSettle();
    expectClosedState();

    // Open container that's partly visible at bottom.
    await tester.tapAt(
      tester.getTopLeft(find.text('Closed 2')) + const Offset(20, 20),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Closed 2'), findsNothing);
    expect(find.text('Open 2'), findsOneWidget);
  });

  testWidgets(
      'Container partly offscreen can be opened without crash - horizontal',
      (WidgetTester tester) async {
    final ScrollController controller =
        ScrollController(initialScrollOffset: 50);
    await tester.pumpWidget(Center(
      child: SizedBox(
        height: 200,
        width: 200,
        child: _boilerplate(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            cacheExtent: 0,
            controller: controller,
            itemBuilder: (BuildContext context, int index) {
              return OpenContainer(
                closedBuilder: (BuildContext context, VoidCallback _) {
                  return SizedBox(
                    height: 100,
                    width: 100,
                    child: Text('Closed $index'),
                  );
                },
                openBuilder: (BuildContext context, VoidCallback _) {
                  return Text('Open $index');
                },
              );
            },
          ),
        ),
      ),
    ));

    void expectClosedState() {
      expect(find.text('Closed 0'), findsOneWidget);
      expect(find.text('Closed 1'), findsOneWidget);
      expect(find.text('Closed 2'), findsOneWidget);
      expect(find.text('Closed 3'), findsNothing);

      expect(find.text('Open 0'), findsNothing);
      expect(find.text('Open 1'), findsNothing);
      expect(find.text('Open 2'), findsNothing);
      expect(find.text('Open 3'), findsNothing);
    }

    expectClosedState();

    // Open container that's partly visible at left edge.
    await tester.tapAt(
      tester.getBottomRight(find.text('Closed 0')) - const Offset(20, 20),
    );
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Closed 0'), findsNothing);
    expect(find.text('Open 0'), findsOneWidget);

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pump();
    await tester.pumpAndSettle();
    expectClosedState();

    // Open container that's partly visible at right edge.
    await tester.tapAt(
      tester.getTopLeft(find.text('Closed 2')) + const Offset(20, 20),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Closed 2'), findsNothing);
    expect(find.text('Open 2'), findsOneWidget);
  });

  testWidgets(
      'Container can be dismissed after container widget itself is removed without crash',
      (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(child: _RemoveOpenContainerExample()));

    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Closed', skipOffstage: false), findsOneWidget);
    expect(find.text('Open'), findsNothing);

    await tester.tap(find.text('Open the container'));
    await tester.pumpAndSettle();

    expect(find.text('Closed'), findsNothing);
    expect(find.text('Closed', skipOffstage: false), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);

    await tester.tap(find.text('Remove the container'));
    await tester.pump();

    expect(find.text('Closed'), findsNothing);
    expect(find.text('Closed', skipOffstage: false), findsNothing);
    expect(find.text('Open'), findsOneWidget);

    await tester.tap(find.text('Close the container'));
    await tester.pumpAndSettle();

    expect(find.text('Closed'), findsNothing);
    expect(find.text('Closed', skipOffstage: false), findsNothing);
    expect(find.text('Open'), findsNothing);
    expect(find.text('Container has been removed'), findsOneWidget);
  });

  testWidgets('onClosed callback is called when container has closed',
      (WidgetTester tester) async {
    bool hasClosed = false;
    final Widget openContainer = OpenContainer(
      onClosed: (dynamic _) {
        hasClosed = true;
      },
      closedBuilder: (BuildContext context, VoidCallback action) {
        return GestureDetector(
          onTap: action,
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

    await tester.pumpWidget(
      _boilerplate(child: openContainer),
    );

    expect(find.text('Open'), findsNothing);
    expect(find.text('Closed'), findsOneWidget);
    expect(hasClosed, isFalse);

    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsNothing);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsNothing);
    expect(find.text('Closed'), findsOneWidget);
    expect(hasClosed, isTrue);
  });

  testWidgets(
      'onClosed callback receives popped value when container has closed',
      (WidgetTester tester) async {
    bool? value = false;
    final Widget openContainer = OpenContainer<bool>(
      onClosed: (bool? poppedValue) {
        value = poppedValue;
      },
      closedBuilder: (BuildContext context, VoidCallback action) {
        return GestureDetector(
          onTap: action,
          child: const Text('Closed'),
        );
      },
      openBuilder:
          (BuildContext context, CloseContainerActionCallback<bool> action) {
        return GestureDetector(
          onTap: () => action(returnValue: true),
          child: const Text('Open'),
        );
      },
    );

    await tester.pumpWidget(
      _boilerplate(child: openContainer),
    );

    expect(find.text('Open'), findsNothing);
    expect(find.text('Closed'), findsOneWidget);
    expect(value, isFalse);

    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Closed'), findsNothing);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsNothing);
    expect(find.text('Closed'), findsOneWidget);
    expect(value, isTrue);
  });

  testWidgets('closedBuilder has anti-alias clip by default',
      (WidgetTester tester) async {
    final GlobalKey closedBuilderKey = GlobalKey();
    final Widget openContainer = OpenContainer(
      closedBuilder: (BuildContext context, VoidCallback action) {
        return Text('Close', key: closedBuilderKey);
      },
      openBuilder:
          (BuildContext context, CloseContainerActionCallback<bool> action) {
        return const Text('Open');
      },
    );

    await tester.pumpWidget(
      _boilerplate(child: openContainer),
    );

    final Finder closedBuilderMaterial = find
        .ancestor(
          of: find.byKey(closedBuilderKey),
          matching: find.byType(Material),
        )
        .first;

    final Material material = tester.widget<Material>(closedBuilderMaterial);
    expect(material.clipBehavior, Clip.antiAlias);
  });

  testWidgets('closedBuilder has no clip', (WidgetTester tester) async {
    final GlobalKey closedBuilderKey = GlobalKey();
    final Widget openContainer = OpenContainer(
      closedBuilder: (BuildContext context, VoidCallback action) {
        return Text('Close', key: closedBuilderKey);
      },
      openBuilder:
          (BuildContext context, CloseContainerActionCallback<bool> action) {
        return const Text('Open');
      },
      clipBehavior: Clip.none,
    );

    await tester.pumpWidget(
      _boilerplate(child: openContainer),
    );

    final Finder closedBuilderMaterial = find
        .ancestor(
          of: find.byKey(closedBuilderKey),
          matching: find.byType(Material),
        )
        .first;

    final Material material = tester.widget<Material>(closedBuilderMaterial);
    expect(material.clipBehavior, Clip.none);
  });

  Widget createRootNavigatorTest({
    required Key appKey,
    required Key nestedNavigatorKey,
    required bool useRootNavigator,
  }) {
    return Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: MaterialApp(
          key: appKey,
          // a nested navigator
          home: Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: Navigator(
                key: nestedNavigatorKey,
                onGenerateRoute: (RouteSettings route) {
                  return MaterialPageRoute<dynamic>(
                    settings: route,
                    builder: (BuildContext context) {
                      return OpenContainer(
                        useRootNavigator: useRootNavigator,
                        closedBuilder: (BuildContext context, _) {
                          return const Text('Closed');
                        },
                        openBuilder: (BuildContext context, _) {
                          return const Text('Opened');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
      'Verify that "useRootNavigator: false" uses the correct navigator',
      (WidgetTester tester) async {
    const Key appKey = Key('App');
    const Key nestedNavigatorKey = Key('Nested Navigator');

    await tester.pumpWidget(createRootNavigatorTest(
        appKey: appKey,
        nestedNavigatorKey: nestedNavigatorKey,
        useRootNavigator: false));

    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();

    expect(
        find.descendant(of: find.byKey(appKey), matching: find.text('Opened')),
        findsOneWidget);

    expect(
        find.descendant(
            of: find.byKey(nestedNavigatorKey), matching: find.text('Opened')),
        findsOneWidget);
  });

  testWidgets('Verify that "useRootNavigator: true" uses the correct navigator',
      (WidgetTester tester) async {
    const Key appKey = Key('App');
    const Key nestedNavigatorKey = Key('Nested Navigator');

    await tester.pumpWidget(createRootNavigatorTest(
        appKey: appKey,
        nestedNavigatorKey: nestedNavigatorKey,
        useRootNavigator: true));

    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();

    expect(
        find.descendant(of: find.byKey(appKey), matching: find.text('Opened')),
        findsOneWidget);

    expect(
        find.descendant(
            of: find.byKey(nestedNavigatorKey), matching: find.text('Opened')),
        findsNothing);
  });

  testWidgets('Verify correct opened size  when "useRootNavigator: false"',
      (WidgetTester tester) async {
    const Key appKey = Key('App');
    const Key nestedNavigatorKey = Key('Nested Navigator');

    await tester.pumpWidget(createRootNavigatorTest(
        appKey: appKey,
        nestedNavigatorKey: nestedNavigatorKey,
        useRootNavigator: false));

    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.text('Opened')),
        equals(tester.getSize(find.byKey(nestedNavigatorKey))));
  });

  testWidgets('Verify correct opened size  when "useRootNavigator: true"',
      (WidgetTester tester) async {
    const Key appKey = Key('App');
    const Key nestedNavigatorKey = Key('Nested Navigator');

    await tester.pumpWidget(createRootNavigatorTest(
        appKey: appKey,
        nestedNavigatorKey: nestedNavigatorKey,
        useRootNavigator: true));

    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.text('Opened')),
        equals(tester.getSize(find.byKey(appKey))));
  });

  testWidgets(
    'Verify routeSettings passed to Navigator',
    (WidgetTester tester) async {
      const RouteSettings routeSettings = RouteSettings(
        name: 'route-name',
        arguments: 'arguments',
      );

      final Widget openContainer = OpenContainer(
        routeSettings: routeSettings,
        closedBuilder: (BuildContext context, VoidCallback action) {
          return GestureDetector(
            onTap: action,
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

      await tester.pumpWidget(_boilerplate(child: openContainer));

      // Open the container
      await tester.tap(find.text('Closed'));
      await tester.pumpAndSettle();

      // Expect the last route pushed to the navigator to contain RouteSettings
      // equal to the RouteSettings passed to the OpenContainer
      final ModalRoute<dynamic> modalRoute = ModalRoute.of(
        tester.element(find.text('Open')),
      )!;
      expect(modalRoute.settings, routeSettings);
    },
  );
}

Color _getScrimColor(WidgetTester tester) {
  return tester
      .widget<ColoredBox>(
        find.descendant(
          of: find.byType(Container),
          matching: find.byType(ColoredBox),
        ),
      )
      .color;
}

void _expectMaterialPropertiesHaveAdvanced({
  required _TrackedData biggerMaterial,
  required _TrackedData smallerMaterial,
  required WidgetTester tester,
}) {
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
  final FadeTransition widget = tester.firstWidget(find.ancestor(
    of: find.text(label),
    matching: find.byType(FadeTransition),
  ));
  // Verify that the correct fade transition is retrieved (i.e. not something from a page transition).
  assert(widget.child is Builder && widget.child?.key is GlobalKey, '$widget');
  return widget.opacity.value;
}

class _TrackedData {
  _TrackedData(this.material, this.rect);

  final Material material;
  final Rect rect;

  double get radius => _getRadius(material);
}

double _getRadius(Material material) {
  final RoundedRectangleBorder? shape =
      material.shape as RoundedRectangleBorder?;
  if (shape == null) {
    return 0.0;
  }
  final BorderRadius radius = shape.borderRadius as BorderRadius;
  return radius.topRight.x;
}

Widget _boilerplate({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

class _SizableContainer extends StatefulWidget {
  const _SizableContainer({required this.initialSize, required this.child});

  final double initialSize;
  final Widget child;

  @override
  State<_SizableContainer> createState() => _SizableContainerState();
}

class _SizableContainerState extends State<_SizableContainer> {
  @override
  void initState() {
    super.initState();
    _size = widget.initialSize;
  }

  double get size => _size;
  late double _size;
  set size(double value) {
    if (value == _size) {
      return;
    }
    setState(() {
      _size = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: widget.child,
    );
  }
}

class _RemoveOpenContainerExample extends StatefulWidget {
  @override
  __RemoveOpenContainerExampleState createState() =>
      __RemoveOpenContainerExampleState();
}

class __RemoveOpenContainerExampleState
    extends State<_RemoveOpenContainerExample> {
  bool removeOpenContainerWidget = false;

  @override
  Widget build(BuildContext context) {
    return removeOpenContainerWidget
        ? const Text('Container has been removed')
        : OpenContainer(
            closedBuilder: (BuildContext context, VoidCallback action) =>
                Column(
              children: <Widget>[
                const Text('Closed'),
                ElevatedButton(
                  onPressed: action,
                  child: const Text('Open the container'),
                ),
              ],
            ),
            openBuilder: (BuildContext context, VoidCallback action) => Column(
              children: <Widget>[
                const Text('Open'),
                ElevatedButton(
                  onPressed: action,
                  child: const Text('Close the container'),
                ),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        removeOpenContainerWidget = true;
                      });
                    },
                    child: const Text('Remove the container')),
              ],
            ),
          );
  }
}

class DummyStatefulWidget extends StatefulWidget {
  const DummyStatefulWidget({super.key});

  @override
  State<StatefulWidget> createState() => DummyState();
}

class DummyState extends State<DummyStatefulWidget> {
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

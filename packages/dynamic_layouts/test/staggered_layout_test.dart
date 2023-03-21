// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dynamic_layouts/dynamic_layouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DynamicGridView', () {
    testWidgets(
        'DynamicGridView works when using DynamicSliverGridDelegateWithFixedCrossAxisCount',
        (WidgetTester tester) async {
      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.physicalSizeTestValue = const Size(400, 100);

      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicGridView(
              gridDelegate:
                  const DynamicSliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              children: List<Widget>.generate(
                50,
                (int index) => SizedBox(
                  height: index % 2 * 20 + 20,
                  child: Text('Index $index'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Index 0'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 0')), Offset.zero);
      expect(find.text('Index 1'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 1')), const Offset(100.0, 0.0));
      expect(find.text('Index 2'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 2')), const Offset(200.0, 0.0));
      expect(find.text('Index 3'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 3')), const Offset(300.0, 0.0));
      expect(find.text('Index 4'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 4')), const Offset(0.0, 20.0));

      expect(find.text('Index 14'), findsNothing);
      expect(find.text('Index 47'), findsNothing);
      expect(find.text('Index 48'), findsNothing);
      expect(find.text('Index 49'), findsNothing);
    });

    testWidgets(
        'DynamicGridView works when using DynamicSliverGridDelegateWithMaxCrossAxisExtent',
        (WidgetTester tester) async {
      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.physicalSizeTestValue = const Size(440, 100);

      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicGridView(
              gridDelegate:
                  const DynamicSliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 100,
              ),
              children: List<Widget>.generate(
                50,
                (int index) => SizedBox(
                  height: index % 2 * 20 + 20,
                  child: Text('Index $index'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Index 0'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 0')), Offset.zero);
      expect(find.text('Index 1'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 1')), const Offset(88.0, 0.0));
      expect(find.text('Index 2'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 2')), const Offset(176.0, 0.0));
      expect(find.text('Index 3'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 3')), const Offset(264.0, 0.0));
      expect(find.text('Index 4'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 4')), const Offset(352.0, 0.0));

      expect(find.text('Index 47'), findsNothing);
      expect(find.text('Index 48'), findsNothing);
      expect(find.text('Index 49'), findsNothing);
    });
  });
  group('DynamicGridView.staggered', () {
    testWidgets('DynamicGridView.staggered works with simple layout',
        (WidgetTester tester) async {
      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.physicalSizeTestValue = const Size(400, 100);

      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicGridView.staggered(
              crossAxisCount: 4,
              children: List<Widget>.generate(
                50,
                (int index) => SizedBox(
                  height: index % 2 * 50 + 20,
                  child: Text('Index $index'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Index 0'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 0')), Offset.zero);
      expect(find.text('Index 1'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 1')), const Offset(100.0, 0.0));
      expect(find.text('Index 2'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 2')), const Offset(200.0, 0.0));
      expect(find.text('Index 3'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 3')), const Offset(300.0, 0.0));
      expect(find.text('Index 4'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 4')), const Offset(0.0, 20.0));
      expect(find.text('Index 5'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Index 5')),
        const Offset(200.0, 20.0),
      );
      expect(find.text('Index 6'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 6')), const Offset(0.0, 40.0));
      expect(find.text('Index 7'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 7')), const Offset(0.0, 60.0));

      expect(find.text('Index 12'), findsNothing); // 100 - 120
      expect(find.text('Index 47'), findsNothing);
      expect(find.text('Index 48'), findsNothing);
      expect(find.text('Index 49'), findsNothing);
    });
    testWidgets('DynamicGridView.staggered works with a horizontal grid',
        (WidgetTester tester) async {
      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.physicalSizeTestValue = const Size(100, 500);

      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicGridView.staggered(
              crossAxisCount: 4,
              scrollDirection: Axis.horizontal,
              children: List<Widget>.generate(
                50,
                (int index) => SizedBox(
                  width: index % 3 * 50 + 20,
                  child: Text('Index $index'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Index 0'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 0')), Offset.zero);
      expect(find.text('Index 1'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 1')), const Offset(0.0, 125.0));
      expect(find.text('Index 2'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 2')), const Offset(0.0, 250.0));
      expect(find.text('Index 3'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 3')), const Offset(0.0, 375.0));
      expect(find.text('Index 4'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 4')), const Offset(20.0, 0.0));
      expect(find.text('Index 5'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Index 5')),
        const Offset(20.0, 375.0),
      );
      expect(find.text('Index 6'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Index 6')),
        const Offset(70.0, 125.0),
      );
      expect(find.text('Index 7'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Index 7')),
        const Offset(90.0, 0.0),
      );

      expect(find.text('Index 47'), findsNothing);
      expect(find.text('Index 48'), findsNothing);
      expect(find.text('Index 49'), findsNothing);
    });
    testWidgets('DynamicGridView.staggered works with a reversed grid',
        (WidgetTester tester) async {
      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.physicalSizeTestValue = const Size(600, 200);

      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicGridView.staggered(
              crossAxisCount: 4,
              reverse: true,
              children: List<Widget>.generate(
                50,
                (int index) => SizedBox(
                  height: index % 3 * 50 + 20,
                  child: Text('Index $index'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Index 0'), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('Index 0')),
        const Offset(0.0, 200.0),
      );
      expect(find.text('Index 1'), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('Index 1')),
        const Offset(150.0, 200.0),
      );
      expect(find.text('Index 2'), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('Index 2')),
        const Offset(300.0, 200.0),
      );
      expect(find.text('Index 3'), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('Index 3')),
        const Offset(450.0, 200.0),
      );
      expect(find.text('Index 4'), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('Index 4')),
        const Offset(0.0, 180.0),
      );
      expect(find.text('Index 5'), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('Index 5')),
        const Offset(450.0, 180.0),
      );
      expect(find.text('Index 6'), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('Index 6')),
        const Offset(150.0, 130.0),
      );
      expect(find.text('Index 7'), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('Index 7')),
        const Offset(0.0, 110.0),
      );

      expect(find.text('Index 47'), findsNothing);
      expect(find.text('Index 48'), findsNothing);
      expect(find.text('Index 49'), findsNothing);
    });

    testWidgets('DynamicGridView.staggered deletes children appropriately',
        (WidgetTester tester) async {
      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.physicalSizeTestValue = const Size(600, 1000);

      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      final List<Widget> children = List<Widget>.generate(
        50,
        (int index) => SizedBox(
          height: index % 3 * 50 + 20,
          child: Text('Index $index'),
        ),
      );
      late StateSetter stateSetter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              stateSetter = setState;
              return DynamicGridView.staggered(
                maxCrossAxisExtent: 150,
                children: <Widget>[...children],
              );
            }),
          ),
        ),
      );

      expect(find.text('Index 0'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 0')), Offset.zero);
      expect(find.text('Index 7'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 7')), const Offset(0.0, 90.0));
      expect(find.text('Index 8'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Index 8')),
        const Offset(150.0, 90.0),
      );
      expect(find.text('Index 27'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Index 27')),
        const Offset(300.0, 420.0),
      );
      expect(find.text('Index 28'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Index 28')),
        const Offset(300.0, 440.0),
      );
      expect(find.text('Index 32'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Index 32')),
        const Offset(300.0, 510.0),
      );
      expect(find.text('Index 33'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Index 33')),
        const Offset(150.0, 540.0),
      );

      stateSetter(() {
        children.removeAt(0);
      });

      await tester.pump();
      expect(find.text('Index 0'), findsNothing);

      expect(
        tester.getTopLeft(find.text('Index 8')),
        const Offset(0.0, 90.0),
      );
      expect(
        tester.getTopLeft(find.text('Index 28')),
        const Offset(150.0, 440.0),
      );
      expect(
        tester.getTopLeft(find.text('Index 33')),
        const Offset(0.0, 540.0),
      );
    });
  });
  group('DynamicGridView.builder', () {
    testWidgets('DynamicGridView.builder works with a staggered layout',
        (WidgetTester tester) async {
      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.physicalSizeTestValue = const Size(400, 100);

      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicGridView.builder(
              gridDelegate:
                  const DynamicSliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemBuilder: (BuildContext context, int index) => SizedBox(
                height: index % 2 * 50 + 20,
                child: Text('Index $index'),
              ),
              itemCount: 50,
            ),
          ),
        ),
      );

      expect(find.text('Index 0'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 0')), Offset.zero);
      expect(find.text('Index 1'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 1')), const Offset(100.0, 0.0));
      expect(find.text('Index 2'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 2')), const Offset(200.0, 0.0));
      expect(find.text('Index 3'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 3')), const Offset(300.0, 0.0));
      expect(find.text('Index 4'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 4')), const Offset(0.0, 20.0));
      expect(find.text('Index 5'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Index 5')),
        const Offset(200.0, 20.0),
      );
      expect(find.text('Index 6'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 6')), const Offset(0.0, 40.0));
      expect(find.text('Index 7'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Index 7')), const Offset(0.0, 60.0));

      expect(find.text('Index 12'), findsNothing); // 100 - 120
      expect(find.text('Index 47'), findsNothing);
      expect(find.text('Index 48'), findsNothing);
      expect(find.text('Index 49'), findsNothing);
    });

    testWidgets(
        'DynamicGridView.builder works with an infinite grid using a staggered layout',
        (WidgetTester tester) async {
      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.physicalSizeTestValue = const Size(400, 100);

      // TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
      // ignore: deprecated_member_use
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicGridView.builder(
              gridDelegate:
                  const DynamicSliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemBuilder: (BuildContext context, int index) => SizedBox(
                height: index % 2 * 50 + 20,
                child: Text('Index $index'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Index 0'), findsOneWidget);
      expect(find.text('Index 1'), findsOneWidget);
      expect(find.text('Index 2'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Index 500'), 500.0);
      await tester.pumpAndSettle();
      expect(find.text('Index 501'), findsOneWidget);
      expect(find.text('Index 502'), findsOneWidget);
    });
  });
}

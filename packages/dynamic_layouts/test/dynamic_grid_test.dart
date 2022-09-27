// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dynamic_layouts/dynamic_layouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DynamicGridView works with simple layout',
      (WidgetTester tester) async {
    // Can have no children
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView(
            gridDelegate: TestDelegate(crossAxisCount: 2),
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView(
            gridDelegate: TestDelegate(crossAxisCount: 2),
            children: List<Widget>.generate(
              50,
              (int index) => SizedBox.square(
                dimension: TestSimpleLayout.childExtent,
                child: Text('Index $index'),
              ),
            ),
          ),
        ),
      ),
    );

    // Only the visible tiles have been laid out.
    expect(find.text('Index 0'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Index 0')), Offset.zero);
    expect(find.text('Index 1'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Index 1')), const Offset(50.0, 0.0));
    expect(find.text('Index 2'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Index 2')), const Offset(0.0, 50.0));
    expect(find.text('Index 47'), findsNothing);
    expect(find.text('Index 48'), findsNothing);
    expect(find.text('Index 49'), findsNothing);
  });
  testWidgets('DynamicGridView.builder works with simple layout',
      (WidgetTester tester) async {
    // Only a few number of tiles
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.builder(
            gridDelegate: TestDelegate(crossAxisCount: 2),
            itemCount: 3,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox.square(
                dimension: TestSimpleLayout.childExtent,
                child: Text('Index $index'),
              );
            },
          ),
        ),
      ),
    );

    // Only the visible tiles have been laid out, up to itemCount.
    expect(find.text('Index 0'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Index 0')), Offset.zero);
    expect(find.text('Index 1'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Index 1')), const Offset(50.0, 0.0));
    expect(find.text('Index 2'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Index 2')), const Offset(0.0, 50.0));
    expect(find.text('Index 3'), findsNothing);
    expect(find.text('Index 4'), findsNothing);
    expect(find.text('Index 5'), findsNothing);

    // Infinite number of tiles
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicGridView.builder(
            gridDelegate: TestDelegate(crossAxisCount: 2),
            itemBuilder: (BuildContext context, int index) {
              return SizedBox.square(
                dimension: TestSimpleLayout.childExtent,
                child: Text('Index $index'),
              );
            },
          ),
        ),
      ),
    );

    // Only the visible tiles have been laid out.
    expect(find.text('Index 0'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Index 0')), Offset.zero);
    expect(find.text('Index 1'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Index 1')), const Offset(50.0, 0.0));
    expect(find.text('Index 2'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Index 2')), const Offset(0.0, 50.0));
    expect(find.text('Index 47'), findsNothing);
    expect(find.text('Index 48'), findsNothing);
    expect(find.text('Index 49'), findsNothing);
  });
}

class TestSimpleLayout extends DynamicSliverGridLayout {
  TestSimpleLayout({
    required this.crossAxisCount,
  });

  final int crossAxisCount;
  static const double childExtent = 50.0;

  @override
  DynamicSliverGridGeometry getGeometryForChildIndex(int index) {
    final double crossAxisStart = (index % crossAxisCount) * childExtent;
    return DynamicSliverGridGeometry(
      scrollOffset: (index ~/ crossAxisCount) * childExtent,
      crossAxisOffset: crossAxisStart,
      mainAxisExtent: childExtent,
      crossAxisExtent: childExtent,
    );
  }

  @override
  bool reachedTargetScrollOffset(double targetOffset) => true;

  @override
  DynamicSliverGridGeometry updateGeometryForChildIndex(
    int index,
    Size childSize,
  ) {
    return getGeometryForChildIndex(index);
  }
}

class TestDelegate extends SliverGridDelegateWithFixedCrossAxisCount {
  TestDelegate({required super.crossAxisCount});

  @override
  DynamicSliverGridLayout getLayout(SliverConstraints constraints) {
    return TestSimpleLayout(crossAxisCount: crossAxisCount);
  }
}

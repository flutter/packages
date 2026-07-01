// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

void main() {
  group('TreeView alignment', () {
    testWidgets('Default alignment - topLeft', (WidgetTester tester) async {
      final tree = <TreeViewNode<String>>[TreeViewNode<String>('Root')];

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 400,
                height: 400,
                child: TreeView<String>(
                  tree: tree,
                  treeNodeBuilder: (context, node, toggleAnimationStyle) =>
                      SizedBox(
                        key: const ValueKey<String>('Root'),
                        height: 100,
                        child: Text(node.content),
                      ),
                  treeRowBuilder: (node) =>
                      const TreeRow(extent: FixedTreeRowExtent(100)),
                ),
              ),
            ),
          ),
        ),
      );

      final Offset treeTopLeft = tester.getTopLeft(
        find.byType(TreeView<String>),
      );
      // Default is Alignment.topLeft (0, 0)
      final Finder root = find.byKey(const ValueKey<String>('Root'));
      expect(tester.getTopLeft(root) - treeTopLeft, Offset.zero);
    });

    testWidgets('Vertical alignment - center', (WidgetTester tester) async {
      const viewportHeight = 600.0;
      final tree = <TreeViewNode<String>>[TreeViewNode<String>('Root')];

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 400,
                height: viewportHeight,
                child: TreeView<String>(
                  tree: tree,
                  alignment: Alignment.center,
                  treeNodeBuilder: (context, node, toggleAnimationStyle) =>
                      SizedBox(
                        key: const ValueKey<String>('Root'),
                        height: 100,
                        child: Text(node.content),
                      ),
                  treeRowBuilder: (node) =>
                      const TreeRow(extent: FixedTreeRowExtent(100)),
                ),
              ),
            ),
          ),
        ),
      );

      final Offset treeTopLeft = tester.getTopLeft(
        find.byType(TreeView<String>),
      );
      // Tree is 100 high, viewport is 600 high. Centered means 250 offset.
      final Finder root = find.byKey(const ValueKey<String>('Root'));
      expect(tester.getTopLeft(root) - treeTopLeft, const Offset(0.0, 250.0));
    });
  });
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

const TreeRow row = TreeRow(extent: FixedTreeRowExtent(100));

TreeRow getTappableRow(TreeViewNode<String> node, VoidCallback callback) {
  return TreeRow(
    extent: const FixedTreeRowExtent(100),
    recognizerFactories: <Type, GestureRecognizerFactory>{
      TapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(),
        (TapGestureRecognizer t) => t.onTap = () => callback(),
      ),
    },
  );
}

TreeRow getMouseTrackingRow({
  PointerEnterEventListener? onEnter,
  PointerExitEventListener? onExit,
}) {
  return TreeRow(
    extent: const FixedTreeRowExtent(100),
    onEnter: onEnter,
    onExit: onExit,
    cursor: SystemMouseCursors.cell,
  );
}

List<TreeViewNode<String>> _setUpNodes() {
  return <TreeViewNode<String>>[
    TreeViewNode<String>('First'),
    TreeViewNode<String>(
      'Second',
      children: <TreeViewNode<String>>[
        TreeViewNode<String>(
          'alpha',
          children: <TreeViewNode<String>>[
            TreeViewNode<String>('uno'),
            TreeViewNode<String>('dos'),
            TreeViewNode<String>('tres'),
          ],
        ),
        TreeViewNode<String>('beta'),
        TreeViewNode<String>('kappa'),
      ],
    ),
    TreeViewNode<String>(
      'Third',
      expanded: true,
      children: <TreeViewNode<String>>[
        TreeViewNode<String>('gamma'),
        TreeViewNode<String>('delta'),
        TreeViewNode<String>('epsilon'),
      ],
    ),
    TreeViewNode<String>('Fourth'),
  ];
}

List<TreeViewNode<String>> treeNodes = _setUpNodes();

void main() {
  group('RenderTreeViewport', () {
    setUp(() {
      treeNodes = _setUpNodes();
    });

    test('asserts proper axis directions', () {
      RenderTreeViewport? treeViewport;
      expect(
        () {
          treeViewport = RenderTreeViewport(
            verticalOffset: TestOffset(),
            verticalAxisDirection: AxisDirection.up,
            horizontalOffset: TestOffset(),
            horizontalAxisDirection: AxisDirection.right,
            delegate: TreeRowBuilderDelegate(
              rowCount: 0,
              nodeBuilder: (_, __) => const SizedBox(),
              rowBuilder: (_) => const TreeRow(
                extent: FixedTreeRowExtent(40.0),
              ),
            ),
            activeAnimations: const <UniqueKey, TreeViewNodesAnimation>{},
            rowDepths: const <int, int>{},
            indentation: 0.0,
            childManager: _NullBuildContext(),
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('verticalAxisDirection == AxisDirection.down'),
          ),
        ),
      );
      expect(
        () {
          treeViewport = RenderTreeViewport(
            verticalOffset: TestOffset(),
            verticalAxisDirection: AxisDirection.down,
            horizontalOffset: TestOffset(),
            horizontalAxisDirection: AxisDirection.left,
            delegate: TreeRowBuilderDelegate(
              rowCount: 0,
              nodeBuilder: (_, __) => const SizedBox(),
              rowBuilder: (_) => const TreeRow(
                extent: FixedTreeRowExtent(40.0),
              ),
            ),
            activeAnimations: const <UniqueKey, TreeViewNodesAnimation>{},
            rowDepths: const <int, int>{},
            indentation: 0.0,
            childManager: _NullBuildContext(),
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('horizontalAxisDirection == AxisDirection.right'),
          ),
        ),
      );
      expect(treeViewport, isNull);
    });

    testWidgets('TreeRow gesture hit testing', (WidgetTester tester) async {
      int tapCounter = 0;
      final List<String> log = <String>[];
      final TreeView<String> treeView = TreeView<String>(
        tree: treeNodes,
        treeRowBuilder: (TreeViewNode<String> node) {
          if (node.depth! == 0) {
            return getTappableRow(
              node,
              () {
                log.add(node.content);
                tapCounter++;
              },
            );
          }
          return row;
        },
      );

      await tester.pumpWidget(MaterialApp(home: treeView));
      await tester.pumpAndSettle();

      // Root level rows are set up for taps.
      expect(tapCounter, 0);
      await tester.tap(find.text('First'));
      await tester.tap(find.text('Second'));
      await tester.tap(find.text('Third'));
      // Should not be logged.
      await tester.tap(find.text('gamma'));
      expect(tapCounter, 3);
      expect(log, <String>['First', 'Second', 'Third']);
    });

    testWidgets('mouse handling', (WidgetTester tester) async {
      int enterCounter = 0;
      int exitCounter = 0;
      final TreeView<String> treeView = TreeView<String>(
        tree: treeNodes,
        treeRowBuilder: (TreeViewNode<String> node) {
          if (node.depth! == 0) {
            return getMouseTrackingRow(
              onEnter: (_) => enterCounter++,
              onExit: (_) => exitCounter++,
            );
          }
          return row;
        },
      );

      await tester.pumpWidget(MaterialApp(home: treeView));
      await tester.pumpAndSettle();
      // Root row will respond to mouse, child will not
      final Offset rootRow = tester.getCenter(find.text('Second'));
      final Offset childRow = tester.getCenter(find.text('gamma'));
      final TestGesture gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: childRow);
      expect(enterCounter, 0);
      expect(exitCounter, 0);
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.basic,
      );
      await gesture.moveTo(rootRow);
      await tester.pumpAndSettle();
      expect(enterCounter, 1);
      expect(exitCounter, 0);
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.cell,
      );
      await gesture.moveTo(childRow);
      await tester.pumpAndSettle();
      expect(enterCounter, 1);
      expect(exitCounter, 1);
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.basic,
      );
    });

    testWidgets('Scrolls when there is enough content',
        (WidgetTester tester) async {
      final ScrollController verticalController = ScrollController();
      final ScrollController horizontalController = ScrollController();
      final TreeViewController treeController = TreeViewController();
      addTearDown(verticalController.dispose);
      addTearDown(horizontalController.dispose);
      final TreeView<String> treeView = TreeView<String>(
        controller: treeController,
        verticalDetails: ScrollableDetails.vertical(
          controller: verticalController,
        ),
        horizontalDetails: ScrollableDetails.horizontal(
          controller: horizontalController,
        ),
        tree: treeNodes,
        // Exaggerated to exceed viewport bounds.
        indentation: TreeViewIndentationType.custom(500),
        treeRowBuilder: (_) => row,
      );
      await tester.pumpWidget(MaterialApp(home: treeView));
      await tester.pump();
      expect(verticalController.position.pixels, 0.0);
      // Room to scroll
      expect(verticalController.position.maxScrollExtent, 100.0);
      expect(horizontalController.position.pixels, 0.0);
      // Room to scroll
      expect(horizontalController.position.maxScrollExtent, 90.0);

      verticalController.jumpTo(10.0);
      horizontalController.jumpTo(10.0);
      await tester.pump();
      expect(verticalController.position.pixels, 10.0);
      expect(verticalController.position.maxScrollExtent, 100.0);
      expect(horizontalController.position.pixels, 10.0);
      expect(horizontalController.position.maxScrollExtent, 90.0);

      // Collapse a node. The horizontal extent should change to zero,
      // and the position should corrrect.
      treeController.toggleNode(treeController.getNodeFor('Third')!);
      await tester.pumpAndSettle();
      expect(horizontalController.position.pixels, 0.0);
      expect(horizontalController.position.maxScrollExtent, 0.0);
    });

    group('Layout', () {
      setUp(() {
        treeNodes = _setUpNodes();
      });

      testWidgets('Basic', (WidgetTester tester) async {
        // Default layout, custom indentation values, row extents.
        TreeView<String> treeView = TreeView<String>(
          tree: treeNodes,
        );
        await tester.pumpWidget(MaterialApp(home: treeView));
        await tester.pump();
        expect(find.text('First'), findsOneWidget);
        expect(
          tester.getRect(find.text('First')),
          const Rect.fromLTRB(46.0, 8.0, 286.0, 32.0),
        );
        expect(find.text('Second'), findsOneWidget);
        expect(
          tester.getRect(find.text('Second')),
          const Rect.fromLTRB(46.0, 48.0, 334.0, 72.0),
        );
        expect(find.text('Third'), findsOneWidget);
        expect(
          tester.getRect(find.text('Third')),
          const Rect.fromLTRB(46.0, 88.0, 286.0, 112.0),
        );
        expect(find.text('gamma'), findsOneWidget);
        expect(
          tester.getRect(find.text('gamma')),
          const Rect.fromLTRB(56.0, 128.0, 296.0, 152.0),
        );
        expect(find.text('delta'), findsOneWidget);
        expect(
          tester.getRect(find.text('delta')),
          const Rect.fromLTRB(56.0, 168.0, 296.0, 192.0),
        );
        expect(find.text('epsilon'), findsOneWidget);
        expect(
          tester.getRect(find.text('epsilon')),
          const Rect.fromLTRB(56.0, 208.0, 392.0, 232.0),
        );
        expect(find.text('Fourth'), findsOneWidget);
        expect(
          tester.getRect(find.text('Fourth')),
          const Rect.fromLTRB(46.0, 248.0, 334.0, 272.0),
        );

        treeView = TreeView<String>(
          tree: treeNodes,
          indentation: TreeViewIndentationType.none,
        );
        await tester.pumpWidget(MaterialApp(home: treeView));
        await tester.pump();
        expect(find.text('First'), findsOneWidget);
        expect(
          tester.getRect(find.text('First')),
          const Rect.fromLTRB(46.0, 8.0, 286.0, 32.0),
        );
        expect(find.text('Second'), findsOneWidget);
        expect(
          tester.getRect(find.text('Second')),
          const Rect.fromLTRB(46.0, 48.0, 334.0, 72.0),
        );
        expect(find.text('Third'), findsOneWidget);
        expect(
          tester.getRect(find.text('Third')),
          const Rect.fromLTRB(46.0, 88.0, 286.0, 112.0),
        );
        expect(find.text('gamma'), findsOneWidget);
        expect(
          tester.getRect(find.text('gamma')),
          const Rect.fromLTRB(46.0, 128.0, 286.0, 152.0),
        );
        expect(find.text('delta'), findsOneWidget);
        expect(
          tester.getRect(find.text('delta')),
          const Rect.fromLTRB(46.0, 168.0, 286.0, 192.0),
        );
        expect(find.text('epsilon'), findsOneWidget);
        expect(
          tester.getRect(find.text('epsilon')),
          const Rect.fromLTRB(46.0, 208.0, 382.0, 232.0),
        );
        expect(find.text('Fourth'), findsOneWidget);
        expect(
          tester.getRect(find.text('Fourth')),
          const Rect.fromLTRB(46.0, 248.0, 334.0, 272.0),
        );

        treeView = TreeView<String>(
          tree: treeNodes,
          indentation: TreeViewIndentationType.custom(50.0),
        );
        await tester.pumpWidget(MaterialApp(home: treeView));
        await tester.pump();
        expect(find.text('First'), findsOneWidget);
        expect(
          tester.getRect(find.text('First')),
          const Rect.fromLTRB(46.0, 8.0, 286.0, 32.0),
        );
        expect(find.text('Second'), findsOneWidget);
        expect(
          tester.getRect(find.text('Second')),
          const Rect.fromLTRB(46.0, 48.0, 334.0, 72.0),
        );
        expect(find.text('Third'), findsOneWidget);
        expect(
          tester.getRect(find.text('Third')),
          const Rect.fromLTRB(46.0, 88.0, 286.0, 112.0),
        );
        expect(find.text('gamma'), findsOneWidget);
        expect(
          tester.getRect(find.text('gamma')),
          const Rect.fromLTRB(96.0, 128.0, 336.0, 152.0),
        );
        expect(find.text('delta'), findsOneWidget);
        expect(
          tester.getRect(find.text('delta')),
          const Rect.fromLTRB(96.0, 168.0, 336.0, 192.0),
        );
        expect(find.text('epsilon'), findsOneWidget);
        expect(
          tester.getRect(find.text('epsilon')),
          const Rect.fromLTRB(96.0, 208.0, 432.0, 232.0),
        );
        expect(find.text('Fourth'), findsOneWidget);
        expect(
          tester.getRect(find.text('Fourth')),
          const Rect.fromLTRB(46.0, 248.0, 334.0, 272.0),
        );

        treeView = TreeView<String>(
          tree: treeNodes,
          treeRowBuilder: (TreeViewNode<String> node) {
            if (node.depth! == 1) {
              // extent == 100
              return row;
            }
            return TreeView.defaultTreeRowBuilder(node);
          },
        );
        await tester.pumpWidget(MaterialApp(home: treeView));
        await tester.pump();
        expect(find.text('First'), findsOneWidget);
        expect(
          tester.getRect(find.text('First')),
          const Rect.fromLTRB(46.0, 8.0, 286.0, 32.0),
        );
        expect(find.text('Second'), findsOneWidget);
        expect(
          tester.getRect(find.text('Second')),
          const Rect.fromLTRB(46.0, 48.0, 334.0, 72.0),
        );
        expect(find.text('Third'), findsOneWidget);
        expect(
          tester.getRect(find.text('Third')),
          const Rect.fromLTRB(46.0, 88.0, 286.0, 112.0),
        );
        expect(find.text('gamma'), findsOneWidget);
        expect(
          tester.getRect(find.text('gamma')),
          const Rect.fromLTRB(56.0, 146.0, 296.0, 194.0),
        );
        expect(find.text('delta'), findsOneWidget);
        expect(
          tester.getRect(find.text('delta')),
          const Rect.fromLTRB(56.0, 246.0, 296.0, 294.0),
        );
        expect(find.text('epsilon'), findsOneWidget);
        expect(
          tester.getRect(find.text('epsilon')),
          const Rect.fromLTRB(56.0, 346.0, 392.0, 394.0),
        );
        expect(find.text('Fourth'), findsOneWidget);
        expect(
          tester.getRect(find.text('Fourth')),
          const Rect.fromLTRB(46.0, 428.0, 334.0, 452.0),
        );
      });

      testWidgets('Animating node segment', (WidgetTester tester) async {
        TreeView<String> treeView = TreeView<String>(tree: treeNodes);
        await tester.pumpWidget(MaterialApp(home: treeView));
        await tester.pump();
        expect(find.text('alpha'), findsNothing);
        await tester.tap(find.byType(Icon).first);
        await tester.pump();
        // It has now been inserted into the tree, along with the other children
        // of the node.
        expect(find.text('alpha'), findsOneWidget);
        expect(
          tester.getRect(find.text('alpha')),
          const Rect.fromLTRB(56.0, -32.0, 296.0, -8.0),
        );
        expect(find.text('beta'), findsOneWidget);
        expect(
          tester.getRect(find.text('beta')),
          const Rect.fromLTRB(56.0, 8.0, 248.0, 32.0),
        );
        expect(find.text('kappa'), findsOneWidget);
        expect(
          tester.getRect(find.text('kappa')),
          const Rect.fromLTRB(56.0, 48.0, 296.0, 72.0),
        );
        // Progress the animation.
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          tester.getRect(find.text('alpha')).top.floor(),
          8.0,
        );
        expect(find.text('beta'), findsOneWidget);
        expect(
          tester.getRect(find.text('beta')).top.floor(),
          48.0,
        );
        expect(find.text('kappa'), findsOneWidget);
        expect(
          tester.getRect(find.text('kappa')).top.floor(),
          88.0,
        );
        // Complete the animation
        await tester.pumpAndSettle();
        expect(find.text('alpha'), findsOneWidget);
        expect(
          tester.getRect(find.text('alpha')),
          const Rect.fromLTRB(56.0, 88.0, 296.0, 112.0),
        );
        expect(find.text('beta'), findsOneWidget);
        expect(
          tester.getRect(find.text('beta')),
          const Rect.fromLTRB(56.0, 128.0, 248.0, 152.0),
        );
        expect(find.text('kappa'), findsOneWidget);
        expect(
          tester.getRect(find.text('kappa')),
          const Rect.fromLTRB(56.0, 168.0, 296.0, 192.0),
        );

        // Customize the animation
        treeView = TreeView<String>(
          tree: treeNodes,
          // ignore: prefer_const_constructors
          toggleAnimationStyle: AnimationStyle(
            duration: const Duration(milliseconds: 500),
            curve: Curves.bounceIn,
          ),
        );
        await tester.pumpWidget(MaterialApp(home: treeView));
        await tester.pump();
        // Still visible from earlier.
        expect(find.text('alpha'), findsOneWidget);
        expect(
          tester.getRect(find.text('alpha')),
          const Rect.fromLTRB(56.0, 88.0, 296.0, 112.0),
        );
        // Collapse the node now
        await tester.tap(find.byType(Icon).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('alpha'), findsOneWidget);
        expect(
          tester.getRect(find.text('alpha')).top.floor(),
          -22,
        );
        expect(find.text('beta'), findsOneWidget);
        expect(
          tester.getRect(find.text('beta')).top.floor(),
          18,
        );
        expect(find.text('kappa'), findsOneWidget);
        expect(
          tester.getRect(find.text('kappa')).top.floor(),
          58,
        );
        // Progress the animation.
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('alpha'), findsOneWidget);
        expect(
          tester.getRect(find.text('alpha')).top.floor(),
          -25,
        );
        expect(find.text('beta'), findsOneWidget);
        expect(
          tester.getRect(find.text('beta')).top.floor(),
          15,
        );
        expect(find.text('kappa'), findsOneWidget);
        expect(
          tester.getRect(find.text('kappa')).top.floor(),
          55.0,
        );
        // Complete the animation
        await tester.pumpAndSettle();
        expect(find.text('alpha'), findsNothing);

        // Disable the animation
        treeView = TreeView<String>(
          tree: treeNodes,
          toggleAnimationStyle: AnimationStyle.noAnimation,
        );
        await tester.pumpWidget(MaterialApp(home: treeView));
        await tester.pump();
        // Not in the tree.
        expect(find.text('alpha'), findsNothing);
        // Collapse the node now
        await tester.tap(find.byType(Icon).first);
        await tester.pump();
        // No animating
        expect(find.text('alpha'), findsOneWidget);
        expect(
          tester.getRect(find.text('alpha')),
          const Rect.fromLTRB(56.0, 88.0, 296.0, 112.0),
        );
        expect(find.text('beta'), findsOneWidget);
        expect(
          tester.getRect(find.text('beta')),
          const Rect.fromLTRB(56.0, 128.0, 248.0, 152.0),
        );
        expect(find.text('kappa'), findsOneWidget);
        expect(
          tester.getRect(find.text('kappa')),
          const Rect.fromLTRB(56.0, 168.0, 296.0, 192.0),
        );
      });

      testWidgets('Multiple animating node segments',
          (WidgetTester tester) async {
        final TreeViewController controller = TreeViewController();
        await tester.pumpWidget(MaterialApp(
          home: TreeView<String>(
            tree: treeNodes,
            controller: controller,
          ),
        ));
        await tester.pump();
        expect(find.text('Second'), findsOneWidget);
        expect(find.text('alpha'), findsNothing); // Second is collapsed
        expect(find.text('Third'), findsOneWidget);
        expect(find.text('gamma'), findsOneWidget); // Third is expanded

        expect(
          tester.getRect(find.text('Second')),
          const Rect.fromLTRB(46.0, 48.0, 334.0, 72.0),
        );
        expect(
          tester.getRect(find.text('Third')),
          const Rect.fromLTRB(46.0, 88.0, 286.0, 112.0),
        );
        expect(
          tester.getRect(find.text('gamma')),
          const Rect.fromLTRB(56.0, 128.0, 296.0, 152.0),
        );

        // Trigger two animations to run together.
        // Collapse Third
        await tester.tap(find.byType(Icon).last);
        // Expand Second
        await tester.tap(find.byType(Icon).first);
        await tester.pump(const Duration(milliseconds: 15));
        // Third is collapsing
        expect(
          tester.getRect(find.text('Third')),
          const Rect.fromLTRB(46.0, 88.0, 286.0, 112.0),
        );
        expect(
          tester.getRect(find.text('gamma')),
          const Rect.fromLTRB(56.0, 128.0, 296.0, 152.0),
        );
        // Second is expanding
        expect(
          tester.getRect(find.text('Second')),
          const Rect.fromLTRB(46.0, 48.0, 334.0, 72.0),
        );
        // alpha has been added and is animating into view.
        expect(
          tester.getRect(find.text('alpha')).top.floor(),
          -32.0,
        );
        await tester.pump(const Duration(milliseconds: 15));
        // Third is still collapsing. Third is sliding down
        // as Seconds's children slide in, gamma is still exiting.
        expect(
          tester.getRect(find.text('Third')).top.floor(),
          100.0,
        );
        // gamma appears to not have moved, this is because it is
        // intersecting both animations, the positive offset of
        // Second animation == the negative offset of Third
        expect(
          tester.getRect(find.text('gamma')),
          const Rect.fromLTRB(56.0, 128.0, 296.0, 152.0),
        );
        // Second is still expanding
        expect(
          tester.getRect(find.text('Second')),
          const Rect.fromLTRB(46.0, 48.0, 334.0, 72.0),
        );
        // alpha is still animating into view.
        expect(
          tester.getRect(find.text('alpha')).top.floor(),
          -20.0,
        );
        // Progress the animation further
        await tester.pump(const Duration(milliseconds: 15));
        // Third is still collapsing. Third is sliding down
        // as Seconds's children slide in, gamma is still exiting.
        expect(
          tester.getRect(find.text('Third')).top.floor(),
          112.0,
        );
        // gamma appears to not have moved, this is because it is
        // intersecting both animations, the positive offset of
        // Second animation == the negative offset of Third
        expect(
          tester.getRect(find.text('gamma')),
          const Rect.fromLTRB(56.0, 128.0, 296.0, 152.0),
        );
        // Second is still expanding
        expect(
          tester.getRect(find.text('Second')),
          const Rect.fromLTRB(46.0, 48.0, 334.0, 72.0),
        );
        // alpha is still animating into view.
        expect(
          tester.getRect(find.text('alpha')).top.floor(),
          -8.0,
        );
        // Complete the animations
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.text('Third')),
          const Rect.fromLTRB(46.0, 208.0, 286.0, 232.0),
        );
        // gamma has left the building
        expect(find.text('gamma'), findsNothing);
        expect(
          tester.getRect(find.text('Second')),
          const Rect.fromLTRB(46.0, 48.0, 334.0, 72.0),
        );
        // alpha is in place.
        expect(
          tester.getRect(find.text('alpha')),
          const Rect.fromLTRB(56.0, 88.0, 296.0, 112.0),
        );
      });
    });

    group('Painting', () {
      setUp(() {
        treeNodes = _setUpNodes();
      });

      testWidgets('only paints visible rows', (WidgetTester tester) async {
        final ScrollController verticalController = ScrollController();
        addTearDown(verticalController.dispose);
        final TreeView<String> treeView = TreeView<String>(
          treeRowBuilder: (_) => const TreeRow(extent: FixedTreeRowExtent(400)),
          tree: treeNodes,
          verticalDetails: ScrollableDetails.vertical(
            controller: verticalController,
          ),
        );

        await tester.pumpWidget(MaterialApp(home: treeView));
        await tester.pump();
        expect(verticalController.position.pixels, 0.0);
        expect(verticalController.position.maxScrollExtent, 600.0);

        bool rowNeedsPaint(String row) {
          return find.text(row).evaluate().first.renderObject!.debugNeedsPaint;
        }

        expect(rowNeedsPaint('First'), isFalse);
        expect(rowNeedsPaint('Second'), isFalse);
        expect(rowNeedsPaint('Third'), isTrue); // In cacheExtent
        expect(find.text('gamma'), findsNothing); // outside of cacheExtent
      });

      testWidgets('paints decorations correctly', (WidgetTester tester) async {
        final ScrollController verticalController = ScrollController();
        final ScrollController horizontalController = ScrollController();
        addTearDown(verticalController.dispose);
        addTearDown(horizontalController.dispose);
        const TreeRowDecoration rootForegroundDecoration = TreeRowDecoration(
          color: Colors.red,
        );
        const TreeRowDecoration rootBackgroundDecoration = TreeRowDecoration(
          color: Colors.blue,
        );
        const TreeRowDecoration foregroundDecoration = TreeRowDecoration(
          color: Colors.orange,
        );
        const TreeRowDecoration backgroundDecoration = TreeRowDecoration(
          color: Colors.green,
        );
        final TreeView<String> treeView = TreeView<String>(
          verticalDetails: ScrollableDetails.vertical(
            controller: verticalController,
          ),
          horizontalDetails: ScrollableDetails.horizontal(
            controller: horizontalController,
          ),
          tree: treeNodes,
          treeRowBuilder: (TreeViewNode<String> node) {
            return row.copyWith(
              backgroundDecoration: node.depth! == 0
                  ? rootBackgroundDecoration
                  : backgroundDecoration,
              foregroundDecoration: node.depth! == 0
                  ? rootForegroundDecoration
                  : foregroundDecoration,
            );
          },
        );
        await tester.pumpWidget(MaterialApp(home: treeView));
        await tester.pump();
        expect(verticalController.position.pixels, 0.0);
        expect(verticalController.position.maxScrollExtent, 100.0);

        expect(
          find.byType(TreeViewport),
          paints
            ..rect(
              rect: const Rect.fromLTRB(0.0, 0.0, 800.0, 100.0),
              color: const Color(0xff2196f3),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 100.0, 800.0, 200.0),
              color: const Color(0xff2196f3),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 200.0, 800.0, 300.0),
              color: const Color(0xff2196f3),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 300.0, 800.0, 400.0),
              color: const Color(0xff4caf50),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 400.0, 800.0, 500.0),
              color: const Color(0xff4caf50),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 500.0, 800.0, 600.0),
              color: const Color(0xff4caf50),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 600.0, 800.0, 700.0),
              color: const Color(0xff2196f3),
            )
            ..paragraph()
            ..paragraph()
            ..paragraph()
            ..paragraph()
            ..paragraph()
            ..paragraph()
            ..paragraph()
            ..rect(
              rect: const Rect.fromLTRB(0.0, 0.0, 800.0, 100.0),
              color: const Color(0xFFF44336),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 100.0, 800.0, 200.0),
              color: const Color(0xFFF44336),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 200.0, 800.0, 300.0),
              color: const Color(0xFFF44336),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 300.0, 800.0, 400.0),
              color: const Color(0xFFFF9800),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 400.0, 800.0, 500.0),
              color: const Color(0xFFFF9800),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 500.0, 800.0, 600.0),
              color: const Color(0xFFFF9800),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 600.0, 800.0, 700.0),
              color: const Color(0xFFF44336),
            ),
        );
        // Change the scroll offset
        verticalController.jumpTo(10.0);
        await tester.pump();
        expect(
          find.byType(TreeViewport),
          paints
            ..rect(
              rect: const Rect.fromLTRB(0.0, -10.0, 800.0, 90.0),
              color: const Color(0xff2196f3),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 90.0, 800.0, 190.0),
              color: const Color(0xff2196f3),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 190.0, 800.0, 290.0),
              color: const Color(0xff2196f3),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 290.0, 800.0, 390.0),
              color: const Color(0xff4caf50),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 390.0, 800.0, 490.0),
              color: const Color(0xff4caf50),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 490.0, 800.0, 590.0),
              color: const Color(0xff4caf50),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 590.0, 800.0, 690.0),
              color: const Color(0xff2196f3),
            )
            ..paragraph()
            ..paragraph()
            ..paragraph()
            ..paragraph()
            ..paragraph()
            ..paragraph()
            ..paragraph()
            ..rect(
              rect: const Rect.fromLTRB(0.0, -10.0, 800.0, 90.0),
              color: const Color(0xFFF44336),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 90.0, 800.0, 190.0),
              color: const Color(0xFFF44336),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 190.0, 800.0, 290.0),
              color: const Color(0xFFF44336),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 290.0, 800.0, 390.0),
              color: const Color(0xFFFF9800),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 390.0, 800.0, 490.0),
              color: const Color(0xFFFF9800),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 490.0, 800.0, 590.0),
              color: const Color(0xFFFF9800),
            )
            ..rect(
              rect: const Rect.fromLTRB(0.0, 590.0, 800.0, 690.0),
              color: const Color(0xFFF44336),
            ),
        );
      });
    });
  });
}

class TestOffset extends ViewportOffset {
  TestOffset();

  @override
  bool get allowImplicitScrolling => throw UnimplementedError();

  @override
  Future<void> animateTo(
    double to, {
    required Duration duration,
    required Curve curve,
  }) {
    throw UnimplementedError();
  }

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    throw UnimplementedError();
  }

  @override
  bool applyViewportDimension(double viewportDimension) {
    throw UnimplementedError();
  }

  @override
  void correctBy(double correction) {}

  @override
  bool get hasPixels => throw UnimplementedError();

  @override
  void jumpTo(double pixels) {}

  @override
  double get pixels => throw UnimplementedError();

  @override
  ScrollDirection get userScrollDirection => throw UnimplementedError();
}

class _NullBuildContext implements BuildContext, TwoDimensionalChildManager {
  @override
  Object? noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

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
    extent: const FixedTableSpanExtent(100),
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

final List<TreeViewNode<String>> treeNodes = <TreeViewNode<String>>[
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

void main() {
  group('RenderTreeViewport', () {
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
            traversalOrder: TreeViewTraversalOrder.depthFirst,
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
            traversalOrder: TreeViewTraversalOrder.depthFirst,
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

    test('Sets mainAxis based on traversal order', () {
      RenderTreeViewport treeViewport = RenderTreeViewport(
        verticalOffset: TestOffset(),
        verticalAxisDirection: AxisDirection.down,
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
        traversalOrder: TreeViewTraversalOrder.depthFirst,
        childManager: _NullBuildContext(),
      );
      expect(treeViewport.mainAxis, Axis.vertical);
      expect(treeViewport.traversalOrder, TreeViewTraversalOrder.depthFirst);

      treeViewport = RenderTreeViewport(
        verticalOffset: TestOffset(),
        verticalAxisDirection: AxisDirection.down,
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
        traversalOrder: TreeViewTraversalOrder.breadthFirst,
        childManager: _NullBuildContext(),
      );
      expect(treeViewport.mainAxis, Axis.horizontal);
      expect(treeViewport.traversalOrder, TreeViewTraversalOrder.breadthFirst);
    });

    testWidgets('TableSpan gesture hit testing', (WidgetTester tester) async {
      int tapCounter = 0;
      final List<String> log = <String>[];
      final TreeView<String> treeView = TreeView<String>(
        tree: treeNodes,
        treeRowBuilder: (TreeViewNode<dynamic> node) {
          if (node.depth! == 0) {
            return getTappableRow(
              node as TreeViewNode<String>,
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
          treeRowBuilder: (TreeViewNode<dynamic> node) {
            if (node.depth! == 0) {
              return getMouseTrackingRow(
                onEnter: (_) => enterCounter++,
                onExit: (_) => exitCounter++,
              );
            }
            return row;
          });

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

    group('Layout', () {
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
          treeRowBuilder: (TreeViewNode<dynamic> node) {
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
          animationStyle: AnimationStyle(duration: const Duration(milliseconds: 500), curve: Curves.bounceIn,),
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
          animationStyle: AnimationStyle.noAnimation,
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

      testWidgets(
          'Multiple animating node segments', (WidgetTester tester) async {

          });
    });

    group('Painting', () {
      testWidgets('only paints visible rows', (WidgetTester tester) async {

      });
      testWidgets('paints decorations in correct order',
          (WidgetTester tester) async {

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
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

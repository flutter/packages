// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

List<TreeViewNode<String>> simpleNodeSet = <TreeViewNode<String>>[
  TreeViewNode<String>('Root 0'),
  TreeViewNode<String>(
    'Root 1',
    expanded: true,
    children: <TreeViewNode<String>>[
      TreeViewNode<String>('Child 1:0'),
      TreeViewNode<String>('Child 1:1'),
    ],
  ),
  TreeViewNode<String>(
    'Root 2',
    children: <TreeViewNode<String>>[
      TreeViewNode<String>('Child 2:0'),
      TreeViewNode<String>('Child 2:1'),
    ],
  ),
  TreeViewNode<String>('Root 3'),
];

void main() {
  group('TreeViewNode', () {
    test('getters, toString', () {
      final List<TreeViewNode<String>> children = <TreeViewNode<String>>[
        TreeViewNode<String>('child'),
      ];
      final TreeViewNode<String> node = TreeViewNode<String>(
        'parent',
        children: children,
        expanded: true,
      );
      expect(node.content, 'parent');
      expect(node.children, children);
      expect(node.isExpanded, isTrue);
      expect(node.children.first.content, 'child');
      expect(node.children.first.children.isEmpty, isTrue);
      expect(node.children.first.isExpanded, isFalse);
      // Set by TreeView when built for tree integrity
      expect(node.depth, isNull);
      expect(node.parent, isNull);
      expect(node.children.first.depth, isNull);
      expect(node.children.first.parent, isNull);

      expect(
        node.toString(),
        'TreeViewNode: parent, depth: null, parent, expanded: true',
      );
      expect(
        node.children.first.toString(),
        'TreeViewNode: child, depth: null, leaf',
      );
    });

    testWidgets('TreeView sets ups parent and depth properties',
        (WidgetTester tester) async {
      final List<TreeViewNode<String>> children = <TreeViewNode<String>>[
        TreeViewNode<String>('child'),
      ];
      final TreeViewNode<String> node = TreeViewNode<String>(
        'parent',
        children: children,
        expanded: true,
      );
      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: <TreeViewNode<String>>[node],
        ),
      ));
      expect(node.content, 'parent');
      expect(node.children, children);
      expect(node.isExpanded, isTrue);
      expect(node.children.first.content, 'child');
      expect(node.children.first.children.isEmpty, isTrue);
      expect(node.children.first.isExpanded, isFalse);
      // Set by TreeView when built for tree integrity
      expect(node.depth, 0);
      expect(node.parent, isNull);
      expect(node.children.first.depth, 1);
      expect(node.children.first.parent, node);

      expect(
        node.toString(),
        'TreeViewNode: parent, depth: root, parent, expanded: true',
      );
      expect(
        node.children.first.toString(),
        'TreeViewNode: child, depth: 1, leaf',
      );
    });
  });

  group('TreeViewController', () {
    setUp(() {
      // Reset node conditions for each test.
      simpleNodeSet = <TreeViewNode<String>>[
        TreeViewNode<String>('Root 0'),
        TreeViewNode<String>(
          'Root 1',
          expanded: true,
          children: <TreeViewNode<String>>[
            TreeViewNode<String>('Child 1:0'),
            TreeViewNode<String>('Child 1:1'),
          ],
        ),
        TreeViewNode<String>(
          'Root 2',
          children: <TreeViewNode<String>>[
            TreeViewNode<String>('Child 2:0'),
            TreeViewNode<String>('Child 2:1'),
          ],
        ),
        TreeViewNode<String>('Root 3'),
      ];
    });
    testWidgets('Can set controller on TreeView', (WidgetTester tester) async {
      final TreeViewController controller = TreeViewController();
      TreeViewController? returnedController;
      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: simpleNodeSet,
          controller: controller,
          treeNodeBuilder: (
            BuildContext context,
            TreeViewNode<String> node,
            AnimationStyle toggleAnimationStyle,
          ) {
            returnedController ??= TreeViewController.of(context);
            return TreeView.defaultTreeNodeBuilder(
              context,
              node,
              toggleAnimationStyle,
            );
          },
        ),
      ));
      expect(controller, returnedController);
    });

    testWidgets('Can get default controller on TreeView',
        (WidgetTester tester) async {
      TreeViewController? returnedController;
      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: simpleNodeSet,
          treeNodeBuilder: (
            BuildContext context,
            TreeViewNode<String> node,
            AnimationStyle toggleAnimationStyle,
          ) {
            returnedController ??= TreeViewController.maybeOf(context);
            return TreeView.defaultTreeNodeBuilder(
              context,
              node,
              toggleAnimationStyle,
            );
          },
        ),
      ));
      expect(returnedController, isNotNull);
    });

    testWidgets('Can get node for TreeViewNode.content',
        (WidgetTester tester) async {
      final TreeViewController controller = TreeViewController();
      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: simpleNodeSet,
          controller: controller,
        ),
      ));

      expect(controller.getNodeFor('Root 0'), simpleNodeSet[0]);
    });

    testWidgets('Can get isExpanded for a node', (WidgetTester tester) async {
      final TreeViewController controller = TreeViewController();
      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: simpleNodeSet,
          controller: controller,
        ),
      ));
      expect(
        controller.isExpanded(simpleNodeSet[0]),
        isFalse,
      );
      expect(
        controller.isExpanded(simpleNodeSet[1]),
        isTrue,
      );
    });

    testWidgets('Can get isActive for a node', (WidgetTester tester) async {
      final TreeViewController controller = TreeViewController();
      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: simpleNodeSet,
          controller: controller,
        ),
      ));
      expect(
        controller.isActive(simpleNodeSet[0]),
        isTrue,
      );
      expect(
        controller.isActive(simpleNodeSet[1]),
        isTrue,
      );
      // The parent 'Root 2' is not expanded, so its children are not active.
      expect(
        controller.isExpanded(simpleNodeSet[2]),
        isFalse,
      );
      expect(
        controller.isActive(simpleNodeSet[2].children[0]),
        isFalse,
      );
    });

    testWidgets('Can toggleNode, to collapse or expand',
        (WidgetTester tester) async {
      final TreeViewController controller = TreeViewController();
      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: simpleNodeSet,
          controller: controller,
        ),
      ));

      // The parent 'Root 2' is not expanded, so its children are not active.
      expect(
        controller.isExpanded(simpleNodeSet[2]),
        isFalse,
      );
      expect(
        controller.isActive(simpleNodeSet[2].children[0]),
        isFalse,
      );
      // Toggle 'Root 2' to expand it
      controller.toggleNode(simpleNodeSet[2]);
      expect(
        controller.isExpanded(simpleNodeSet[2]),
        isTrue,
      );
      expect(
        controller.isActive(simpleNodeSet[2].children[0]),
        isTrue,
      );

      // The parent 'Root 1' is expanded, so its children are active.
      expect(
        controller.isExpanded(simpleNodeSet[1]),
        isTrue,
      );
      expect(
        controller.isActive(simpleNodeSet[1].children[0]),
        isTrue,
      );
      // Collapse 'Root 1'
      controller.toggleNode(simpleNodeSet[1]);
      expect(
        controller.isExpanded(simpleNodeSet[1]),
        isFalse,
      );
      expect(
        controller.isActive(simpleNodeSet[1].children[0]),
        isTrue,
      );
      // Nodes are not removed from the active list until the collapse animation
      // completes. The parent's expansions status also does not change until the
      // animation completes.
      await tester.pumpAndSettle();
      expect(
        controller.isExpanded(simpleNodeSet[1]),
        isFalse,
      );
      expect(
        controller.isActive(simpleNodeSet[1].children[0]),
        isFalse,
      );
    });

    testWidgets('Can expandNode, then collapseAll',
        (WidgetTester tester) async {
      final TreeViewController controller = TreeViewController();
      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: simpleNodeSet,
          controller: controller,
        ),
      ));

      // The parent 'Root 2' is not expanded, so its children are not active.
      expect(
        controller.isExpanded(simpleNodeSet[2]),
        isFalse,
      );
      expect(
        controller.isActive(simpleNodeSet[2].children[0]),
        isFalse,
      );
      // Expand 'Root 2'
      controller.expandNode(simpleNodeSet[2]);
      expect(
        controller.isExpanded(simpleNodeSet[2]),
        isTrue,
      );
      expect(
        controller.isActive(simpleNodeSet[2].children[0]),
        isTrue,
      );

      // Both parents from our simple node set are expanded.
      // 'Root 1'
      expect(controller.isExpanded(simpleNodeSet[1]), isTrue);
      // 'Root 2'
      expect(controller.isExpanded(simpleNodeSet[2]), isTrue);
      // Collapse both.
      controller.collapseAll();
      await tester.pumpAndSettle();
      // Both parents from our simple node set have collapsed.
      // 'Root 1'
      expect(controller.isExpanded(simpleNodeSet[1]), isFalse);
      // 'Root 2'
      expect(controller.isExpanded(simpleNodeSet[2]), isFalse);
    });

    testWidgets('Can collapseNode, then expandAll',
        (WidgetTester tester) async {
      final TreeViewController controller = TreeViewController();
      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: simpleNodeSet,
          controller: controller,
        ),
      ));

      // The parent 'Root 1' is expanded, so its children are active.
      expect(
        controller.isExpanded(simpleNodeSet[1]),
        isTrue,
      );
      expect(
        controller.isActive(simpleNodeSet[1].children[0]),
        isTrue,
      );
      // Collapse 'Root 1'
      controller.collapseNode(simpleNodeSet[1]);
      expect(
        controller.isExpanded(simpleNodeSet[1]),
        isFalse,
      );
      expect(
        controller.isActive(simpleNodeSet[1].children[0]),
        isTrue,
      );
      // Nodes are not removed from the active list until the collapse animation
      // completes.
      await tester.pumpAndSettle();
      expect(
        controller.isActive(simpleNodeSet[1].children[0]),
        isFalse,
      );

      // Both parents from our simple node set are collapsed.
      // 'Root 1'
      expect(controller.isExpanded(simpleNodeSet[1]), isFalse);
      // 'Root 2'
      expect(controller.isExpanded(simpleNodeSet[2]), isFalse);
      // Expand both.
      controller.expandAll();
      // Both parents from our simple node set are expanded.
      // 'Root 1'
      expect(controller.isExpanded(simpleNodeSet[1]), isTrue);
      // 'Root 2'
      expect(controller.isExpanded(simpleNodeSet[2]), isTrue);
    });
  });

  group('TreeView', () {
    setUp(() {
      // Reset node conditions for each test.
      simpleNodeSet = <TreeViewNode<String>>[
        TreeViewNode<String>('Root 0'),
        TreeViewNode<String>(
          'Root 1',
          expanded: true,
          children: <TreeViewNode<String>>[
            TreeViewNode<String>('Child 1:0'),
            TreeViewNode<String>('Child 1:1'),
          ],
        ),
        TreeViewNode<String>(
          'Root 2',
          children: <TreeViewNode<String>>[
            TreeViewNode<String>('Child 2:0'),
            TreeViewNode<String>('Child 2:1'),
          ],
        ),
        TreeViewNode<String>('Root 3'),
      ];
    });
    test('asserts proper axis directions', () {
      TreeView<String>? treeView;
      expect(
        () {
          treeView = TreeView<String>(
            tree: simpleNodeSet,
            verticalDetails: const ScrollableDetails.vertical(reverse: true),
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('verticalDetails.direction == AxisDirection.down'),
          ),
        ),
      );
      expect(
        () {
          treeView = TreeView<String>(
            tree: simpleNodeSet,
            horizontalDetails:
                const ScrollableDetails.horizontal(reverse: true),
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('horizontalDetails.direction == AxisDirection.right'),
          ),
        ),
      );
      expect(treeView, isNull);
    });

    testWidgets('.toggleNodeWith, onNodeToggle', (WidgetTester tester) async {
      final TreeViewController controller = TreeViewController();
      // The default node builder wraps the leading icon with toggleNodeWith.
      bool toggled = false;
      TreeViewNode<String>? toggledNode;
      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: simpleNodeSet,
          controller: controller,
          onNodeToggle: (TreeViewNode<String> node) {
            toggled = true;
            toggledNode = node;
          },
        ),
      ));
      expect(controller.isExpanded(simpleNodeSet[1]), isTrue);
      await tester.tap(find.byType(Icon).first);
      await tester.pump();
      expect(controller.isExpanded(simpleNodeSet[1]), isFalse);
      expect(toggled, isTrue);
      expect(toggledNode, simpleNodeSet[1]);
      await tester.pumpAndSettle();
      expect(controller.isExpanded(simpleNodeSet[1]), isFalse);
      toggled = false;
      toggledNode = null;

      // Use toggleNodeWith to make the whole row trigger the node state.
      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: simpleNodeSet,
          controller: controller,
          onNodeToggle: (TreeViewNode<String> node) {
            toggled = true;
            toggledNode = node;
          },
          treeNodeBuilder: (
            BuildContext context,
            TreeViewNode<String> node,
            AnimationStyle toggleAnimationStyle,
          ) {
            final Duration animationDuration = toggleAnimationStyle.duration ??
                TreeView.defaultAnimationDuration;
            final Curve animationCurve =
                toggleAnimationStyle.curve ?? TreeView.defaultAnimationCurve;
            // This makes the whole row trigger toggling.
            return TreeView.wrapChildToToggleNode(
              node: node,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: <Widget>[
                  // Icon for parent nodes
                  SizedBox.square(
                    dimension: 30.0,
                    child: node.children.isNotEmpty
                        ? AnimatedRotation(
                            turns: node.isExpanded ? 0.25 : 0.0,
                            duration: animationDuration,
                            curve: animationCurve,
                            child: const Icon(IconData(0x25BA), size: 14),
                          )
                        : null,
                  ),
                  // Spacer
                  const SizedBox(width: 8.0),
                  // Content
                  Text(node.content),
                ]),
              ),
            );
          },
        ),
      ));
      // Still collapsed from earlier
      expect(controller.isExpanded(simpleNodeSet[1]), isFalse);
      // Tapping on the text instead of the Icon.
      await tester.tap(find.text('Root 1'));
      await tester.pump();
      expect(controller.isExpanded(simpleNodeSet[1]), isTrue);
      expect(toggled, isTrue);
      expect(toggledNode, simpleNodeSet[1]);
    });

    testWidgets('AnimationStyle is piped through to node builder',
        (WidgetTester tester) async {
      AnimationStyle? style;
      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: simpleNodeSet,
          treeNodeBuilder: (
            BuildContext context,
            TreeViewNode<String> node,
            AnimationStyle toggleAnimationStyle,
          ) {
            style ??= toggleAnimationStyle;
            return Text(node.content);
          },
        ),
      ));
      // Default
      expect(
        style,
        AnimationStyle(
          duration: TreeView.defaultAnimationDuration,
          curve: TreeView.defaultAnimationCurve,
        ),
      );

      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: simpleNodeSet,
          toggleAnimationStyle: AnimationStyle.noAnimation,
          treeNodeBuilder: (
            BuildContext context,
            TreeViewNode<String> node,
            AnimationStyle toggleAnimationStyle,
          ) {
            style = toggleAnimationStyle;
            return Text(node.content);
          },
        ),
      ));
      expect(style, isNotNull);
      expect(style!.curve, isNull);
      expect(style!.duration, Duration.zero);
      style = null;

      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: simpleNodeSet,
          toggleAnimationStyle: AnimationStyle(
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 200),
          ),
          treeNodeBuilder: (
            BuildContext context,
            TreeViewNode<String> node,
            AnimationStyle toggleAnimationStyle,
          ) {
            style ??= toggleAnimationStyle;
            return Text(node.content);
          },
        ),
      ));
      expect(style, isNotNull);
      expect(style!.curve, Curves.easeIn);
      expect(style!.duration, const Duration(milliseconds: 200));
    });

    testWidgets('Adding more root TreeViewNodes are reflected in the tree',
        (WidgetTester tester) async {
      final TreeViewController controller = TreeViewController();
      await tester.pumpWidget(MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              body: TreeView<String>(
                tree: simpleNodeSet,
                controller: controller,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    simpleNodeSet.add(TreeViewNode<String>('Added root'));
                  });
                },
              ),
            );
          },
        ),
      ));
      await tester.pump();

      expect(find.text('Root 0'), findsOneWidget);
      expect(find.text('Root 1'), findsOneWidget);
      expect(find.text('Child 1:0'), findsOneWidget);
      expect(find.text('Child 1:1'), findsOneWidget);
      expect(find.text('Root 2'), findsOneWidget);
      expect(find.text('Child 2:0'), findsNothing);
      expect(find.text('Child 2:1'), findsNothing);
      expect(find.text('Root 3'), findsOneWidget);
      expect(find.text('Added root'), findsNothing);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('Root 0'), findsOneWidget);
      expect(find.text('Root 1'), findsOneWidget);
      expect(find.text('Child 1:0'), findsOneWidget);
      expect(find.text('Child 1:1'), findsOneWidget);
      expect(find.text('Root 2'), findsOneWidget);
      expect(find.text('Child 2:0'), findsNothing);
      expect(find.text('Child 2:1'), findsNothing);
      expect(find.text('Root 3'), findsOneWidget);
      // Node was added
      expect(find.text('Added root'), findsOneWidget);
    });

    testWidgets(
        'Adding more TreeViewNodes below the root are reflected in the tree',
        (WidgetTester tester) async {
      final TreeViewController controller = TreeViewController();
      await tester.pumpWidget(MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              body: TreeView<String>(
                tree: simpleNodeSet,
                controller: controller,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    simpleNodeSet[1].children.add(
                          TreeViewNode<String>('Added child'),
                        );
                  });
                },
              ),
            );
          },
        ),
      ));
      await tester.pump();

      expect(find.text('Root 0'), findsOneWidget);
      expect(find.text('Root 1'), findsOneWidget);
      expect(find.text('Child 1:0'), findsOneWidget);
      expect(find.text('Child 1:1'), findsOneWidget);
      expect(find.text('Added child'), findsNothing);
      expect(find.text('Root 2'), findsOneWidget);
      expect(find.text('Child 2:0'), findsNothing);
      expect(find.text('Child 2:1'), findsNothing);
      expect(find.text('Root 3'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('Root 0'), findsOneWidget);
      expect(find.text('Root 1'), findsOneWidget);
      expect(find.text('Child 1:0'), findsOneWidget);
      expect(find.text('Child 1:1'), findsOneWidget);
      // Child node was added
      expect(find.text('Added child'), findsOneWidget);
      expect(find.text('Root 2'), findsOneWidget);
      expect(find.text('Child 2:0'), findsNothing);
      expect(find.text('Child 2:1'), findsNothing);
      expect(find.text('Root 3'), findsOneWidget);
    });

    test('should use the generic type for callbacks and builders', () {
      final TreeView<String> treeView = TreeView<String>(
        tree: simpleNodeSet,
        treeNodeBuilder: (
          BuildContext context,
          TreeViewNode<String> node,
          AnimationStyle animationStyle,
        ) {
          return TreeView.defaultTreeNodeBuilder(
            context,
            node,
            animationStyle,
          );
        },
        treeRowBuilder: (TreeViewNode<String> node) {
          return TreeView.defaultTreeRowBuilder(node);
        },
        onNodeToggle: (TreeViewNode<String> node) {},
      );

      expect(treeView.onNodeToggle, isA<TreeViewNodeCallback<String>>());
      expect(treeView.treeNodeBuilder, isA<TreeViewNodeBuilder<String>>());
      expect(treeView.treeRowBuilder, isA<TreeViewRowBuilder<String>>());
    });

    testWidgets(
        'TreeViewNode should expand/collapse correctly when the animation duration is set to zero.',
        (WidgetTester tester) async {
      // Regression test for https://github.com/flutter/flutter/issues/154292
      final TreeViewController controller = TreeViewController();
      final List<TreeViewNode<String>> tree = <TreeViewNode<String>>[
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

      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: tree,
          controller: controller,
          toggleAnimationStyle: AnimationStyle(
            curve: Curves.easeInOut,
            duration: Duration.zero,
          ),
          treeNodeBuilder: (
            BuildContext context,
            TreeViewNode<Object?> node,
            AnimationStyle animationStyle,
          ) {
            final Widget child = GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => controller.toggleNode(node),
              child: TreeView.defaultTreeNodeBuilder(
                context,
                node,
                animationStyle,
              ),
            );

            return child;
          },
        ),
      ));

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
      expect(find.text('Fourth'), findsOneWidget);
      expect(find.text('alpha'), findsNothing);
      expect(find.text('beta'), findsNothing);
      expect(find.text('kappa'), findsNothing);
      expect(find.text('gamma'), findsOneWidget);
      expect(find.text('delta'), findsOneWidget);
      expect(find.text('epsilon'), findsOneWidget);
      expect(find.text('uno'), findsNothing);
      expect(find.text('dos'), findsNothing);
      expect(find.text('tres'), findsNothing);

      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();

      expect(find.text('alpha'), findsOneWidget);

      await tester.tap(find.text('alpha'));
      await tester.pumpAndSettle();

      expect(find.text('uno'), findsOneWidget);
      expect(find.text('dos'), findsOneWidget);
      expect(find.text('tres'), findsOneWidget);

      await tester.tap(find.text('alpha'));
      await tester.pumpAndSettle();

      expect(find.text('uno'), findsNothing);
      expect(find.text('dos'), findsNothing);
      expect(find.text('tres'), findsNothing);
    });

    testWidgets(
        'TreeViewNode should close all child nodes when collapsed, once the animation is completed',
        (WidgetTester tester) async {
      final TreeViewController controller = TreeViewController();
      final List<TreeViewNode<String>> tree = <TreeViewNode<String>>[
        TreeViewNode<String>(
          'First',
          expanded: true,
          children: <TreeViewNode<String>>[
            TreeViewNode<String>(
              'alpha',
              expanded: true,
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
      ];

      await tester.pumpWidget(MaterialApp(
        home: TreeView<String>(
          tree: tree,
          controller: controller,
          toggleAnimationStyle: AnimationStyle(
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 200),
          ),
          treeNodeBuilder: (
            BuildContext context,
            TreeViewNode<Object?> node,
            AnimationStyle animationStyle,
          ) {
            final Widget child = GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => controller.toggleNode(node),
              child: TreeView.defaultTreeNodeBuilder(
                context,
                node,
                animationStyle,
              ),
            );

            return child;
          },
        ),
      ));

      expect(find.text('alpha'), findsOneWidget);
      expect(find.text('uno'), findsOneWidget);
      expect(find.text('dos'), findsOneWidget);
      expect(find.text('tres'), findsOneWidget);

      // Using runAsync to handle collapse and animations properly.
      await tester.runAsync(() async {
        await tester.tap(find.text('alpha'));
        await tester.pumpAndSettle();

        expect(find.text('uno'), findsNothing);
        expect(find.text('dos'), findsNothing);
        expect(find.text('tres'), findsNothing);
      });
    });
  });

  group('TreeViewport', () {
    test('asserts proper axis directions', () {
      TreeViewport? treeViewport;
      expect(
        () {
          treeViewport = TreeViewport(
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
          treeViewport = TreeViewport(
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

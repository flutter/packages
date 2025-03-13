// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

/// The class containing a TreeView that highlights the selected node.
/// The custom TreeView.treeNodeBuilder makes tapping the whole row of a parent
/// toggle the node open and closed with TreeView.toggleNodeWith. The
/// scrollbars will appear as the content exceeds the bounds of the viewport.
class CustomTreeExample extends StatefulWidget {
  /// Creates a screen that demonstrates the TreeView widget.
  const CustomTreeExample({super.key});

  @override
  State<CustomTreeExample> createState() => CustomTreeExampleState();
}

/// The state of the [CustomTreeExample].
class CustomTreeExampleState extends State<CustomTreeExample> {
  /// The [TreeViewController] associated with this [TreeView].
  @visibleForTesting
  final TreeViewController treeController = TreeViewController();

  /// The [ScrollController] associated with the vertical axis.
  @visibleForTesting
  final ScrollController verticalController = ScrollController();

  TreeViewNode<String>? _selectedNode;
  final ScrollController _horizontalController = ScrollController();
  final List<TreeViewNode<String>> _tree = <TreeViewNode<String>>[
    TreeViewNode<String>('README.md'),
    TreeViewNode<String>('analysis_options.yaml'),
    TreeViewNode<String>(
      'lib',
      children: <TreeViewNode<String>>[
        TreeViewNode<String>(
          'src',
          children: <TreeViewNode<String>>[
            TreeViewNode<String>(
              'common',
              children: <TreeViewNode<String>>[
                TreeViewNode<String>('span.dart'),
              ],
            ),
            TreeViewNode<String>(
              'table_view',
              children: <TreeViewNode<String>>[
                TreeViewNode<String>('table_cell.dart'),
                TreeViewNode<String>('table_delegate.dart'),
                TreeViewNode<String>('table_span.dart'),
                TreeViewNode<String>('table.dart'),
              ],
            ),
            TreeViewNode<String>(
              'tree_view',
              children: <TreeViewNode<String>>[
                TreeViewNode<String>('render_tree.dart'),
                TreeViewNode<String>('tree_core.dart'),
                TreeViewNode<String>('tree_delegate.dart'),
                TreeViewNode<String>('tree_span.dart'),
                TreeViewNode<String>('tree.dart'),
              ],
            ),
          ],
        ),
        TreeViewNode<String>('two_dimensional_scrollables.dart'),
      ],
    ),
    TreeViewNode<String>('pubspec.lock'),
    TreeViewNode<String>('pubspec.yaml'),
    TreeViewNode<String>(
      'test',
      children: <TreeViewNode<String>>[
        TreeViewNode<String>(
          'common',
          children: <TreeViewNode<String>>[
            TreeViewNode<String>('span_test.dart'),
          ],
        ),
        TreeViewNode<String>(
          'table_view',
          children: <TreeViewNode<String>>[
            TreeViewNode<String>('table_cell_test.dart'),
            TreeViewNode<String>('table_delegate_test.dart'),
            TreeViewNode<String>('table_span_test.dart'),
            TreeViewNode<String>('table_test.dart'),
          ],
        ),
        TreeViewNode<String>(
          'tree_view',
          children: <TreeViewNode<String>>[
            TreeViewNode<String>('render_tree_test.dart'),
            TreeViewNode<String>('tree_core_test.dart'),
            TreeViewNode<String>('tree_delegate_test.dart'),
            TreeViewNode<String>('tree_span_test.dart'),
            TreeViewNode<String>('tree_test.dart'),
          ],
        ),
      ],
    ),
  ];

  Widget _treeNodeBuilder(
    BuildContext context,
    TreeViewNode<String> node,
    AnimationStyle toggleAnimationStyle,
  ) {
    final bool isParentNode = node.children.isNotEmpty;
    final BorderSide border = BorderSide(
      width: 2,
      color: Colors.purple[300]!,
    );
    // TRY THIS: TreeView.toggleNodeWith can be wrapped around any Widget (even
    // the whole row) to trigger parent nodes to toggle opened and closed.
    // Currently, the toggle is triggered in _getTapRecognizer below using the
    // TreeViewController.
    return Row(
      children: <Widget>[
        // Custom indentation
        SizedBox(width: 10.0 * node.depth! + 8.0),
        DecoratedBox(
          decoration: BoxDecoration(
            border: node.parent != null
                ? Border(left: border, bottom: border)
                : null,
          ),
          child: const SizedBox(height: 50.0, width: 20.0),
        ),
        // Leading icon for parent nodes
        if (isParentNode)
          DecoratedBox(
            decoration: BoxDecoration(border: Border.all()),
            child: SizedBox.square(
              dimension: 20.0,
              child: Icon(
                node.isExpanded ? Icons.remove : Icons.add,
                size: 14,
              ),
            ),
          ),
        // Spacer
        const SizedBox(width: 8.0),
        // Content
        Text(node.content),
      ],
    );
  }

  Map<Type, GestureRecognizerFactory> _getTapRecognizer(
    TreeViewNode<String> node,
  ) {
    return <Type, GestureRecognizerFactory>{
      TapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(),
        (TapGestureRecognizer t) => t.onTap = () {
          setState(() {
            // Toggling the node here instead means any tap on the row can
            // toggle parent nodes opened and closed.
            treeController.toggleNode(node);
            _selectedNode = node;
          });
        },
      ),
    };
  }

  Widget _getTree() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Scrollbar(
        controller: _horizontalController,
        thumbVisibility: true,
        child: Scrollbar(
          controller: verticalController,
          thumbVisibility: true,
          child: TreeView<String>(
            controller: treeController,
            verticalDetails: ScrollableDetails.vertical(
              controller: verticalController,
            ),
            horizontalDetails: ScrollableDetails.horizontal(
              controller: _horizontalController,
            ),
            tree: _tree,
            onNodeToggle: (TreeViewNode<String> node) {
              setState(() {
                _selectedNode = node;
              });
            },
            treeNodeBuilder: _treeNodeBuilder,
            treeRowBuilder: (TreeViewNode<String> node) {
              if (_selectedNode == node) {
                return TreeRow(
                  extent: FixedTreeRowExtent(
                    node.children.isNotEmpty ? 60.0 : 50.0,
                  ),
                  recognizerFactories: _getTapRecognizer(node),
                  backgroundDecoration: TreeRowDecoration(
                    color: Colors.amber[100],
                  ),
                  foregroundDecoration: const TreeRowDecoration(
                      border: TreeRowBorder.all(BorderSide())),
                );
              }
              return TreeRow(
                extent: FixedTreeRowExtent(
                  node.children.isNotEmpty ? 60.0 : 50.0,
                ),
                recognizerFactories: _getTapRecognizer(node),
              );
            },
            // No internal indentation, the custom treeNodeBuilder applies its
            // own indentation to decorate in the indented space.
            indentation: TreeViewIndentationType.none,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This example is assumes the full screen is available.
    final Size screenSize = MediaQuery.sizeOf(context);
    final List<Widget> selectedChildren = <Widget>[];
    if (_selectedNode != null) {
      selectedChildren.addAll(<Widget>[
        const Spacer(),
        Icon(
          _selectedNode!.children.isEmpty
              ? Icons.file_open_outlined
              : Icons.folder_outlined,
        ),
        const SizedBox(height: 25.0),
        Text(_selectedNode!.content),
        const Spacer(),
      ]);
    }
    return Scaffold(
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(children: <Widget>[
            SizedBox(
              width: (screenSize.width - 50) / 2,
              height: double.infinity,
              child: _getTree(),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: SizedBox(
                width: (screenSize.width - 50) / 2,
                height: double.infinity,
                child: Center(
                  child: Column(
                    children: selectedChildren,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

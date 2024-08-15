// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

/// The class containing a TreeView that highlights the selected row. The
/// default TreeView.treeNodeBuilder, makes tapping the leading icon of a parent
/// toggle the node open and closed. The scrollbars will appear as the content
/// exceeds the bounds of the viewport.
class TreeExample extends StatefulWidget {
  /// Creates a screen that demonstrates the TreeView widget.
  const TreeExample({super.key});

  @override
  State<TreeExample> createState() => TreeExampleState();
}

/// The state of the [TreeExample].
class TreeExampleState extends State<TreeExample> {
  /// The [TreeViewController] associated with this [TreeView].
  @visibleForTesting
  final TreeViewController treeController = TreeViewController();

  /// The [ScrollController] associated with the horizontal axis.
  @visibleForTesting
  final ScrollController horizontalController = ScrollController();
  TreeViewNode<String>? _selectedNode;
  final ScrollController _verticalController = ScrollController();
  final List<TreeViewNode<String>> _tree = <TreeViewNode<String>>[
    TreeViewNode<String>(
      "It's supercalifragilisticexpialidocious",
      children: <TreeViewNode<String>>[
        TreeViewNode<String>(
          'Even though the sound of it is something quite atrocious',
        ),
        TreeViewNode<String>(
          "If you say it loud enough you'll always sound precocious",
        ),
      ],
    ),
    TreeViewNode<String>(
      'Supercalifragilisticexpialidocious',
      children: <TreeViewNode<String>>[
        TreeViewNode<String>(
          'Um-dittle-ittl-um-dittle-I',
          children: <TreeViewNode<String>>[
            TreeViewNode<String>(
              'Um-dittle-ittl-um-dittle-I',
              children: <TreeViewNode<String>>[
                TreeViewNode<String>(
                  'Um-dittle-ittl-um-dittle-I',
                  children: <TreeViewNode<String>>[
                    TreeViewNode<String>(
                      'Um-dittle-ittl-um-dittle-I',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];

  Map<Type, GestureRecognizerFactory> _getTapRecognizer(
    TreeViewNode<String> node,
  ) {
    return <Type, GestureRecognizerFactory>{
      TapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(),
        (TapGestureRecognizer t) => t.onTap = () {
          setState(() {
            _selectedNode = node;
          });
        },
      ),
    };
  }

  Widget _getTree() {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all()),
      child: Scrollbar(
        controller: horizontalController,
        thumbVisibility: true,
        child: Scrollbar(
          controller: _verticalController,
          thumbVisibility: true,
          child: TreeView<String>(
            controller: treeController,
            verticalDetails: ScrollableDetails.vertical(
              controller: _verticalController,
            ),
            horizontalDetails: ScrollableDetails.horizontal(
              controller: horizontalController,
            ),
            tree: _tree,
            onNodeToggle: (TreeViewNode<String> node) {
              setState(() {
                _selectedNode = node;
              });
            },
            treeRowBuilder: (TreeViewNode<String> node) {
              if (_selectedNode == node) {
                return TreeView.defaultTreeRowBuilder(node).copyWith(
                  recognizerFactories: _getTapRecognizer(node),
                  backgroundDecoration: TreeRowDecoration(
                    color: Colors.purple[100],
                  ),
                );
              }
              return TreeView.defaultTreeRowBuilder(node).copyWith(
                recognizerFactories: _getTapRecognizer(node),
              );
            },
            // Exaggerated indentation to exceed viewport bounds.
            indentation: TreeViewIndentationType.custom(50.0),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _verticalController.dispose();
    horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.25,
            vertical: 25.0,
          ),
          child: _getTree(),
        ),
      ),
    );
  }
}

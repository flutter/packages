// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'custom_tree.dart';
import 'simple_tree.dart';

/// The page containing the interactive controls that modify the sample
/// TreeView.
class TreeExplorer extends StatefulWidget {
  /// Creates a screen that demonstrates the TreeView widget in varying
  /// configurations.
  const TreeExplorer({super.key});

  @override
  State<TreeExplorer> createState() => _TreeExplorerState();
}

/// Which example is being displayed.
enum TreeType {
  /// Displays TreeExample.
  simple,

  /// Displays CustomTreeExample.
  custom,
}

class _TreeExplorerState extends State<TreeExplorer> {
  final SizedBox _spacer = const SizedBox.square(dimension: 20.0);
  TreeType _currentExample = TreeType.simple;
  String _getTitle() {
    return switch (_currentExample) {
      TreeType.simple => 'Simple TreeView',
      TreeType.custom => 'Customizing TreeView',
    };
  }

  Widget _getTree() {
    return switch (_currentExample) {
      TreeType.simple => const TreeExample(),
      TreeType.custom => const CustomTreeExample(),
    };
  }

  Widget _getRadioRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          const Spacer(),
          Radio<TreeType>(
            value: TreeType.simple,
            groupValue: _currentExample,
            onChanged: (TreeType? value) {
              setState(() {
                _currentExample = value!;
              });
            },
          ),
          const Text('Simple'),
          _spacer,
          Radio<TreeType>(
            value: TreeType.custom,
            groupValue: _currentExample,
            onChanged: (TreeType? value) {
              setState(() {
                _currentExample = value!;
              });
            },
          ),
          const Text('Custom'),
          const Spacer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _getRadioRow(),
          ),
        ),
      ),
      body: _getTree(),
    );
  }
}

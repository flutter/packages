// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'infinite_table.dart';
import 'merged_table.dart';
import 'simple_table.dart';

/// The page containing the interactive controls that modify the sample
/// TableView.
class TableExplorer extends StatefulWidget {
  /// Creates a screen that demonstrates the TableView widget in varying
  /// configurations.
  const TableExplorer({super.key});

  @override
  State<TableExplorer> createState() => _TableExplorerState();
}

/// Which example is being displayed.
enum TableType {
  /// Displays TableExample.
  simple,

  /// Displays MergedTableExample.
  merged,

  /// Displays InfiniteTableExample.
  infinite,
}

class _TableExplorerState extends State<TableExplorer> {
  final SizedBox _spacer = const SizedBox.square(dimension: 20.0);
  TableType _currentExample = TableType.simple;
  String _getTitle() {
    return switch (_currentExample) {
      TableType.simple => 'Simple TableView',
      TableType.merged => 'Merged cells in TableView',
      TableType.infinite => 'Infinite TableView',
    };
  }

  Widget _getTable() {
    return switch (_currentExample) {
      TableType.simple => const TableExample(),
      TableType.merged => const MergedTableExample(),
      TableType.infinite => const InfiniteTableExample(),
    };
  }

  Widget _getRadioRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          const Spacer(),
          RadioGroup<TableType>(
            groupValue: _currentExample,
            onChanged: (TableType? value) {
              if (value == null) {
                return;
              }
              setState(() => _currentExample = value);
            },
            child: Row(
              children: <Widget>[
                const Radio<TableType>(value: TableType.simple),
                const Text('Simple'),
                _spacer,
                const Radio<TableType>(value: TableType.merged),
                const Text('Merged'),
                _spacer,
                const Radio<TableType>(value: TableType.infinite),
                const Text('Infinite'),
              ],
            ),
          ),
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
      body: _getTable(),
    );
  }
}

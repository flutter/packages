// Copyright 2013 The Flutter Authors. All rights reserved.
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
          Radio<TableType>(
            value: TableType.simple,
            groupValue: _currentExample,
            onChanged: (TableType? value) {
              setState(() {
                _currentExample = value!;
              });
            },
          ),
          const Text('Simple'),
          _spacer,
          Radio<TableType>(
            value: TableType.merged,
            groupValue: _currentExample,
            onChanged: (TableType? value) {
              setState(() {
                _currentExample = value!;
              });
            },
          ),
          const Text('Merged'),
          _spacer,
          Radio<TableType>(
            value: TableType.infinite,
            groupValue: _currentExample,
            onChanged: (TableType? value) {
              setState(() {
                _currentExample = value!;
              });
            },
          ),
          const Text('Infinite'),
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

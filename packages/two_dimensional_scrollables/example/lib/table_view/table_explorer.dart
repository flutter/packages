// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'simple_table.dart';
import 'merged_table.dart';
import 'infinite_table.dart';

/// The page containing the interactive controls that modify the sample
/// TableView.
class TableExplorer extends StatefulWidget {
  /// Creates a screen that demonstrates the TableView widget in varying
  /// configurations.
  const TableExplorer({super.key});

  @override
  State<TableExplorer> createState() => _TableExplorerState();
}

enum _TableExample {
  simple,
  merged,
  infinite,
}

class _TableExplorerState extends State<TableExplorer> {
  final SizedBox _spacer = const SizedBox.square(dimension: 20.0);
  _TableExample _currentExample = _TableExample.simple;
  String _getTitle() {
    return switch (_currentExample) {
      _TableExample.simple => 'Simple TableView',
      _TableExample.merged => 'Merged cells in TableView',
      _TableExample.infinite => 'Infinite TableView',
    };
  }

  Widget _getTable() {
    return switch (_currentExample) {
      _TableExample.simple => const TableExample(),
      _TableExample.merged => const MergedTableExample(),
      _TableExample.infinite => const InfiniteTableExample(),
    };
  }

  Widget _getRadioRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          const Spacer(),
          Radio<_TableExample>(
            value: _TableExample.simple,
            groupValue: _currentExample,
            onChanged: (_TableExample? value) {
              setState(() {
                _currentExample = value!;
              });
            },
          ),
          const Text('Simple'),
          _spacer,
          Radio<_TableExample>(
            value: _TableExample.merged,
            groupValue: _currentExample,
            onChanged: (_TableExample? value) {
              setState(() {
                _currentExample = value!;
              });
            },
          ),
          const Text('Merged'),
          _spacer,
          Radio<_TableExample>(
            value: _TableExample.infinite,
            groupValue: _currentExample,
            onChanged: (_TableExample? value) {
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

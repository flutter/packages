// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

// Print statements are only for illustrative purposes, not recommended for
// production applications.
// ignore_for_file: avoid_print

void main() {
  runApp(const TableExampleApp());
}

/// A sample application that utilizes the TableView API.
class TableExampleApp extends StatelessWidget {
  /// Creates an instance of the TableView example app.
  const TableExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Example',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const TableExample(),
    );
  }
}

/// The class containing the TableView for the sample application.
class TableExample extends StatefulWidget {
  /// Creates a screen that demonstrates the TableView widget.
  const TableExample({super.key});

  @override
  State<TableExample> createState() => _TableExampleState();
}

class _TableExampleState extends State<TableExample> {
  final Map<TableVicinity, (int, int)> mergedRows = <TableVicinity, (int, int)>{
    // TableVicinity in merged cell : (start, span)
    TableVicinity.zero: (0, 2),
    TableVicinity.zero.copyWith(row: 1): (0, 2),
    const TableVicinity(row: 1, column: 1): (1, 2),
    const TableVicinity(row: 2, column: 1): (1, 2),
    const TableVicinity(row: 2, column: 2): (2, 2),
    const TableVicinity(row: 3, column: 2): (2, 2),
  };

  final Map<TableVicinity, (int, int)> mergedColumns = <TableVicinity, (int, int)>{
    // TableVicinity in merged cell : (start, span)
    const TableVicinity(row: 0, column: 2) : (2, 2),
    const TableVicinity(row: 0, column: 3) : (2, 2),
    const TableVicinity(row: 3, column: 0) : (0, 2),
    const TableVicinity(row: 3, column: 1) : (0, 2),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Example'),
      ),
      body: TableView.builder(
        cellBuilder: _buildCell,
        columnCount: 4,
        columnBuilder: _buildColumnSpan,
        rowCount: 4,
        rowBuilder: _buildRowSpan,
      ),
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    if (mergedColumns.keys.contains(vicinity) || mergedRows.keys.contains(vicinity)) {
      print('Vicinity $vicinity has: \n '
        '\t rowMergeStart: ${mergedRows[vicinity]?.$1}\n'
        '\t rowMergeSpan: ${mergedRows[vicinity]?.$2}\n'
        '\t columnMergeStart: ${mergedColumns[vicinity]?.$1}\n'
        '\t columnMergeSpan: ${mergedColumns[vicinity]?.$2} '
      );
      return TableViewCell(
        rowMergeStart: mergedRows[vicinity]?.$1,
        rowMergeSpan: mergedRows[vicinity]?.$2,
        // columnMergeStart: mergedColumns[vicinity]?.$1,
        // columnMergeSpan: mergedColumns[vicinity]?.$2,
        child: const Center(
          child: Text('Merged'),
        ),
      );
    }

    return TableViewCell(
      child: Center(
        child: Text('Tile c: ${vicinity.column}, r: ${vicinity.row}'),
      ),
    );
  }

  TableSpan _buildRowSpan(int index) {
    late final Color color;
    switch (index) {
      case 1:
        color = Colors.purple;
      case 2:
        color = Colors.blue;
      case 3:
        color = Colors.green;
      default:
        color = Colors.transparent;
    }

    return TableSpan(
      extent: const FixedTableSpanExtent(100.0),
      // backgroundDecoration: TableSpanDecoration(
      //   color: color,
      //   border: const TableSpanBorder(
      //     leading: BorderSide(),
      //     trailing: BorderSide(),
      //   ),
      // ),
    );
  }

  TableSpan _buildColumnSpan(int index) {
    return const TableSpan(
      extent: FixedTableSpanExtent(100.0),
      // foregroundDecoration: TableSpanDecoration(
      //   border: TableSpanBorder(leading: BorderSide(), trailing: BorderSide(),),
      // ),
    );
  }
}

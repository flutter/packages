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
  int counter = 0;
  int get _columnCount {
    return switch (counter % 3) {
      0 => 20,
      1 => 30,
      2 => 10,
      _ => 500,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Row count $_columnCount'),
      ),
      body: TableView.builder(
        cellBuilder: _buildCell,
        // columnCount: 20,
        columnBuilder: _buildColumnSpan,
        // rowCount: _rowCount,
        rowBuilder: _buildRowSpan,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            print('press');
            counter++;
          });
        },
      ),
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    print(vicinity);
    return TableViewCell(
      child: Center(
        child: Text('Tile c: ${vicinity.column}, r: ${vicinity.row}'),
      ),
    );
  }

  TableSpan? _buildColumnSpan(int index) {
    if (index > _columnCount) {
      return null;
    }
    const TableSpanDecoration decoration = TableSpanDecoration(
      border: TableSpanBorder(
        trailing: BorderSide(),
      ),
    );

    return const TableSpan(
          foregroundDecoration: decoration,
          extent: FixedTableSpanExtent(100),
        );
  }

  TableSpan? _buildRowSpan(int index) {

    final TableSpanDecoration decoration = TableSpanDecoration(
      color: index.isEven ? Colors.purple[100] : null,
      border: const TableSpanBorder(
        trailing: BorderSide(
          width: 3,
        ),
      ),
    );
    return TableSpan(
          backgroundDecoration: decoration,
          extent: const FixedTableSpanExtent(50),
        );
  }
}

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
  late final ScrollController _verticalController = ScrollController();
  int _rowCount = 20;

  final Map<TableVicinity, ({int start, int span})> mergedRows =
      <TableVicinity, ({int start, int span})>{
    TableVicinity.zero: (start: 0, span: 2),
    TableVicinity.zero.copyWith(row: 1): (start: 0, span: 2),
  };

  final Map<TableVicinity, ({int start, int span})> mergedColumns =
      <TableVicinity, ({int start, int span})>{
    const TableVicinity(row: 0, column: 1): (start: 1, span: 2),
    const TableVicinity(row: 0, column: 2): (start: 1, span: 2),
  };

  // If a merged square is along the identity matrix, the values are the same
  // for row merge and column merge data.
  final Map<TableVicinity, ({int start, int span})> mergedIdentitySquares =
      <TableVicinity, ({int start, int span})>{
    const TableVicinity(row: 1, column: 1): (start: 1, span: 2),
    const TableVicinity(row: 1, column: 2): (start: 1, span: 2),
    const TableVicinity(row: 2, column: 1): (start: 1, span: 2),
    const TableVicinity(row: 2, column: 2): (start: 1, span: 2),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: TableView.builder(
          verticalDetails: ScrollableDetails.vertical(
            controller: _verticalController,
          ),
          cellBuilder: _buildCell,
          columnCount: 20,
          rowCount: _rowCount,
          columnBuilder: _buildColumnSpan,
          rowBuilder: _buildRowSpan,
        ),
      ),
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    final bool mergedCell = mergedRows.keys.contains(vicinity) ||
        mergedColumns.keys.contains(vicinity) ||
        mergedIdentitySquares.keys.contains(vicinity);
    if (mergedCell) {
      return TableViewCell(
        rowMergeStart: mergedIdentitySquares[vicinity]?.start ??
            mergedRows[vicinity]?.start,
        rowMergeSpan:
            mergedIdentitySquares[vicinity]?.span ?? mergedRows[vicinity]?.span,
        columnMergeStart: mergedIdentitySquares[vicinity]?.start ??
            mergedColumns[vicinity]?.start,
        columnMergeSpan: mergedIdentitySquares[vicinity]?.span ??
            mergedColumns[vicinity]?.span,
        child: const Center(
          child: Text('Merged'),
        ),
      );
    }

    return TableViewCell(
      child: Center(
        child: Text('(${vicinity.row}, ${vicinity.column})'),
      ),
    );
  }

  TableSpan _buildColumnSpan(int index) {
    const TableSpanDecoration decoration = TableSpanDecoration(
      border: TableSpanBorder(
        trailing: BorderSide(),
      ),
    );

    switch (index % 5) {
      case 0:
        return TableSpan(
          foregroundDecoration: decoration,
          extent: const FixedTableSpanExtent(100),
          onEnter: (_) => print('Entered column $index'),
          recognizerFactories: <Type, GestureRecognizerFactory>{
            TapGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              () => TapGestureRecognizer(),
              (TapGestureRecognizer t) =>
                  t.onTap = () => print('Tap column $index'),
            ),
          },
        );
      case 1:
        return TableSpan(
          foregroundDecoration: decoration,
          extent: const FractionalTableSpanExtent(0.5),
          onEnter: (_) => print('Entered column $index'),
          cursor: SystemMouseCursors.contextMenu,
        );
      case 2:
        return TableSpan(
          foregroundDecoration: decoration,
          extent: const FixedTableSpanExtent(120),
          onEnter: (_) => print('Entered column $index'),
        );
      case 3:
        return TableSpan(
          foregroundDecoration: decoration,
          extent: const FixedTableSpanExtent(145),
          onEnter: (_) => print('Entered column $index'),
        );
      case 4:
        return TableSpan(
          foregroundDecoration: decoration,
          extent: const FixedTableSpanExtent(200),
          onEnter: (_) => print('Entered column $index'),
        );
    }
    throw AssertionError(
        'This should be unreachable, as every index is accounted for in the switch clauses.');
  }

  TableSpan _buildRowSpan(int index) {
    final TableSpanDecoration decoration = TableSpanDecoration(
      color: index.isEven ? Colors.blueAccent[100] : null,
      border: const TableSpanBorder(
        trailing: BorderSide(
          width: 3,
        ),
      ),
    );

    switch (index % 3) {
      case 0:
        return TableSpan(
          backgroundDecoration: decoration,
          extent: const FixedTableSpanExtent(50),
          recognizerFactories: <Type, GestureRecognizerFactory>{
            TapGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              () => TapGestureRecognizer(),
              (TapGestureRecognizer t) =>
                  t.onTap = () => print('Tap row $index'),
            ),
          },
        );
      case 1:
        return TableSpan(
          backgroundDecoration: decoration,
          extent: const FixedTableSpanExtent(65),
          cursor: SystemMouseCursors.click,
        );
      case 2:
        return TableSpan(
          backgroundDecoration: decoration,
          extent: const FractionalTableSpanExtent(0.15),
        );
    }
    throw AssertionError(
        'This should be unreachable, as every index is accounted for in the switch clauses.');
  }
}

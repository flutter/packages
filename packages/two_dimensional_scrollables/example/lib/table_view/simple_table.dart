// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

// Print statements are only for illustrative purposes, not recommended for
// production applications.
// ignore_for_file: avoid_print

/// The class containing the TableView for the sample application.
class TableExample extends StatefulWidget {
  /// Creates a screen that demonstrates the TableView widget.
  const TableExample({super.key});

  @override
  State<TableExample> createState() => _TableExampleState();
}

enum _TableSelection { multiCell, singleCell, disabled }

class _TableExampleState extends State<TableExample> {
  late final ScrollController _verticalController = ScrollController();
  _TableSelection _selectionMode = _TableSelection.disabled;
  int _rowCount = 20;

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: _selectionMode == _TableSelection.multiCell
            ? SelectionArea(
                child: TableView.builder(
                  verticalDetails: ScrollableDetails.vertical(
                    controller: _verticalController,
                  ),
                  cellBuilder: _buildCell,
                  columnCount: 20,
                  columnBuilder: _buildColumnSpan,
                  rowCount: _rowCount,
                  rowBuilder: _buildRowSpan,
                ),
              )
            : TableView.builder(
                verticalDetails: ScrollableDetails.vertical(
                  controller: _verticalController,
                ),
                cellBuilder: _buildCell,
                columnCount: 20,
                columnBuilder: _buildColumnSpan,
                rowCount: _rowCount,
                rowBuilder: _buildRowSpan,
              ),
      ),
      persistentFooterButtons: <Widget>[
        OverflowBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Selection'),
                SegmentedButton<_TableSelection>(
                  segments: const <ButtonSegment<_TableSelection>>[
                    ButtonSegment<_TableSelection>(
                      value: _TableSelection.multiCell,
                      label: Text('Multi-Cell'),
                      icon: Icon(Icons.layers),
                    ),
                    ButtonSegment<_TableSelection>(
                      value: _TableSelection.singleCell,
                      label: Text('Single-Cell'),
                      icon: Icon(Icons.crop_square),
                    ),
                    ButtonSegment<_TableSelection>(
                      value: _TableSelection.disabled,
                      label: Text('Disabled'),
                      icon: Icon(Icons.disabled_by_default),
                    ),
                  ],
                  selected: <_TableSelection>{_selectionMode},
                  onSelectionChanged: (Set<_TableSelection> newSelectionMode) {
                    setState(() {
                      // By default there is only a single segment that can be
                      // selected at one time, so its value is always the first
                      // item in the selected set.
                      _selectionMode = newSelectionMode.first;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    _verticalController.jumpTo(0);
                  },
                  child: const Text('Jump to Top'),
                ),
                TextButton(
                  onPressed: () {
                    _verticalController.jumpTo(
                      _verticalController.position.maxScrollExtent,
                    );
                  },
                  child: const Text('Jump to Bottom'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _rowCount += 10;
                    });
                  },
                  child: const Text('Add 10 Rows'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    Widget result = Center(
      child: Text('Tile c: ${vicinity.column}, r: ${vicinity.row}'),
    );
    if (_selectionMode == _TableSelection.singleCell) {
      result = SelectionArea(child: result);
    }
    return TableViewCell(child: result);
  }

  TableSpan _buildColumnSpan(int index) {
    const TableSpanDecoration decoration = TableSpanDecoration(
      border: TableSpanBorder(trailing: BorderSide()),
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
      'This should be unreachable, as every index is accounted for in the '
      'switch clauses.',
    );
  }

  TableSpan _buildRowSpan(int index) {
    final TableSpanDecoration decoration = TableSpanDecoration(
      color: index.isEven ? Colors.purple[100] : null,
      border: const TableSpanBorder(trailing: BorderSide(width: 3)),
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
      'This should be unreachable, as every index is accounted for in the '
      'switch clauses.',
    );
  }
}

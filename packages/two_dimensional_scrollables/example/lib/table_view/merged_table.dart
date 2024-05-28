// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

/// The class demonstrating merged cells in TableView.
class MergedTableExample extends StatefulWidget {
  /// Creates a screen that shows a color palette in the TableView widget.
  const MergedTableExample({super.key});

  @override
  State<MergedTableExample> createState() => _MergedTableExampleState();
}

class _MergedTableExampleState extends State<MergedTableExample> {
  ({String name, Color color}) _getColorForVicinity(TableVicinity vicinity) {
    final int colorIndex = (vicinity.row / 3).floor();
    final MaterialColor primary = Colors.primaries[colorIndex];
    if (vicinity.column == 0) {
      // Leading primary color
      return (
        color: primary[500]!,
        name: '${_getPrimaryNameFor(colorIndex)}, 500',
      );
    }
    final int leadingRow = colorIndex * 3;
    final int middleRow = leadingRow + 1;
    int? colorValue;
    if (vicinity.row == leadingRow) {
      colorValue = switch (vicinity.column) {
        1 => 50,
        2 => 100,
        3 => 200,
        _ => throw AssertionError('This should be unreachable.'),
      };
    } else if (vicinity.row == middleRow) {
      colorValue = switch (vicinity.column) {
        1 => 300,
        2 => 400,
        3 => 600,
        _ => throw AssertionError('This should be unreachable.'),
      };
    } else {
      // last row
      colorValue = switch (vicinity.column) {
        1 => 700,
        2 => 800,
        3 => 900,
        _ => throw AssertionError('This should be unreachable.'),
      };
    }
    return (color: primary[colorValue]!, name: colorValue.toString());
  }

  String _getPrimaryNameFor(int index) {
    return switch (index) {
      0 => 'Red',
      1 => 'Pink',
      2 => 'Purple',
      3 => 'DeepPurple',
      4 => 'Indigo',
      5 => 'Blue',
      6 => 'LightBlue',
      7 => 'Cyan',
      8 => 'Teal',
      9 => 'Green',
      10 => 'LightGreen',
      11 => 'Lime',
      12 => 'Yellow',
      13 => 'Amber',
      14 => 'Orange',
      15 => 'DeepOrange',
      16 => 'Brown',
      17 => 'BlueGrey',
      _ => throw AssertionError('This should be unreachable.'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.15),
        child: TableView.builder(
          cellBuilder: _buildCell,
          columnCount: 4,
          pinnedColumnCount: 1,
          columnBuilder: _buildColumnSpan,
          rowCount: 51, // 17 primary colors * 3 rows each
          rowBuilder: _buildRowSpan,
        ),
      ),
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    final int colorIndex = (vicinity.row / 3).floor();
    final ({String name, Color color}) cell = _getColorForVicinity(vicinity);
    final Color textColor =
        ThemeData.estimateBrightnessForColor(cell.color) == Brightness.light
            ? Colors.black
            : Colors.white;
    final TextStyle style = TextStyle(
      color: textColor,
      fontSize: 18.0,
      fontWeight: vicinity.column == 0 ? FontWeight.bold : null,
    );
    return TableViewCell(
      rowMergeStart: vicinity.column == 0 ? colorIndex * 3 : null,
      rowMergeSpan: vicinity.column == 0 ? 3 : null,
      child: ColoredBox(
        color: cell.color,
        child: Center(
          child: Text(cell.name, style: style),
        ),
      ),
    );
  }

  TableSpan _buildColumnSpan(int index) {
    return TableSpan(
      extent: FixedTableSpanExtent(index == 0 ? 220 : 180),
      foregroundDecoration: index == 0
          ? const TableSpanDecoration(
              border: TableSpanBorder(
                trailing: BorderSide(
                  width: 5,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  TableSpan _buildRowSpan(int index) {
    return TableSpan(
      extent: const FixedTableSpanExtent(120),
      padding: index % 3 == 0 ? const TableSpanPadding(leading: 5.0) : null,
    );
  }
}

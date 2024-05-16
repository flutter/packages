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
  int _rowCount = 40;
  ValueNotifier<double> childPositionListener = ValueNotifier<double>(0.0);

  final TableVicinity _childVicinity = const TableVicinity(column: 0, row: 10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: TableView.builder(
          childPositionGetter: _onChildPosition,
          verticalDetails:
              ScrollableDetails.vertical(controller: _verticalController),
          cellBuilder: _buildCell,
          columnCount: 20,
          columnBuilder: _buildColumnSpan,
          rowCount: _rowCount,
          rowBuilder: _buildRowSpan,
        ),
      ),
      persistentFooterButtons: <Widget>[
        TextButton(
          onPressed: () {
            _verticalController.jumpTo(0);
          },
          child: const Text('Jump to Top'),
        ),
        TextButton(
          onPressed: () {
            _verticalController
                .jumpTo(_verticalController.position.maxScrollExtent);
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
    );
  }

  Widget _childPosition() {
    return ValueListenableBuilder<double>(
      valueListenable: childPositionListener,
      builder: (BuildContext context, double value, Widget? child) => Text(
        'position: ${childPositionListener.value.toStringAsFixed(2)}',
      ),
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    Widget child = Center(
      child: Text('Tile c: ${vicinity.column}, r: ${vicinity.row}'),
    );

    if (vicinity == _childVicinity) {
      child = Column(
        children: <Widget>[
          child,
          _childPosition(),
        ],
      );
    }

    return TableViewCell(
      child: child,
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
      color: index.isEven ? Colors.purple[100] : null,
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

  void _onChildPosition(TableVicinity vicinity, double? position) {
    if (vicinity != _childVicinity) {
      return;
    }
    print('Child position: $position');
    WidgetsBinding.instance.endOfFrame
        .then((_) => childPositionListener.value = position!);
  }
}

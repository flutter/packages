---
name: two-dimensional-scrollables-setup-and-usage
description: Set up and use two_dimensional_scrollables to build lazy-loading TableView and TreeView widgets that scroll simultaneously in vertical and horizontal axes.
---

# Setting Up and Using two_dimensional_scrollables

The `two_dimensional_scrollables` package provides `TableView` and `TreeView` widgets built on Flutter's two-dimensional scrolling foundation (`TwoDimensionalScrollView`). These widgets lazily build visible cells and nodes within a 2D viewport while supporting diagonal scrolling, axis locking, pinned headers, cell merging, and row/column decorations.

## 1. Installation

Add `two_dimensional_scrollables` to your project's `pubspec.yaml`:

```bash
flutter pub add two_dimensional_scrollables
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  two_dimensional_scrollables: ^0.5.4
```

## 2. Usage and API Examples

Import the package in your Dart code:

```dart
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
```

### Building a 2D `TableView` with Pinned Headers and Decorations

Use `TableView.builder` to lazily construct cells on demand. Configure `pinnedRowCount` and `pinnedColumnCount` to keep header rows or columns fixed while scrolling:

```dart
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class SpreadsheetTableExample extends StatelessWidget {
  const SpreadsheetTableExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2D TableView')),
      body: TableView.builder(
        pinnedRowCount: 1,
        pinnedColumnCount: 1,
        columnCount: 20,
        rowCount: 50,
        columnBuilder: (int index) {
          return TableSpan(
            extent: const FixedTableSpanExtent(120.0),
            backgroundDecoration: TableSpanDecoration(
              border: TableSpanBorder(
                trailing: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          );
        },
        rowBuilder: (int index) {
          return TableSpan(
            extent: const FixedTableSpanExtent(48.0),
            backgroundDecoration: TableSpanDecoration(
              color: index == 0 ? Colors.blueGrey.shade50 : null,
              border: TableSpanBorder(
                trailing: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          );
        },
        cellBuilder: (BuildContext context, TableVicinity vicinity) {
          final bool isHeader = vicinity.row == 0 || vicinity.column == 0;
          return TableViewCell(
            child: Center(
              child: Text(
                'R${vicinity.row}:C${vicinity.column}',
                style: TextStyle(
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### Building a 2D `TreeView`

Use `TreeView` with `TreeViewNode` items to render hierarchical trees that scroll both vertically and horizontally when nested branches expand:

```dart
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class FileTreeExample extends StatefulWidget {
  const FileTreeExample({super.key});

  @override
  State<FileTreeExample> createState() => _FileTreeExampleState();
}

class _FileTreeExampleState extends State<FileTreeExample> {
  final TreeViewController _controller = TreeViewController();

  final List<TreeViewNode<String>> _tree = <TreeViewNode<String>>[
    TreeViewNode<String>(
      'lib',
      expanded: true,
      children: <TreeViewNode<String>>[
        TreeViewNode<String>('main.dart'),
        TreeViewNode<String>(
          'src',
          children: <TreeViewNode<String>>[
            TreeViewNode<String>('app.dart'),
            TreeViewNode<String>('routes.dart'),
          ],
        ),
      ],
    ),
    TreeViewNode<String>('pubspec.yaml'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2D TreeView')),
      body: TreeView<String>(
        controller: _controller,
        tree: _tree,
        treeNodeBuilder: (
          BuildContext context,
          TreeViewNode<String> node,
          AnimationStyle toggleAnimationStyle,
        ) {
          return TreeView.defaultTreeNodeBuilder(
            context,
            node,
            toggleAnimationStyle,
          );
        },
        treeRowBuilder: (TreeViewNode<String> node) {
          return const TreeRow(
            extent: FixedTreeRowExtent(40.0),
          );
        },
      ),
    );
  }
}
```

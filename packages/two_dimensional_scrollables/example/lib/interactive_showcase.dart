// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Interactive Span Decorations Showcase',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const InteractiveShowcasePage(),
    ),
  );
}

/// A playground screen that demonstrates interactive [TableSpanDecoration] and
/// [TreeRowDecoration] features: hover/press [WidgetStateColor], animated
/// [WidgetStateBorderSide], tap splash ripples, and custom [AnimationStyle]s.
class InteractiveShowcasePage extends StatefulWidget {
  /// Creates an [InteractiveShowcasePage].
  const InteractiveShowcasePage({super.key});

  @override
  State<InteractiveShowcasePage> createState() => _InteractiveShowcasePageState();
}

class _InteractiveShowcasePageState extends State<InteractiveShowcasePage> {
  bool _interactiveEnabled = true;
  bool _interactiveColumns = true;
  bool _enableSplash = true;
  bool _roundedBorders = false;
  bool _foregroundOverlay = false;
  int _stateDurationMs = 200;
  int _splashDurationMs = 400;
  int? _selectedRow;

  final ScrollController _tableVerticalController = ScrollController();
  final ScrollController _tableHorizontalController = ScrollController();
  final TreeViewController _treeController = TreeViewController();
  final ScrollController _treeVerticalController = ScrollController();
  TreeViewNode<String>? _selectedTreeNode;

  final List<TreeViewNode<String>> _treeNodes = <TreeViewNode<String>>[
    TreeViewNode<String>(
      'packages/two_dimensional_scrollables',
      expanded: true,
      children: <TreeViewNode<String>>[
        TreeViewNode<String>(
          'lib/src/common',
          expanded: true,
          children: <TreeViewNode<String>>[
            TreeViewNode<String>('span.dart (WidgetStateColor, splashColor, animationStyle)'),
            TreeViewNode<String>('span_state.dart (hover, press, ripple animations)'),
          ],
        ),
        TreeViewNode<String>(
          'lib/src/table_view',
          expanded: true,
          children: <TreeViewNode<String>>[
            TreeViewNode<String>('table.dart (RenderTableViewport)'),
            TreeViewNode<String>('table_span.dart (TableSpanDecoration & TableSpanBorder)'),
          ],
        ),
        TreeViewNode<String>(
          'lib/src/tree_view',
          expanded: true,
          children: <TreeViewNode<String>>[
            TreeViewNode<String>('render_tree.dart (RenderTreeViewport)'),
            TreeViewNode<String>('tree_span.dart (TreeRowDecoration & TreeRowBorder)'),
          ],
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _tableVerticalController.dispose();
    _tableHorizontalController.dispose();
    _treeVerticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Interactive Decorations Showcase'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.table_chart), text: 'TableView'),
              Tab(icon: Icon(Icons.account_tree), text: 'TreeView'),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            _buildControlPanel(context),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  Builder(builder: (BuildContext context) => _buildTableShowcase()),
                  Builder(builder: (BuildContext context) => _buildTreeShowcase()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Wrap(
          spacing: 16.0,
          runSpacing: 8.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            FilterChip(
              label: const Text('Interactive Decorations'),
              selected: _interactiveEnabled,
              onSelected: (bool value) => setState(() => _interactiveEnabled = value),
            ),
            FilterChip(
              label: const Text('Interactive Columns'),
              selected: _interactiveColumns,
              onSelected: _interactiveEnabled
                  ? (bool value) => setState(() => _interactiveColumns = value)
                  : null,
            ),
            FilterChip(
              label: const Text('Tap Splash (Ripple)'),
              selected: _enableSplash,
              onSelected: _interactiveEnabled
                  ? (bool value) => setState(() => _enableSplash = value)
                  : null,
            ),
            FilterChip(
              label: const Text('Rounded BorderRadius'),
              selected: _roundedBorders,
              onSelected: (bool value) => setState(() => _roundedBorders = value),
            ),
            FilterChip(
              label: const Text('Foreground Badge Border'),
              selected: _foregroundOverlay,
              onSelected: _interactiveEnabled
                  ? (bool value) => setState(() => _foregroundOverlay = value)
                  : null,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Hover anim: ${_stateDurationMs}ms'),
                Slider(
                  value: _stateDurationMs.toDouble(),
                  max: 600,
                  divisions: 6,
                  onChanged: _interactiveEnabled
                      ? (double value) => setState(() => _stateDurationMs = value.round())
                      : null,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Splash: ${_splashDurationMs}ms'),
                Slider(
                  value: _splashDurationMs.toDouble(),
                  min: 100,
                  max: 1000,
                  divisions: 9,
                  onChanged: _interactiveEnabled && _enableSplash
                      ? (double value) => setState(() => _splashDurationMs = value.round())
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableShowcase() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
        child: TableView.builder(
          verticalDetails: ScrollableDetails.vertical(controller: _tableVerticalController),
          horizontalDetails: ScrollableDetails.horizontal(controller: _tableHorizontalController),
          pinnedRowCount: 1,
          pinnedColumnCount: 1,
          rowCount: 25,
          columnCount: 8,
          columnBuilder: _buildColumnSpan,
          rowBuilder: _buildRowSpan,
          cellBuilder: _buildCell,
        ),
      ),
    );
  }

  TableSpan _buildColumnSpan(int index) {
    final isPinned = index == 0;
    if (!_interactiveEnabled || !_interactiveColumns || isPinned) {
      return TableSpan(
        extent: FixedTableSpanExtent(isPinned ? 140.0 : 160.0),
        backgroundDecoration: isPinned ? TableSpanDecoration(color: Colors.indigo.shade50) : null,
        foregroundDecoration: TableSpanDecoration(
          border: TableSpanBorder(
            trailing: BorderSide(
              color: isPinned ? Colors.indigo.shade300 : Colors.grey.shade300,
              width: isPinned ? 2.0 : 1.0,
            ),
          ),
        ),
      );
    }

    return TableSpan(
      extent: const FixedTableSpanExtent(160.0),
      backgroundDecoration: TableSpanDecoration(
        color: WidgetStateColor.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) {
            return Colors.teal.withValues(alpha: 0.08);
          }
          return Colors.transparent;
        }),
        animationStyle: AnimationStyle(
          duration: Duration(milliseconds: _stateDurationMs),
          curve: Curves.easeOut,
        ),
      ),
      foregroundDecoration: TableSpanDecoration(
        border: TableSpanBorder(
          trailing: BorderSide(
            color: WidgetStateColor.resolveWith((Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.teal.shade400;
              }
              return Colors.grey.shade300;
            }),
          ),
        ),
        animationStyle: AnimationStyle(
          duration: Duration(milliseconds: _stateDurationMs),
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  TableSpan _buildRowSpan(int index) {
    if (index == 0) {
      return TableSpan(
        extent: const FixedTableSpanExtent(48.0),
        backgroundDecoration: TableSpanDecoration(
          color: Colors.indigo.shade100,
          border: TableSpanBorder(trailing: BorderSide(color: Colors.indigo.shade400, width: 2.0)),
        ),
      );
    }

    final isSelected = _selectedRow == index;
    final Color baseColor = isSelected
        ? Colors.indigo.shade100
        : (index.isEven ? Colors.grey.shade50 : Colors.white);
    final BorderRadius? borderRadius = _roundedBorders
        ? const BorderRadius.all(Radius.circular(12.0))
        : null;

    if (!_interactiveEnabled) {
      return TableSpan(
        extent: const FixedTableSpanExtent(56.0),
        padding: _roundedBorders
            ? const TableSpanPadding(leading: 2.0, trailing: 2.0)
            : const TableSpanPadding(),
        backgroundDecoration: TableSpanDecoration(color: baseColor, borderRadius: borderRadius),
        foregroundDecoration: TableSpanDecoration(
          border: TableSpanBorder(trailing: BorderSide(color: Colors.grey.shade300)),
        ),
      );
    }

    final backgroundColor = WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.indigo.shade200;
      }
      if (states.contains(WidgetState.hovered)) {
        return isSelected ? Colors.indigo.shade200 : Colors.indigo.shade50;
      }
      return baseColor;
    });

    final foregroundBorder = TableSpanBorder(
      leading: WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return BorderSide(color: Colors.indigo.shade700, width: 4.0);
        }
        if (states.contains(WidgetState.hovered)) {
          return BorderSide(color: Colors.indigo.shade400, width: 2.0);
        }
        return null;
      }),
      trailing: BorderSide(
        color: WidgetStateColor.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) {
            return Colors.indigo.shade300;
          }
          return Colors.grey.shade300;
        }),
      ),
    );

    return TableSpan(
      extent: const FixedTableSpanExtent(56.0),
      cursor: SystemMouseCursors.click,
      padding: _roundedBorders
          ? const TableSpanPadding(leading: 2.0, trailing: 2.0)
          : const TableSpanPadding(),
      recognizerFactories: <Type, GestureRecognizerFactory>{
        TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => TapGestureRecognizer(),
          (TapGestureRecognizer recognizer) {
            recognizer.onTap = () {
              setState(() {
                _selectedRow = _selectedRow == index ? null : index;
              });
            };
          },
        ),
      },
      backgroundDecoration: TableSpanDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        consumeSpanPadding: false,
        splashColor: _enableSplash ? Colors.indigo.withValues(alpha: 0.22) : null,
        animationStyle: AnimationStyle(
          duration: Duration(milliseconds: _stateDurationMs),
          curve: Curves.easeOutCubic,
        ),
        splashAnimationStyle: AnimationStyle(
          duration: Duration(milliseconds: _splashDurationMs),
          curve: Curves.decelerate,
        ),
      ),
      foregroundDecoration: _foregroundOverlay
          ? TableSpanDecoration(
              border: foregroundBorder,
              consumeSpanPadding: false,
              animationStyle: AnimationStyle(
                duration: Duration(milliseconds: _stateDurationMs),
                curve: Curves.easeInOut,
              ),
            )
          : TableSpanDecoration(
              border: TableSpanBorder(trailing: BorderSide(color: Colors.grey.shade300)),
            ),
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    if (vicinity.row == 0) {
      return TableViewCell(
        child: Center(
          child: Text(
            vicinity.column == 0 ? 'Pinned Row / Col' : 'Column ${vicinity.column}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    if (vicinity.column == 0) {
      return TableViewCell(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                Icon(
                  _selectedRow == vicinity.row ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 8),
                Text('Row ${vicinity.row}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
    }
    return TableViewCell(child: Center(child: Text('Cell (${vicinity.row}, ${vicinity.column})')));
  }

  Widget _buildTreeShowcase() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
        child: TreeView<String>(
          controller: _treeController,
          verticalDetails: ScrollableDetails.vertical(controller: _treeVerticalController),
          tree: _treeNodes,
          treeRowBuilder: (TreeViewNode<String> node) {
            final isSelected = _selectedTreeNode == node;
            final BorderRadius? borderRadius = _roundedBorders
                ? const BorderRadius.all(Radius.circular(10.0))
                : null;

            return TreeRow(
              extent: const FixedTreeRowExtent(48.0),
              cursor: SystemMouseCursors.click,
              recognizerFactories: <Type, GestureRecognizerFactory>{
                TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  () => TapGestureRecognizer(),
                  (TapGestureRecognizer recognizer) {
                    recognizer.onTap = () {
                      setState(() {
                        _selectedTreeNode = node;
                        if (node.children.isNotEmpty) {
                          _treeController.toggleNode(node);
                        }
                      });
                    };
                  },
                ),
              },
              backgroundDecoration: _interactiveEnabled
                  ? TreeRowDecoration(
                      color: WidgetStateColor.resolveWith((Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.indigo.shade200;
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return isSelected ? Colors.indigo.shade100 : Colors.indigo.shade50;
                        }
                        return isSelected ? Colors.indigo.shade100 : Colors.transparent;
                      }),
                      borderRadius: borderRadius,
                      splashColor: _enableSplash ? Colors.indigo.withValues(alpha: 0.20) : null,
                      animationStyle: AnimationStyle(
                        duration: Duration(milliseconds: _stateDurationMs),
                        curve: Curves.easeOut,
                      ),
                      splashAnimationStyle: AnimationStyle(
                        duration: Duration(milliseconds: _splashDurationMs),
                        curve: Curves.decelerate,
                      ),
                    )
                  : TreeRowDecoration(
                      color: isSelected ? Colors.indigo.shade100 : Colors.transparent,
                      borderRadius: borderRadius,
                    ),
              foregroundDecoration: _interactiveEnabled
                  ? TreeRowDecoration(
                      borderRadius: borderRadius,
                      border: _roundedBorders
                          ? TreeRowBorder.all(
                              WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return BorderSide(color: Colors.indigo.shade800, width: 2.5);
                                }
                                if (states.contains(WidgetState.hovered) || isSelected) {
                                  return BorderSide(color: Colors.indigo.shade400, width: 1.5);
                                }
                                return BorderSide(color: Colors.grey.shade300);
                              }),
                            )
                          : TreeRowBorder(
                              left: WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return BorderSide(color: Colors.indigo.shade800, width: 6.0);
                                }
                                if (states.contains(WidgetState.hovered) || isSelected) {
                                  return BorderSide(color: Colors.indigo.shade500, width: 4.0);
                                }
                                return null;
                              }),
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                      animationStyle: AnimationStyle(
                        duration: Duration(milliseconds: _stateDurationMs),
                        curve: Curves.easeInOut,
                      ),
                    )
                  : TreeRowDecoration(
                      borderRadius: borderRadius,
                      border: _roundedBorders
                          ? TreeRowBorder.all(BorderSide(color: Colors.grey.shade300))
                          : TreeRowBorder(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
            );
          },
        ),
      ),
    );
  }
}

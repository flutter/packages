// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'render_dynamic_grid.dart';
import 'wrap_layout.dart';

/// A scrollable, 2D array of widgets.
///
// TODO(all): Add more documentation & sample code
class DynamicGridView extends GridView {
  /// Creates a scrollable, 2D array of widgets with a custom
  /// [SliverGridDelegate].
  DynamicGridView({
    super.key,
    super.scrollDirection,
    super.reverse,
    required super.gridDelegate,
    // This creates a SliverChildListDelegate in the super class.
    super.children = const <Widget>[],
  });

  /// Creates a scrollable, 2D array of widgets that are created on demand.
  DynamicGridView.builder({
    super.key,
    super.scrollDirection,
    super.reverse,
    required super.gridDelegate,
    // This creates a SliverChildBuilderDelegate in the super class.
    required super.itemBuilder,
    super.itemCount,
  }) : super.builder();

  /// Creates a scrollable, 2D array of widgets with tiles where each tile can
  /// have its own size.
  ///
  /// Uses a [SliverGridDelegateWithWrapping] as the [gridDelegate].
  ///
  /// The following example shows how to use the DynamicGridView.wrap constructor.
  ///
  /// ```dart
  /// DynamicGridView.wrap(
  ///     mainAxisSpacing: 10,
  ///     crossAxisSpacing: 20,
  ///     children: [
  ///         Container(
  ///           height: 100,
  ///           width: 200,
  ///           color: Colors.amberAccent[100],
  ///           child: const Center(child: Text('Item 1')
  ///          ),
  ///       ),
  ///       Container(
  ///           height: 50,
  ///           width: 70,
  ///           color: Colors.blue[100],
  ///           child: const Center(child: Text('Item 2'),
  ///          ),
  ///       ),
  ///       Container(
  ///           height: 82,
  ///           width: 300,
  ///           color: Colors.pink[100],
  ///           child: const Center(child: Text('Item 3'),
  ///         ),
  ///       ),
  ///       Container(
  ///           color: Colors.green[100],
  ///           child: const Center(child: Text('Item 3'),
  ///       ),
  ///     ),
  ///   ],
  /// ),
  /// ```
  ///
  /// See also:
  ///
  ///  * [SliverGridDelegateWithWrapping] to see a more detailed explanation of
  ///    how the wrapping works.
  DynamicGridView.wrap({
    super.key,
    super.scrollDirection,
    super.reverse,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childCrossAxisExtent = double.infinity,
    double childMainAxisExtent = double.infinity,
    super.children = const <Widget>[],
  }) : super(
          gridDelegate: SliverGridDelegateWithWrapping(
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childCrossAxisExtent: childCrossAxisExtent,
            childMainAxisExtent: childMainAxisExtent,
          ),
        );

  // TODO(DavBot09): DynamicGridView.stagger?

  @override
  Widget buildChildLayout(BuildContext context) {
    return DynamicSliverGrid(
      delegate: childrenDelegate,
      gridDelegate: gridDelegate,
    );
  }
}

/// A sliver that places multiple box children in a two dimensional arrangement.
class DynamicSliverGrid extends SliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement.
  const DynamicSliverGrid({
    super.key,
    required super.delegate,
    required this.gridDelegate,
  });

  /// The delegate that manages the size and position of the children.
  final SliverGridDelegate gridDelegate;

  @override
  RenderDynamicSliverGrid createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return RenderDynamicSliverGrid(
        childManager: element, gridDelegate: gridDelegate);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDynamicSliverGrid renderObject,
  ) {
    renderObject.gridDelegate = gridDelegate;
  }
}

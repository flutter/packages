// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'render_dynamic_grid.dart';

class DynamicGridView extends GridView {
  DynamicGridView({
    super.key, 
    required super.gridDelegate,
    super.children = const <Widget>[],
  }) : assert(gridDelegate != null);

  @override
  DynamicGridView.builder({
    super.key,
    required super.gridDelegate,
    required super.itemBuilder,
  });

  // TODO(snat-s): DynamicGridView.wrap?

  // TODO(DavBot09): DynamicGridView.stagger?

  @override
  Widget buildChildLayout(BuildContext context) {
    return DynamicSliverGrid(
      delegate: childrenDelegate,
      gridDelegate: gridDelegate,
    );
  }
}

class DynamicSliverGrid extends SliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement.
  const DynamicSliverGrid({
    super.key,
    required super.delegate,
    required this.gridDelegate,
  });

  /// The delegate that controls the size and position of the children.
  final SliverGridDelegate gridDelegate;

  @override
  RenderDynamicSliverGrid createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element = context as SliverMultiBoxAdaptorElement;
    return RenderDynamicSliverGrid(childManager: element, gridDelegate: gridDelegate);
  }

  @override
  void updateRenderObject(BuildContext context, RenderDynamicSliverGrid renderObject) {
    renderObject.gridDelegate = gridDelegate;
  }
}
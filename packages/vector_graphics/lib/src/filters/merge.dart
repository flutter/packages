// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';

/// Composites merge nodes in document order, with the last node on top.
FilterImage merge(FilterContext context, VectorFilter primitive) {
  final inputs = <FilterImage>[];
  Rect? region;
  for (final VectorFilter node in primitive.children) {
    if (node.name != 'feMergeNode') {
      throw FormatException('Invalid feMerge child: ${node.name}');
    }
    final FilterImage input = context.input(node.attributes['in']);
    inputs.add(input);
    region = region?.expandToInclude(input.region) ?? input.region;
  }
  return context.recordColor(primitive, context.subregion(primitive, region ?? context.region), (
    Canvas canvas,
    bool linear,
  ) {
    for (final input in inputs) {
      context.drawInput(canvas, input, linear);
    }
  });
}

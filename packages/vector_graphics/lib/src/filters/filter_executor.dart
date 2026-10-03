// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'color_matrix.dart';
import 'filter_context.dart';
import 'offset.dart';

/// Evaluates the contributing graph in document order, preserving named results.
FilterImage executeFilter(FilterContext context) {
  if (context.region.isEmpty || context.definition.children.isEmpty) {
    return context.record(Rect.zero, (Canvas canvas) {});
  }
  for (final VectorFilter primitive in context.definition.activePrimitives) {
    context.publish(primitive, executePrimitive(context, primitive));
  }
  return context.previous;
}

/// Dispatches one primitive. Each supported operation has a separate implementation.
FilterImage executePrimitive(FilterContext context, VectorFilter primitive) {
  switch (primitive.name) {
    case 'feOffset':
      return offset(context, primitive);
    case 'feColorMatrix':
      return colorMatrix(context, primitive);
    default:
      throw UnsupportedError('SVG filter primitive ${primitive.name} is not implemented');
  }
}

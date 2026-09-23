// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';

/// Evaluates a definition in document order, preserving named intermediate results.
FilterImage executeFilter(FilterContext context) {
  if (context.region.isEmpty || context.definition.children.isEmpty) {
    return context.record(Rect.zero, (Canvas canvas) {});
  }
  for (final VectorFilter primitive in context.definition.children) {
    context.publish(primitive, executePrimitive(context, primitive));
  }
  return context.previous;
}

/// Dispatches one primitive. Each supported operation has a separate implementation.
FilterImage executePrimitive(FilterContext context, VectorFilter primitive) {
  throw UnsupportedError('SVG filter primitive ${primitive.name} is not implemented');
}

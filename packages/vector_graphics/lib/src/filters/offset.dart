// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';

/// Offsets an input in primitive coordinates, then clips the output subregion.
FilterImage offset(FilterContext context, VectorFilter primitive) {
  final FilterImage input = context.input(primitive.attributes['in']);
  final double dx = context.primitiveNumber(primitive.attributes['dx'] ?? '0', horizontal: true);
  final double dy = context.primitiveNumber(primitive.attributes['dy'] ?? '0', horizontal: false);
  return context.record(context.subregion(primitive, input.region), (Canvas canvas) {
    canvas.translate(dx, dy);
    context.draw(canvas, input);
  });
}

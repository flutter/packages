// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';

/// Paints a constant color throughout the primitive subregion, without an input.
FilterImage flood(FilterContext context, VectorFilter primitive) {
  final Rect bounds = context.subregion(primitive, context.region);
  final Color color = floodColor(primitive);
  return context.record(bounds, (Canvas canvas) {
    canvas.drawRect(bounds, Paint()..color = color);
  });
}

/// Resolves the compiler-normalized flood color and combined opacity.
Color floodColor(VectorFilter primitive) {
  final color = Color(int.parse(primitive.attributes['flood-color-argb'] ?? '4278190080'));
  final String rawOpacity = primitive.attributes['flood-opacity'] ?? '1';
  final double opacity =
      (rawOpacity.endsWith('%')
              ? FilterContext.number(rawOpacity.substring(0, rawOpacity.length - 1)) / 100
              : FilterContext.number(rawOpacity))
          .clamp(0.0, 1.0);
  return color.withValues(alpha: color.a * opacity);
}

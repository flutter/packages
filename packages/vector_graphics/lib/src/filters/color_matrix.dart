// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filter_context.dart';

const List<double> _identity = <double>[1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];

/// Resolves the SVG matrix in normalized (0..1) channel coordinates.
List<double> colorMatrixValues(VectorFilter primitive) {
  final String type = primitive.attributes['type'] ?? 'matrix';
  if (type == 'luminanceToAlpha') {
    return <double>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, .2126, .7152, .0722, 0, 0];
  }
  final String? raw = primitive.attributes['values'];
  final List<double>? values = raw == null ? null : FilterContext.numbers(raw);
  if (type == 'matrix') {
    return values == null || values.length != 20 ? _identity : values;
  }
  if (type != 'saturate' && type != 'hueRotate') {
    throw FormatException('Invalid feColorMatrix type: $type');
  }
  if (values != null && values.length != 1) {
    return _identity;
  }
  if (type == 'saturate') {
    final double s = values?.single ?? 1;
    return <double>[
      .213 + .787 * s,
      .715 - .715 * s,
      .072 - .072 * s,
      0,
      0,
      .213 - .213 * s,
      .715 + .285 * s,
      .072 - .072 * s,
      0,
      0,
      .213 - .213 * s,
      .715 - .715 * s,
      .072 + .928 * s,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }
  final double angle = ((values?.single ?? 0) % 360) * math.pi / 180;
  final double c = math.cos(angle);
  final double s = math.sin(angle);
  return <double>[
    .213 + .787 * c - .213 * s,
    .715 - .715 * c - .715 * s,
    .072 - .072 * c + .928 * s,
    0,
    0,
    .213 - .213 * c + .143 * s,
    .715 + .285 * c + .140 * s,
    .072 - .072 * c - .283 * s,
    0,
    0,
    .213 - .213 * c - .787 * s,
    .715 - .715 * c + .715 * s,
    .072 + .928 * c + .072 * s,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];
}

/// Applies a matrix to straight color channels, including transparent pixels.
FilterImage colorMatrix(FilterContext context, VectorFilter primitive) {
  final FilterImage input = context.input(primitive.attributes['in']);
  final List<double> matrix = colorMatrixValues(primitive);
  final Rect bounds = context.subregion(primitive, input.region);
  final filter = ColorFilter.matrix(<double>[
    for (var i = 0; i < 20; i++) matrix[i] * (i % 5 == 4 ? 255 : 1),
  ]);
  return context.recordColor(primitive, bounds, (Canvas canvas, bool linear) {
    canvas.saveLayer(bounds, Paint()..colorFilter = filter);
    context.drawInput(canvas, input, linear);
    canvas.restore();
  });
}
